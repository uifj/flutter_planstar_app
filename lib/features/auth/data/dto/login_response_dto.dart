/// 登录响应（来源 `lib\model\LoginBean`）。
///
/// ```java
/// public class LoginBean implements Serializable {
///     private boolean needCaptcha;
///     private boolean newUser;
///     private UserProfile user;
/// }
/// ```
///
/// 三个字段的含义：
/// - `needCaptcha`：风控要求先过图形验证码，**此时 `user` 是 null**；
/// - `newUser`：这次登录顺带注册了新账号；
/// - `user`：资料。这里直接复用领域模型 [AuthUser]——它就是这个接口的
///   输出形状，再套一层 `UserDto` 只是给字段搬一次家。
library;

import '../../domain/auth_user.dart';
import 'json_shape.dart';

/// 登录响应。
final class LoginResponseDto {
  /// 创建响应。
  const LoginResponseDto({
    this.needCaptcha = false,
    this.newUser = false,
    this.user,
  });

  /// 是否需要图形验证码。
  final bool needCaptcha;

  /// 是否新注册用户。
  final bool newUser;

  /// 用户资料（需要验证码时为 `null`）。
  final AuthUser? user;

  /// 从 JSON 解析。
  ///
  /// `user` 缺失或不是对象时返回 `null`，**不抛**——"登录成功但没有 user"
  /// 是一个需要上层判断的业务状态，不是解析错误。
  factory LoginResponseDto.fromJson(Map<String, Object?> json) {
    final Object? rawUser = json['user'];
    return LoginResponseDto(
      needCaptcha: _asBool(json['needCaptcha']),
      newUser: _asBool(json['newUser']),
      user: rawUser is Map<Object?, Object?>
          ? AuthUser.fromJson(
              asStringKeyedMap(rawUser, what: '登录响应的 user 字段'),
            )
          : null,
    );
  }

  @override
  String toString() =>
      'LoginResponseDto(needCaptcha: $needCaptcha, newUser: $newUser, user: $user)';
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
