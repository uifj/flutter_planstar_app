import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import '../../shared/ui/ps_poster.dart';
import '../../shared/ui/ps_price.dart';
import '../../shared/ui/ps_tag.dart';
import '../catalog/application/catalog_providers.dart';
import '../catalog/domain/show_summary.dart';
import '../catalog/ui/catalog_l10n.dart';
import '../../l10n/l10n.dart';

/// 选档页。
///
/// ## 在支持漏斗中的位置
///
/// 企划详情 → **选档页** → 确认支持 → 支付
///
/// 详情页的「立即支持」跳到这里，而不是直接跳确认支持：
/// 确认支持需要知道「选了哪个线下回报场次、哪个回报档位、几份」，这些选择就发生在这一页。
///
/// ## 刻意不做的事
///
/// - 选档有"聚合选档 / 座席图 / 档位表"三种形态，本页只做**聚合选档**（普通支持）：
///   不内嵌座席图（需要地图引擎，不做假实现，选座走独立的降级座位图页），
///   也不做档位表（只是另一种排列，数据源相同）。
/// - 不加 15 分钟选档倒计时（到时自动返回）：
///   演示数据没有真实的库存锁定，倒计时只会给用户制造不必要的焦虑。
/// - 不做「代抢 / 组队支持」两个分支 tab：代抢属遗留票务能力（待下线），
///   组队支持走独立的 `group_buy` 链路，不在选档页分叉。
class ChooseTicketPage extends ConsumerStatefulWidget {
  const ChooseTicketPage({super.key, required this.showId});

  final String showId;

  @override
  ConsumerState<ChooseTicketPage> createState() => _ChooseTicketPageState();
}

class _ChooseTicketPageState extends ConsumerState<ChooseTicketPage> {
  /// 选中的线下回报场次索引（`-1` = 未选）。
  int _selectedSession = -1;

  /// 选中的回报档位索引（`-1` = 未选）。
  int _selectedTier = -1;

  /// 支持份数。
  int _quantity = 1;

