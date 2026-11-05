import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../catalog/application/catalog_providers.dart';
import '../catalog/data/demo_catalog.dart';
import 'widgets/city_tile.dart';

/// 城市列表页（企划星 `CityListActivity`）。
///
/// ## 为什么要有独立页面
///
/// 首页顶部城市按钮打开的是 [CityPickerSheet]（只放 8 个热门城市，够用且
/// 不打断浏览）。但企划星还有一屏完整的城市列表：定位、热门城市、全部城市
/// （按拼音 A-Z 分组）。这里把"全部城市"独立成页，从面板底部的
/// 「查看全部城市」进入。
///
/// ## 与 Android 的差异
///
/// - **不做 A-Z 分组与右侧索引条**：`demoCities` 只有 10 个城市，
///   分组后每组 1 个，索引条比内容还长。接真实城市表（几百个）时再加。
/// - **不做定位**：原页用 `AMapLocation` 拿当前城市。本项目没有定位权限
///   与 SDK，所以「当前定位」是写死的上海，并在旁边标注"演示"——
///   假装定位成功比不显示更糟。
/// - **无数据的城市仍可点**：切过去看到的是首页空态（"暂无演出"），
///   这是真实存在的一屏，比禁止点击诚实。
class CityListPage extends ConsumerWidget {
  const CityListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final String current = ref.watch(selectedCityProvider);

    // 选中后写全局状态并返回。用 `context.pop()` 而不是 `go('/')`：
    // 用户是从首页面板进来的，返回应该回到面板打开前的首页，
    // 而不是把导航栈清空重来（那会丢掉首页的滚动位置）。
    void select(String city) {
      ref.read(selectedCityProvider.notifier).select(city);
      if (!citiesWithData.contains(city)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$city 暂无演出数据（演示数据仅覆盖部分城市）')));
      }
      context.pop();
    }

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: const AdaptiveAppBar(title: '选择城市'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          _LocatedCard(current: current, onUse: () => select('上海')),
          _Section(
            title: '热门城市',
            cities: demoCities.take(8).toList(growable: false),
            current: current,
            onSelect: select,
          ),
          _Section(
            title: '全部城市',
            cities: demoCities,
            current: current,
            onSelect: select,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 16, 15, 0),
            child: Text(
              '演示数据只覆盖上海、北京、杭州、广州、深圳；其余城市会显示空态。',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.textDisabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 当前定位卡。
class _LocatedCard extends StatelessWidget {
  const _LocatedCard({required this.current, required this.onUse});

  final String current;

  /// 「使用当前定位」的回调。
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 12, 15, 0),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: <Widget>[
          Icon(LucideIcons.mapPin, size: 18, color: colors.brand),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '当前定位：上海',
                  style: TextStyle(fontSize: 15, color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  '演示环境没有接入定位，这里固定为上海',
                  style: TextStyle(fontSize: 11, color: colors.textDisabled),
                ),
              ],
            ),
          ),
          if (current != '上海')
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onUse,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: colors.brand, width: 0.5),
                ),
                child: Text(
                  '使用',
                  style: TextStyle(fontSize: 12, color: colors.brand),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 一个城市分组（标题 + 城市网格）。
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.cities,
    required this.current,
    required this.onSelect,
  });

  final String title;
  final List<String> cities;
  final String current;
  final void Function(String city) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 12, 15, 0),
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
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
          const SizedBox(height: 12),
          // 用 Wrap 而不是 GridView：每行自动填满（屏宽 - 30 - 4×10）/5，
          // 在窄屏（320dp）与宽屏（430dp）上都不需要写死列宽。
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (final String city in cities)
                CityTile(
                  city: city,
                  selected: city == current,
                  available: citiesWithData.contains(city),
                  onTap: () => onSelect(city),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
