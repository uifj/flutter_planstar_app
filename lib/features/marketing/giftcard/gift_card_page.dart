import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui/ps_empty_state.dart';
import 'gift_card.dart';
import 'gift_card_providers.dart';
import '../../../l10n/marketing_localizations.dart';

/// 礼品卡列表页。
///
/// ## 与 Android 的差异
///
/// - 企划星 `GiftCardActivity` 是单列表 + pick 模式。这里拆成"可用 / 不可用"
///   两个 Section，更清晰。pick 模式（下单时选礼品卡抵扣）后续在确认订单页实现。
/// - 卡片颜色分级对齐 Android：≤100 绿、≤200 蓝、≤500 黄、≤1000 红、>1000 黑。
/// - 绑定入口在 AppBar 右侧「+」，对齐 Android `AddGiftCardActivity`。
class GiftCardPage extends ConsumerWidget {
  const GiftCardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCards = ref.watch(activeGiftCardsProvider);
    final inactiveCards = ref.watch(inactiveGiftCardsProvider);

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: MarketingLocalizations.of(context).giftCardPage_30,
        actions: <AdaptiveAppBarAction>[
          AdaptiveAppBarAction(
            icon: LucideIcons.plus,
            label: MarketingLocalizations.of(context).giftCardPage_34,
            onPressed: () => context.push('/giftcards/add'),
          ),
        ],
      ),
      body: activeCards.isEmpty && inactiveCards.isEmpty
          ? PsEmptyState(
              title: MarketingLocalizations.of(context).giftCardPage_41,
              description: MarketingLocalizations.of(context).giftCardPage_42,
              icon: LucideIcons.gift,
            )
          : ListView(
              children: <Widget>[
                if (activeCards.isNotEmpty) ...<Widget>[
                  _SectionHeader(
                    title: MarketingLocalizations.of(context).giftCardPage_49,
                    count: activeCards.length,
                  ),
                  for (final card in activeCards) _GiftCardItem(card: card),
                  const SizedBox(height: 12),
                ],
                if (inactiveCards.isNotEmpty) ...<Widget>[
                  _SectionHeader(
                    title: MarketingLocalizations.of(context).giftCardPage_57,
                    count: inactiveCards.length,
                  ),
                  for (final card in inactiveCards) _GiftCardItem(card: card),
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

/// Section 标题。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: TextStyle(fontSize: 13, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// 礼品卡卡片。
///
/// 对齐 Android `item_giftcard.xml`：
/// 左侧面值色块 + 右侧标题/描述/余额/到期。
/// 色块颜色按面值分级。
class _GiftCardItem extends StatelessWidget {
  const _GiftCardItem({required this.card});

  final GiftCard card;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final cardColor = _cardColor(card, colors);
    final isInactive = card.status != GiftCardStatus.active;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // 面值色块
          Container(
            width: 80,
            height: 90,
            decoration: BoxDecoration(
              color: isInactive ? colors.textDisabled : cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  card.denomination.format(withSymbol: false),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  MarketingLocalizations.of(context).giftCardPage_158,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // 右侧信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    card.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Text(
                        MarketingLocalizations.of(context).giftCardPage_196,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                      Text(
                        card.balance.format(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isInactive
                              ? colors.textTertiary
                              : colors.brand,
                        ),
                      ),
                      const Spacer(),
                      if (card.isExpiringSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            MarketingLocalizations.of(context).giftCardPage_224,
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.expiryLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 面值对应的颜色。
  /// 对齐 Android：≤100 绿、≤200 蓝、≤500 黄、≤1000 红、>1000 黑。
  Color _cardColor(GiftCard card, AppColors colors) {
    final yuan = card.denomination.minorUnits ~/ 100;
    if (yuan <= 100) return const Color(0xFF4CAF50);
    if (yuan <= 200) return const Color(0xFF2196F3);
    if (yuan <= 500) return const Color(0xFFFFC107);
    if (yuan <= 1000) return const Color(0xFFF44336);
    return const Color(0xFF333333);
  }
}
