import 'package:flutter/widgets.dart';

import '../../../l10n/l10n.dart';
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

/// 本地兜底排序（服务端榜单缺失时使用）。
///
/// 契约：榜单仅统计 `funding_status ∈ (ongoing, achieved)`，
/// 预热与已结束不参与。
List<ShowSummary> rankShowsLocally(List<ShowSummary> source, RankingType type) {
  final List<ShowSummary> list = source
      .where((show) {
        final String status = show.fundingStatusValue;
        return status == 'ongoing' || status == 'achieved';
      })
      .toList(growable: true);

  switch (type) {
    case RankingType.hot:
      list.sort((a, b) => b.supporterCount.compareTo(a.supporterCount));
    case RankingType.achievement:
      list.sort(
        (a, b) => b.achievementPermille.compareTo(a.achievementPermille),
      );
    case RankingType.ending:
      list.sort((a, b) => a.remainingDays.compareTo(b.remainingDays));
  }
  return list;
}

/// 服务端指标值 → 展示文案。
///
/// 热榜支持人数、达成榜千分比、冲刺榜剩余天数。
String rankingMetricLabel(BuildContext context, RankingType type, int value) {
  return switch (type) {
    RankingType.hot => context.l10n.homeRankingMetricSupporters(value),
    RankingType.achievement => context.l10n.homeRankingMetricAchievement(
      (value / 10).round(),
    ),
    RankingType.ending => context.l10n.homeRankingMetricRemaining(value),
  };
}

/// 本地企划 → 指标文案（口径与服务端一致）。
String rankingMetricForShow(
  BuildContext context,
  RankingType type,
  ShowSummary show,
) {
  return switch (type) {
    RankingType.hot => context.l10n.homeRankingMetricSupporters(
      show.supporterCount,
    ),
    RankingType.achievement => context.l10n.homeRankingMetricAchievement(
      (show.achievementPermille / 10).round(),
    ),
    RankingType.ending => context.l10n.homeRankingMetricRemaining(
      show.remainingDays,
    ),
  };
}
