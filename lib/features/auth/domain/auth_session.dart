/// 一次登录建立起来的会话。
library;

import 'auth_user.dart';

/// 会话 = 用户资料 + 会话令牌。
///
/// 企划星的令牌是 `psSession`（登录响应头下发，之后走 `Cookie: psSession=…`）。
/// 来源把它和资料**分两处存**：`psSession` 在 `SharedPreferences("account")`，
/// 资料在同一个 prefs 的 `profile` 字段（URL 编码的 JSON）。
/// 这里仍然分两处存（令牌进安全存储、资料进普通偏好），但合成一个对象
/// 返回，避免调用方自己去拼"令牌有了但资料还没到"的中间态。
final class AuthSession {
  /// 创建会话。
  const AuthSession({required this.user, this.token});

  /// 用户资料。
  final AuthUser user;

  /// 会话令牌（`psSession`）。`null` 表示服务端没下发（例如只刷新资料时）。
  final String? token;

  /// 是否可用的会话（有真实用户）。
  bool get isValid => user.isValid;

  /// 换一份资料（保留令牌）。
  AuthSession copyWithUser(AuthUser next) =>
      AuthSession(user: next, token: token);

  @override
  String toString() => 'AuthSession(${user.userId}, token: ${token == null ? '无' : '有'})';
}
