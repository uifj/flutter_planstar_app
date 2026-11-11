/// 登录失败的结构化描述。
///
/// 为什么需要分类而不是"一个 message 字符串"：服务端错误体是**原文直弹**的
/// 中文文本，于是
/// "验证码不正确 / 该账号已被锁定 / 图形验证码错误" 在 UI 上是同一个东西，
/// 唯一的区别只能靠 `message.contains("该账号已被锁定")` 这种字符串判断来做。
/// 这里把那些 `contains` 收在仓库层、提成枚举，
/// UI 只 switch 一次。
///
/// 与 `package:core/result.dart` 的关系：传输层与仓库层仍然统一返回 `Result`/`Failure`
/// （全项目只有一套失败契约）。[AuthFailure] 是**面向 UI 的视图**，
/// 由 [AuthFailure.fromFailure] 从 `Failure` 派生——分类信息装在
/// `Failure.code` 里（见 [AuthFailureCodes]），因为 `Failure` 的 `code`
/// 本来就是"机器可读的失败码"。
library;

import 'package:core/result.dart';

/// 失败类别。
enum AuthFailureKind {
  /// 服务端明确拒绝，[AuthFailure.message] 就是服务端原文（可直接展示）。
  business,

  /// 账号被锁定（UI 弹一个不可取消的对话框）。
  accountLocked,

  /// 需要图形验证码（风控触发）。
  needsCaptcha,

  /// 网络不可用（DNS/连接失败）。
  network,

  /// 超时。
  timeout,

  /// 会话失效（401），需要重新登录。
  unauthorized,

  /// 响应解析失败 / 未知错误。
  unknown,
}

/// 认证失败码（写进 `Failure.code`）。
abstract final class AuthFailureCodes {
  /// 服务端业务拒绝，`message` 是服务端原文。
  static const String business = 'AUTH_BUSINESS';

  /// 账号被锁定。
  static const String accountLocked = 'AUTH_ACCOUNT_LOCKED';

  /// 需要图形验证码。
  static const String needsCaptcha = 'AUTH_NEEDS_CAPTCHA';
}

/// 一次登录失败。
final class AuthFailure {
  /// 创建失败。
  const AuthFailure({
    required this.kind,
    required this.message,
    this.code,
    this.statusCode,
  });

  /// 从 `Failure` 派生。
  ///
  /// 分类优先看 `code`（仓库层显式标注的三种），其余按 `FailureType` 归一。
  factory AuthFailure.fromFailure(Failure failure) {
    final kind = switch (failure.code) {
      AuthFailureCodes.needsCaptcha => AuthFailureKind.needsCaptcha,
      AuthFailureCodes.accountLocked => AuthFailureKind.accountLocked,
      AuthFailureCodes.business => AuthFailureKind.business,
      _ => switch (failure.type) {
        FailureType.network => AuthFailureKind.network,
        FailureType.timeout => AuthFailureKind.timeout,
        FailureType.authentication => AuthFailureKind.unauthorized,
        FailureType.data => AuthFailureKind.unknown,
        FailureType.validation => AuthFailureKind.business,
        FailureType.server => AuthFailureKind.business,
      },
    };
    return AuthFailure(
      kind: kind,
      message: failure.message,
      code: failure.code,
      statusCode: failure.statusCode,
    );
  }

  /// 类别。
  final AuthFailureKind kind;

  /// 可直接展示给用户的文案。
  ///
  /// `business` / `accountLocked` 时就是服务端原文——企划星的错误体是
  /// `text/plain` 中文（实测：`验证码不正确`、`请使用手机号验证码登录…`），
  /// 翻译它只会更差。
  final String message;

  /// 机器可读的失败码（[AuthFailureCodes] 或传输层码）。
  final String? code;

  /// HTTP 状态码。
  final int? statusCode;

  /// 是否需要弹图形验证码。
  bool get needsCaptcha => kind == AuthFailureKind.needsCaptcha;

  /// 是否值得用户原样重试（网络类）。
  bool get isRetryable =>
      kind == AuthFailureKind.network || kind == AuthFailureKind.timeout;

  @override
  String toString() => 'AuthFailure(${kind.name}, $message)';
}