  /// 单笔支持上限（从回报档位的 `remaining` 或默认 6 取较小值）。
  int get _maxQuantity {
    final show = ref.read(showFullProvider(widget.showId));
    if (show == null || show.tiers.isEmpty) return 6;
    final tier = _selectedTier >= 0 ? show.tiers[_selectedTier] : null;
    if (tier == null) return 6;
    // 单笔支持上限通常是 6 份（见 `purchase_limit_policy.dart`）。
    // 如果余量更少，以余量为准。
    final remaining = tier.remaining;
    if (remaining != null && remaining > 0) {
      return remaining < 6 ? remaining : 6;
    }
    return 6;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final show = ref.watch(showFullProvider(widget.showId));

    if (show == null) {
      return AdaptiveScaffold(
        appBar: AdaptiveAppBar(title: context.l10n.chooseTicketPage_71),
        body: PsEmptyState(
          title: context.l10n.chooseTicketPage_73,
          description: context.l10n.chooseTicketPage_74(widget.showId),
          icon: LucideIcons.calendarX,
          actionLabel: context.l10n.chooseTicketPage_76,
          onAction: () => context.pop(),
        ),
      );
    }

    final sessions = show.sessions;
    final tiers = show.tiers;
    final hasOfflineSession = tiers.any(
      (TicketTier tier) => tier.rewardType == '线下参与',
    );

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(
        title: show.title.length > 14
            ? '${show.title.substring(0, 14)}…'
            : show.title,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ShowInfoCard(show: show),
                  if (hasOfflineSession) ...<Widget>[
                    if (sessions.isNotEmpty) ...<Widget>[
                      _SectionTitle(title: context.l10n.chooseTicketPage_100),
                      _SessionList(
                        sessions: sessions,
                        selectedIndex: _selectedSession,
                        onSelect: (index) => setState(() {
                          _selectedSession = index;
                        }),
                      ),
                    ] else ...<Widget>[
                      _SectionTitle(title: context.l10n.chooseTicketPage_109),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                        child: Text(
                          show.firstSessionLabelOf(context),
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                  _SectionTitle(title: context.l10n.chooseTicketPage_122),
                  if (tiers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                      child: Text(
                        context.l10n.chooseTicketPage_127,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textTertiary,
                        ),
                      ),
                    )
                  else
                    _TierList(
                      tiers: tiers,
                      selectedIndex: _selectedTier,
                      onSelect: (index) => setState(() {
                        _selectedTier = index;
                        // 切回报档位时重置份数，避免超过新档位的余量。
                        _quantity = 1;
                      }),
                    ),
                  if (_selectedTier >= 0) ...<Widget>[
                    _SectionTitle(title: context.l10n.chooseTicketPage_142),
                    _QuantitySelector(
                      quantity: _quantity,
                      min: 1,
                      max: _maxQuantity,
                      onChanged: (value) => setState(() => _quantity = value),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _PurchaseNoticeCard(),
                ],
              ),
            ),
          ),
          _BottomBar(
            show: show,
            tierIndex: _selectedTier,
            quantity: _quantity,
            canProceed: _selectedTier >= 0,
            onProceed: () => _proceed(context, show),
            showId: widget.showId,
          ),
        ],
      ),
    );
  }

  void _proceed(BuildContext context, ShowSummary show) {
    if (_selectedTier < 0) {
      _toast(context, context.l10n.chooseTicketPage_171);
      return;
    }
    if (show.soldOut) {
      _toast(context, context.l10n.chooseTicketPage_175);
      return;
    }
    // 把选好的参数带到确认订单页：用 query 参数传递。
    context.push(
      '/order/confirm?showId=${widget.showId}'
      '&tier=$_selectedTier'
      '&qty=$_quantity'
      '${_selectedSession >= 0 ? '&session=$_selectedSession' : ''}',
    );
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 企划信息卡（头部）。
class _ShowInfoCard extends StatelessWidget {
  const _ShowInfoCard({required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 12, 15, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          PsPoster(seed: show.title, width: 60, height: 80, radius: 4),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  show.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Icon(
                      show.venueLabel.isEmpty
                          ? LucideIcons.user
                          : LucideIcons.mapPin,
                      size: 12,
                      color: colors.textTertiary,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        show.venueLabel.isEmpty ? show.artist : show.venueLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Icon(
                      LucideIcons.clock,
                      size: 12,
                      color: colors.textTertiary,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        show.isProject
                            ? '${context.l10n.projectDeadline} · '
                                  '${formatDate(show.projectDeadline)}'
                            : '${show.firstSessionLabelOf(context)} · ${show.duration}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 段标题（16sp 粗体 + 左侧品牌色竖线）。
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: colors.brand,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 线下回报场次列表（水平横滑卡片，仅线下活动型企划展示）。
class _SessionList extends StatelessWidget {
  const _SessionList({
    required this.sessions,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<ShowSession> sessions;
  final int selectedIndex;
  final void Function(int index) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: sessions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final session = sessions[index];
          final selected = index == selectedIndex;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: session.soldOut ? null : () => onSelect(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? colors.brandSubtle : colors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? colors.brand : colors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    formatSessionLabelL10n(context, session.startsAt),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: session.soldOut
                          ? colors.textDisabled
                          : selected
                          ? colors.brand
                          : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.soldOut
                        ? context.l10n.chooseTicketPage_355
                        : session.tierSummary,
                    style: TextStyle(
                      fontSize: 11,
                      color: session.soldOut
                          ? colors.textDisabled
                          : colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 回报档位列表（纵向卡片）。
class _TierList extends StatelessWidget {
  const _TierList({
    required this.tiers,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<TicketTier> tiers;
  final int selectedIndex;
  final void Function(int index) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < tiers.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: tiers[i].soldOut ? null : () => onSelect(i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: i == selectedIndex
                      ? colors.brandSubtle
                      : colors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: i == selectedIndex ? colors.brand : colors.border,
                    width: i == selectedIndex ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                tiers[i].name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: tiers[i].soldOut
                                      ? colors.textDisabled
                                      : colors.textPrimary,
                                ),
                              ),
                              if (tiers[i].note != null) ...<Widget>[
                                const SizedBox(width: 6),
                                PsTag(
                                  label: tiers[i].note!,
                                  tone: PsTagTone.solid,
                                  fontSize: 9,
                                ),
                              ],
                            ],
                          ),
                          if (tiers[i].remaining != null &&
                              tiers[i].remaining! > 0 &&
                              tiers[i].remaining! <= 10)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                context.l10n.chooseTicketPage_439(
                                  tiers[i].remaining!,
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.price,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (tiers[i].soldOut)
                      Text(
                        context.l10n.chooseTicketPage_451,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textDisabled,
                        ),
                      )
                    else
                      PsPrice(
                        amount: tiers[i].price,
                        size: 18,
                        suffix: i == selectedIndex
                            ? context.l10n.chooseTicketPage_458
                            : null,
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

/// 数量选择器（-/+ 按钮 + 数字）。
class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int quantity;
  final int min;
  final int max;
  final void Function(int value) onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: <Widget>[
          _QtyButton(
            icon: LucideIcons.minus,
            enabled: quantity > min,
            onTap: () => onChanged(quantity - 1),
          ),
          Container(
            width: 48,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.bgCard,
              border: Border.all(color: colors.border),
            ),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
          _QtyButton(
            icon: LucideIcons.plus,
            enabled: quantity < max,
            onTap: () => onChanged(quantity + 1),
          ),
          const SizedBox(width: 12),
          Text(
            context.l10n.chooseTicketPage_520(max),
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? colors.brandSubtle : colors.bgSubtle,
          border: Border.all(color: enabled ? colors.brand : colors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? colors.brand : colors.textDisabled,
        ),
      ),
    );
  }
}

/// 支持须知卡。
class _PurchaseNoticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final notices = <String>[
      context.l10n.chooseTicketPage_569,
      context.l10n.chooseTicketPage_570,
      context.l10n.chooseTicketPage_571,
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.bgSubtle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(LucideIcons.info, size: 14, color: colors.textTertiary),
              const SizedBox(width: 4),
              Text(
                context.l10n.chooseTicketPage_588,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final notice in notices)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '· ',
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                  Expanded(
                    child: Text(
                      notice,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: colors.textTertiary,
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

/// 底部支持栏（金额 + 确认按钮）。
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.show,
    required this.tierIndex,
    required this.quantity,
    required this.canProceed,
    required this.onProceed,
    required this.showId,
  });

  final ShowSummary show;
  final int tierIndex;
  final int quantity;
  final bool canProceed;
  final VoidCallback onProceed;
  final String showId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    // 选中回报档位时显示单价 × 份数；否则显示起价。
    final tier = tierIndex >= 0 ? show.tiers[tierIndex] : null;
    final amount = tier != null ? tier.price * quantity : show.priceFrom;
    final hasOfflineSession = show.tiers.any(
      (TicketTier item) => item.rewardType == '线下参与',
    );

    return Container(
      color: colors.bgCard,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // 「选座支持」入口：仅线下回报场次型企划提供具体座席选择。
          // 选座入口放在底部栏上方而不是页顶，更符合 Flutter 习惯。
          if (hasOfflineSession)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 6, 15, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.push('/show/$showId/seat-selection'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(LucideIcons.armchair, size: 14, color: colors.brand),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.chooseTicketPage_669,
                        style: TextStyle(fontSize: 13, color: colors.brand),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Container(height: 1, color: colors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (tier != null)
                        Text(
                          '${tier.name} × $quantity',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        )
                      else
                        Text(
                          context.l10n.chooseTicketPage_697,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Row(
                        children: <Widget>[
                          Text(
                            context.l10n.chooseTicketPage_707,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                          PsPrice(amount: amount, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: canProceed ? onProceed : null,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: canProceed ? colors.price : colors.brandDisabled,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      context.l10n.chooseTicketPage_731,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: canProceed ? Colors.white : colors.textDisabled,
                      ),
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
