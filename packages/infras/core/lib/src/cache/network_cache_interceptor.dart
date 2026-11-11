/// 挂在 Dio 上的缓存拦截器：五策略 + 请求级 opt-in。
library;

import 'dart:convert';

import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:dio/dio.dart';

import 'cache_entry.dart';
import 'cache_key.dart';
import 'cache_policy.dart';
import 'cache_store.dart';

/// `onlyCache` 策略下缓存未命中。
///
/// 实现 [FailureCarryingError]，因此能原样穿过 Dio 变成 `Failure(code:
/// 'CACHE_MISS')`，不需要让 `package:core/network.dart` 认识缓存。
final class CacheMiss implements FailureCarryingError {
  /// 用未命中的缓存键创建。
  const CacheMiss(this.key);

  /// 未命中的键。
  final String key;

  @override
  Failure get failure => Failure(
        code: 'CACHE_MISS',
        message: '离线模式下没有可用缓存',
        type: FailureType.network,
        cause: this,
      );

  @override
  String toString() => 'CacheMiss($key)';
}

/// HTTP 缓存拦截器。
///
/// 三条设计原则（都刻意收紧过）：
///
/// 1. **默认不缓存**。没在 [CachePolicyTable] 里配规则、也没在请求 `extra`
///    里显式指定策略的请求，一律 [CachePolicy.onlyNetwork]。理由是
///    "带签名的请求缓存有重放语义风险"，这里再收紧一层：
///    连"默认 5 分钟"都不给。
/// 2. **没有 scope 就不缓存**。键里没有用户身份 → 换账号串号。
///    拿不到 scope 时**静默跳过缓存**而不是抛错：缓存是优化，不该让请求失败。
/// 3. **只缓存 JSON**。`responseType` 不是 json、或响应体无法 `jsonEncode`
///    的，直接跳过——缓存二进制流既没意义又容易爆内存。
///
/// 用法：
/// ```dart
/// final dio = buildDio(
///   baseUrl: base,
///   interceptors: <Interceptor>[
///     NetworkCacheInterceptor(store: MemoryLruCacheStore()),
///   ],
/// );
/// // 单请求指定策略与 scope：
/// await client.get<Map<String, Object?>>(
///   '/home/floors',
///   options: Options(extra: <String, Object?>{
///     NetworkCacheInterceptor.policyKey: CachePolicy.cacheThenNetwork,
///     NetworkCacheInterceptor.scopeKey: userId,
///   }),
/// );
/// ```
final class NetworkCacheInterceptor extends Interceptor {
  /// 创建拦截器。
  NetworkCacheInterceptor({
    required this.store,
    this.policyTable,
    this.cacheableMethods = const <String>{'GET'},
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// 缓存存储（L1 内存 / L2 磁盘都由调用方注入）。
  final HttpCacheStore store;

  /// 路径规则表。为 `null` 时只认请求 `extra` 里的显式策略。
  final CachePolicyTable? policyTable;

  /// 允许缓存的方法。
  ///
  /// 默认只有 `GET`。企划星不少接口是 `POST + JSON body`，如果确认某个 POST
  /// 接口是幂等的，显式传入 `{'GET', 'POST'}` 再配合策略表使用。
  final Set<String> cacheableMethods;

  final DateTime Function() _clock;

  /// 请求级策略：`extra[policyKey] = CachePolicy.xxx`。
  static const String policyKey = 'cachePolicy';

  /// 用户 scope：`extra[scopeKey] = userId`。未登录传 [anonymousScope]。
  static const String scopeKey = 'cacheScope';

  /// 请求级 TTL 覆盖：`extra[ttlKey] = Duration(...)`。
  static const String ttlKey = 'cacheTtl';

  /// `cacheThenNetwork` 命中时，旧数据放在这里供首屏消费。
  static const String staleResponseKey = 'staleResponse';

  /// 响应是否来自缓存：`response.requestOptions.extra[cacheHitKey] == true`。
  static const String cacheHitKey = 'cacheHit';

  /// 响应是否为"过期兜底"（`networkFirst` 网络失败后用的旧数据）。
  static const String cacheStaleKey = 'cacheStale';

  static const String _keyKey = 'cacheKey';
  static const String _writeKey = 'cacheWrite';
  static const String _fallbackKey = 'cacheFallback';
  static const Duration _defaultTtl = Duration(minutes: 5);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final policy = _resolvePolicy(options);

    // onlyNetwork：不读也不写，直接放行。
    if (!policy.readsCache && !policy.writesCache) {
      handler.next(options);
      return;
    }
    if (!cacheableMethods.contains(options.method.toUpperCase())) {
      handler.next(options);
      return;
    }
    if (options.responseType != ResponseType.json) {
      handler.next(options);
      return;
    }

    // fail closed：拿不到用户身份就不缓存。缓存是优化，不该让请求失败。
    final scope = options.extra[scopeKey];
    if (scope is! String || scope.trim().isEmpty) {
      handler.next(options);
      return;
    }

    final rule = policyTable?.lookup(options.path);
    final ttl = switch (options.extra[ttlKey]) {
      final Duration explicit => explicit,
      _ => rule?.ttl ?? _defaultTtl,
    };
    final key = buildCacheKey(
      scope: scope,
      method: options.method,
      path: options.path,
      query: options.queryParameters,
      body: options.data,
    );
    options.extra[_keyKey] = key;
    options.extra[ttlKey] = ttl;

    switch (policy) {
      case CachePolicy.onlyNetwork:
        // 上面已提前返回，这里仅为穷举。
        handler.next(options);
      case CachePolicy.onlyCache:
        final entry = await store.read(key);
        if (entry == null) {
          handler.reject(_cacheMiss(options, key));
          return;
        }
        options.extra[cacheHitKey] = true;
        handler.resolve(_toResponse(options, entry));
      case CachePolicy.cacheFirst:
        final entry = await store.read(key);
        if (entry != null && !entry.isExpiredAt(_clock())) {
          options.extra[cacheHitKey] = true;
          handler.resolve(_toResponse(options, entry));
          return;
        }
        options.extra[_writeKey] = true;
        handler.next(options);
      case CachePolicy.networkFirst:
        options.extra[_writeKey] = true;
        // 提前取兜底数据：放到 onError 再读会让"请求耗时"包含一次存储 IO，
        // 也避免请求期间缓存被并发写覆盖导致行为不可预期。
        final entry = await store.read(key);
        if (entry != null) {
          options.extra[_fallbackKey] = entry;
        }
        handler.next(options);
      case CachePolicy.cacheThenNetwork:
        final entry = await store.read(key);
        if (entry != null) {
          options.extra[staleResponseKey] = entry;
        }
        options.extra[_writeKey] = true;
        handler.next(options);
    }
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final options = response.requestOptions;
    if (options.extra[_writeKey] != true) {
      handler.next(response);
      return;
    }
    final key = options.extra[_keyKey];
    if (key is! String) {
      handler.next(response);
      return;
    }

    // 一律 jsonEncode（含 String 响应）：保证"存进去什么类型，取出来还是什么
    // 类型"。若对 String 走特例直接存原文，回放时会被 jsonDecode 成对象，
    // 类型就变了。
    String body;
    try {
      body = jsonEncode(response.data);
    } on JsonUnsupportedObjectError {
      // 不可序列化（含二进制）→ 不缓存，不是错误。
      handler.next(response);
      return;
    }

    final ttl = options.extra[ttlKey];
    await store.write(
      key,
      HttpCacheEntry(
        body: body,
        statusCode: response.statusCode ?? 200,
        headers: <String, String>{
          for (final entry in response.headers.map.entries)
            if (entry.value.isNotEmpty) entry.key: entry.value.first,
        },
        storedAt: _clock(),
        ttl: ttl is Duration ? ttl : _defaultTtl,
      ),
    );
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final entry = options.extra[_fallbackKey];
    if (entry is! HttpCacheEntry) {
      handler.next(err);
      return;
    }
    // networkFirst 的兜底：网络失败时用旧数据顶上，并标记 stale 让 UI 可提示。
    options.extra[cacheHitKey] = true;
    options.extra[cacheStaleKey] = true;
    handler.resolve(_toResponse(options, entry));
  }

  CachePolicy _resolvePolicy(RequestOptions options) {
    final explicit = options.extra[policyKey];
    if (explicit is CachePolicy) {
      return explicit;
    }
    return policyTable?.lookup(options.path)?.policy ?? CachePolicy.onlyNetwork;
  }

  Response<dynamic> _toResponse(RequestOptions options, HttpCacheEntry entry) {
    return Response<dynamic>(
      requestOptions: options,
      statusCode: entry.statusCode,
      statusMessage: 'OK (from cache)',
      headers: Headers.fromMap(<String, List<String>>{
        for (final item in entry.headers.entries) item.key: <String>[item.value],
      }),
      data: entry.decodedBody,
      extra: options.extra,
    );
  }

  DioException _cacheMiss(RequestOptions options, String key) => DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
        error: CacheMiss(key),
        message: '缓存未命中：$key',
      );
}
