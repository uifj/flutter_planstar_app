/// 重试拦截器：只重试**瞬时网络错误**，不重试业务失败。
///
/// 按本包契约收紧的三条规则：
/// - 重试计数存在 `requestOptions.extra`（内部元数据，**不会**写进 HTTP
///   请求头，避免 `retry_attempt` 泄漏到服务端）；
/// - 只认超时 / 连接失败 / `SocketException`：5xx 与业务码失败不重试，
///   否则下单、支付这类非幂等请求会被重复提交；
/// - 最后一次重试的错误原样上抛（而不是首个错误），避免上层拿到过期信息。
library;

import 'dart:io' show SocketException;

import 'package:core/logger.dart';
import 'package:dio/dio.dart';

/// 挂在 Dio 上的重试拦截器。
///
/// 用法（顺序即语义：缓存 → 鉴权 → 重试）：
///
/// ```dart
/// final dio = buildDio(
///   baseUrl: base,
///   interceptors: <Interceptor>[
///     NetworkCacheInterceptor(store: MemoryLruCacheStore()),
///     AuthInterceptor(...),
///     RetryInterceptor(dio: ???), // 见下方说明
///   ],
/// );
/// ```
///
/// `buildDio` 返回后才拿到 Dio 实例，而拦截器构造又需要它。有两种写法：
/// 先建 Dio 再 `dio.interceptors.add(RetryInterceptor(dio: dio))`；或注入一个
/// `Dio Function()` 延迟取实例。这里保留 `Dio` 参数。
final class RetryInterceptor extends Interceptor {
  /// 创建拦截器。
  ///
  /// [maxRetries] 为**重试次数**（不含首次请求）。[retryDelays] 逐次取用：
  /// 第 N 次重试等待 `retryDelays[N]`，长度不足时不再重试。
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelays = const <Duration>[
      Duration(seconds: 1),
      Duration(seconds: 3),
      Duration(seconds: 5),
    ],
    this.logger,
  })  : assert(maxRetries >= 0, 'maxRetries 不能为负'),
        assert(
          maxRetries == 0 || retryDelays.isNotEmpty,
          '开启重试时 retryDelays 不能为空',
        );

  /// 用于重发请求的 Dio。
  ///
  /// 必须是**同一个**实例：换实例会丢掉基础配置与其它拦截器。
  final Dio dio;

  /// 最大重试次数（不含首次请求）。
  final int maxRetries;

  /// 第 N 次重试前的等待时间。
  final List<Duration> retryDelays;

  /// 可选的日志器。为空时不打日志。
  final AppLogger? logger;

  /// 重试计数在 `extra` 里的键。
  ///
  /// 只放 `extra`，绝不写 `headers`——测试会守住这一点。
  static const String attemptExtraKey = 'retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return super.onError(err, handler);
    }

    final attempt = _attemptOf(err.requestOptions);
    if (attempt >= maxRetries || attempt >= retryDelays.length) {
      return super.onError(err, handler);
    }

    final delay = retryDelays[attempt];
    logger?.warn(
      '重试 ${err.requestOptions.method} ${err.requestOptions.path} '
      '（${attempt + 1}/$maxRetries，等待 ${delay.inMilliseconds}ms）',
      error: err,
    );

    await Future<void>.delayed(delay);

    final options = Options(
      method: err.requestOptions.method,
      headers: err.requestOptions.headers,
      contentType: err.requestOptions.contentType,
      responseType: err.requestOptions.responseType,
      followRedirects: err.requestOptions.followRedirects,
      listFormat: err.requestOptions.listFormat,
      receiveTimeout: err.requestOptions.receiveTimeout,
      sendTimeout: err.requestOptions.sendTimeout,
      validateStatus: err.requestOptions.validateStatus,
      extra: <String, Object?>{
        ...err.requestOptions.extra,
        attemptExtraKey: attempt + 1,
      },
    );

    try {
      final response = await dio.request<dynamic>(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        cancelToken: err.requestOptions.cancelToken,
        options: options,
        onSendProgress: err.requestOptions.onSendProgress,
        onReceiveProgress: err.requestOptions.onReceiveProgress,
      );
      return handler.resolve(response);
    } on DioException catch (retryError) {
      // 透传最后一次重试的错误：首个错误可能已经过期（如首次超时、末次 500）。
      return super.onError(retryError, handler);
    }
  }

  int _attemptOf(RequestOptions options) {
    final value = options.extra[attemptExtraKey];
    return value is int ? value : 0;
  }

  bool _shouldRetry(DioException err) {
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout ||
      DioExceptionType.connectionError =>
        true,
      DioExceptionType.unknown =>
        err.error is SocketException,
      _ => false,
    };
  }
}
