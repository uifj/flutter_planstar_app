import 'dart:typed_data';

import 'package:core/cache.dart';
import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// 计数的假适配器：既能返回响应，也能统计网络调用次数（判断"是否真的没走网络"）。
class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this.responder);

  final ResponseBody Function(RequestOptions options) responder;
  int calls = 0;
  final List<RequestOptions> seen = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    seen.add(options);
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(String body, {int status = 200}) => ResponseBody.fromString(
      body,
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json; charset=utf-8'],
      },
    );

Dio _dioWith(_CountingAdapter adapter, NetworkCacheInterceptor cache) {
  final dio = buildDio(baseUrl: 'https://api.planstar.test');
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(cache);
  return dio;
}

void main() {
  group('buildCacheKey 防串号（30-07 必须修的点）', () {
    test('scope 为空或全空白直接抛', () {
      expect(
        () => buildCacheKey(scope: '', method: 'GET', path: '/a'),
        throwsArgumentError,
      );
      expect(
        () => buildCacheKey(scope: '   ', method: 'GET', path: '/a'),
        throwsArgumentError,
      );
    });

    test('不同用户 → 不同键（核心断言）', () {
      final a = buildCacheKey(scope: 'user-a', method: 'GET', path: '/order/list');
      final b = buildCacheKey(scope: 'user-b', method: 'GET', path: '/order/list');
      expect(a, isNot(equals(b)));
    });

    test('Map 键顺序不同 → 同一个键（稳定序列化）', () {
      final a = buildCacheKey(
        scope: 'u',
        method: 'GET',
        path: '/a',
        query: <String, Object?>{'x': 1, 'y': 2},
      );
      final b = buildCacheKey(
        scope: 'u',
        method: 'GET',
        path: '/a',
        query: <String, Object?>{'y': 2, 'x': 1},
      );
      expect(a, b);
    });

    test('同 path 不同 body → 不同键（防撞键）', () {
      final a = buildCacheKey(
        scope: 'u',
        method: 'POST',
        path: '/a',
        body: <String, Object?>{'id': 1},
      );
      final b = buildCacheKey(
        scope: 'u',
        method: 'POST',
        path: '/a',
        body: <String, Object?>{'id': 2},
      );
      expect(a, isNot(equals(b)));
    });

    test('List 顺序不同 → 不同键（保序）', () {
      final a = buildCacheKey(
        scope: 'u',
        method: 'GET',
        path: '/a',
        query: <String, Object?>{'ids': <int>[1, 2]},
      );
      final b = buildCacheKey(
        scope: 'u',
        method: 'GET',
        path: '/a',
        query: <String, Object?>{'ids': <int>[2, 1]},
      );
      expect(a, isNot(equals(b)));
    });

    test('嵌套 Map 也按键排序', () {
      final a = buildCacheKey(
        scope: 'u',
        method: 'POST',
        path: '/a',
        body: <String, Object?>{
          'outer': <String, Object?>{'b': 2, 'a': 1},
        },
      );
      final b = buildCacheKey(
        scope: 'u',
        method: 'POST',
        path: '/a',
        body: <String, Object?>{
          'outer': <String, Object?>{'a': 1, 'b': 2},
        },
      );
      expect(a, b);
    });
  });

  group('MemoryLruCacheStore', () {
    HttpCacheEntry entry(String body) => HttpCacheEntry(
          body: body,
          statusCode: 200,
          headers: const <String, String>{},
          storedAt: DateTime.utc(2026),
          ttl: const Duration(minutes: 5),
        );

    test('超容量淘汰最久未使用', () async {
      final store = MemoryLruCacheStore(capacity: 2);
      await store.write('a', entry('1'));
      await store.write('b', entry('2'));
      await store.write('c', entry('3'));
      expect(store.debugKeys, <String>['b', 'c']);
    });

    test('read 命中后移到队尾（避免被优先淘汰）', () async {
      final store = MemoryLruCacheStore(capacity: 2);
      await store.write('a', entry('1'));
      await store.write('b', entry('2'));
      await store.read('a'); // a 变成最近使用
      await store.write('c', entry('3')); // 该淘汰 b
      expect(store.debugKeys, <String>['a', 'c']);
    });

    test('同键覆盖不增加条目数', () async {
      final store = MemoryLruCacheStore(capacity: 2);
      await store.write('a', entry('1'));
      await store.write('a', entry('2'));
      expect(store.length, 1);
      final hit = await store.read('a');
      expect(hit!.body, '2', reason: '同键覆盖应取后写的值');
    });
  });

  group('evictScope 按用户清理', () {
    test('只删该 scope，别的用户保留', () async {
      final store = MemoryLruCacheStore();
      await store.write('u1|GET|/a|null|null', _entry());
      await store.write('u1|GET|/b|null|null', _entry());
      await store.write('u2|GET|/a|null|null', _entry());
      final removed = await evictScope(store, 'u1');
      expect(removed, 2);
      expect(await store.keys(), <String>['u2|GET|/a|null|null']);
    });
  });

  group('NetworkCacheInterceptor', () {
    test('未配规则且未指定策略 → 不缓存（默认 fail closed）', () async {
      final adapter = _CountingAdapter((_) => _json('{"v":1}'));
      final dio = _dioWith(adapter, NetworkCacheInterceptor(store: MemoryLruCacheStore()));
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());
      final opts = Options(extra: <String, Object?>{
        NetworkCacheInterceptor.scopeKey: 'u1',
      });

      await client.get<Object?>('/unknown/path', options: opts);
      await client.get<Object?>('/unknown/path', options: opts);
      expect(adapter.calls, 2, reason: '两次都必须走网络');
    });

    test('没有 scope → 不缓存（缓存是优化，不该让请求失败）', () async {
      final adapter = _CountingAdapter((_) => _json('{"v":1}'));
      final dio = _dioWith(adapter, NetworkCacheInterceptor(store: MemoryLruCacheStore()));
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());
      final opts = Options(extra: <String, Object?>{
        NetworkCacheInterceptor.policyKey: CachePolicy.cacheFirst,
      });

      final first = await client.get<Object?>('/home/floor', options: opts);
      expect(first.isSuccess, isTrue);
      await client.get<Object?>('/home/floor', options: opts);
      expect(adapter.calls, 2);
    });

    test('cacheFirst 未过期 → 第二次不发网络', () async {
      final adapter = _CountingAdapter((_) => _json('{"v":1}'));
      final store = MemoryLruCacheStore();
      final now = DateTime.utc(2026, 1, 1);
      final dio = _dioWith(
        adapter,
        NetworkCacheInterceptor(store: store, clock: () => now),
      );
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());
      final opts = Options(extra: <String, Object?>{
        NetworkCacheInterceptor.policyKey: CachePolicy.cacheFirst,
        NetworkCacheInterceptor.scopeKey: 'u1',
        NetworkCacheInterceptor.ttlKey: const Duration(minutes: 5),
      });

      final first = await client.get<Object?>('/city/list', options: opts);
      final second = await client.get<Object?>('/city/list', options: opts);

      expect(adapter.calls, 1, reason: '第二次必须命中缓存');
      expect(second.isSuccess, isTrue);
      expect(second.requireData, first.requireData);
      expect(
        second.requireData,
        isA<Map<Object?, Object?>>(),
        reason: '回放的数据类型必须与首次一致',
      );
    });

    test('cacheFirst 已过期 → 重新发网络', () async {
      final adapter = _CountingAdapter((_) => _json('{"v":1}'));
      var now = DateTime.utc(2026, 1, 1);
      final dio = _dioWith(
        adapter,
        NetworkCacheInterceptor(
          store: MemoryLruCacheStore(),
          clock: () => now,
        ),
      );
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());
      final opts = Options(extra: <String, Object?>{
        NetworkCacheInterceptor.policyKey: CachePolicy.cacheFirst,
        NetworkCacheInterceptor.scopeKey: 'u1',
        NetworkCacheInterceptor.ttlKey: const Duration(minutes: 5),
      });

      await client.get<Object?>('/city/list', options: opts);
      now = now.add(const Duration(minutes: 6));
      await client.get<Object?>('/city/list', options: opts);
      expect(adapter.calls, 2);
    });

    test('networkFirst 网络失败 → 用过期缓存兜底并标记 stale', () async {
      var shouldFail = false;
      final adapter = _CountingAdapter((options) {
        if (shouldFail) {
          throw DioException.connectionError(
            requestOptions: options,
            reason: 'offline',
          );
        }
        return _json('{"v":1}');
      });
      var now = DateTime.utc(2026, 1, 1);
      final dio = _dioWith(
        adapter,
        NetworkCacheInterceptor(
          store: MemoryLruCacheStore(),
          clock: () => now,
        ),
      );
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());
      final opts = Options(extra: <String, Object?>{
        NetworkCacheInterceptor.policyKey: CachePolicy.networkFirst,
        NetworkCacheInterceptor.scopeKey: 'u1',
        NetworkCacheInterceptor.ttlKey: const Duration(minutes: 5),
      });

      await client.get<Object?>('/show/detail', options: opts);
      // 让它过期，再断网：仍应拿到旧数据。
      now = now.add(const Duration(hours: 1));
      shouldFail = true;
      final fallback = await client.get<Object?>('/show/detail', options: opts);

      expect(fallback.isSuccess, isTrue, reason: '弱网必须兜底，不能失败');
      expect(fallback.requireData, isA<Map<Object?, Object?>>());
      expect(
        fallback.requireData,
        <Object?, Object?>{'v': 1},
      );
    });

    test('networkFirst 无缓存时断网 → 正常失败', () async {
      final adapter = _CountingAdapter((options) {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        );
      });
      final dio = _dioWith(
        adapter,
        NetworkCacheInterceptor(store: MemoryLruCacheStore()),
      );
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());
      final result = await client.get<Object?>(
        '/show/detail',
        options: Options(extra: <String, Object?>{
          NetworkCacheInterceptor.policyKey: CachePolicy.networkFirst,
          NetworkCacheInterceptor.scopeKey: 'u1',
        }),
      );
      expect(result.isFailure, isTrue);
      expect(result.failure!.type, FailureType.network);
    });

    test('cacheThenNetwork → stale 进 extra，同时仍走网络', () async {
      var payload = 1;
      final adapter = _CountingAdapter((_) => _json('{"v":$payload}'));
      final dio = _dioWith(
        adapter,
        NetworkCacheInterceptor(store: MemoryLruCacheStore()),
      );
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());
      Options opts() => Options(extra: <String, Object?>{
            NetworkCacheInterceptor.policyKey: CachePolicy.cacheThenNetwork,
            NetworkCacheInterceptor.scopeKey: 'u1',
          });

      await client.get<Object?>('/home/floor', options: opts());
      payload = 2;
      final second = await client.get<Object?>('/home/floor', options: opts());

      expect(adapter.calls, 2, reason: 'SWR 必须同时刷新');
      expect(second.requireData, <Object?, Object?>{'v': 2});

      // stale 数据挂在第二次请求的 extra 上（适配器捕获了 RequestOptions）。
      final stale =
          adapter.seen.last.extra[NetworkCacheInterceptor.staleResponseKey];
      expect(stale, isA<HttpCacheEntry>(), reason: 'SWR 必须给出旧数据供首屏用');
      expect((stale! as HttpCacheEntry).decodedBody, <Object?, Object?>{'v': 1});
    });

    test('onlyNetwork → 不写缓存', () async {
      final adapter = _CountingAdapter((_) => _json('{"v":1}'));
      final store = MemoryLruCacheStore();
      final dio = _dioWith(adapter, NetworkCacheInterceptor(store: store));
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());

      await client.get<Object?>(
        '/seat/map',
        options: Options(extra: <String, Object?>{
          NetworkCacheInterceptor.policyKey: CachePolicy.onlyNetwork,
          NetworkCacheInterceptor.scopeKey: 'u1',
        }),
      );
      expect(store.length, 0, reason: '支付/座位图链路不该留缓存');
    });

    test('onlyCache 未命中 → Failure(code: CACHE_MISS)，且不打网络', () async {
      final adapter = _CountingAdapter((_) => _json('{"v":1}'));
      final dio = _dioWith(
        adapter,
        NetworkCacheInterceptor(store: MemoryLruCacheStore()),
      );
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());
      final result = await client.get<Object?>(
        '/city/list',
        options: Options(extra: <String, Object?>{
          NetworkCacheInterceptor.policyKey: CachePolicy.onlyCache,
          NetworkCacheInterceptor.scopeKey: 'u1',
        }),
      );
      expect(result.isFailure, isTrue);
      expect(result.failure!.code, 'CACHE_MISS');
      expect(adapter.calls, 0);
    });

    test('POST 默认不缓存，显式放开后可缓存', () async {
      final adapter = _CountingAdapter((_) => _json('{"v":1}'));
      final store = MemoryLruCacheStore();
      final dio = _dioWith(adapter, NetworkCacheInterceptor(store: store));
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());
      final opts = Options(extra: <String, Object?>{
        NetworkCacheInterceptor.policyKey: CachePolicy.cacheFirst,
        NetworkCacheInterceptor.scopeKey: 'u1',
      });

      await client.post<Object?>('/search', data: <String, Object?>{'q': 'a'}, options: opts);
      expect(store.length, 0, reason: 'POST 默认不缓存');

      final dio2 = _dioWith(
        adapter,
        NetworkCacheInterceptor(
          store: MemoryLruCacheStore(),
          cacheableMethods: const <String>{'GET', 'POST'},
        ),
      );
      final client2 = ApiClient(dio2, envelope: const PassthroughEnvelope());
      await client2.post<Object?>('/search', data: <String, Object?>{'q': 'a'}, options: opts);
      expect(adapter.calls, 2);
    });

    test('规则表命中：/city/list → cacheFirst，无需请求级指定策略', () async {
      final adapter = _CountingAdapter((_) => _json('{"v":1}'));
      final dio = _dioWith(
        adapter,
        NetworkCacheInterceptor(
          store: MemoryLruCacheStore(),
          policyTable: CachePolicyTable.planstar,
        ),
      );
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());
      final opts = Options(extra: <String, Object?>{
        NetworkCacheInterceptor.scopeKey: 'u1',
      });

      await client.get<Object?>('/v1/city/list', options: opts);
      await client.get<Object?>('/v1/city/list', options: opts);
      expect(adapter.calls, 1);
    });

    test('规则表命中：/seat/ → onlyNetwork，即使显式要缓存也不生效', () async {
      final adapter = _CountingAdapter((_) => _json('{"v":1}'));
      final store = MemoryLruCacheStore();
      final dio = _dioWith(
        adapter,
        NetworkCacheInterceptor(store: store, policyTable: CachePolicyTable.planstar),
      );
      final client = ApiClient(dio, envelope: const PassthroughEnvelope());
      await client.get<Object?>(
        '/v1/seat/map',
        options: Options(extra: <String, Object?>{
          NetworkCacheInterceptor.scopeKey: 'u1',
        }),
      );
      expect(store.length, 0);
    });
  });

  group('HttpCacheEntry 序列化', () {
    test('toJson/fromJson 往返一致', () {
      final original = HttpCacheEntry(
        body: '{"a":1}',
        statusCode: 200,
        headers: const <String, String>{'x': 'y'},
        storedAt: DateTime.utc(2026, 5, 6, 7, 8, 9),
        ttl: const Duration(seconds: 30),
      );
      final restored = HttpCacheEntry.fromJson(original.toJson());
      expect(restored.body, original.body);
      expect(restored.statusCode, 200);
      expect(restored.headers, <String, String>{'x': 'y'});
      expect(restored.storedAt, original.storedAt);
      expect(restored.ttl, original.ttl);
    });

    test('字段缺失抛 FormatException（当作缓存损坏，而不是造空条目）', () {
      expect(
        () => HttpCacheEntry.fromJson(<String, Object?>{'body': 'x'}),
        throwsFormatException,
      );
    });

    test('过期判断', () {
      final entry = HttpCacheEntry(
        body: '1',
        statusCode: 200,
        headers: const <String, String>{},
        storedAt: DateTime.utc(2026),
        ttl: const Duration(minutes: 5),
      );
      expect(entry.isExpiredAt(DateTime.utc(2026).add(const Duration(minutes: 4))), isFalse);
      expect(entry.isExpiredAt(DateTime.utc(2026).add(const Duration(minutes: 5))), isTrue);
    });
  });
}

HttpCacheEntry _entry() => HttpCacheEntry(
      body: '1',
      statusCode: 200,
      headers: const <String, String>{},
      storedAt: DateTime.utc(2026),
      ttl: const Duration(minutes: 5),
    );
