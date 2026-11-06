/// 登录状态。
library;

import '../domain/auth_failure.dart';
import '../domain/auth_user.dart';

/// 会话状态机。
enum AuthStatus {
  /// 冷启动正在读本地会话（此时既不算登录也不算未登录）。
  restoring,

  /// 未登录。
  guest,

  /// 已登录。
  authenticated,
}

/// 认证状态（不可变）。
final class AuthState {
  /// 创建状态。
  const AuthState({
    this.status = AuthStatus.restoring,
    this.user,
    this.sendingCode = false,
    this.loggingIn = false,
    this.cooldownSeconds = 0,
    this.failure,
  });

  /// 冷启动中。
  const AuthState.restoring() : this();

  /// 未登录。
  const AuthState.guest({AuthFailure? failure})
    : this(status: AuthStatus.guest, failure: failure);

  /// 状态。
  final AuthStatus status;

  /// 当前用户（未登录为 `null`）。
  final AuthUser? user;

  /// 正在发验证码。
  final bool sendingCode;

  /// 正在登录。
  final bool loggingIn;

  /// 发码冷却剩余秒数（>0 时按钮显示倒计时并禁用）。
  final int cooldownSeconds;

  /// 最近一次失败（成功后清空）。
  final AuthFailure? failure;

  /// 是否已登录。
  bool get isLoggedIn => status == AuthStatus.authenticated && user != null;

  /// 是否正在恢复会话。
  bool get isRestoring => status == AuthStatus.restoring;

  /// 是否有请求在飞。
  bool get busy => sendingCode || loggingIn;

  /// 是否在倒计时中。
  bool get inCooldown => cooldownSeconds > 0;

  /// 是否可以发码（不在冷却、没有请求在飞）。
  bool get canSendCode => !inCooldown && !sendingCode && !loggingIn;

  /// 浅拷贝。`clearFailure` 用来主动清空失败（`null` 语义会与"保持原值"冲突）。
  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? sendingCode,
    bool? loggingIn,
    int? cooldownSeconds,
    AuthFailure? failure,
    bool clearFailure = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      sendingCode: sendingCode ?? this.sendingCode,
      loggingIn: loggingIn ?? this.loggingIn,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  String toString() =>
      'AuthState(${status.name}, user: $user, cooldown: $cooldownSeconds, '
      'failure: $failure)';
}
