import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/ui/ps_empty_state.dart';
import '../application/catalog_providers.dart';
import '../domain/show_summary.dart';
import 'show_cards.dart';

/// 精品 / 新企划 / 已达成三个落地页的集合类型。
enum ShowCollectionKind {
  /// 精品：按热度精选。
  featured,

  /// 新企划：按最近开演时间排序。
  newProjects,

  /// 已达成：只保留已达成目标的企划。
  achieved;

  String titleOf(BuildContext context) => switch (this) {
    ShowCollectionKind.featured => context.l10n.homeCollectionFeaturedTitle,
    ShowCollectionKind.newProjects => context.l10n.homeCollectionNewTitle,
    ShowCollectionKind.achieved => context.l10n.homeCollectionAchievedTitle,
  };

  String descriptionOf(BuildContext context) => switch (this) {
    ShowCollectionKind.featured => context.l10n.homeCollectionFeaturedDesc,
    ShowCollectionKind.newProjects => context.l10n.homeCollectionNewDesc,
    ShowCollectionKind.achieved => context.l10n.homeCollectionAchievedDesc,
  };

  /// 对应的服务端查询条件。
  ///
  /// 筛选与排序全部交给 `/v1/projects`，不再「拉一页全量再本地过滤」——
  /// 每页只有 20 条时本地过滤会得到很稀疏甚至为空的结果。
  ShowFeedQuery get query => switch (this) {
    ShowCollectionKind.featured => const ShowFeedQuery(
      sort: 'hot',
      onlyProjects: true,
    ),
    ShowCollectionKind.newProjects => const ShowFeedQuery(
      sort: 'new',
      onlyProjects: true,
    ),
    ShowCollectionKind.achieved => const ShowFeedQuery(
      fundingStatus: 'achieved',
      sort: 'hot',
    ),
  };
}

/// 首页快捷入口的落地页：精品 / 新企划 / 已达成。
///
/// 列表按服务端分页触底续拉，末尾给出加载中 / 没有更多的边界提示。
class ShowCollectionPage extends ConsumerStatefulWidget {
  const ShowCollectionPage({super.key, required this.kind});

  final ShowCollectionKind kind;

  @override
  ConsumerState<ShowCollectionPage> createState() => _ShowCollectionPageState();
}

class _ShowCollectionPageState extends ConsumerState<ShowCollectionPage> {
  /// 触底加载的提前量：距底部不足该距离就开始请求下一页。
  static const double _loadMoreThreshold = 300;

  bool _loadingMore = false;
  bool _exhausted = false;

  Future<void> _loadMore() async {
    if (_loadingMore || _exhausted) return;
    final notifier = ref.read(showFeedProvider(widget.kind.query).notifier);
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
    final query = widget.kind.query;
    final showsAsync = ref.watch(showFeedProvider(query));
    final shows = showsAsync.valueOrNull ?? const <ShowSummary>[];
    final hasError = showsAsync.hasError && !showsAsync.hasValue;

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: widget.kind.titleOf(context)),
      body: hasError
          ? PsEmptyState(
              title: context.l10n.showListPage_78,
              description: psErrorMessage(showsAsync.error!),
              icon: LucideIcons.wifiOff,
              actionLabel: context.l10n.actionRetry,
              onAction: () => ref.invalidate(showFeedProvider(query)),
            )
          : shows.isEmpty
          ? PsEmptyState(
              title: context.l10n.showListPage_78,
              description: context.l10n.showListPage_79,
              icon: LucideIcons.inbox,
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.metrics.axis == Axis.vertical &&
                    notification.metrics.extentAfter < _loadMoreThreshold) {
                  _loadMore();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 24),
                // 首项是描述文案，最后一项是加载状态。
                itemCount: shows.length + 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        widget.kind.descriptionOf(context),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                    );
                  }
                  if (index == shows.length + 1) {
                    return _FeedFooter(
                      loading: _loadingMore,
                      exhausted: _exhausted,
                    );
                  }
                  final show = shows[index - 1];
                  return Column(
                    children: <Widget>[
                      ShowCardRow(
                        show: show,
                        onTap: () => context.push('/show/${show.id}'),
                      ),
                      if (index < shows.length)
                        Divider(height: 1, thickness: 1, color: colors.divider),
                    ],
                  );
                },
              ),
            ),
    );
  }
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
