import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import '../catalog/application/catalog_providers.dart';
import '../catalog/domain/show_category.dart';
import '../catalog/domain/show_summary.dart';
import '../catalog/ui/show_cards.dart';
import '../../l10n/l10n.dart';

/// 场馆详情页（企划星 `VenueDetailActivity` + `VenueDetailFragment`）。
///
/// ## 为什么放在 `goods` 而不是新建 feature
///
/// 场馆页的内容只有两件事：**场馆是谁**（名称/地址）+ **这里演什么**
/// （该场馆的近期演出）。它不持有任何自己的领域模型——`VenueSummary` 在
/// `catalog`，演出列表也在 `catalog`。为它单开一个 feature 会得到一个
/// 只有一个文件、且所有依赖都指向 `catalog` 的目录，不如就近放在 `goods`
/// （演出详情域）里。
///
/// ## 与 Android 的差异
///
/// 原页有三块：场馆信息、**地图**（百度地图 `MapView` + 周边）、近期演出。
/// 这里**不做地图**：`flutter_baidu_mapapi_map` 虽然已在依赖里，但演示数据
/// 没有真实经纬度，画一个假坐标点比不画更误导。地址行给了「复制地址」，
/// 这是没有地图时最实用的替代动作。
class VenuePage extends ConsumerWidget {
  const VenuePage({super.key, required this.venueName});

  final String venueName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final VenueSummary? venue = ref
        .watch(venueByNameProvider(venueName))
        .valueOrNull;
    final List<ShowSummary> shows =
        ref.watch(venueShowsProvider(venueName)).valueOrNull ??
        const <ShowSummary>[];
    final String city = ref.watch(selectedCityProvider);

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: context.l10n.venuePage_45),
      body: venue == null
          ? PsEmptyState(
              title: context.l10n.venuePage_48,
              description: context.l10n.venuePage_49,
              icon: LucideIcons.mapPinOff,
              actionLabel: context.l10n.venuePage_51,
              onAction: () => context.pop(),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: <Widget>[
                _VenueHeader(venue: venue, city: city),
                _SectionBar(
                  title: context.l10n.venuePage_58,
                  count: shows.length,
                ),
                if (shows.isEmpty)
                  PsEmptyState(
                    title: context.l10n.venuePage_61,
                    description: context.l10n.venuePage_62,
                    icon: LucideIcons.calendarX,
                    compact: true,
                  )
                else
                  for (final ShowSummary show in shows)
                    ShowCardRow(
                      show: show,
                      onTap: () => context.push('/show/${show.id}'),
                    ),
              ],
            ),
    );
  }
}

/// 场馆头部（`view_venue_header.xml`）。
class _VenueHeader extends StatelessWidget {
  const _VenueHeader({required this.venue, required this.city});

  final VenueSummary venue;
  final String city;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            venue.name,
            style: TextStyle(
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(LucideIcons.mapPin, size: 14, color: colors.textTertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$city ${venue.address}',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: '$city ${venue.address}'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.venuePage_124)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: <Widget>[
                      Icon(LucideIcons.copy, size: 13, color: colors.brand),
                      const SizedBox(width: 2),
                      Text(
                        context.l10n.venuePage_134,
                        style: TextStyle(fontSize: 12, color: colors.brand),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _Metric(
                value: '${venue.showCount}',
                label: context.l10n.venuePage_146,
              ),
              const SizedBox(width: 24),
              _Metric(
                value: '${venue.showIds.length}',
                label: context.l10n.venuePage_148,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.price,
          ),
        ),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 12, color: colors.textTertiary)),
      ],
    );
  }
}

/// 分区标题 + 数量。
class _SectionBar extends StatelessWidget {
  const _SectionBar({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 6),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}
