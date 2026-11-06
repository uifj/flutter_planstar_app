/// 响应信封：把"后端返回长什么样"抽象成可替换策略。
///
/// 企划星 Android 侧有 87 个 Service 接口、两种响应封装，且判码逻辑散落在每个
/// Service 里（`if (bean.getCode() != 0) throw ...`）。信封层把这处判断收敛成
/// **一处可配置的策略**，并用两级注入处理例外：
///
/// ```dart
/// // 构造级：这个后端的默认格式
/// final client = ApiClient(dio, envelope: const RestCodeEnvelope());
/// // 调用级：单个接口的例外
/// await client.get('/third-party/callback', envelope: const PassthroughEnvelope());
/// ```
library;

/// 当 body 里找不到信封字段（如 `code`）时的处置方式。
///
/// 来源实现是"直接当成功"（保守回退），代价是后端改字段名时**全部接口静默成功**，
/// 真实业务码丢失，排查时只能看到 `Response handling failed`（30-08）。
/// 因此这里把它变成显式选择，默认 [fail]。
enum MissingEnvelopePolicy {
  /// 当作失败，`code = 'MISSING_ENVELOPE'`。**默认**——宁可报错，不可静默。
  fail,

  /// 当作成功，body 直通（用于已知未包装的接口）。
  assumeSuccess,
}

/// 信封解析出的业务错误。
final class EnvelopeError {
  const EnvelopeError({this.code, this.message, this.requestId});

  /// 业务错误码（`'not_login'`、`'InvalidParameter'`、`'1001'`…）。
  final String? code;

  /// 业务错误信息。
  final String? message;

  /// 服务端追踪 id（用于对日志）。
  final String? requestId;

  @override
  String toString() =>
      'EnvelopeError(code: $code, message: $message, requestId: $requestId)';
}

/// 响应信封策略。
abstract class ResponseEnvelope {
  const ResponseEnvelope();

  /// 业务是否成功。[statusCode] 供需要 HTTP 语义参与判定的实现使用。
  bool isSuccess(Object? body, int? statusCode);

  /// 提取业务数据段（成功时交给 parser）。
  Object? extractData(Object? body);

  /// 提取业务错误（[isSuccess] 为 false 时调用）。
  EnvelopeError extractError(Object? body, int? statusCode);
}

/// 直通信封：永远成功，数据段即原始 body。
///
/// 用于裸 body 的接口（图片、第三方回调、OSS 预签名响应）。
final class PassthroughEnvelope extends ResponseEnvelope {
  const PassthroughEnvelope();

  @override
  bool isSuccess(Object? body, int? statusCode) => true;

  @override
  Object? extractData(Object? body) => body;

  @override
  EnvelopeError extractError(Object? body, int? statusCode) =>
      const EnvelopeError();
}

/// 通用 REST 信封：`{code, message, data}`（键名与成功码集可配）。
///
/// 企划星的默认格式即此类，`RestCodeEnvelope()` 无需参数即可用。
final class RestCodeEnvelope extends ResponseEnvelope {
  const RestCodeEnvelope({
    this.codeKey = 'code',
    this.messageKey = 'message',
    this.dataKey = 'data',
    this.requestIdKey = 'requestId',
    this.successCodes = const <int>{0, 200},
    this.missingEnvelope = MissingEnvelopePolicy.fail,
  });

  /// 业务码键名。
  final String codeKey;

  /// 业务信息键名。
  final String messageKey;

  /// 数据段键名。
  final String dataKey;

  /// 追踪 id 键名。
  final String requestIdKey;

  /// 视为成功的业务码集合（int 或其字符串形式均可匹配）。
  final Set<int> successCodes;

  /// 缺信封字段时的处置方式。
  final MissingEnvelopePolicy missingEnvelope;

  bool _hasEnvelope(Object? body) =>
      body is Map<Object?, Object?> && body.containsKey(codeKey);

  int? _codeOf(Object? body) {
    if (body is! Map<Object?, Object?>) {
      return null;
    }
    final raw = body[codeKey];
    if (raw is int) {
      return raw;
    }
    if (raw is String) {
      return int.tryParse(raw);
    }
    return null;
  }

  @override
  bool isSuccess(Object? body, int? statusCode) {
    if (!_hasEnvelope(body)) {
      return missingEnvelope == MissingEnvelopePolicy.assumeSuccess;
    }
    final code = _codeOf(body);
    // 有 code 键但不是数字：无法判定成败，按失败处理（不猜）。
    if (code == null) {
      return false;
    }
    return successCodes.contains(code);
  }

  @override
  Object? extractData(Object? body) {
    if (!_hasEnvelope(body)) {
      return body;
    }
    return (body! as Map<Object?, Object?>)[dataKey];
  }

  @override
  EnvelopeError extractError(Object? body, int? statusCode) {
    if (body is! Map<Object?, Object?>) {
      return const EnvelopeError();
    }
    if (!_hasEnvelope(body)) {
      return EnvelopeError(
        code: 'MISSING_ENVELOPE',
        message: '响应缺少 `$codeKey` 字段，可能后端已改契约',
      );
    }
    final code = body[codeKey];
    final message = body[messageKey];
    final requestId = body[requestIdKey];
    return EnvelopeError(
      code: code?.toString(),
      message: message?.toString(),
      requestId: requestId?.toString(),
    );
  }
}
