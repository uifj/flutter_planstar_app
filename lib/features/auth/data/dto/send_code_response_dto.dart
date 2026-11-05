/// 发验证码响应（`POST v3/user/sendLoginCode`）。
///
/// 实测（2026-11，`api.planstar.com`）：
///
/// ```text
/// POST /v3/user/sendLoginCode  {"ua":"123"}
/// → 200 application/json  {"success":false,"needCaptcha":false,"errorMsg":"发送失败"}
/// ```
///
/// 注意它是 **HTTP 200 + `success:false`**，而不是 HTTP 错误码——和
/// `v1/user/login` 的错误表达方式（`500` + `text/plain`）完全不同。
/// 同一个后端里两种错误风格并存，所以两个接口要分开建模。
library;

/// 发验证码响应。
final class SendCodeResponseDto {
  /// 创建响应。
  const SendCodeResponseDto({
    required this.success,
    this.needCaptcha = false,
    this.errorMsg,
  });

  /// 是否已下发。
  final bool success;

  /// 是否需要先过图形验证码。
  final bool needCaptcha;

  /// 失败原因（服务端原文，例如"发送失败"）。
  final String? errorMsg;

  /// 从 JSON 解析。
  factory SendCodeResponseDto.fromJson(Map<String, Object?> json) {
    final Object? msg = json['errorMsg'];
    return SendCodeResponseDto(
      success: _asBool(json['success']),
      needCaptcha: _asBool(json['needCaptcha']),
      errorMsg: msg is String && msg.isNotEmpty ? msg : null,
    );
  }

  @override
  String toString() =>
      'SendCodeResponseDto(success: $success, needCaptcha: $needCaptcha, '
      'errorMsg: $errorMsg)';
}

bool _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return value == 'true';
  }
  if (value is num) {
    return value != 0;
  }
  return false;
}
