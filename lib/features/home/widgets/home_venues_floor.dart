import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../../shared/ui/ps_poster.dart';
import '../../../shared/ui/ps_price.dart';
import '../../catalog/domain/show_category.dart';
import '../../catalog/domain/show_summary.dart';
import '../../../l10n/home_localizations.dart';

/// 首页「热门场馆」楼层（`view_home_popular_venues.xml` + `item_home_venues.xml`）。
///
/// 20sp 粗体标题（上边距 16、左右 14）→ 横滑场馆卡（268dp 宽）：
/// 头部 72dp（场馆名 16dp 粗体 + 副标题 12dp `text_2` + 右箭头）、
/// 0.5dp 分隔线、下方并排两张 115dp 宽的演出小卡。
class HomeVenuesFloor extends StatelessWidget {
  const HomeVenuesFloor({
    super.key,
    required this.venues,
    required this.showsById,
    required this.onTapVenue,
    required this.onTapShow,
  });

  final List<VenueSummary> venues;

  /// `showId → ShowSummary`，用于渲染场馆下的两张小卡。
  final Map<String, ShowSummary> showsById;

  final void Function(VenueSummary venue) onTapVenue;
  final void Function(ShowSummary show) onTapShow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    if (venues.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.only(bottom: 5),
      color: colors.bgCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              HomeLocalizations.of(context).homeVenuesFloor_48,
              style: TextStyle(
                fontSize: 20,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: venues.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final venue = venues[index];
                final shows = <ShowSummary>[
                  for (final id in venue.showIds)
                    if (showsById[id] != null) showsById[id]!,
                ];
                return _VenueCard(
                  venue: venue,
                  shows: shows,
                  onTap: () => onTapVenue(venue),
                  onTapShow: onTapShow,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({
    required this.venue,
    required this.shows,
    required this.onTap,
    required this.onTapShow,
  });

  final VenueSummary venue;
  final List<ShowSummary> shows;
  final VoidCallback onTap;
  final void Function(ShowSummary show) onTapShow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 268,
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colors.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 72,
              child: Padding(
                padding: const EdgeInsets.only(left: 19, right: 8, top: 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            venue.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            venue.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: colors.textDisabled,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Divider(
                height: 0.5,
                thickness: 0.5,
                color: colors.divider,
              ),
            ),
            const SizedBox(height: 9),
            Padding(
              padding: const EdgeInsets.only(left: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (var i = 0; i < shows.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: 2),
                    SizedBox(
                      width: 115,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTapShow(shows[i]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            PsPoster(
                              seed: shows[i].title,
                              width: 115,
                              height: 140,
                              radius: 4,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              shows[i].title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.25,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            PsPrice(amount: shows[i].priceFrom, size: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
