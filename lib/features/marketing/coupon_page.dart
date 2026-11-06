import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import 'coupon.dart';
import 'coupon_providers.dart';
import '../../l10n/marketing_localizations.dart';

/// 我的优惠券页面。
///
/// ## 与 Android 的差异
///
/// - 企划星 `CouponActivity` 用两个 RecyclerView（可用 / 不可用）垂直排列，
///   不分 Tab。这里改成三 Tab（可用 / 已使用 / 已过期），对齐主流电商 App
///   的券列表范式（美团 / 淘宝），也更符合用户对"分类浏览"的心智模型。
/// - 兑换入口放在 AppBar 右上角（`IconButton`），而不是页面底部的悬浮按钮。
/// - 选择模式（pick mode）单独走 [CouponSelectionSheet]，不在这页里混。
class CouponPage extends ConsumerWidget {
  const CouponPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: AdaptiveScaffold(
        appBar: AdaptiveAppBar(
          title: MarketingLocalizations.of(context).couponPage_30,
          actions: <AdaptiveAppBarAction>[
            AdaptiveAppBarAction(
              icon: LucideIcons.circlePlus,
              label: MarketingLocalizations.of(context).couponPage_34,
              onPressed: () => context.push('/coupons/exchange'),
            ),
          ],
        ),
        body: const Column(
          children: <Widget>[
            _TabBar(),
            Expanded(child: _TabContent()),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      child: TabBar(
        tabs: <Widget>[
          for (final tab in CouponTab.values) Tab(text: tab.label),
        ],
        labelColor: colors.textPrimary,
        unselectedLabelColor: colors.textTertiary,
        indicatorColor: colors.brand,
        indicatorSize: TabBarIndicatorSize.label,
        dividerHeight: 0,
      ),
    );
  }
}

class _TabContent extends ConsumerWidget {
  const _TabContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      children: <Widget>[
        for (final tab in CouponTab.values) _CouponList(tab: tab),
      ],
    );
  }
}

class _CouponList extends ConsumerWidget {
  const _CouponList({required this.tab});

  final CouponTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = ref.watch(filteredCouponsProvider(tab));

    if (coupons.isEmpty) {
      return PsEmptyState(
        title: switch (tab) {
          CouponTab.usable => MarketingLocalizations.of(context).couponPage_97,
          CouponTab.used => MarketingLocalizations.of(context).couponPage_98,
          CouponTab.expired => MarketingLocalizations.of(context).couponPage_99,
        },
        description: switch (tab) {
          CouponTab.usable => MarketingLocalizations.of(context).couponPage_102,
          CouponTab.used => MarketingLocalizations.of(context).couponPage_103,
          CouponTab.expired => MarketingLocalizations.of(context).couponPage_104,
        },
        icon: LucideIcons.ticket,
        actionLabel: tab == CouponTab.usable ? MarketingLocalizations.of(context).couponPage_107 : null,
        onAction: tab == CouponTab.usable ? () => context.go('/') : null,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: <Widget>[
        for (final coupon in coupons) _CouponCard(coupon: coupon),
      ],
    );
  }
}

/// 单张优惠券卡片。
///
/// 对齐 Android `CouponAdapter.convert` 的排版：
/// 左侧金额/折扣大字 → 右侧标题 + 描述 + 到期时间。
class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final isUsable = coupon.status == CouponStatus.usable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: isUsable
            ? null
            : Border.all(color: colors.divider, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: <Widget>[
          // 左侧金额区
          _AmountSection(coupon: coupon, isUsable: isUsable),
          // 右侧信息区
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    coupon.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isUsable
                          ? colors.textPrimary
                          : colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    coupon.thresholdLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Text(
                        coupon.expiryLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textTertiary,
                        ),
                      ),
                      if (coupon.isExpiringSoon) ...<Widget>[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            MarketingLocalizations.of(context).couponPage_208(coupon.daysUntilExpiry),
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 左侧金额/折扣展示区。
class _AmountSection extends StatelessWidget {
  const _AmountSection({required this.coupon, required this.isUsable});

  final Coupon coupon;
  final bool isUsable;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final accentColor = isUsable ? colors.brand : colors.textDisabled;

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isUsable
            ? colors.brand.withValues(alpha: 0.06)
            : colors.bgPage,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (coupon.discountType == CouponDiscountType.amount) ...<Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                Text(
                  '${coupon.discountAmount.minorUnits ~/ 100}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ] else ...<Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  (coupon.discountRate / 10).toStringAsFixed(coupon.discountRate % 10 == 0 ? 0 : 1),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                Text(
                  MarketingLocalizations.of(context).couponPage_290,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            MarketingLocalizations.of(context).couponPage_302,
            style: TextStyle(
              fontSize: 10,
              color: accentColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
