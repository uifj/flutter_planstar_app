/// 登录状态控制器。
///
/// 承担来源 `BaseLoginActivity` + 4 个 Cell 里被复制了**五份**的职责
/// （23 页 §5）：发码、倒计时、登录、失败分支。区别：
///
/// | | 来源 | 这里 |
/// |---|---|---|
/// | 倒计时 | 5 个 `Handler` + 5 个 `mValidateLeftCount`，全部无 `onDestroy` 清理（泄漏 60 秒） | 1 个 `Timer`，`ref.onDispose` 里 cancel |
/// | 失败分支 | `errorBody().string().contains("该账号已被锁定")` | `Failure.code` + [AuthFailureKind] 枚举 |
/// | 登录态 | `AccountService` 单例 + 静态初始化里读盘 | [AuthState] 不可变状态机 |
library;

import 'dart:async';

import 'package:core_result/core_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../../../app/network/ps_request_context.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

/// 登录状态控制器。
///
/// 所有动作都返回 `AuthFailure?`——`null` 表示成功。这样页面不需要自己
/// 判断 `Result`，又能拿到**服务端原文**去弹提示（企划星的错误体是中文
/// 纯文本，翻译它只会更差）。
class AuthController extends Notifier<AuthState> {
  Timer? _cooldownTimer;
  bool _disposed = false;

  @override
  AuthState build() {
    final PsRequestContext context = ref.watch(pnRequestContextProvider);

    // 401 → 全局登出。注册成钩子而不是让拦截器直接依赖 auth 层，
    // 否则 providers 成环（见 PsRequestContext.onUnauthorized 的注释）。
    context.onUnauthorized = _handleUnauthorized;

    ref.onDispose(() {
      _disposed = true;
      _cooldownTimer?.cancel();
      if (identical(context.onUnauthorized, _handleUnauthorized)) {
        context.onUnauthorized = null;
      }
    });

    // 冷启动恢复会话。build 必须同步返回，所以这里 fire-and-forget。
    unawaited(_restore());
    return const AuthState.restoring();
  }

  /// 发登录验证码。成功返回 `null` 并开始倒计时。
  Future<AuthFailure?> sendCode(String phone, {String? captcha}) async {
    if (!state.canSendCode) {
      return null;
    }
    state = state.copyWith(sendingCode: true, clearFailure: true);

    final Result<SendCodeOutcome> result =
        await ref.read(authRepositoryProvider).sendLoginCode(
              phone,
              captcha: captcha,
            );
    if (_disposed) {
      return null;
    }
    return result.fold(
      onFailure: (Failure failure) => _fail(failure, sendingCode: true),
      onSuccess: (SendCodeOutcome outcome) {
        state = state.copyWith(
          sendingCode: false,
          cooldownSeconds: outcome.cooldownSeconds,
        );
        _startCooldown();
        return null;
      },
    );
  }

  /// 验证码登录。
  Future<AuthFailure?> loginWithCode(
    String phone,
    String code, {
    String? captcha,
  }) {
    return _login(
      () => ref.read(authRepositoryProvider).loginWithCode(
            phone,
            code,
            captcha: captcha,
          ),
    );
  }

  /// 密码登录。
  Future<AuthFailure?> loginWithPassword(
    String phone,
    String password, {
    String? captcha,
  }) {
    return _login(
      () => ref.read(authRepositoryProvider).loginWithPassword(
            phone,
            password,
            captcha: captcha,
          ),
    );
  }

  /// 拉图形验证码（PNG 字节）。失败时把失败写进状态。
  Future<Result<List<int>>> fetchCaptcha() async {
    final Result<List<int>> result =
        await ref.read(authRepositoryProvider).fetchCaptchaImage();
    final Failure? failure = result.failure;
    if (failure != null && !_disposed) {
      state = state.copyWith(failure: AuthFailure.fromFailure(failure));
    }
    return result;
  }

  /// 登出。
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    if (_disposed) {
      return;
    }
    state = const AuthState.guest();
  }

  /// 清掉最近一次失败（例如用户重新输入时）。
  void clearFailure() {
    if (state.failure != null) {
      state = state.copyWith(clearFailure: true);
    }
  }

  Future<AuthFailure?> _login(Future<Result<AuthSession>> Function() run) async {
    if (state.loggingIn) {
      return null;
    }
    state = state.copyWith(loggingIn: true, clearFailure: true);

    final Result<AuthSession> result = await run();
    if (_disposed) {
      return null;
    }
    return result.fold(
      onFailure: (Failure failure) => _fail(failure, loggingIn: true),
      onSuccess: (AuthSession session) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: session.user,
        );
        return null;
      },
    );
  }

  Future<void> _restore() async {
    final AuthSession? session =
        await ref.read(authRepositoryProvider).restoreSession();
    if (_disposed) {
      return;
    }
    state = session == null
        ? const AuthState.guest()
        : AuthState(status: AuthStatus.authenticated, user: session.user);
  }

  AuthFailure _fail(
    Failure failure, {
    bool sendingCode = false,
    bool loggingIn = false,
  }) {
    final authFailure = AuthFailure.fromFailure(failure);
    state = state.copyWith(
      sendingCode: sendingCode ? false : null,
      loggingIn: loggingIn ? false : null,
      failure: authFailure,
    );
    return authFailure;
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      final int next = state.cooldownSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        state = state.copyWith(cooldownSeconds: 0);
      } else {
        state = state.copyWith(cooldownSeconds: next);
      }
    });
  }

  void _handleUnauthorized() {
    if (_disposed || !state.isLoggedIn) {
      return;
    }
    unawaited(logout());
  }
}
