import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/application/auth_state.dart';
import '../../auth/domain/auth_user.dart';
import '../../marketing/coupon_providers.dart';
import '../../marketing/wallet_providers.dart';
import '../../order/application/order_list_controller.dart';
import '../../../shared/ui/ps_network_images.dart';
import '../data/planstar_user_api.dart';
import 'user_api_providers.dart';

/// 用户资料（"我的"页顶部卡片）。
///
/// 企划星的这些数字来自 `v1/user/info`（想看/关注/等级）+ `v1/coupon/count`
/// + `v1/wallet/balance` 三个接口。**登录返回的 `user` 里已经带了**
/// 昵称 / 头像 / 等级 / 想看数 / 关注数，所以这几项直接用真值；
/// 券数与余额还没接（要额外的接口），暂时给固定演示值——**不伪造接口形状**：
/// 等那两个接口接上时，这个类就是 DTO 映射的目标。
final class UserProfile {
  const UserProfile({
    required this.nickname,
    this.levelLabel = '',
    required this.wannaSeeCount,
    required this.followCount,
    required this.couponCount,
    required this.walletBalance,
    this.level = 0,
    this.avatarFallbackUrl = PsImages.defaultAvatar,
    this.avatarUrl,
    this.mobileLabel,
    this.isLoggedIn = false,
  });

  final String nickname;

  /// 服务端返回的等级标；为空时 UI 用 [level] 生成默认文案。
  final String levelLabel;

  /// 会员等级，0 表示没有等级。
  final int level;

  final int wannaSeeCount;
  final int followCount;
  final int couponCount;

  /// 钱包余额。
  final Money walletBalance;

  /// 兜底头像 URL（开源免费图床）。
  final String avatarFallbackUrl;

  /// 服务端头像 URL。空表示用户没设置头像 → 用 [avatarFallbackUrl] 里的网络图。
  final String? avatarUrl;

  /// 脱敏手机号（`138****8000`），等级未设置时顶替等级胶囊的位置。
  final String? mobileLabel;

  final bool isLoggedIn;

  /// 未登录时的占位资料。
  static const UserProfile guest = UserProfile(
    nickname: '',
    levelLabel: '',
    wannaSeeCount: 0,
    followCount: 0,
    couponCount: 0,
    walletBalance: Money.zero(),
  );
}

/// 服务端资料（真实模式）。
///
/// 失败返回 `null`，由 [userProfileProvider] 回退到登录接口返回的 `user`，
/// 这样"我的"页不会因为资料接口抖动而变空。
final remoteProfileProvider = FutureProvider<UserProfileDto?>((ref) async {
  if (ref.watch(useDemoProvider)) return null;
  final AuthState auth = ref.watch(authControllerProvider);
  if (!auth.isLoggedIn || auth.user == null) return null;

  final result = await ref.watch(planstarUserApiProvider).fetchProfile();
  return result.fold<UserProfileDto?>(
    onSuccess: (profile) => profile,
    onFailure: (_) => null,
  );
});

/// 用户资料。
///
/// 真源优先取 `GET /v1/user`；接口失败或 demo 模式时用登录返回的 `user` 兜底。
final userProfileProvider = Provider<UserProfile>((ref) {
  final AuthState auth = ref.watch(authControllerProvider);
  final AuthUser? user = auth.user;
  if (!auth.isLoggedIn || user == null) {
    return UserProfile.guest;
  }

  // 券数与钱包余额来自 marketing 域的 provider；服务端资料优先。
  final couponCount = ref.watch(couponCountProvider);
  final walletBalance = ref.watch(walletBalanceProvider);
  final remote = ref.watch(remoteProfileProvider).valueOrNull;
  final mobile = remote?.mobile;

  return UserProfile(
    nickname: remote?.nickname.isNotEmpty == true
        ? remote!.nickname
        : user.displayName,
    level: remote?.level ?? user.level,
    levelLabel: remote?.levelLabel ?? '',
    wannaSeeCount: remote?.wannaSeeCount ?? user.wantWatchNum,
    followCount: remote?.followCount ?? user.followingNum,
    couponCount: remote?.couponCount ?? couponCount,
    walletBalance: remote != null
        ? Money.fromMinorUnits(remote.walletBalance)
        : walletBalance,
    avatarUrl: remote?.avatarUrl?.isNotEmpty == true
        ? remote!.avatarUrl
        : (user.avatar.isEmpty ? null : user.avatar),
    mobileLabel: mobile != null && mobile.isNotEmpty
        ? _maskMobile(mobile)
        : user.maskedMobile,
    isLoggedIn: true,
  );
});

/// 手机号脱敏：`138****8000`。
String _maskMobile(String mobile) {
  if (mobile.length < 7) return mobile;
  return '${mobile.substring(0, 3)}****${mobile.substring(mobile.length - 4)}';
}

/// 四个订单状态入口的待处理数量（「我的订单」卡片上的小红点）。
///
/// 复用订单列表的筛选定义，保证"我的页角标"和"订单页 tab 数"永远一致——
/// 企划星这两处是分别请求的，出现过角标有数、点进去是空列表的情况。
final userOrderBadgesProvider = Provider<Map<OrderListFilter, int>>((ref) {
  final counts = ref.watch(orderStatusCountsProvider);
  return <OrderListFilter, int>{
    OrderListFilter.awaitingPayment:
        counts[OrderListFilter.awaitingPayment] ?? 0,
    OrderListFilter.awaitingTickets:
        counts[OrderListFilter.awaitingTickets] ?? 0,
    OrderListFilter.ticketsInTransit:
        counts[OrderListFilter.ticketsInTransit] ?? 0,
    OrderListFilter.awaitingReview: counts[OrderListFilter.awaitingReview] ?? 0,
  };
});
