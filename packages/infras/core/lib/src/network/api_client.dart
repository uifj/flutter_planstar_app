/// `ApiClient`：包一层 Dio，**永不抛**，全部返回 `Result<T>`。
library;

import 'dart:convert';
import 'dart:io';

import 'package:core/result.dart';
import 'package:dio/dio.dart';

import 'failure_carrying_error.dart';
import 'response_envelope.dart';

/// 从错误响应体里抽出的统一信息。
final class _ErrorPayload {
  const _ErrorPayload({this.code, this.message, this.requestId});

  final String? code;
  final String? message;
  final String? requestId;
}

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
        final payload = _errorOf(body);
        return Fail<T>(
          Failure(
            code: err.code ?? payload.code ?? 'BIZ_ERROR',
            message: err.message ?? payload.message ?? '业务处理失败',
            type: FailureType.server,
            statusCode: response.statusCode,
            cause: err,
            requestId: err.requestId ?? payload.requestId,
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
        return Failure.timeout(message: '网络超时，请稍后重试', cause: e);
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
    final payload = _errorOf(data);
    final message = payload.message;
    switch (statusCode) {
      case 400:
        return Failure.server(
          code: payload.code ?? 'BAD_REQUEST',
          message: message ?? '请求参数有误',
          statusCode: 400,
          requestId: payload.requestId,
        );
      case 401:
        // 401 仍然交给上层登录失效流程处理；服务端文案优先。
        return Failure.unauthorized(
          message: message ?? '登录已失效',
          code: payload.code ?? 'UNAUTHORIZED',
          requestId: payload.requestId,
        );
      case 403:
        return Failure(
          code: payload.code ?? 'FORBIDDEN',
          message: message ?? '没有访问权限',
          type: FailureType.authentication,
          statusCode: 403,
          requestId: payload.requestId,
        );
      case 404:
        return Failure.server(
          code: payload.code ?? 'NOT_FOUND',
          message: message ?? '资源不存在',
          statusCode: 404,
          requestId: payload.requestId,
        );
      case 409:
        return Failure.server(
          code: payload.code ?? 'CONFLICT',
          message: message ?? '状态冲突，请刷新后重试',
          statusCode: 409,
          requestId: payload.requestId,
        );
      case 429:
        return Failure.server(
          code: payload.code ?? 'TOO_MANY_REQUESTS',
          message: message ?? '操作过于频繁',
          statusCode: 429,
          requestId: payload.requestId,
        );
      default:
        if (statusCode != null && statusCode >= 500) {
          return Failure.server(
            code: payload.code ?? 'SERVER_ERROR',
            message: message ?? '服务开小差了，请稍后重试',
            statusCode: statusCode,
            requestId: payload.requestId,
          );
        }
        return Failure.server(
          code: payload.code ?? 'HTTP_ERROR',
          message: message ?? '请求失败（HTTP $statusCode）',
          statusCode: statusCode,
          requestId: payload.requestId,
        );
    }
  }

  /// 统一解析错误体：JSON 信封 `{code,message,traceId}` 或旧 `text/plain`。
  ///
  /// JSON 可能是原始 Map，也可能是被 content-type 识别成字符串的正文
  /// （网关/后端混用），所以字符串会再尝试一次 JSON 解码。
  _ErrorPayload _errorOf(Object? data) {
    if (data is Map<Object?, Object?>) return _payloadFromMap(data);
    if (data is List<dynamic>) return const _ErrorPayload();
    if (data is String) {
      final text = data.trim();
      if (text.isEmpty || text.startsWith('<')) {
        return const _ErrorPayload();
      }
      if (text.startsWith('{') || text.startsWith('[')) {
        try {
          final decoded = jsonDecode(text);
          if (decoded is Map<Object?, Object?>) return _payloadFromMap(decoded);
        } catch (_) {
          // 不是合法 JSON，按纯文本处理。
        }
      }
      // 源码里旧接口直接弹原文；这里限制长度，避免把网关 HTML 塞给用户。
      return _ErrorPayload(
        message: text.length > 120 ? '${text.substring(0, 120)}…' : text,
      );
    }
    return const _ErrorPayload();
  }

  _ErrorPayload _payloadFromMap(Map<Object?, Object?> map) {
    final rawMessage =
        map['message'] ?? map['msg'] ?? map['ResultMessage'] ?? map['error'];
    final rawCode = map['code'] ?? map['errorCode'];
    final rawTrace =
        map['traceId'] ?? map['trace_id'] ?? map['requestId'] ?? map['reqId'];
    final message = rawMessage is String && rawMessage.isNotEmpty
        ? rawMessage
        : null;
    final code = rawCode?.toString();
    return _ErrorPayload(
      code: code == null || code.isEmpty ? null : code,
      message: message,
      requestId: rawTrace?.toString(),
    );
  }
}
