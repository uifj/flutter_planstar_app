/// 登录态（路由门禁与页面的只读视图）。
///
/// 这是一个**适配层**：真源在 `features/auth/application/auth_controller.dart`，
/// 但路由（`app/router.dart`）与"我的"页只关心"登没登录、叫什么"。
/// 保留 [Session] 这层的好处是它们不必知道 `AuthState` 的全部字段，
/// 也避免 `app/` 直接依赖某个 feature 的内部状态机。
///
/// 相对第一版的改动：以前 `SessionController.login()` 是个**模拟登录**的
/// stub（写个昵称就算登录）。现在 [sessionProvider] 是纯派生 Provider，
/// 登录动作必须走 `AuthController`（真实接口）——这样"点一下就能登录"的
/// 假路径在代码里**不存在**，而不是靠约定不去调它。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/application/auth_state.dart';

/// 登录态视图。
final class Session {
  /// 创建视图。
  const Session({
    this.isLoggedIn = false,
    this.restoring = false,
    this.nickname,
    this.userId,
    this.avatarUrl,
  });

  /// 未登录。
  static const Session guest = Session();

  /// 是否已登录。
  final bool isLoggedIn;

  /// 是否正在从本地恢复会话（冷启动的极短窗口）。
  ///
  /// 路由门禁要跳过这个窗口：否则用户带着登录态深链进 `/order`，
  /// 会在"会话还没读完"的那一帧被踢去登录页。
  final bool restoring;

  /// 昵称（未登录为 `null`）。
  final String? nickname;

  /// 用户 id。
  ///
  /// 未登录为 `null`——来源用 `-1` 表示未登录（`AccountService.userId()`），
  /// 于是调用方 `profile().getUserId()` 直接 NPE（M6-02）。用 `null` +
  /// 空安全可以让编译器帮忙拦住这类取值。
  final int? userId;

  /// 头像 URL（未登录为 `null`）。
  final String? avatarUrl;

  @override
  String toString() =>
      'Session(loggedIn: $isLoggedIn, restoring: $restoring, $nickname)';
}

/// 登录态。
final sessionProvider = Provider<Session>((ref) {
  final AuthState auth = ref.watch(authControllerProvider);
  return Session(
    isLoggedIn: auth.isLoggedIn,
    restoring: auth.isRestoring,
    nickname: auth.user?.displayName,
    userId: auth.user?.userId,
    avatarUrl: auth.user?.avatar,
  );
});
