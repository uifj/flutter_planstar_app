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

import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_code_response_dto.freezed.dart';
part 'send_code_response_dto.g.dart';

/// 发验证码响应。
@freezed
abstract class SendCodeResponseDto with _$SendCodeResponseDto {
  /// 创建响应。
  const factory SendCodeResponseDto({
    /// 是否已下发。
    @JsonKey(fromJson: _asBool) required bool success,

    /// 是否需要先过图形验证码。
    @JsonKey(fromJson: _asBool) @Default(false) bool needCaptcha,

    /// 失败原因（服务端原文，例如"发送失败"）。
    @JsonKey(fromJson: _nonEmptyStringOrNull) String? errorMsg,
  }) = _SendCodeResponseDto;

  factory SendCodeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SendCodeResponseDtoFromJson(json);
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

String? _nonEmptyStringOrNull(Object? value) =>
    value is String && value.isNotEmpty ? value : null;
