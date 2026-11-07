import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui/ps_empty_state.dart';
import '../application/catalog_providers.dart';
import '../domain/show_category.dart';
import '../domain/show_summary.dart';
import 'show_cards.dart';
import '../../../l10n/l10n.dart';

/// 演出列表页（企划星 `CategoryHomeActivity` / `HotListActivity` 的合并版）。
///
/// ## 为什么把两个页面合成一个
///
/// 原项目里「分类列表」和「热门列表」是两个 Activity，但除了**标题和默认排序**
/// 之外完全一样：同一张 `item_show_list.xml`、同一个 `ShowListAdapter`、
/// 同一套分页参数。差异只有入口带的 `categoryId` 和默认 `sort`。
/// 合成一个页面 + 两个 query 参数（`category` / `title`），
/// 比复制一份 400 行列表页更好维护——这也是 Flutter 侧一直的做法
/// （见 `ShowCardRow` 被搜索结果/相似推荐共用）。
///
/// ## 与 Android 的差异
///
/// - 原页的分页是 `RecyclerView` + 上拉加载；这里用 `NotificationListener`
///   监听滚动到底部时调用 `ShowCatalogController.loadMore()`，真实接口按
///   `page/pageSize` 追加；演示数据一次给全，不再触发网络。
/// - 原页有「筛选」抽屉（价格区间/时间/场馆）；这里只保留排序。
///   筛选需要服务端支持多维聚合，客户端硬筛会把"筛完是空"变成常态。
class ShowListPage extends ConsumerStatefulWidget {
  const ShowListPage({super.key, this.categoryId, this.title});

  /// 一级分类 id。`null` = 不限分类（「全部演出」）。
  final int? categoryId;

  /// 页面标题。`null` 时按分类名兜底，再兜底成「全部演出」。
  final String? title;

  @override
  ConsumerState<ShowListPage> createState() => _ShowListPageState();
}

class _ShowListPageState extends ConsumerState<ShowListPage> {
  /// 当前分类。`null` = 全部。
  late int? _categoryId = widget.categoryId;

  _SortMode _sort = _SortMode.recommended;

  bool _loadingMore = false;

  /// 触底追加下一页；失败时 provider 会保留已有列表并把 `hasMore` 置 false。
  Future<void> _loadMore() async {
    if (_loadingMore) return;
    final notifier = ref.read(showCatalogProvider.notifier);
    if (!notifier.hasMore) return;
    setState(() => _loadingMore = true);
    await notifier.loadMore();
    if (mounted) setState(() => _loadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final showsAsync = ref.watch(cityShowsProvider);
    final shows = _sorted(showsAsync.valueOrNull ?? const <ShowSummary>[]);
    final categories =
        ref.watch(showCategoriesProvider).valueOrNull ?? const <ShowCategory>[];
    final hasError = showsAsync.hasError && !showsAsync.hasValue;

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: _titleOf(categories)),
      body: Column(
        children: <Widget>[
          _CategoryBar(
            categories: categories,
            selected: _categoryId,
            onSelect: (int? id) => setState(() => _categoryId = id),
          ),
          _SortBar(
            selected: _sort,
            total: shows.length,
            onSelect: (_SortMode mode) => setState(() => _sort = mode),
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
                : shows.isEmpty
                ? PsEmptyState(
                    title: context.l10n.showListPage_78,
                    description: context.l10n.showListPage_79,
                    icon: LucideIcons.drama,
                    actionLabel: context.l10n.showListPage_81,
                    onAction: () => setState(() => _categoryId = null),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      // 距底部 300px 内追加下一页；provider 内部会去重与限流。
                      if (notification.metrics.extentAfter < 300) {
                        _loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: shows.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: colors.divider,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final ShowSummary show = shows[index];
                        return ShowCardRow(
                          show: show,
                          onTap: () => context.push('/show/${show.id}'),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// 标题优先级：显式传入 > 分类名 > 兜底。
  String _titleOf(List<ShowCategory> categories) {
    if (widget.title != null) return widget.title!;
    final id = _categoryId;
    if (id != null) {
      for (final category in categories) {
        if (category.id == id) return category.name;
      }
    }
    return context.l10n.showListPage_112;
  }

  /// 先按分类过滤，再按当前排序规则排。
  ///
  /// 过滤/排序都放在页面里而不是 provider：它们是**这一屏的视图状态**，
  /// 放进 provider 会让别的页面被迫继承这套排序。
  List<ShowSummary> _sorted(List<ShowSummary> source) {
    final id = _categoryId;
    final filtered = id == null
        ? <ShowSummary>[...source]
        : source.where((show) => show.categoryId == id).toList();

    switch (_sort) {
      case _SortMode.recommended:
        // 「推荐」= 想看人数降序，与原项目默认排序一致。
        filtered.sort((a, b) => b.wishCount.compareTo(a.wishCount));
      case _SortMode.soonest:
        filtered.sort((a, b) => a.firstSessionAt.compareTo(b.firstSessionAt));
      case _SortMode.priceAsc:
        filtered.sort(
          (a, b) => a.priceFrom.minorUnits.compareTo(b.priceFrom.minorUnits),
        );
    }
    return filtered;
  }
}

/// 排序方式。
enum _SortMode {
  recommended,
  soonest,
  priceAsc;

  String labelOf(BuildContext context) => switch (this) {
    _SortMode.recommended => context.l10n.showListPage_140,
    _SortMode.soonest => context.l10n.showListPage_141,
    _SortMode.priceAsc => context.l10n.showListPage_142,
  };
}

/// 分类筛选条（`view_show_list_filter.xml` 的横向 tab）。
class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<ShowCategory> categories;
  final int? selected;
  final void Function(int? id) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: <Widget>[
          _CategoryChip(
            label: context.l10n.showListPage_172,
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final category in categories)
            _CategoryChip(
              label: category.name,
              selected: selected == category.id,
              onTap: () => onSelect(category.id),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.brandSubtle : colors.bgSubtle,
          borderRadius: BorderRadius.circular(14),
          border: selected ? Border.all(color: colors.brand, width: 0.5) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            height: 1.1,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? colors.brand : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 排序条 + 结果数。
class _SortBar extends StatelessWidget {
  const _SortBar({
    required this.selected,
    required this.total,
    required this.onSelect,
  });

  final _SortMode selected;
  final int total;
  final void Function(_SortMode mode) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      padding: const EdgeInsets.fromLTRB(14, 0, 8, 8),
      child: Row(
        children: <Widget>[
          Text(
            context.l10n.showListPage_249(total),
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
          ),
          const Spacer(),
          for (final mode in _SortMode.values)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(mode),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  mode.labelOf(context),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: mode == selected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: mode == selected
                        ? colors.brand
                        : colors.textTertiary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
