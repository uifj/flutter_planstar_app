import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import '../../shared/ui/ps_floating_tab_bar.dart';
import '../catalog/application/catalog_providers.dart';
import '../catalog/domain/show_summary.dart';
import 'application/feed_providers.dart';
import 'domain/feed_post.dart';
import 'widgets/feed_card.dart';
import 'widgets/publish_sheet.dart';
import '../../l10n/l10n.dart';

/// 发现 Tab（`fragment_discovery.xml`）。
///
/// ## 结构
///
/// - 顶部 44dp 条：左侧搜索图标（50dp 宽、左右 15dp 内边距），中间两个 tab
///   （17sp 粗体、`pstsIndicatorHeight=0` 即无下划线，靠**字色**区分选中）；
/// - 下方是双列瀑布流（`home_item_waterfall_feed.xml` 的深色卡）；
/// - 右下角 42dp 发布按钮（`btnNewPost`，`marginEnd=11`、`marginBottom=14`）。
///
/// ## 瀑布流实现
///
/// 没有引入 `flutter_staggered_grid_view`：卡片只有"标题 1 行 / 2 行"两种高度，
/// 用"两列 `Column` 交替装填"就能得到真正的瀑布流，且不增加依赖。
/// 20 条数据全量构建，滚动性能足够；接真实分页时再换 `SliverGrid`。
class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  List<String> get _tabs => <String>[
    context.l10n.discoverPage_39,
    context.l10n.discoverPage_39_2,
  ];
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final hot = ref.watch(feedControllerProvider);
    final following = ref.watch(followingFeedProvider);
    final posts = _tab == 0 ? hot : following;

    // 动态详情页（`/feed/:id`）。以前这里只有一条 toast——`showId` 非空时
    // 跳演出、为空时什么也不做。现在每条动态都有详情页，关联演出的那条
    // 在详情页里再给「查看演出」入口，层级比"卡片直接跳走"更合理：
    // 用户点的是这条动态，不是那场演出。
    void openPost(FeedPost post) => context.push('/feed/${post.id}');

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              _DiscoveryTopBar(
                tabs: _tabs,
                selected: _tab,
                onSelect: (index) => setState(() => _tab = index),
                // 搜索图标进独立的搜索页（原先是 `context.go('/')` 回首页，
                // 那是"点了没反应"的同义词）。
                onTapSearch: () => context.push('/search'),
              ),
              Expanded(
                child: posts.isEmpty
                    ? PsEmptyState(
                        title: context.l10n.discoverPage_72,
                        description: context.l10n.discoverPage_73,
                        icon: LucideIcons.users,
                        actionLabel: context.l10n.discoverPage_75,
                        onAction: () => setState(() => _tab = 0),
                      )
                    : _MasonryFeed(posts: posts, onTapPost: openPost),
              ),
            ],
          ),
          Positioned(
            right: 11,
            bottom: 14,
            child: _PublishButton(
              onTap: () => PublishSheet.show(
                context,
                onPublish: (title) {
                  ref
                      .read(feedControllerProvider.notifier)
                      .publish(
                        title,
                        author: context.l10n.feedProviders_18,
                        tag: context.l10n.feedProviders_25,
                      );
                  setState(() => _tab = 0);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶部条（`layout_search` 44dp）。
class _DiscoveryTopBar extends StatelessWidget {
  const _DiscoveryTopBar({
    required this.tabs,
    required this.selected,
    required this.onSelect,
    required this.onTapSearch,
  });

  final List<String> tabs;
  final int selected;
  final void Function(int index) onSelect;
  final VoidCallback onTapSearch;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 44,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (var i = 0; i < tabs.length; i++)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onSelect(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              tabs[i],
                              style: TextStyle(
                                fontSize: 17,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: i == selected
                                    ? colors.brand
                                    : colors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTapSearch,
                    child: SizedBox(
                      width: 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Icon(
                          LucideIcons.search,
                          size: 20,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // shadow_gray_to_trans：3dp 的下投影，分隔顶部条与内容。
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0x14000000), Color(0x00000000)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 双列瀑布流。
class _MasonryFeed extends ConsumerWidget {
  const _MasonryFeed({required this.posts, required this.onTapPost});

  final List<FeedPost> posts;
  final void Function(FeedPost post) onTapPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final left = <FeedPost>[];
    final right = <FeedPost>[];
    for (var i = 0; i < posts.length; i++) {
      (i.isEven ? left : right).add(posts[i]);
    }

    Widget buildCard(FeedPost post) {
      final showId = post.showId;
      final ShowSummary? show = showId == null
          ? null
          : ref.watch(showByIdProvider(showId));
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FeedCard(post: post, show: show, onTap: () => onTapPost(post)),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        PsFloatingTabBar.bottomClearance(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[for (final post in left) buildCard(post)],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: <Widget>[for (final post in right) buildCard(post)],
            ),
          ),
        ],
      ),
    );
  }
}

/// 发布按钮（`btnNewPost` 42×42）。
class _PublishButton extends StatelessWidget {
  const _PublishButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[colors.brand, colors.brandPressed],
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x33FF317B),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(LucideIcons.pencil, size: 20, color: Colors.white),
      ),
    );
  }
}
