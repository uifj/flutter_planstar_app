/// 登录响应。
///
/// 三个字段的含义：
/// - `needCaptcha`：风控要求先过图形验证码，**此时 `user` 是 null**；
/// - `newUser`：这次登录顺带注册了新账号；
/// - `user`：资料。这里直接复用领域模型 [AuthUser]——它就是这个接口的
///   输出形状，再套一层 `UserDto` 只是给字段搬一次家。
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/auth_user.dart';
import 'json_shape.dart';

part 'login_response_dto.freezed.dart';
part 'login_response_dto.g.dart';

/// 登录响应。
@freezed
abstract class LoginResponseDto with _$LoginResponseDto {
  /// 创建响应。
  const factory LoginResponseDto({
    /// 是否需要图形验证码。
    @JsonKey(fromJson: _asBool) @Default(false) bool needCaptcha,

    /// 是否新注册用户。
    @JsonKey(fromJson: _asBool) @Default(false) bool newUser,

    /// 用户资料（需要验证码时为 `null`）。
    ///
    /// `user` 缺失或不是对象时返回 `null`，**不抛**——"登录成功但没有 user"
    /// 是一个需要上层判断的业务状态，不是解析错误。
    @JsonKey(fromJson: _authUserOrNull) AuthUser? user,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
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

AuthUser? _authUserOrNull(Object? raw) {
  if (raw is Map<Object?, Object?>) {
    return AuthUser.fromJson(asStringKeyedMap(raw, what: '登录响应的 user 字段'));
  }
  return null;
}
