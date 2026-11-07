import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/ui/ps_section_header.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/data/planstar_catalog_api.dart';
import '../../catalog/domain/show_summary.dart';

/// 榜单类型。
enum RankingType {
  hot('hot'),
  achievement('achievement'),
  ending('ending');

  const RankingType(this.apiValue);

  /// 与 `v1/rankings` 的 `type` 参数一致。
  final String apiValue;
}

/// 首页「企划榜单」楼层（P2）。
///
/// 榜单优先取服务端 `v1/rankings`（名次与指标都由服务端给出）；
/// demo 模式或接口失败时，用本地企划列表按同一口径排序兜底。
class HomeRankingFloor extends ConsumerStatefulWidget {
  const HomeRankingFloor({
    super.key,
    required this.shows,
    required this.onTapShow,
  });

  final List<ShowSummary> shows;
  final void Function(ShowSummary show) onTapShow;

  @override
  ConsumerState<HomeRankingFloor> createState() => _HomeRankingFloorState();
}

class _HomeRankingFloorState extends ConsumerState<HomeRankingFloor> {
  RankingType _type = RankingType.hot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final rows = _rows(context);
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8, left: 12, right: 12),
      padding: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 12),
          PsSectionHeader(
            title: context.l10n.homeRankingTitle,
            horizontalPadding: 10,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: <Widget>[
                _RankTab(
                  label: context.l10n.homeRankingHot,
                  selected: _type == RankingType.hot,
                  onTap: () => setState(() => _type = RankingType.hot),
                ),
                const SizedBox(width: 8),
                _RankTab(
                  label: context.l10n.homeRankingAchievement,
                  selected: _type == RankingType.achievement,
                  onTap: () => setState(() => _type = RankingType.achievement),
                ),
                const SizedBox(width: 8),
                _RankTab(
                  label: context.l10n.homeRankingEnding,
                  selected: _type == RankingType.ending,
                  onTap: () => setState(() => _type = RankingType.ending),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (final row in rows)
            _RankRow(
              rank: row.rank,
              show: row.show,
              metric: row.metric,
              onTap: () => widget.onTapShow(row.show),
            ),
        ],
      ),
    );
  }

  /// 服务端榜单优先；为空（demo / 失败 / 加载中）时用本地排序兜底。
  List<_RankItem> _rows(BuildContext context) {
    final server =
        ref.watch(projectRankingProvider(_type.apiValue)).valueOrNull ??
        const <RankingEntry>[];
    if (server.isNotEmpty) {
      return <_RankItem>[
        for (final entry in server.take(5))
          _RankItem(
            rank: entry.rank,
            show: entry.show,
            metric: _serverMetric(context, entry.metricValue),
          ),
      ];
    }

    final ranked = _ranked(widget.shows).take(5).toList(growable: false);
    return <_RankItem>[
      for (var index = 0; index < ranked.length; index++)
        _RankItem(
          rank: index + 1,
          show: ranked[index],
          metric: _metric(context, ranked[index]),
        ),
    ];
  }

  /// 服务端指标：热榜支持人数、达成榜千分比、冲刺榜剩余天数。
  String _serverMetric(BuildContext context, int value) {
    return switch (_type) {
      RankingType.hot => context.l10n.homeRankingMetricSupporters(value),
      RankingType.achievement => context.l10n.homeRankingMetricAchievement(
        (value / 10).round(),
      ),
      RankingType.ending => context.l10n.homeRankingMetricRemaining(value),
    };
  }

  List<ShowSummary> _ranked(List<ShowSummary> source) {
    // 契约：榜单仅统计 funding_status ∈ (ongoing, achieved)，预热与已结束不参与。
    final list = source
        .where((show) {
          final status = show.fundingStatusValue;
          return status == 'ongoing' || status == 'achieved';
        })
        .toList(growable: true);
    switch (_type) {
      case RankingType.hot:
        list.sort(
          (a, b) => b.supporterCount.compareTo(a.supporterCount),
        );
      case RankingType.achievement:
        list.sort(
          (a, b) => b.achievementPermille.compareTo(a.achievementPermille),
        );
      case RankingType.ending:
        list.sort((a, b) => a.remainingDays.compareTo(b.remainingDays));
    }
    return list;
  }

  String _metric(BuildContext context, ShowSummary show) {
    switch (_type) {
      case RankingType.hot:
        return context.l10n.homeRankingMetricSupporters(show.supporterCount);
      case RankingType.achievement:
        return context.l10n.homeRankingMetricAchievement(
          (show.achievementPermille / 10).round(),
        );
      case RankingType.ending:
        return context.l10n.homeRankingMetricRemaining(show.remainingDays);
    }
  }
}

/// 榜单楼层里的一行：名次 + 企划 + 指标文案。
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? colors.brand : colors.bgSubtle,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 22,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: rank <= 3 ? colors.price : colors.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                show.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              metric,
              style: TextStyle(fontSize: 11, color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
