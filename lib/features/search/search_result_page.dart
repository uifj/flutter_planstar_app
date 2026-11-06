import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import '../catalog/application/catalog_providers.dart';
import '../catalog/domain/show_summary.dart';
import '../catalog/ui/show_cards.dart';
import '../discover/domain/feed_post.dart';
import '../discover/widgets/feed_card.dart';
import 'application/search_providers.dart';
import 'domain/search_models.dart';
import 'search_l10n.dart';
import '../../l10n/l10n.dart';

/// 搜索结果页（企划星 `SearchResultActivity` + 5 个 `SearchResult*Fragment`）。
///
/// ## 查询词来自路由
///
/// `query` 是构造参数（路由 `/search/result?q=...`），不是全局 provider。
/// 这样结果页是**纯函数式**的：同一个词永远出同一份结果，返回再进入也不会
/// 读到上一个词。原因写在 `search_providers.dart` 的 `searchResultsProvider`。
///
/// ## 分域
///
/// 「全部 / 演出 / 动态」三栏。原项目还有「商品」栏，本项目没有商品数据源，
/// 所以**不声明**它——见 `SearchScope` 的注释。
///
/// ## 「全部」栏只给预览
///
/// 每类最多 3 条 + 「查看全部」跳到对应分域。企划星的「全部」也是这个策略，
/// 否则用户永远不会点开分域 tab。
class SearchResultPage extends ConsumerStatefulWidget {
  const SearchResultPage({super.key, required this.query});

  final String query;

  @override
  ConsumerState<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends ConsumerState<SearchResultPage> {
  SearchScope _scope = SearchScope.all;

  /// 「全部」栏每类的预览条数。
  static const int _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final SearchResults results = ref.watch(
      searchResultsProvider(widget.query),
    );

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(titleWidget: _buildQueryPill(colors)),
      body: Column(
        children: <Widget>[
          _ScopeTabs(
            selected: _scope,
            results: results,
            onSelect: (SearchScope scope) => setState(() => _scope = scope),
          ),
          Container(height: 1, color: colors.divider),
          Expanded(
            child: results.isEmpty
                ? PsEmptyState.search(onAction: () => context.pop())
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: _buildSections(context, results),
                  ),
          ),
        ],
      ),
    );
  }

  /// 顶部的查询词胶囊，点击回到搜索页改词。
  Widget _buildQueryPill(AppColors colors) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.pop(),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colors.bgSubtle,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: <Widget>[
            Icon(LucideIcons.search, size: 16, color: colors.textTertiary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.query,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: colors.textPrimary),
              ),
            ),
            Icon(LucideIcons.pencil, size: 13, color: colors.textDisabled),
          ],
        ),
      ),
    );
  }

  /// 按当前分域拼列表。
  List<Widget> _buildSections(BuildContext context, SearchResults results) {
    final List<ShowSummary> shows = switch (_scope) {
      SearchScope.all => results.shows.take(_previewCount).toList(),
      SearchScope.shows => results.shows,
      SearchScope.feeds => const <ShowSummary>[],
    };
    final List<FeedPost> feeds = switch (_scope) {
      SearchScope.all => results.feeds.take(_previewCount).toList(),
      SearchScope.feeds => results.feeds,
      SearchScope.shows => const <FeedPost>[],
    };

    return <Widget>[
      if (shows.isNotEmpty) ...<Widget>[
        _SectionHeader(
          title: context.l10n.searchResultPage_125,
          count: results.shows.length,
          moreLabel:
              _scope == SearchScope.all && results.shows.length > _previewCount
              ? context.l10n.searchResultPage_129
              : null,
          onMore: () => setState(() => _scope = SearchScope.shows),
        ),
        for (final ShowSummary show in shows)
          ShowCardRow(
            show: show,
            onTap: () => context.push('/show/${show.id}'),
          ),
      ],
      if (feeds.isNotEmpty) ...<Widget>[
        _SectionHeader(
          title: context.l10n.searchResultPage_142,
          count: results.feeds.length,
          moreLabel:
              _scope == SearchScope.all && results.feeds.length > _previewCount
              ? context.l10n.searchResultPage_146
              : null,
          onMore: () => setState(() => _scope = SearchScope.feeds),
        ),
        for (final FeedPost post in feeds)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: FeedCard(
              post: post,
              show: post.showId == null
                  ? null
                  : ref.watch(showByIdProvider(post.showId!)),
              onTap: () => context.push('/feed/${post.id}'),
            ),
          ),
      ],
    ];
  }
}

/// 分域 tab（等宽、下划线）。
class _ScopeTabs extends StatelessWidget {
  const _ScopeTabs({
    required this.selected,
    required this.results,
    required this.onSelect,
  });

  final SearchScope selected;
  final SearchResults results;
  final void Function(SearchScope scope) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      height: 42,
      child: Row(
        children: <Widget>[
          for (final SearchScope scope in SearchScope.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(scope),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${scope.labelOf(context)} ${results.countOf(scope)}',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: scope == selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: scope == selected
                            ? colors.brand
                            : colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 24,
                      height: 2,
                      color: scope == selected
                          ? colors.brand
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 分区标题（演出 12 / 动态 4）。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    this.moreLabel,
    this.onMore,
  });

  final String title;
  final int count;
  final String? moreLabel;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
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
          const Spacer(),
          if (moreLabel != null && onMore != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onMore,
              child: Row(
                children: <Widget>[
                  Text(
                    moreLabel!,
                    style: TextStyle(fontSize: 11, color: colors.textTertiary),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 12,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
