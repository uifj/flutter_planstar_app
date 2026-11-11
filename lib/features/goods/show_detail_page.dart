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
import '../../shared/ui/ps_network_images.dart';
import '../../l10n/l10n.dart';

/// 企划详情。
///
/// ## 结构
///
/// - 顶部沉浸式头图：海报 92×124、
///   标题 14sp 白字最多 3 行、达成率与支持人数、底部 20dp 白色圆角压住；
/// - 42dp 的锚点 tab（目标进度 / 回报档位 / 进度更新 / 风险说明），点击滚动到对应段落；
/// - 内容：目标进度 → 截止/交付信息 → 保障条 → 回报档位 → 进度更新 →
///   风险说明 → 创作者信息 → 企划故事 → 支持须知 → 支持保障；
/// - 底部 46dp 支持栏：客服 / 关注 + 支持此企划。
///
/// ## 刻意不做的事
///
/// - 没有实现「代抢 / 组队支持 / 选座 / 求票浮标」四个分支：代抢与求票属于
///   遗留票务叙事（POSITIONING.md §10 待下线），选座只是线下活动型企划的
///   可选降级能力；本页只保留回报档位与线下回报场次。
class ShowDetailPage extends ConsumerStatefulWidget {
  const ShowDetailPage({super.key, required this.showId});

  final String showId;

  @override
  ConsumerState<ShowDetailPage> createState() => _ShowDetailPageState();
}

