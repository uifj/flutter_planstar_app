import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/session.dart';
import '../../l10n/l10n.dart';
import '../../shared/ui/ps_empty_state.dart';
import '../../shared/ui/ps_floating_tab_bar.dart';
import 'application/project_idea_analytics.dart';
import 'application/project_idea_providers.dart';
import 'model/project_idea.dart';
import 'oppose_sheet.dart';
import 'project_idea_feedback.dart';
import 'support_sheet.dart';

/// 创意详情（`/project-idea/:ideaId`）。
///
/// 明确标注「尚未立项」——它不是正式 project，不能出现购买/付款类入口。
/// 底部操作栏复用叠卡页的支持 / 不支持弹窗。
class ProjectIdeaDetailPage extends ConsumerStatefulWidget {
  const ProjectIdeaDetailPage({super.key, required this.ideaId});

  final int ideaId;

  @override
  ConsumerState<ProjectIdeaDetailPage> createState() =>
      _ProjectIdeaDetailPageState();
}

class _ProjectIdeaDetailPageState extends ConsumerState<ProjectIdeaDetailPage> {
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      trackProjectIdeaEvent(ProjectIdeaEvents.ideaDetailView, <String, Object?>{
        'ideaId': widget.ideaId,
        'from': 'feed',
      });
    });
  }

  /// 未登录不弹窗：先跳登录并带上来源；登录成功回跳后继续打开原弹窗。
  Future<bool> _ensureLoggedIn() async {
    if (ref.read(sessionProvider).isLoggedIn) return true;
    final String from = Uri.encodeComponent('/project-idea/${widget.ideaId}');
    await context.push('/login?from=$from');
    if (!mounted) return false;
    return ref.read(sessionProvider).isLoggedIn;
  }

  Future<void> _openSupport() async {
    if (_submitting) return;
    trackProjectIdeaEvent(ProjectIdeaEvents.ideaSupportClick, <String, Object?>{
      'ideaId': widget.ideaId,
    });
    if (!await _ensureLoggedIn()) return;
    if (!mounted) return;
    setState(() => _submitting = true);
    final IdeaVoteResult? result = await SupportSheet.show(
      context,
      onSubmit: (SupportSelection selection) {
        trackProjectIdeaEvent(
          ProjectIdeaEvents.ideaSupportSubmit,
          <String, Object?>{'ideaId': widget.ideaId, 'tier': selection.tier},
        );
        return ref
            .read(projectIdeaVoteServiceProvider)
            .support(
              widget.ideaId,
              tier: selection.tier,
              reason: selection.reason.isEmpty ? null : selection.reason,
            );
      },
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result == null) return;
    showIdeaToast(
      context,
      result.alreadyVoted
          ? context.l10n.ideaAlreadyVoted
          : context.l10n.supportSuccess,
    );
    ref.invalidate(projectIdeaDetailProvider(widget.ideaId));
  }

  Future<void> _openOppose() async {
    if (_submitting) return;
    trackProjectIdeaEvent(ProjectIdeaEvents.ideaOpposeClick, <String, Object?>{
      'ideaId': widget.ideaId,
    });
    if (!await _ensureLoggedIn()) return;
    if (!mounted) return;
    setState(() => _submitting = true);
    final IdeaVoteResult? result = await OpposeSheet.show(
      context,
      onSubmit: (OpposeSelection selection) {
        trackProjectIdeaEvent(
          ProjectIdeaEvents.ideaOpposeSubmit,
          <String, Object?>{
            'ideaId': widget.ideaId,
            'reasonCode': selection.reasonCode,
          },
        );
        return ref
            .read(projectIdeaVoteServiceProvider)
            .oppose(
              widget.ideaId,
              reasonCode: selection.reasonCode,
              reasonText: selection.reasonText.isEmpty
                  ? null
                  : selection.reasonText,
            );
      },
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result == null) return;
    showIdeaToast(
      context,
      result.alreadyVoted
          ? context.l10n.ideaAlreadyVoted
          : context.l10n.opposeSuccess,
    );
    ref.invalidate(projectIdeaDetailProvider(widget.ideaId));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final AsyncValue<ProjectIdeaDetail> detail = ref.watch(
      projectIdeaDetailProvider(widget.ideaId),
    );

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: context.l10n.ideaDetailTitle),
      body: detail.when(
        data: (ProjectIdeaDetail idea) => Column(
          children: <Widget>[
            Expanded(child: _DetailBody(idea: idea)),
            _VoteBar(
              idea: idea,
              submitting: _submitting,
              onSupport: () => unawaited(_openSupport()),
              onOppose: () => unawaited(_openOppose()),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => PsEmptyState(
          title: context.l10n.ideaDetailLoadFailed,
          description: psErrorMessage(error),
          icon: LucideIcons.circleAlert,
          actionLabel: context.l10n.actionRetry,
          onAction: () =>
              ref.invalidate(projectIdeaDetailProvider(widget.ideaId)),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.idea});

  final ProjectIdeaDetail idea;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = context.l10n;
    final String category = idea.categoryName.isEmpty
        ? l10n.ideaCategoryFallback
        : idea.categoryName;

    final List<_ReasonCount> reasons = _reasonCounts(context, idea.reasonCounts)
      ..sort((_ReasonCount a, _ReasonCount b) => b.count.compareTo(a.count));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _DetailCover(idea: idea),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _Chip(label: category, color: colors.brand, bg: colors.brandSubtle),
            _Chip(
              label: l10n.ideaNotLaunched,
              color: colors.warning,
              bg: colors.warningBg,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          idea.title,
          style: TextStyle(
            fontSize: 22,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            _Avatar(idea: idea),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                idea.creatorName.isEmpty
                    ? l10n.ideaCreatorLabel
                    : idea.creatorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ),
            Text(
              l10n.ideaDetailPublishedAt(_formatDate(idea.createdAt)),
              style: TextStyle(fontSize: 12, color: colors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          idea.summary,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        _StatsCard(idea: idea),
        if (idea.description.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          _Section(
            title: l10n.ideaDetailDescription,
            child: Text(
              idea.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
        if (idea.gallery.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          _Section(
            title: l10n.ideaDetailGallery,
            child: _Gallery(images: idea.gallery),
          ),
        ],
        const SizedBox(height: 16),
        _Section(
          title: l10n.ideaDetailReasons,
          child: reasons.isEmpty
              ? Text(
                  l10n.ideaDetailNoReasons,
                  style: TextStyle(fontSize: 13, color: colors.textTertiary),
                )
              : Column(
                  children: <Widget>[
                    for (final _ReasonCount reason in reasons)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                reason.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              '${reason.count}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(LucideIcons.info, size: 14, color: colors.warning),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.ideaDetailNotLaunchedHint,
                style: TextStyle(fontSize: 12, color: colors.warning),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 只保留标准理由的计数；未知 code 不展示，避免暴露用户原文。
  List<_ReasonCount> _reasonCounts(
    BuildContext context,
    Map<String, int> counts,
  ) {
    final List<_ReasonCount> result = <_ReasonCount>[];
    for (final IdeaOpposeReason reason in IdeaOpposeReason.values) {
      final int count = counts[reason.code] ?? 0;
      if (count > 0) {
        result.add(_ReasonCount(label: reason.labelOf(context), count: count));
      }
    }
    return result;
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}

class _ReasonCount {
  const _ReasonCount({required this.label, required this.count});

  final String label;
  final int count;
}

class _DetailCover extends StatelessWidget {
  const _DetailCover({required this.idea});

  final ProjectIdea idea;

  @override
  Widget build(BuildContext context) {
    if (idea.cover.isEmpty) return const _DetailCoverPlaceholder();
    return Image.network(
      idea.cover,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _DetailCoverPlaceholder(),
    );
  }
}

class _DetailCoverPlaceholder extends StatelessWidget {
  const _DetailCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[colors.brand, colors.brandPressed],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        LucideIcons.lightbulb,
        size: 52,
        color: colors.onBrand.withValues(alpha: 0.75),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.idea});

  final ProjectIdeaDetail idea;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = context.l10n;
    final double rate = idea.supportRate.isFinite
        ? idea.supportRate.clamp(0, 1).toDouble()
        : 0;
    final int tierTotal = idea.tierDistribution.total;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _Metric(
                  value: l10n.ideaDetailSupportPeople(idea.supportCount),
                  label: l10n.ideaSupport,
                  color: colors.brand,
                ),
              ),
              Expanded(
                child: _Metric(
                  value: l10n.ideaDetailOpposePeople(idea.opposeCount),
                  label: l10n.ideaOppose,
                  color: colors.textSecondary,
                ),
              ),
              Expanded(
                child: _Metric(
                  value: '${(rate * 100).toStringAsFixed(1)}%',
                  label: l10n.ideaDetailSupportRate,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: colors.divider),
          const SizedBox(height: 14),
          Text(
            l10n.ideaDetailTierDistribution,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _TierRow(
            label: l10n.ideaTierOption(5),
            count: idea.tierDistribution.five,
            total: tierTotal,
            color: colors.brand,
          ),
          const SizedBox(height: 8),
          _TierRow(
            label: l10n.ideaTierOption(10),
            count: idea.tierDistribution.ten,
            total: tierTotal,
            color: colors.brand,
          ),
          const SizedBox(height: 8),
          _TierRow(
            label: l10n.ideaTierOption(20),
            count: idea.tierDistribution.twenty,
            total: tierTotal,
            color: colors.brand,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: colors.textTertiary)),
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final double percent = total <= 0 ? 0 : count / total;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: colors.textTertiary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 6,
              color: colors.bgSubtle,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: percent,
                child: Container(color: color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(percent * 100).toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 11, color: colors.textTertiary),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = 8;
        final double size = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: <Widget>[
            for (final String image in images)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: colors.bgSubtle,
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.image,
                        size: 20,
                        color: colors.textDisabled,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, required this.bg});

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.idea});

  final ProjectIdea idea;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final String name = idea.creatorName;
    final Widget fallback = CircleAvatar(
      radius: 13,
      backgroundColor: colors.brandSubtle,
      child: Text(
        name.isEmpty ? '?' : name[0],
        style: TextStyle(fontSize: 12, color: colors.brand),
      ),
    );
    return ClipOval(
      child: idea.creatorAvatar.isEmpty
          ? fallback
          : Image.network(
              idea.creatorAvatar,
              width: 26,
              height: 26,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

/// 底部固定操作栏。已表态时两个按钮都禁用，并用「已支持 / 已不支持」替换文案。
class _VoteBar extends StatelessWidget {
  const _VoteBar({
    required this.idea,
    required this.submitting,
    required this.onSupport,
    required this.onOppose,
  });

  final ProjectIdeaDetail idea;
  final bool submitting;
  final VoidCallback onSupport;
  final VoidCallback onOppose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = context.l10n;
    final IdeaVote? vote = idea.myVote;
    final bool voted = vote != null;
    final bool supported = vote?.voteType == 1;
    final bool disabled = voted || submitting;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        PsFloatingTabBar.bottomClearance(context) + 10,
      ),
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: disabled ? null : onOppose,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textSecondary,
                minimumSize: const Size(0, 46),
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                voted && !supported
                    ? l10n.ideaDetailVotedOppose
                    : l10n.ideaOppose,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: disabled ? null : onSupport,
              style: FilledButton.styleFrom(
                backgroundColor: colors.brand,
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                voted && supported
                    ? l10n.ideaDetailVotedSupport
                    : l10n.ideaSupport,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
