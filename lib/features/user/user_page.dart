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
import 'application/sign_in_providers.dart';
import 'data/planstar_user_api.dart';
import '../../l10n/l10n.dart';

/// 我的 Tab（`layout_user.xml`）。
///
/// ## 结构（自上而下）
///
/// 1. 渐变头 + 103dp 白色资料卡（圆角 12）：56dp 头像、14sp 昵称、等级标、
///    卡片底部「支持过 / 关注」两列（20sp 粗体数字 + 12sp 文案 + 1dp 竖线）；
/// 2. 120dp 支持卡：「我的支持 / 全部支持」+ 四个状态入口（26dp 图标 + 12sp 文案）；
/// 3. 横向快捷区：星币商城 / 我的钱包 / 优惠券 / 礼品卡（24dp 品牌色图标 + 12sp 文案）；
/// 4. 每日签到卡；
/// 5. 分组菜单：「更多服务」地址 / 支持人 / 联系客服 / 卖家招募（58dp 行，leading 图标）；
/// 6. 登出 / 登录按钮。
///
/// ## 与 Android 的差异
///
/// - 企划星在支持卡**背后**还有一张粉色渐变的「支持过清单」卡（`list_to_watch`，
///   支持卡 `marginTop=92` 压在它上面）。本项目没有"支持过"数据源，
///   所以按 layout 里 `layoutMyOrder` 的 `goneMarginTop=17` 分支渲染。
/// - 头部渐变改用品牌语义色（`brandSubtle → bgPage`），亮/暗主题自动适配。
/// - 原资料卡右上角「个人主页」是无落地页的死入口，已移除。
class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final profile = ref.watch(userProfileProvider);
    final badges = ref.watch(userOrderBadgesProvider);
    final unread = ref.watch(messageUnreadProvider).valueOrNull ?? 0;

    void openOrders(OrderListFilter filter) {
      ref.read(orderListFilterProvider.notifier).state = filter;
      // /order 现在是「我的」下的二级页，用 push 而不是 go：
      // 返回键回到个人中心，而不是被当作一次 tab 切换。
      context.push('/order');
    }

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      // 大屏（平板/折叠屏展开）下内容居中限宽，避免卡片被拉成整屏宽条。
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView(
              // 内容不足一屏时也能触发下拉刷新。
              physics: const AlwaysScrollableScrollPhysics(),
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
                  onTapMessage: () => context.push('/message'),
                  onTapSetting: () => context.push('/settings'),
                ),
                _OrderCard(
                  badges: badges,
                  onTapAll: () => openOrders(OrderListFilter.all),
                  onTapStatus: openOrders,
                ),
                const _QuickGrid(),
                const _SignInCard(),
                // 低频设置：地址 / 支持人 / 客服 / 招募。
                _MenuGroupCard(
                  title: context.l10n.userMenuGroupMore,
                  entries: <(IconData, String, VoidCallback)>[
                    (
                      LucideIcons.mapPin,
                      context.l10n.userPage_653,
                      () => context.push('/address'),
                    ),
                    (
                      LucideIcons.users,
                      context.l10n.userPage_654,
                      () => _toast(context, context.l10n.userPage_81),
                    ),
                    (
                      LucideIcons.headset,
                      context.l10n.userPage_655,
                      () => _toast(context, context.l10n.userPage_82),
                    ),
                    (
                      LucideIcons.megaphone,
                      context.l10n.userPage_656,
                      () => _toast(context, context.l10n.userPage_83),
                    ),
                  ],
                ),
                if (profile.isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                            borderRadius: BorderRadius.circular(AppRadius.md),
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () => context.push('/login?from=%2Fme'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.brand,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 下拉刷新：资料、订单角标、未读数三路一起重拉，单接口失败不阻断。
  static Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(orderListProvider);
    ref.invalidate(remoteProfileProvider);
    ref.invalidate(messageUnreadProvider);
    try {
      await Future.wait<void>(<Future<void>>[
        ref.read(orderListProvider.future),
        ref.read(remoteProfileProvider.future),
        ref.read(messageUnreadProvider.future),
      ]);
    } catch (_) {
      // 任一接口失败不阻断下拉刷新结束。
    }
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
  });

  final UserProfile profile;
  final int unread;
  final VoidCallback onTapAvatar;
  final VoidCallback onTapMessage;
  final VoidCallback onTapSetting;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      // 上方留白给状态栏与图标，下面才是 103dp 卡片 + 16dp 边距。
      padding: EdgeInsets.only(top: topPadding, bottom: 16),
      decoration: BoxDecoration(
        // 品牌语义色渐变：品牌淡色 → 页面背景，亮/暗色主题自动适配
        //（不再是硬编码的粉色）。
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[colors.brandSubtle, colors.bgPage],
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 48,
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
                    // IconButton 保证 ≥48dp 触控热区 + 按压反馈，
                    // 替代原来的裸 GestureDetector（热区仅 20dp）。
                    child: IconButton(
                      onPressed: onTapMessage,
                      icon: Icon(
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
            // 企业级资料卡结构（对齐起点/bilibili「我的」页）：上部身份区
            //（头像光环 + 昵称 + 等级胶囊），分隔线，下部统计区（支持过/关注）。
            // 不用固定 103dp + Stack 定位，改为内容自适应，长昵称/大字号不裁剪。
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colors.border.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                // ── 身份区：头像（品牌光环）+ 昵称 + 等级/占位 ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: onTapAvatar,
                        child: Container(
                          // 头像外圈 2dp 品牌色光环，弱光下也能一眼识别身份区。
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.brand,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: _Avatar(profile: profile, colors: colors),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
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
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppTypography.subtitle,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (!profile.isLoggedIn)
                              Text(
                                context.l10n.userPage_254,
                                style: TextStyle(
                                  fontSize: AppTypography.caption,
                                  color: colors.textTertiary,
                                ),
                              )
                            else if (profile.levelLabel.isNotEmpty ||
                                profile.level > 0)
                              // 等级胶囊：品牌淡底 + 品牌描边 + 品牌文字。
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.brandSubtle,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                  border: Border.all(
                                    color: colors.brand,
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
                                    fontSize: AppTypography.label,
                                    height: 1.2,
                                    color: colors.brand,
                                  ),
                                ),
                              )
                            else if (profile.mobileLabel != null)
                              // 没有等级（`level == 0`）时用脱敏手机号占位，
                              // 比显示"点击登录"（已经登录了）合理。
                              Text(
                                profile.mobileLabel!,
                                style: TextStyle(
                                  fontSize: AppTypography.caption,
                                  color: colors.textTertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ── 分隔线 ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(height: 1, color: colors.divider),
                ),
                // ── 统计区：支持过 / 关注 ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
          // 数字用令牌字号（title=20）+ 等宽数字特性，避免多位数跳动。
          style: AppTypography.numeric(
            size: AppTypography.title,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.caption,
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
      // 边距对齐间距令牌（16），原 layout 的 17/8.5 不在 4 基准阶梯上。
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          // 整行可点：「全部支持」入口，热区覆盖整行而不是只有右侧箭头。
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapAll,
            child: Row(
              children: <Widget>[
                Text(
                  context.l10n.orderListTitle,
                  style: TextStyle(
                    fontSize: AppTypography.body,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  context.l10n.userPage_483,
                  style: TextStyle(
                    fontSize: AppTypography.body,
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

/// 每日签到卡。
class _SignInCard extends ConsumerWidget {
  const _SignInCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final profile = ref.watch(userProfileProvider);
    final status =
        ref.watch(signInStatusProvider).valueOrNull ?? SignInStatus.guest;
    final submitting = ref.watch(signInControllerProvider);
    final label = status.signed
        ? context.l10n.signInDone
        : context.l10n.signInReward(status.todayReward);

    Future<void> handleTap() async {
      if (!profile.isLoggedIn) {
        context.push('/login?from=%2Fme');
        return;
      }
      final result = await ref.read(signInControllerProvider.notifier).submit();
      if (!context.mounted) return;
      if (result.success) {
        final reward = result.status?.todayReward ?? status.todayReward;
        UserPage._toast(context, context.l10n.signInSuccess('$reward'));
      } else {
        UserPage._toast(
          context,
          result.errorMessage ?? context.l10n.signInFailed,
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: status.signed || submitting ? null : handleTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(LucideIcons.calendarCheck, size: 22, color: colors.brand),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: status.signed
                        ? colors.textTertiary
                        : colors.textPrimary,
                  ),
                ),
              ),
              if (submitting)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.brand,
                  ),
                )
              else
                Icon(
                  status.signed
                      ? LucideIcons.circleCheck
                      : LucideIcons.chevronRight,
                  size: 18,
                  color: colors.textDisabled,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 横向图标快捷区：星币商城 / 我的钱包 / 礼品卡。
///
/// 整格可点（InkWell 按压反馈，热区 ≥48dp），品牌色图标 + caption 文案。
/// 优惠券入口已按产品要求暂时隐藏（路由 `/coupons` 保留，恢复时加回）。
class _QuickGrid extends StatelessWidget {
  const _QuickGrid();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final List<(IconData, String, VoidCallback)> entries = <(
      IconData,
      String,
      VoidCallback,
    )>[
      (
        LucideIcons.store,
        context.l10n.userMenuMall,
        () => context.push('/mall'),
      ),
      (
        LucideIcons.wallet,
        context.l10n.userPage_580,
        () => context.push('/wallet'),
      ),
      (
        LucideIcons.gift,
        context.l10n.userPage_650,
        () => context.push('/giftcards'),
      ),
    ];
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: <Widget>[
          for (final (IconData icon, String label, VoidCallback onTap)
              in entries)
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: SizedBox(
                  height: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(icon, size: 24, color: colors.brand),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: AppTypography.caption,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 分组菜单卡（对齐 bilibili / 起点「我的」的信息层级：分组标题 + 带图标行）。
///
/// 分组标题用 caption 字号 + 三级文字色；行沿用 [PsCell]（58dp 高、16dp 左右
/// 内边距、leading 图标 18dp、右侧 18dp 箭头）。
class _MenuGroupCard extends StatelessWidget {
  const _MenuGroupCard({required this.title, required this.entries});

  final String title;

  /// (leading 图标, 行文案, 点击回调)。
  final List<(IconData, String, VoidCallback)> entries;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: AppTypography.caption,
              color: colors.textTertiary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.bgCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              for (var i = 0; i < entries.length; i++)
                PsCell(
                  leading: Icon(
                    entries[i].$1,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  label: entries[i].$2,
                  onTap: entries[i].$3,
                  horizontalPadding: AppSpacing.md,
                  showDivider: i != entries.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
