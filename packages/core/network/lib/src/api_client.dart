/// `ApiClient`：包一层 Dio，**永不抛**，全部返回 `Result<T>`。
library;

import 'dart:io';

import 'package:core_result/core_result.dart';
import 'package:dio/dio.dart';

import 'failure_carrying_error.dart';
import 'response_envelope.dart';

/// 基于 [Dio] 的 API 客户端。
///
/// 契约：
/// - 所有方法返回 `Future<Result<T>>`，**不抛异常**（含解析失败与非法参数）；
/// - 失败统一归一为 [Failure]，携带 [FailureType] 与业务码；
/// - 信封两级注入：[ApiClient] 构造级默认 + 单次调用覆盖。
final class ApiClient {
  /// 用给定的 [Dio] 与可选构造级信封创建客户端。
  ApiClient(this._dio, {ResponseEnvelope? envelope})
      : _envelope = envelope ?? const PassthroughEnvelope();

  final Dio _dio;
  final ResponseEnvelope _envelope;

  /// 构造级信封（只读，便于诊断）。
  ResponseEnvelope get envelope => _envelope;

  /// GET。
  Future<Result<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    T Function(Object? data)? parser,
    ResponseEnvelope? envelope,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onReceiveProgress,
  }) {
    return _send<T>(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onReceiveProgress: onReceiveProgress,
      ),
      parser: parser,
      envelope: envelope,
      path: path,
    );
  }

  /// POST。
  Future<Result<T>> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    T Function(Object? data)? parser,
    ResponseEnvelope? envelope,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _send<T>(
      () => _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      parser: parser,
      envelope: envelope,
      path: path,
    );
  }

  /// PUT。
  Future<Result<T>> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    T Function(Object? data)? parser,
    ResponseEnvelope? envelope,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return _send<T>(
      () => _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
      parser: parser,
      envelope: envelope,
      path: path,
    );
  }

  /// PATCH。
  Future<Result<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    T Function(Object? data)? parser,
    ResponseEnvelope? envelope,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return _send<T>(
      () => _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
      parser: parser,
      envelope: envelope,
      path: path,
    );
  }

  /// DELETE。
  Future<Result<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    T Function(Object? data)? parser,
    ResponseEnvelope? envelope,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return _send<T>(
      () => _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
      parser: parser,
      envelope: envelope,
      path: path,
    );
  }

  // ---------------------------------------------------------------------------
  // 内部
  // ---------------------------------------------------------------------------

  Future<Result<T>> _send<T>(
    Future<Response<dynamic>> Function() run, {
    required T Function(Object? data)? parser,
    required ResponseEnvelope? envelope,
    required String path,
  }) async {
    try {
      final response = await run();
      return _resolve<T>(response, parser, envelope);
    } on DioException catch (e) {
      return Fail<T>(_handleDioException(e, path));
    } catch (error) {
      // 拦截器若直接抛出携带 Failure 的领域异常（见 FailureCarryingError），
      // 尊重它，不要改写成 UNEXPECTED。
      if (error is FailureCarryingError) {
        return Fail<T>(error.failure);
      }
      // 非 DioException 也不能逃逸：来源只 catch DioException，
      // 非法 URL / 序列化错误会直接抛到调用方（30-02 的连带问题）。
      return Fail<T>(
        Failure.server(
          code: 'UNEXPECTED',
          message: '请求未能完成：$error',
          cause: error,
        ),
      );
    }
  }

  /// 信封解包 + 数据提取。调用级 [envelope] 覆盖构造级默认。
  Result<T> _resolve<T>(
    Response<dynamic> response,
    T Function(Object? data)? parser,
    ResponseEnvelope? envelope,
  ) {
    final active = envelope ?? _envelope;
    final Object? body = response.data;
    try {
      if (!active.isSuccess(body, response.statusCode)) {
        final err = active.extractError(body, response.statusCode);
        return Fail<T>(
          Failure(
            code: err.code ?? 'BIZ_ERROR',
            message: err.message ?? '业务处理失败',
            type: FailureType.server,
            statusCode: response.statusCode,
            cause: err,
            requestId: err.requestId,
          ),
        );
      }
      final data = active.extractData(body);
      if (parser != null) {
        return Success<T>(parser(data));
      }
      return Success<T>(data as T);
    } catch (error) {
      // 解析失败属于 data 类（不是服务端错，重试也没用）。
      return Fail<T>(
        Failure(
          code: 'PARSE_ERROR',
          message: '响应解析失败：$error',
          type: FailureType.data,
          statusCode: response.statusCode,
          cause: error,
        ),
      );
    }
  }

  Failure _handleDioException(DioException e, String path) {
    // 拦截器通过 `error` 携带的领域失败优先——它比任何类型推断都准确。
    final carried = e.error;
    if (carried is FailureCarryingError) {
      return carried.failure;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      // dio 5.10+ 新增：响应体 transform 阶段的超时。语义上仍是超时。
      case DioExceptionType.transformTimeout:
        return Failure.timeout(
          message: '网络超时，请稍后重试',
          cause: e,
        );
      case DioExceptionType.badCertificate:
        // 证书校验失败必须暴露，不能降级重试。
        return Failure(
          code: 'BAD_CERTIFICATE',
          message: '服务端证书校验失败',
          type: FailureType.network,
          cause: e,
        );
      case DioExceptionType.cancel:
        return Failure.network(
          code: 'REQUEST_CANCELLED',
          message: '请求已取消',
          cause: e,
        );
      case DioExceptionType.connectionError:
        return Failure.network(message: '网络连接失败，请检查网络', cause: e);
      case DioExceptionType.badResponse:
        return _mapStatusCode(e.response?.statusCode, e.response?.data);
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return Failure.network(message: '无网络连接', cause: e);
        }
        return Failure.server(
          message: e.message ?? '未知错误',
          code: 'UNKNOWN',
          cause: e,
        );
    }
  }

  Failure _mapStatusCode(int? statusCode, Object? data) {
    final message = _messageOf(data);
    switch (statusCode) {
      case 400:
        return Failure.server(
          code: 'BAD_REQUEST',
          message: message ?? '请求参数有误',
          statusCode: 400,
        );
      case 401:
        return Failure.unauthorized(message: message ?? '登录已失效');
      case 403:
        return Failure(
          code: 'FORBIDDEN',
          message: message ?? '没有访问权限',
          type: FailureType.authentication,
          statusCode: 403,
        );
      case 404:
        return Failure.server(
          code: 'NOT_FOUND',
          message: message ?? '资源不存在',
          statusCode: 404,
        );
      case 409:
        return Failure.server(
          code: 'CONFLICT',
          message: message ?? '状态冲突，请刷新后重试',
          statusCode: 409,
        );
      case 429:
        return Failure.server(
          code: 'TOO_MANY_REQUESTS',
          message: message ?? '操作过于频繁',
          statusCode: 429,
        );
      default:
        if (statusCode != null && statusCode >= 500) {
          return Failure.server(
            code: 'SERVER_ERROR',
            message: message ?? '服务开小差了，请稍后重试',
            statusCode: statusCode,
          );
        }
        return Failure.server(
          code: 'HTTP_ERROR',
          message: message ?? '请求失败（HTTP $statusCode）',
          statusCode: statusCode,
        );
    }
  }

  /// 从错误体里取可直接展示给用户的文案。
  ///
  /// 两种真实形态都要支持：
  ///
  /// 1. `{code, message}` 这类 JSON 信封（大部分业务接口）；
  /// 2. **纯文本**——企划星的登录类接口失败时返回的是
  ///    `HTTP 4xx/5xx` + `Content-Type: text/plain;charset=UTF-8`，正文就是
  ///    给用户看的中文。实测（2026-11，`api.planstar.com`）：
  ///
  ///    ```text
  ///    POST /v1/user/login  {"ua":"13800138000","code":"000000","ct":11}
  ///    → 500 text/plain  «验证码不正确»
  ///
  ///    POST /v1/user/login  {"ua":"123","pw":"x","ct":11}
  ///    → 500 text/plain  «请使用手机号验证码登录，若手机号登录异常，请联系客服»
  ///    ```
  ///
  ///    来源实现是 `showToast(response.errorBody().string())`，即**原文直弹**。
  ///    这里不这么做就会退化成「服务开小差了」，把"验证码错 / 账号被锁定"
  ///    这类唯一有用的信息丢掉。
  ///
  /// 纯文本仍要设边界：CDN / 网关返回的 HTML 错误页（`<!DOCTYPE html>…`）
  /// 不能弹给用户，超长正文截断。
  String? _messageOf(Object? data) {
    if (data is Map<Object?, Object?>) {
      final raw = data['message'] ?? data['msg'] ?? data['ResultMessage'];
      if (raw is String && raw.isNotEmpty) {
        return raw;
      }
      return null;
    }
    if (data is String) {
      final text = data.trim();
      if (text.isEmpty || text.startsWith('<')) {
        return null;
      }
      return text.length > 120 ? '${text.substring(0, 120)}…' : text;
    }
    return null;
  }
}
