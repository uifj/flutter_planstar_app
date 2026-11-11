/// 一次登录建立起来的会话。
library;

import 'auth_user.dart';

/// 会话 = 用户资料 + 会话令牌。
///
/// 企划星的令牌是 `psSession`（登录响应头下发，之后走 `Cookie: psSession=…`）。
/// 令牌和资料在存储上**分两处放**：`psSession` 进安全存储，
/// 资料进普通偏好（纯 JSON，不做 URL 编码）。
/// 但对调用方合成一个对象返回，避免自己去拼"令牌有了但资料还没到"
/// 的中间态。
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
  String toString() =>
      'AuthSession(${user.userId}, token: ${token == null ? '无' : '有'})';
}