class _ShowDetailPageState extends ConsumerState<ShowDetailPage> {
  List<String> get _tabs => <String>[
    context.l10n.projectTabProgress,
    context.l10n.projectTabRewards,
    context.l10n.projectTabUpdates,
    context.l10n.projectTabRisk,
  ];

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _progressKey = GlobalKey();
  final GlobalKey _rewardsKey = GlobalKey();
  final GlobalKey _updatesKey = GlobalKey();
  final GlobalKey _riskKey = GlobalKey();
  int _tab = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpTo(int index) {
    setState(() => _tab = index);
    final key = switch (index) {
      0 => _progressKey,
      1 => _rewardsKey,
      2 => _updatesKey,
      _ => _riskKey,
    };
    final target = key.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final detail = ref.watch(showDetailProvider(widget.showId));
    final show =
        detail.valueOrNull ?? ref.watch(showByIdProvider(widget.showId));

    if (show == null) {
      return AdaptiveScaffold(
        appBar: AdaptiveAppBar(title: context.l10n.homeEntryShowDetail),
        body: PsEmptyState(
          title: context.l10n.showDetailPage_84,
          description: context.l10n.showDetailPage_85(widget.showId),
          icon: LucideIcons.calendarX,
          actionLabel: context.l10n.showDetailPage_87,
          onAction: () => context.go('/'),
        ),
      );
    }

    final topPadding = MediaQuery.paddingOf(context).top;

    return AdaptiveScaffold(
      backgroundColor: colors.bgCard,
      body: Column(
        children: <Widget>[
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _DetailHeader(
                    show: show,
                    topPadding: topPadding,
                    onBack: () => context.pop(),
                    onShare: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.showDetailPage_110)),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _AnchorTabs(
                    tabs: _tabs,
                    selected: _tab,
                    onSelect: _jumpTo,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    _ProgressSection(key: _progressKey, show: show),
                    _InfoSection(show: show),
                    _GuaranteeBanner(
                      onTap: () =>
                          _toast(context, context.l10n.showDetailPage_125),
                    ),
                    _TierSection(
                      key: _rewardsKey,
                      show: show,
                      onBuy: () => _buy(context),
                    ),
                    _UpdatesSection(key: _updatesKey, show: show),
                    _RiskSection(key: _riskKey, show: show),
                    _ReviewSection(show: show),
                    _FaqSection(show: show),
                    _CreatorSection(show: show),
                    _IntroSection(show: show),
                    _NoticeSection(show: show),
                    _ServiceGuaranteeSection(),
                    const _ReportEntry(),
                    const SizedBox(height: 24),
                  ]),
                ),
              ],
            ),
          ),
          _PurchaseBar(
            show: show,
            onService: () => _toast(context, context.l10n.showDetailPage_143),
            onWish: () => _toast(context, context.l10n.showDetailPage_144),
            onBuy: () => _buy(context),
          ),
        ],
      ),
    );
  }

  void _buy(BuildContext context) {
    final current = ref.watch(showByIdProvider(widget.showId));
    if (current != null && (!current.isFundingOpen || current.soldOut)) {
      _toast(context, context.l10n.projectSupportClosed);
      return;
    }
    // 详情页 → 选择回报档位 → 确认支持。
    // 档位与数量必须由用户选出来，不能在详情页假设默认值。
    context.push('/show/${widget.showId}/choose-ticket');
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 顶部头图。
class _DetailHeader extends SliverPersistentHeaderDelegate {
  _DetailHeader({
    required this.show,
    required this.topPadding,
    required this.onBack,
    required this.onShare,
  });

  final ShowSummary show;
  final double topPadding;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  double get maxExtent => topPadding + 230;

  @override
  double get minExtent => topPadding + 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = ((shrinkOffset) / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // 背景：海报放大 + 40% 透明压暗（遮罩 #66000000）。
        PsPoster(
          seed: show.title,
          width: double.infinity,
          height: double.infinity,
          radius: 0,
        ),
        const ColoredBox(color: Color(0x8C000000)),
        // 内容：海报 + 标题 + 评分 + 价格。
        Positioned(
          left: 15,
          right: 15,
          top: topPadding + 44,
          child: Opacity(
            opacity: (1 - t * 1.5).clamp(0.0, 1.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PsPoster(seed: show.title, width: 92, height: 124, radius: 4),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        show.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          Text(
                            context.l10n.projectCardAchievement(
                              (show.achievementPermille / 10).round(),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFB238),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.l10n.projectCardSupporters(
                              show.supporterCount,
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xCCFFFFFF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: <Widget>[
                          for (final tag in show.tags)
                            PsTag(
                              label: tag,
                              tone: PsTagTone.outline,
                              color: Colors.white,
                              fontSize: 9,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PsPrice(
                          amount: show.priceFrom,
                          size: 18,
                          suffix: context.l10n.projectSupportFrom,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 底部 20dp 白色圆角压住头图。
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        // 返回 / 分享。
        Positioned(
          left: 4,
          top: topPadding + 2,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(
              LucideIcons.chevronLeft,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          right: 4,
          top: topPadding + 2,
          child: IconButton(
            onPressed: onShare,
            icon: const Icon(LucideIcons.share, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _DetailHeader oldDelegate) =>
      oldDelegate.show.id != show.id || oldDelegate.topPadding != topPadding;
}

/// 42dp 锚点 tab。
class _AnchorTabs extends SliverPersistentHeaderDelegate {
  _AnchorTabs({
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  final List<String> tabs;
  final int selected;
  final void Function(int index) onSelect;

  @override
  double get maxExtent => 42;

  @override
  double get minExtent => 42;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      tabs[i],
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: i == selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: i == selected
                            ? colors.brand
                            : colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 24,
                      height: 2,
                      decoration: BoxDecoration(
                        color: i == selected
                            ? colors.brand
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
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

  @override
  bool shouldRebuild(covariant _AnchorTabs oldDelegate) =>
      oldDelegate.selected != selected;
}

/// 目标进度（企划详情页固定第一屏区块）。
class _ProgressSection extends StatelessWidget {
  const _ProgressSection({super.key, required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final goal = show.goalAmount;
    final raised = show.raisedAmount;
    final rate = (show.achievementPermille / 10).round();
    final days = show.remainingDays;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                context.l10n.projectCardAchievement(rate),
                style: TextStyle(
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: show.achievementPermille >= 1000
                      ? colors.price
                      : colors.brand,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  context.l10n.projectAchievement,
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
              ),
              const Spacer(),
              Text(
                show.fundingStatusValue == 'failed'
                    ? context.l10n.projectStatusFailed
                    : (days <= 0
                          ? context.l10n.projectCardEnded
                          : context.l10n.projectDaysLeft(days)),
                style: TextStyle(
                  fontSize: 12,
                  color: show.fundingStatusValue == 'failed'
                      ? colors.textDisabled
                      : colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (show.achievementPermille / 1000).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: colors.bgSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(
                show.achievementPermille >= 1000 ? colors.price : colors.brand,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricCell(
                  label: context.l10n.projectGoalAmount,
                  value: goal == null ? '—' : goal.format(withSymbol: false),
                ),
              ),
              Expanded(
                child: _MetricCell(
                  label: context.l10n.projectRaisedAmount,
                  value: raised == null
                      ? '—'
                      : raised.format(withSymbol: false),
                ),
              ),
              Expanded(
                child: _MetricCell(
                  label: context.l10n.projectSupporters,
                  value: '${show.supporterCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: colors.textTertiary)),
      ],
    );
  }
}

/// 企划截止与交付信息。
class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    // 企划没有活动场地：用交付计划占位，避免出现空白信息块。
    final hasVenue = show.venue.isNotEmpty || show.venueAddress.isNotEmpty;
    final infoTitle = hasVenue ? show.venue : show.deliveryPlan;
    final infoSubtitle = hasVenue ? show.venueAddress : '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${context.l10n.projectDeadline} · '
                  '${formatDate(show.projectDeadline)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                _fundingStatusLabel(context, show),
                style: TextStyle(fontSize: 12, color: colors.price),
              ),
            ],
          ),
          if (infoTitle.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(LucideIcons.truck, size: 16, color: colors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        infoTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (infoSubtitle.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          infoSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 支持保障条（34dp）。
class _GuaranteeBanner extends StatelessWidget {
  const _GuaranteeBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDAE9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              Icon(LucideIcons.badgeCheck, size: 20, color: colors.price),
              const SizedBox(width: 4),
              Text(
                context.l10n.showDetailPage_473,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.price,
                ),
              ),
              Container(
                width: 1,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: colors.border,
              ),
              Expanded(
                child: Text(
                  context.l10n.showDetailPage_488,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 14, color: colors.brand),
            ],
          ),
        ),
      ),
    );
  }
}

/// 回报档位（详情页的「选择回报」段）。
class _TierSection extends StatelessWidget {
  const _TierSection({super.key, required this.show, required this.onBuy});

  final ShowSummary show;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.projectRewardsTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (show.tiers.isEmpty)
            Text(
              context.l10n.projectRewardsEmpty,
              style: TextStyle(fontSize: 13, color: colors.textTertiary),
            ),
          for (final tier in show.tiers)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: tier.soldOut || !show.isFundingOpen ? null : onBuy,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.bgSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  tier.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              if (tier.rewardType.isNotEmpty)
                                PsTag(
                                  label: tier.rewardType,
                                  fontSize: 9,
                                  radius: 2,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                ),
                            ],
                          ),
                          if (tier.items.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              tier.items.join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.5,
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                          if (tier.note != null) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              tier.note!,
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                          if (tier
                              .estimatedDeliveryTime
                              .isNotEmpty) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.projectRewardDelivery(
                                tier.estimatedDeliveryTime,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (tier.soldOut)
                      Text(
                        context.l10n.projectSupportClosed,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textDisabled,
                        ),
                      )
                    else
                      PsPrice(amount: tier.price, size: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 进度更新（企划详情页固定区块）。
class _UpdatesSection extends StatelessWidget {
  const _UpdatesSection({super.key, required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.projectUpdatesTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (show.updates.isEmpty)
            Text(
              context.l10n.projectUpdatesEmpty,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: colors.textTertiary,
              ),
            ),
          for (final update in show.updates)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          update.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      if (update.publishTime != null)
                        Text(
                          formatDate(update.publishTime!),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    update.content,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: colors.textSecondary,
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

/// 风险说明（企划详情页固定区块）。
class _RiskSection extends StatelessWidget {
  const _RiskSection({super.key, required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final refundText = show.refundRule.isEmpty
        ? ''
        : '${show.refundRule}（${context.l10n.projectRefundArrival(show.refundDays)}）';
    final entries = <(String, String)>[
      (context.l10n.projectRiskNote, show.riskNote),
      (context.l10n.projectDeliveryPlan, show.deliveryPlan),
      (context.l10n.projectFundUsage, show.fundUsage),
      (context.l10n.projectRefundRule, refundText),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.projectRiskTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (show.riskNote.isEmpty && show.deliveryPlan.isEmpty)
            Text(
              context.l10n.projectRiskEmpty,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: colors.textTertiary,
              ),
            ),
          for (final (label, value) in entries)
            if (value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: colors.textSecondary,
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

/// 评价晒单（企划详情页固定区块，仅展示最近 3 条）。
class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final reviews = show.reviews.take(3).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                context.l10n.projectReviewsTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              if (show.reviewCount > 0)
                Text(
                  context.l10n.projectReviewsSummary(
                    show.ratingAverage.toStringAsFixed(1),
                    show.reviewCount,
                    show.showCount,
                  ),
                  style: TextStyle(fontSize: 11, color: colors.textTertiary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            Text(
              context.l10n.projectReviewsEmpty,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: colors.textTertiary,
              ),
            )
          else
            for (final review in reviews)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.bgSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            review.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '★' * review.rating,
                          style: TextStyle(fontSize: 11, color: colors.price),
                        ),
                        if (review.isShow) ...<Widget>[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: colors.bgSubtle,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              context.l10n.projectReviewShowBadge,
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.brand,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (review.likeCount > 0)
                          Text(
                            '♥ ${review.likeCount}',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                    if (review.content.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        review.content,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// 常见问题（企划详情页固定区块）。
class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.projectFaqTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (show.faqs.isEmpty)
            Text(
              context.l10n.projectFaqEmpty,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: colors.textTertiary,
              ),
            )
          else
            for (final faq in show.faqs)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      faq.question,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      faq.answer,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: colors.textSecondary,
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

/// 举报入口（P2 风控）：选择原因后提交，当前为客户端演示反馈。
class _ReportEntry extends StatelessWidget {
  const _ReportEntry();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
      child: Center(
        child: GestureDetector(
          onTap: () => _showReportSheet(context),
          child: Text(
            context.l10n.projectReportEntry,
            style: TextStyle(
              fontSize: 12,
              color: colors.textTertiary,
              decoration: TextDecoration.underline,
              decorationColor: colors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showReportSheet(BuildContext context) async {
    final reasons = <String>[
      context.l10n.projectReportFraud,
      context.l10n.projectReportInfringe,
      context.l10n.projectReportPorn,
      context.l10n.projectReportOther,
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                context.l10n.projectReportTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final reason in reasons)
              ListTile(
                title: Text(reason, style: const TextStyle(fontSize: 14)),
                onTap: () => Navigator.of(sheetContext).pop(reason),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.projectReportSubmitted)),
    );
  }
}

/// 创作者信息（企划详情页固定区块）。
class _CreatorSection extends StatelessWidget {
  const _CreatorSection({required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final rate = (show.creatorFulfillmentPermille / 10).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.projectCreatorTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              ClipOval(
                child: Image.network(
                  PsImages.defaultAvatar,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 48,
                    height: 48,
                    color: colors.brandSubtle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            show.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        PsTag(
                          label: show.creatorVerified
                              ? context.l10n.projectCreatorVerified
                              : context.l10n.projectCreatorUnverified,
                          fontSize: 9,
                          radius: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      show.creatorProjectNum > 0
                          ? context.l10n.projectCreatorStats(
                              show.creatorProjectNum,
                              show.creatorSuccessNum,
                              rate,
                            )
                          : context.l10n.projectCreatorBioEmpty,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (show.creatorBio.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              show.creatorBio,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 企划故事。
class _IntroSection extends StatelessWidget {
  const _IntroSection({required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    if (show.intro.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.projectStoryTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            show.intro,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 支持须知。
class _NoticeSection extends StatelessWidget {
  const _NoticeSection({required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final notices = show.purchaseNotice.isEmpty
        ? <String>[
            context.l10n.showDetailPage_685,
            context.l10n.showDetailPage_685_2,
          ]
        : show.purchaseNotice;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.projectNoticeTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (final notice in notices)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '· ',
                    style: TextStyle(fontSize: 14, color: colors.textTertiary),
                  ),
                  Expanded(
                    child: Text(
                      notice,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: colors.textSecondary,
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

/// 服务保障。
class _ServiceGuaranteeSection extends StatelessWidget {
  static const List<IconData> _icons = <IconData>[
    LucideIcons.creditCard,
    LucideIcons.shieldCheck,
    LucideIcons.ticket,
    LucideIcons.truck,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final labels = <String>[
      context.l10n.projectGuaranteeFund,
      context.l10n.projectGuaranteeRefund,
      context.l10n.projectGuaranteeProgress,
      context.l10n.projectGuaranteeDelivery,
    ];
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      color: colors.bgPage,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(width: 40, height: 1, color: colors.border),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  context.l10n.projectGuaranteeTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.textTertiary,
                  ),
                ),
              ),
              Container(width: 40, height: 1, color: colors.border),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              for (var i = 0; i < _icons.length; i++)
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Icon(_icons[i], size: 30, color: colors.textTertiary),
                      const SizedBox(height: 10),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 底部支持栏。
class _PurchaseBar extends StatelessWidget {
  const _PurchaseBar({
    required this.show,
    required this.onService,
    required this.onWish,
    required this.onBuy,
  });

  final ShowSummary show;
  final VoidCallback onService;
  final VoidCallback onWish;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0x14000000), Color(0x00000000)],
              ),
            ),
          ),
          SizedBox(
            height: 66,
            child: Row(
              children: <Widget>[
                _BarAction(
                  icon: LucideIcons.headset,
                  label: context.l10n.showDetailPage_820,
                  onTap: onService,
                ),
                _BarAction(
                  icon: LucideIcons.heart,
                  label: context.l10n.showDetailPage_823,
                  color: colors.price,
                  onTap: onWish,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                    child: GestureDetector(
                      onTap: onBuy,
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !show.isFundingOpen || show.soldOut
                              ? colors.brandDisabled
                              : colors.price,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          !show.isFundingOpen || show.soldOut
                              ? context.l10n.projectSupportClosed
                              : context.l10n.projectSupportButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
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

class _BarAction extends StatelessWidget {
  const _BarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 26, color: color ?? colors.textPrimary),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                height: 1.1,
                color: color ?? colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 筹资状态文案。
String _fundingStatusLabel(BuildContext context, ShowSummary show) {
  return switch (show.fundingStatusValue) {
    'preheating' => context.l10n.projectStatusPreheating,
    'achieved' => context.l10n.projectStatusAchieved,
    'delivered' => context.l10n.projectStatusDelivered,
    'failed' => context.l10n.projectStatusFailed,
    _ => context.l10n.projectStatusOngoing,
  };
}
