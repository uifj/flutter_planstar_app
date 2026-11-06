import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_badge.dart';
import '../../shared/ui/ps_cell.dart';
import '../../shared/ui/ps_floating_tab_bar.dart';
import '../auth/application/auth_providers.dart';
import '../message/application/message_providers.dart';
import '../order/application/order_list_controller.dart';
import '../order/order_l10n.dart';
import 'application/profile_providers.dart';
import '../../l10n/l10n.dart';

/// 我的 Tab（`layout_user.xml`）。
///
/// ## 结构（自上而下）
///
/// 1. 渐变头 + 103dp 白色资料卡（圆角 14）：56dp 头像、14sp 昵称、18dp 等级标、
///    卡片底部「想看 / 关注」两列（18sp 粗体数字 + 12sp 文案 + 1dp 竖线）；
/// 2. 120dp 订单卡：「我的订单 / 全部订单」+ 四个状态入口（26dp 图标 + 12sp 文案）；
/// 3. 66dp 资产卡：「优惠券 / 我的钱包」两个品牌色数字；
/// 4. 菜单卡：地址管理 / 观演人 / 联系客服 / 卖家招募（58dp 行）。
///
/// ## 与 Android 的差异
///
/// - 企划星在订单卡**背后**还有一张粉色渐变的「想看清单」卡（`list_to_watch`，
///   订单卡 `marginTop=92` 压在它上面）。本项目没有"想看"数据源，
///   所以按 layout 里 `layoutMyOrder` 的 `goneMarginTop=17` 分支渲染。
/// - 资料卡右上角的「个人主页」入口没有落地页（那是个人主页，不在本次范围内），
///   点它只提示。
class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final profile = ref.watch(userProfileProvider);
    final badges = ref.watch(userOrderBadgesProvider);
    final unread = ref.watch(messageUnreadProvider);

    void openOrders(OrderListFilter filter) {
      ref.read(orderListFilterProvider.notifier).state = filter;
      context.go('/order');
    }

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      body: ListView(
        padding: EdgeInsets.only(
          bottom: PsFloatingTabBar.bottomClearance(context),
        ),
        children: <Widget>[
          _ProfileHeader(
            profile: profile,
            unread: unread,
            onTapAvatar: () {
              if (profile.isLoggedIn) {
                context.push('/me/edit-profile');
              } else {
                context.push('/login?from=%2Fme');
              }
            },
            onTapMessage: () => context.go('/message'),
            onTapSetting: () => context.push('/settings'),
            onTapHome: () => _toast(context, context.l10n.userPage_67),
          ),
          _OrderCard(
            badges: badges,
            onTapAll: () => openOrders(OrderListFilter.all),
            onTapStatus: openOrders,
          ),
          _AssetsCard(
            profile: profile,
            onTapCoupon: () => context.push('/coupons'),
            onTapWallet: () => context.push('/wallet'),
          ),
          _MenuCard(
            onTapAddress: () => context.push('/address'),
            onTapVisitors: () => _toast(context, context.l10n.userPage_81),
            onTapService: () => _toast(context, context.l10n.userPage_82),
            onTapBusiness: () => _toast(context, context.l10n.userPage_83),
            onTapGiftCard: () => context.push('/giftcards'),
            onTapProxyBuy: () => context.push('/proxy-buy'),
            onTapGroupBuy: () => context.push('/group-buy'),
          ),
          if (profile.isLoggedIn)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 24),
              child: SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: () {
                    // 真实登出：清掉 psSession 令牌 + 本地资料，并让路由门禁
                    // 立刻把受保护页弹回登录页。
                    ref.read(authControllerProvider.notifier).logout();
                    _toast(context, context.l10n.userPage_98);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: colors.bgCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.userLogout,
                    style: TextStyle(fontSize: 16, color: colors.error),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 24),
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () => context.push('/login?from=%2Fme'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.brand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.authLoginTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 66),
        ],
      ),
    );
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 渐变头 + 资料卡（`view_user_info.xml`）。
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.unread,
    required this.onTapAvatar,
    required this.onTapMessage,
    required this.onTapSetting,
    required this.onTapHome,
  });

  final UserProfile profile;
  final int unread;
  final VoidCallback onTapAvatar;
  final VoidCallback onTapMessage;
  final VoidCallback onTapSetting;
  final VoidCallback onTapHome;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      // 上方 67dp 是纯背景区（企划星留白给状态栏与图标），下面才是 103dp 卡片 + 15dp 边距。
      padding: EdgeInsets.only(top: topPadding, bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[const Color(0xFFFFE4EE), colors.bgPage],
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  onPressed: onTapSetting,
                  icon: Icon(
                    LucideIcons.settings,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PsBadgeAnchor(
                    count: unread,
                    offset: const Offset(8, -4),
                    child: GestureDetector(
                      onTap: onTapMessage,
                      child: Icon(
                        LucideIcons.mail,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 103,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: <Widget>[
                // 左：头像 + 昵称 + 等级
                Positioned(
                  left: 15,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: onTapAvatar,
                        child: ClipOval(
                          // 登录后显示服务端头像；没设置头像（`avatar` 为空串）
                          // 或加载失败时回落到默认图，不要留一个破图。
                          child: _Avatar(profile: profile, colors: colors),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            profile.nickname.isEmpty
                                ? (profile.isLoggedIn
                                      ? context.l10n.authUser_119
                                      : context.l10n.profileProviders_58)
                                : profile.nickname,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 7),
                          if (!profile.isLoggedIn)
                            Text(
                              context.l10n.userPage_254,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textTertiary,
                              ),
                            )
                          else if (profile.levelLabel.isNotEmpty ||
                              profile.level > 0)
                            Container(
                              constraints: const BoxConstraints(minHeight: 18),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: colors.border,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                profile.levelLabel.isNotEmpty
                                    ? profile.levelLabel
                                    : context.l10n.profileProviders_86(
                                        profile.level,
                                      ),
                                style: TextStyle(
                                  fontSize: 10,
                                  height: 1.2,
                                  color: colors.textPrimary,
                                ),
                              ),
                            )
                          else if (profile.mobileLabel != null)
                            // 没有等级（`level == 0`）时用脱敏手机号占位，
                            // 比显示"点击登录"（已经登录了）合理。
                            Text(
                              profile.mobileLabel!,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 右上：个人主页
                Positioned(
                  right: 10,
                  top: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTapHome,
                    child: Row(
                      children: <Widget>[
                        Text(
                          context.l10n.userPage_308,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textPrimary,
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 14,
                          color: colors.textDisabled,
                        ),
                      ],
                    ),
                  ),
                ),
                // 底部：想看 / 关注
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _StatColumn(
                          value: profile.wannaSeeCount,
                          label: context.l10n.userPage_333,
                        ),
                      ),
                      Container(width: 1, height: 18, color: colors.border),
                      Expanded(
                        child: _StatColumn(
                          value: profile.followCount,
                          label: context.l10n.userPage_340,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 56dp 圆形头像：服务端 URL 优先，为空或加载失败时回落默认图。
class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile, required this.colors});

  final UserProfile profile;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final Widget fallback = Image.network(
      profile.avatarFallbackUrl,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: 56,
        height: 56,
        color: colors.brandSubtle,
        child: Icon(LucideIcons.user, color: colors.brand),
      ),
    );

    final String? url = profile.avatarUrl;
    if (url == null) {
      return fallback;
    }
    return Image.network(
      url,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      // 弱网/图片挂了都不能留一个破图占位。
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '$value',
          style: TextStyle(
            fontSize: 18,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 1.1,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// 订单卡（`view_user_order.xml` 的 `layoutMyOrder`，120dp）。
class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.badges,
    required this.onTapAll,
    required this.onTapStatus,
  });

  final Map<OrderListFilter, int> badges;
  final VoidCallback onTapAll;
  final void Function(OrderListFilter filter) onTapStatus;

  static const List<(OrderListFilter, IconData)> _entries =
      <(OrderListFilter, IconData)>[
        (OrderListFilter.awaitingPayment, LucideIcons.wallet),
        (OrderListFilter.awaitingTickets, LucideIcons.package),
        (OrderListFilter.ticketsInTransit, LucideIcons.truck),
        (OrderListFilter.awaitingReview, LucideIcons.star),
      ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      height: 120,
      // layoutMyOrder 在 list_to_watch 为 gone 时用 marginTop=17。
      margin: const EdgeInsets.only(top: 17, left: 8.5, right: 8.5),
      padding: const EdgeInsets.symmetric(horizontal: 21),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 25),
          Row(
            children: <Widget>[
              Text(
                context.l10n.orderListTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTapAll,
                child: Row(
                  children: <Widget>[
                    Text(
                      context.l10n.userPage_483,
                      style: TextStyle(fontSize: 14, color: colors.textPrimary),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 14,
                      color: colors.textDisabled,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                for (final (filter, icon) in _entries)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTapStatus(filter),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          PsBadgeAnchor(
                            count: badges[filter] ?? 0,
                            offset: const Offset(10, -4),
                            child: Icon(
                              icon,
                              size: 26,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filter.labelOf(context),
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.1,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 资产卡（66dp）。
class _AssetsCard extends StatelessWidget {
  const _AssetsCard({
    required this.profile,
    required this.onTapCoupon,
    required this.onTapWallet,
  });

  final UserProfile profile;
  final VoidCallback onTapCoupon;
  final VoidCallback onTapWallet;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      height: 66,
      margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapCoupon,
              child: _AssetColumn(
                value: '${profile.couponCount}',
                label: context.l10n.userPage_569,
              ),
            ),
          ),
          Container(width: 1, height: 18, color: colors.border),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapWallet,
              child: _AssetColumn(
                value: profile.walletBalance.format(withSymbol: false),
                label: context.l10n.userPage_580,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetColumn extends StatelessWidget {
  const _AssetColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          value,
          maxLines: 1,
          style: TextStyle(
            fontSize: 18,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: colors.brand,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 1.1,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// 菜单卡（`view_user_menu.xml`）。
class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.onTapAddress,
    required this.onTapVisitors,
    required this.onTapService,
    required this.onTapBusiness,
    required this.onTapGiftCard,
    required this.onTapProxyBuy,
    required this.onTapGroupBuy,
  });

  final VoidCallback onTapAddress;
  final VoidCallback onTapVisitors;
  final VoidCallback onTapService;
  final VoidCallback onTapBusiness;
  final VoidCallback onTapGiftCard;
  final VoidCallback onTapProxyBuy;
  final VoidCallback onTapGroupBuy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final entries = <(String, VoidCallback)>[
      (context.l10n.userPage_650, onTapGiftCard),
      (context.l10n.userPage_651, onTapProxyBuy),
      (context.l10n.userPage_652, onTapGroupBuy),
      (context.l10n.userPage_653, onTapAddress),
      (context.l10n.userPage_654, onTapVisitors),
      (context.l10n.userPage_655, onTapService),
      (context.l10n.userPage_656, onTapBusiness),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (var i = 0; i < entries.length; i++)
            PsCell(
              label: entries[i].$1,
              onTap: entries[i].$2,
              showDivider: i != entries.length - 1,
            ),
        ],
      ),
    );
  }
}
