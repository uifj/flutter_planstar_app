import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../catalog/data/demo_catalog.dart';
import 'city_tile.dart';
import '../../../l10n/home_localizations.dart';

/// 城市选择面板。
///
/// 企划星的城市选择是一个独立页面（带定位、热门城市、A-Z 索引），
/// 这里收成一个底部面板：定位行 + 城市网格。**没有数据的城市**会标灰并提示
/// 「暂无演出」——这比点了没反应诚实，也让空态在演示里可被看到。
///
/// 完整的城市列表（含 A-Z 索引与"暂无演出"说明）在 `CityListPage`
/// （`/cities`），面板底部给了入口。格子本身共用 [CityTile]。
class CityPickerSheet extends StatelessWidget {
  const CityPickerSheet({
    super.key,
    required this.current,
    required this.onSelected,
    this.onMore,
  });

  final String current;
  final void Function(String city) onSelected;

  /// 「查看全部城市」的回调。由调用方负责先关面板再跳转——
  /// 面板自己 push 会在 pop 之后用到已销毁的 context。
  final VoidCallback? onMore;

  /// 面板里只放前 8 个热门城市，剩下的走 `/cities`。
  static const int _hotCount = 8;

  /// 打开面板。
  static Future<void> show(
    BuildContext context, {
    required String current,
    required void Function(String city) onSelected,
    VoidCallback? onMore,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CityPickerSheet(
        current: current,
        onSelected: onSelected,
        onMore: onMore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  HomeLocalizations.of(context).cityPickerSheet_70,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(LucideIcons.x, size: 20, color: colors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Icon(LucideIcons.mapPin, size: 14, color: colors.brand),
                const SizedBox(width: 4),
                Text(
                  HomeLocalizations.of(context).cityPickerSheet_90,
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              HomeLocalizations.of(context).cityPickerSheet_97,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                for (final city in demoCities.take(_hotCount))
                  CityTile(
                    city: city,
                    selected: city == current,
                    available: citiesWithData.contains(city),
                    onTap: () {
                      Navigator.of(context).maybePop();
                      onSelected(city);
                    },
                  ),
              ],
            ),
            if (onMore != null) ...<Widget>[
              const SizedBox(height: 6),
              InkWell(
                onTap: onMore,
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        HomeLocalizations.of(context).cityPickerSheet_127,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: colors.textDisabled,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
