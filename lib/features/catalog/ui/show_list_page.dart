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

/// 企划列表页（「分类列表」与「热门列表」的合并版）。
///
/// ## 为什么把两个页面合成一个
///
/// 「分类列表」和「热门列表」是两个入口，但除了**标题和默认排序**
/// 之外完全一样：同一张列表卡片、同一套渲染逻辑、
/// 同一套分页参数。差异只有入口带的 `categoryId` 和默认 `sort`。
/// 合成一个页面 + 两个 query 参数（`category` / `title`），
/// 比复制一份 400 行列表页更好维护——这也是 Flutter 侧一直的做法
/// （见 `ShowCardRow` 被搜索结果/相似推荐共用）。
///
/// ## 分页与筛选
///
/// - 分类与排序都交给服务端（`categoryId` / `sort`），分页用
///   `NotificationListener` 监听滚动到底部时调用 `showFeedProvider` 的
///   `loadMore()`，按 `page/pageSize` 追加；演示数据一次给全。
/// - 价格升序后端没有对应排序，只能对已加载的页本地排序——这是已知取舍。
/// - 不做「筛选」抽屉（价格区间/时间/活动场地）；这里只保留排序。
///   筛选需要服务端支持多维聚合，客户端硬筛会把"筛完是空"变成常态。
class ShowListPage extends ConsumerStatefulWidget {
  const ShowListPage({super.key, this.categoryId, this.title});

  /// 一级分类 id。`null` = 不限分类（「全部企划」）。
  final int? categoryId;

  /// 页面标题。`null` 时按分类名兜底，再兜底成「全部企划」。
  final String? title;

  @override
  ConsumerState<ShowListPage> createState() => _ShowListPageState();
}

class _ShowListPageState extends ConsumerState<ShowListPage> {
  /// 当前分类。`null` = 全部。
  late int? _categoryId = widget.categoryId;

  _SortMode _sort = _SortMode.recommended;

  bool _loadingMore = false;
  bool _exhausted = false;

  ShowFeedQuery get _query =>
      ShowFeedQuery(categoryId: _categoryId, sort: _sort.apiSort);

  /// 触底追加下一页；失败时 provider 会保留已有列表并把 `hasMore` 置 false。
  Future<void> _loadMore() async {
    if (_loadingMore || _exhausted) return;
    final notifier = ref.read(showFeedProvider(_query).notifier);
    if (!notifier.hasMore) {
      setState(() => _exhausted = true);
      return;
    }
    setState(() => _loadingMore = true);
    await notifier.loadMore();
    if (!mounted) return;
    setState(() {
      _loadingMore = false;
      _exhausted = !notifier.hasMore;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final showsAsync = ref.watch(showFeedProvider(_query));
    final shows = _sorted(showsAsync.valueOrNull ?? const <ShowSummary>[]);
    final categories = ref.watch(showCategoriesProvider);
    final hasError = showsAsync.hasError && !showsAsync.hasValue;
    final isLoading = showsAsync.isLoading && !showsAsync.hasValue;

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: _titleOf(categories)),
      body: Column(
        children: <Widget>[
          _CategoryBar(
            categories: categories,
            selected: _categoryId,
            onSelect: (int? id) => setState(() {
              if (id == _categoryId) return;
              _categoryId = id;
              _exhausted = false;
              _loadingMore = false;
            }),
          ),
          _SortBar(
            selected: _sort,
            total: shows.length,
            onSelect: (_SortMode mode) => setState(() {
              if (mode == _sort) return;
              _sort = mode;
              _exhausted = false;
              _loadingMore = false;
            }),
          ),
          Container(height: 1, color: colors.divider),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : hasError
                ? PsEmptyState(
                    title: context.l10n.showListPage_78,
                    description: psErrorMessage(showsAsync.error!),
                    icon: LucideIcons.wifiOff,
                    actionLabel: context.l10n.actionRetry,
                    onAction: () => ref.invalidate(showFeedProvider(_query)),
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
                      if (notification.metrics.axis == Axis.vertical &&
                          notification.metrics.extentAfter < 300) {
                        _loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      // 末尾一项是加载状态 / 没有更多。
                      itemCount: shows.length + 1,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: colors.divider,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == shows.length) {
                          return _FeedFooter(
                            loading: _loadingMore,
                            exhausted: _exhausted,
                          );
                        }
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

  /// 服务端已经按分类过滤、按 `sort` 排好序；只有价格升序需要本地兜底
  /// （后端没有价格排序参数），此时只对已加载的页排序。
  List<ShowSummary> _sorted(List<ShowSummary> source) {
    if (_sort != _SortMode.priceAsc) return source;
    return <ShowSummary>[
      ...source,
    ]..sort((a, b) => a.priceFrom.minorUnits.compareTo(b.priceFrom.minorUnits));
  }
}

/// 排序方式。
enum _SortMode {
  recommended,
  soonest,
  priceAsc;

  /// 对应的 `/v1/projects` 排序枚举；价格升序后端没有，退回默认排序。
  String get apiSort => switch (this) {
    _SortMode.recommended => 'hot',
    _SortMode.soonest => 'ending',
    _SortMode.priceAsc => 'hot',
  };

  String labelOf(BuildContext context) => switch (this) {
    _SortMode.recommended => context.l10n.showListPage_140,
    _SortMode.soonest => context.l10n.showListPage_141,
    _SortMode.priceAsc => context.l10n.showListPage_142,
  };
}

/// 列表末尾的加载状态：加载中转圈，到底了给「没有更多」。
class _FeedFooter extends StatelessWidget {
  const _FeedFooter({required this.loading, required this.exhausted});

  final bool loading;
  final bool exhausted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: loading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.brand,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.homeFeedLoading,
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                ],
              )
            : exhausted
            ? Text(
                context.l10n.homeFeedEnd,
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              )
            : const SizedBox(height: 20),
      ),
    );
  }
}

/// 分类筛选条（横向 tab）。
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
