/// 失败的结构化描述。**永不抛出**——它是 [Result] 的失败分支载荷。
library;

/// 失败类别。
///
/// 与来源的差别：`validation`（输入校验）与 `data`（解析/完整性）分开。
/// 企划星 Android 侧这两类混在同一个 `Throwable` 里，重构时必须先分清，
/// 否则"用户输入错"会被当成"服务端错"重试。
enum FailureType {
  /// 服务端错误（5xx、业务码失败）。
  server,

  /// 网络层错误（无连接、请求取消）。
  network,

  /// 认证 / 鉴权失败（401 / 403）。
  authentication,

  /// 超时（连接 / 发送 / 接收）。
  timeout,

  /// 数据层错误（解析失败、分片完整性）。
  data,

  /// 输入校验错误（已释放、文件不存在、参数非法）。
  validation,
}

/// 一次失败。
///
/// 命名构造的用法约定：**用它来排除非法状态**，而不是先建对象再填字段。
/// 例如 [Failure.network] 不接受 `statusCode`——网络层错误本来就没有状态码。
final class Failure {
  const Failure({
    required this.code,
    required this.message,
    required this.type,
    this.statusCode,
    this.cause,
    this.requestId,
  });

  /// 服务端错误。[statusCode] 可填（5xx），[cause] 可挂信封错误。
  const Failure.server({
    required this.message,
    this.code = 'SERVER_ERROR',
    this.statusCode,
    this.cause,
    this.requestId,
  }) : type = FailureType.server;

  /// 网络层错误（无连接、取消）。没有状态码。
  const Failure.network({
    required this.message,
    this.code = 'NETWORK_ERROR',
    this.cause,
  })  : type = FailureType.network,
        statusCode = null,
        requestId = null;

  /// 超时。没有状态码。
  const Failure.timeout({
    required this.message,
    this.code = 'TIMEOUT',
    this.cause,
  })  : type = FailureType.timeout,
        statusCode = null,
        requestId = null;

  /// 认证失败。默认 401。
  const Failure.unauthorized({
    required this.message,
    this.code = 'UNAUTHORIZED',
    this.statusCode = 401,
    this.requestId,
  })  : type = FailureType.authentication,
        cause = null;

  /// 输入校验失败。
  const Failure.input({
    required this.message,
    this.code = 'INPUT_ERROR',
  })  : type = FailureType.validation,
        statusCode = null,
        cause = null,
        requestId = null;

  /// 机器可读的失败码（`HTTP_ERROR` / `TIMEOUT` / 后端业务码…）。
  final String code;

  /// 人类可读的失败信息（可直接展示给用户）。
  final String message;

  /// 失败类别。
  final FailureType type;

  /// HTTP 状态码（若有）。
  final int? statusCode;

  /// 触发失败的底层对象（`DioException` / `EnvelopeError` / …），仅供日志。
  final Object? cause;

  /// 服务端追踪 id（用于对日志）。
  final String? requestId;

  /// 是否值得自动重试。
  ///
  /// 只认超时与网络中断：服务端 5xx 与业务码失败**不**重试（可能重复下单）。
  bool get isRetryable =>
      type == FailureType.timeout || type == FailureType.network;

  /// 是否属于"登录态失效"，需要踢回登录页。
  bool get isAuthFailure =>
      type == FailureType.authentication || statusCode == 401;

  /// 浅拷贝。`null` 表示"保持原值"（无法用本方法把字段清空）。
  Failure copyWith({
    String? code,
    String? message,
    FailureType? type,
    int? statusCode,
    Object? cause,
    String? requestId,
  }) {
    return Failure(
      code: code ?? this.code,
      message: message ?? this.message,
      type: type ?? this.type,
      statusCode: statusCode ?? this.statusCode,
      cause: cause ?? this.cause,
      requestId: requestId ?? this.requestId,
    );
  }

  @override
  String toString() =>
      'Failure(code: $code, type: ${type.name}, statusCode: $statusCode, '
      'message: $message)';
}
