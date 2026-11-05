import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui/ps_empty_state.dart';
import '../../../shared/ui/ps_floating_tab_bar.dart';
import '../../../shared/ui/ps_poster.dart';
import '../../../shared/ui/ps_price.dart';
import '../../../shared/ui/ps_tag.dart';
import '../application/catalog_providers.dart';
import '../domain/show_category.dart';
import '../domain/show_summary.dart';

/// 分类首页（企划星 `CategoryHomeActivity` + `CategoryHomeFragment`）。
///
/// ## 结构
///
/// - 顶部分类切换条（横向滚动 tab，选中态加粗 + 品牌色）；
/// - 二级标签筛选条（选中的一级分类的 `subTags`，可选，多选）；
/// - 演出列表（按筛选条件过滤后的当前城市演出）。
///
/// ## 与 Android 的差异
///
/// - 原页有"日历"入口和"城市日历"楼层（`autoOpenCalendar`）。
///   日历需要服务端数据（按日期返回演出），这里没有数据源，不做。
/// - 原页的列表是服务端分页返回。这里从本地 `showCatalogProvider` 过滤，
///   数据量有限（演示数据每分类 3–5 条），不需要分页。
/// - 分类切换时不做 `ViewPager` 预加载——数据来自同一个 provider，
///   切换只是改变过滤条件，不需要多页面实例。
class CategoryHomePage extends ConsumerStatefulWidget {
  const CategoryHomePage({super.key, this.initialCategoryId});

  /// 初始分类 id。从路由来；缺省时取第一个分类。
  final int? initialCategoryId;

  @override
  ConsumerState<CategoryHomePage> createState() => _CategoryHomePageState();
}

class _CategoryHomePageState extends ConsumerState<CategoryHomePage> {
  late int _selectedCategoryId;
  final Set<int> _selectedSubTagIds = <int>{};

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final categories =
        ref.watch(showCategoriesProvider).valueOrNull ?? const <ShowCategory>[];

    // 如果初始 categoryId 没有对应分类，取第一个。
    if (_selectedCategoryId == 0 && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    final selectedCategory = categories
        .where((c) => c.id == _selectedCategoryId)
        .firstOrNull;

    final city = ref.watch(selectedCityProvider);
    final allShows = ref.watch(cityShowsProvider).valueOrNull ?? const <ShowSummary>[];

    // 按分类 + 二级标签筛选。
    final filteredShows = allShows.where((show) {
      if (show.categoryId != _selectedCategoryId) return false;
      if (_selectedSubTagIds.isEmpty) return true;
      // 演出没有 subCategoryId 字段，这里只按分类筛选。
      // 接真实接口后，标签筛选会由服务端 query 参数完成。
      return true;
    }).toList();

    final topPadding = MediaQuery.paddingOf(context).top;

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      body: Column(
        children: <Widget>[
          _CategoryTopBar(
            topPadding: topPadding,
            city: city,
            onTapCity: () => context.push('/cities'),
            onTapSearch: () => context.push('/search'),
          ),
          if (categories.isNotEmpty)
            _CategoryTabs(
              categories: categories,
              selectedId: _selectedCategoryId,
              onSelect: (id) => setState(() {
                _selectedCategoryId = id;
                _selectedSubTagIds.clear();
              }),
            ),
          if (selectedCategory != null && selectedCategory.subTags.isNotEmpty)
            _SubTagBar(
              subTags: selectedCategory.subTags,
              selectedIds: _selectedSubTagIds,
              onToggle: (tagId) => setState(() {
                if (_selectedSubTagIds.contains(tagId)) {
                  _selectedSubTagIds.remove(tagId);
                } else {
                  _selectedSubTagIds.add(tagId);
                }
              }),
            ),
          Expanded(
            child: filteredShows.isEmpty
                ? PsEmptyState(
                    title: '$city 暂无${selectedCategory?.name ?? '该分类'}演出',
                    description: '试试切换城市或查看其他分类',
                    icon: LucideIcons.calendarCheck,
                    actionLabel: '去首页',
                    onAction: () => context.go('/'),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(
                      top: 8,
                      bottom: PsFloatingTabBar.bottomClearance(context),
                    ),
                    itemCount: filteredShows.length,
                    itemBuilder: (context, index) {
                      final show = filteredShows[index];
                      return _CategoryShowCard(
                        show: show,
                        onTap: () => context.push('/show/${show.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 顶栏（分类 logo + 城市 + 搜索）。
class _CategoryTopBar extends StatelessWidget {
  const _CategoryTopBar({
    required this.topPadding,
    required this.city,
    required this.onTapCity,
    required this.onTapSearch,
  });

  final double topPadding;
  final String city;
  final VoidCallback onTapCity;
  final VoidCallback onTapSearch;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      padding: EdgeInsets.only(top: topPadding),
      child: SizedBox(
        height: 44,
        child: Row(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapCity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: <Widget>[
                    Text(
                      city,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Icon(LucideIcons.chevronDown, size: 18, color: colors.textTertiary),
                  ],
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapSearch,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Icon(LucideIcons.search, size: 22, color: colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 分类切换条（横向滚动）。
class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<ShowCategory> categories;
  final int selectedId;
  final void Function(int id) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = cat.id == selectedId;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(cat.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected ? colors.brand : colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 20,
                    height: 2,
                    decoration: BoxDecoration(
                      color: selected ? colors.brand : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 二级标签筛选条（横向滚动，多选 chip）。
class _SubTagBar extends StatelessWidget {
  const _SubTagBar({
    required this.subTags,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<SubCategoryTag> subTags;
  final Set<int> selectedIds;
  final void Function(int tagId) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgPage,
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: subTags.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = subTags[index];
          final selected = selectedIds.contains(tag.id);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onToggle(tag.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? colors.brand : colors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? colors.brand : colors.border,
                ),
              ),
              child: Center(
                child: Text(
                  tag.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white : colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 演出卡片（分类列表用）。
class _CategoryShowCard extends StatelessWidget {
  const _CategoryShowCard({required this.show, required this.onTap});

  final ShowSummary show;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 6, 15, 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            PsPoster(seed: show.title, width: 72, height: 96, radius: 4),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    show.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (show.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: <Widget>[
                        for (final tag in show.tags.take(3))
                          PsTag(label: tag, tone: PsTagTone.outline, fontSize: 9),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Text(
                    '${show.firstSessionLabel} · ${show.duration}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Icon(LucideIcons.mapPin, size: 12, color: colors.textTertiary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${show.city} · ${show.venue}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: colors.textTertiary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      if (show.discountLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: PsTag(
                            label: show.discountLabel!,
                            tone: PsTagTone.solid,
                            color: colors.price,
                            fontSize: 9,
                          ),
                        ),
                      PsPrice(amount: show.priceFrom, size: 16, suffix: '起'),
                      const Spacer(),
                      Text(
                        '${show.wishCount} 人想看',
                        style: TextStyle(fontSize: 11, color: colors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
