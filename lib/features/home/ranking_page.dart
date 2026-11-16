import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../shared/ui/ps_empty_state.dart';
import '../catalog/application/catalog_providers.dart';
import '../catalog/data/planstar_catalog_api.dart';
import '../catalog/domain/show_summary.dart';
import 'application/project_ranking.dart';

/// 完整榜单页：热度榜 / 达成榜 / 冲刺榜。
///
/// 首页的「企划榜单」楼层只展示前 5 名；这里展示服务端返回的全部榜单
/// （最多 10 名），服务端缺数据时用本地企划按同一口径排序兜底。
class RankingPage extends ConsumerStatefulWidget {
  const RankingPage({super.key});

  @override
  ConsumerState<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends ConsumerState<RankingPage> {
  RankingType _type = RankingType.hot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final showsAsync = ref.watch(cityShowsProvider);
    final shows = showsAsync.valueOrNull ?? const <ShowSummary>[];
    final rows = _rows(context, shows);
    final hasError = showsAsync.hasError && !showsAsync.hasValue;

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: context.l10n.homeRankingTitle),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: <Widget>[
                for (final type in RankingType.values) ...<Widget>[
                  _RankTab(
                    label: _labelOf(context, type),
                    selected: _type == type,
                    onTap: () => setState(() => _type = type),
                  ),
                  if (type != RankingType.values.last) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Container(height: 1, color: colors.divider),
          Expanded(
            child: hasError
                ? PsEmptyState(
                    title: context.l10n.showListPage_78,
                    description: psErrorMessage(showsAsync.error!),
                    icon: LucideIcons.wifiOff,
                    actionLabel: context.l10n.actionRetry,
                    onAction: () => ref.invalidate(showCatalogProvider),
                  )
                : rows.isEmpty
                ? PsEmptyState(
                    title: context.l10n.showListPage_78,
                    description: context.l10n.showListPage_79,
                    icon: LucideIcons.trophy,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: rows.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, thickness: 1, color: colors.divider),
                    itemBuilder: (BuildContext context, int index) {
                      final row = rows[index];
                      return _RankRow(
                        rank: row.rank,
                        show: row.show,
                        metric: row.metric,
                        onTap: () => context.push('/show/${row.show.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _labelOf(BuildContext context, RankingType type) => switch (type) {
    RankingType.hot => context.l10n.homeRankingHot,
    RankingType.achievement => context.l10n.homeRankingAchievement,
    RankingType.ending => context.l10n.homeRankingEnding,
  };

  List<_RankItem> _rows(BuildContext context, List<ShowSummary> shows) {
    final server =
        ref.watch(projectRankingProvider(_type.apiValue)).valueOrNull ??
        const <RankingEntry>[];
    if (server.isNotEmpty) {
      return <_RankItem>[
        for (final entry in server)
          _RankItem(
            rank: entry.rank,
            show: entry.show,
            metric: rankingMetricLabel(context, _type, entry.metricValue),
          ),
      ];
    }

    final ranked = rankShowsLocally(shows, _type);
    return <_RankItem>[
      for (var index = 0; index < ranked.length; index++)
        _RankItem(
          rank: index + 1,
          show: ranked[index],
          metric: rankingMetricForShow(context, _type, ranked[index]),
        ),
    ];
  }
}

/// 榜单行：名次 + 企划 + 指标文案。
final class _RankItem {
  const _RankItem({
    required this.rank,
    required this.show,
    required this.metric,
  });

  final int rank;
  final ShowSummary show;
  final String metric;
}

class _RankTab extends StatelessWidget {
  const _RankTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colors.brand : colors.bgSubtle,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colors.bgCard : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.show,
    required this.metric,
    required this.onTap,
  });

  final int rank;
  final ShowSummary show;
  final String metric;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 28,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: rank <= 3 ? colors.price : colors.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    show.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    show.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              metric,
              style: TextStyle(fontSize: 12, color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
