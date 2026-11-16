import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/ui/ps_poster.dart';
import '../../../shared/ui/ps_section_header.dart';
import '../../catalog/domain/show_summary.dart';

/// 首页「正在支持的企划」楼层。
///
/// 与分类楼层的横滑卡片不同，这里用**左图右文**的横向卡片竖排展示，
/// 每行固定 76dp，信息密度更低、更适合阅读标题与达成进度。
class HomeSupportingFloor extends StatelessWidget {
  const HomeSupportingFloor({
    super.key,
    required this.shows,
    required this.onTapShow,
    this.onTapMore,
  });

  /// 行高（需求指定 76dp）。
  static const double rowHeight = 76;

  final List<ShowSummary> shows;
  final void Function(ShowSummary show) onTapShow;
  final VoidCallback? onTapMore;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    if (shows.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 12),
          PsSectionHeader(
            title: context.l10n.homeHotProjectTitle,
            subtitle: context.l10n.homeHotProjectDesc,
            onAction: onTapMore,
            horizontalPadding: 10,
          ),
          const SizedBox(height: 4),
          for (var index = 0; index < shows.length; index++) ...<Widget>[
            if (index > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 10,
                endIndent: 10,
                color: colors.divider,
              ),
            _SupportingRow(
              show: shows[index],
              onTap: () => onTapShow(shows[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _SupportingRow extends StatelessWidget {
  const _SupportingRow({required this.show, required this.onTap});

  final ShowSummary show;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final bool achieved = show.achievementPermille >= 1000;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: HomeSupportingFloor.rowHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              PsPoster(seed: show.title, width: 56, height: 56, radius: 6),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    const SizedBox(height: 3),
                    Text(
                      '${show.categoryName} · '
                      '${context.l10n.projectCardSupporters(show.supporterCount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        Text(
                          context.l10n.projectCardAchievement(
                            (show.achievementPermille / 10).round(),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: achieved ? colors.price : colors.brand,
                          ),
                        ),
                        if (show.remainingDays > 0) ...<Widget>[
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              context.l10n.homeRankingMetricRemaining(
                                show.remainingDays,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
