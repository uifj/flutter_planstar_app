import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import '../../shared/ui/ps_floating_tab_bar.dart';
import '../../shared/ui/ps_shortcut_grid.dart';
import '../catalog/application/catalog_providers.dart';
import '../catalog/data/demo_catalog.dart';
import '../catalog/domain/show_category.dart';
import '../catalog/domain/show_summary.dart';
import 'application/home_shortcuts.dart';
import 'widgets/city_picker_sheet.dart';
import 'widgets/home_banner_floor.dart';
import 'widgets/home_choiceness_floor.dart';
import 'widgets/home_guarantee_floor.dart';
import 'widgets/home_header.dart';
import 'widgets/home_show_floor.dart';
import 'widgets/home_venues_floor.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/home_localizations.dart';

/// 首页（`layout_home.xml` + `HomeFragment`）。
///
/// ## 楼层顺序
///
/// 企划星的首页楼层由服务端 `HomeFloorBean` 列表驱动（`HomeMultiAdapter` 里注册了
/// 17 个 provider）。服务端不给我们数据，所以这里固定成一套**稳定可读**的顺序：
///
/// 1. 顶部（logo + 服务承诺 + 搜索栏，可收起）
/// 2. 分类快捷入口（5 列 × 2 行，超一页带指示器）
/// 3. 运营 banner（80dp，4 秒轮播）
/// 4. 服务保障条（26dp）
/// 5. 精选推荐（可横滑分类 tab + 105dp 卡片）
/// 6. 热门演出（76dp 卡片楼层）
/// 7. 分类楼层 ×4（演唱会 / 话剧歌剧 / 音乐会 / 儿童亲子）
/// 8. 热门场馆
/// 9. 页脚 logo
///
/// ## 与 Android 的差异（写在页面里，避免"看起来一样其实不同"）
///
/// - 没有"限时秒杀 / 品牌馆 / 城市日历 / 视频频道"这些运营楼层：
///   它们依赖服务端配置，没有数据源就无法正确渲染，硬造等于假功能。
/// - 分类快捷入口的图标用 Material 图标（原项目是 `drawable` 位图，未迁移）。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// 分类楼层（分类 id + 副标题）。
  static const List<(int, String)> _categoryFloors = <(int, String)>[
    (1, '演唱会 · 音乐节 · 巡演'),
    (2, '话剧 · 音乐剧 · 沉浸式'),
    (3, '交响 · 独奏 · 室内乐'),
    (4, '儿童剧 · 亲子活动'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final city = ref.watch(selectedCityProvider);
    final AsyncValue<List<ShowSummary>> showsAsync = ref.watch(
      cityShowsProvider,
    );
    final AsyncValue<List<ChoicenessGroup>> groupsAsync = ref.watch(
      choicenessGroupsProvider,
    );
    final AsyncValue<List<VenueSummary>> venuesAsync = ref.watch(
      popularVenuesProvider,
    );
    final categories =
        ref.watch(showCategoriesProvider).valueOrNull ?? const <ShowCategory>[];
    final topPadding = MediaQuery.paddingOf(context).top;

    return showsAsync.when(
      loading: () => _LoadingScaffold(topPadding: topPadding, city: city),
      error: (error, _) => _ErrorScaffold(
        topPadding: topPadding,
        city: city,
        error: error,
        onRetry: () => ref.read(showCatalogProvider.notifier).refresh(),
      ),
      data: (shows) {
        final showsById = <String, ShowSummary>{
          for (final show in shows) show.id: show,
        };
        final hints = _hints(shows);

        void openShow(ShowSummary show) => context.push('/show/${show.id}');

        void openSearch({String? keyword}) {
          final String query = (keyword ?? '').trim();
          context.push(
            query.isEmpty
                ? '/search'
                : '/search?q=${Uri.encodeQueryComponent(query)}',
          );
        }

        void openShows({int? categoryId, String? title}) {
          // 有分类 id 时优先进分类首页（更丰富的落地页）；
          // 无分类时进全部演出列表。
          if (categoryId != null) {
            context.push('/category/$categoryId');
          } else {
            context.push('/shows');
          }
        }

        final hotShows = <ShowSummary>[...shows]
          ..sort((a, b) => b.wishCount.compareTo(a.wishCount));

        final groups = groupsAsync.valueOrNull ?? const <ChoicenessGroup>[];
        final venues = venuesAsync.valueOrNull ?? const <VenueSummary>[];

        return AdaptiveScaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeHeader(
                  topPadding: topPadding,
                  city: city,
                  hints: hints,
                  onTapCity: () => CityPickerSheet.show(
                    context,
                    current: city,
                    onSelected: (next) {
                      ref.read(selectedCityProvider.notifier).select(next);
                      if (!citiesWithData.contains(next)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$next 暂无演出数据（演示数据仅覆盖部分城市）')),
                        );
                      }
                    },
                    onMore: () {
                      Navigator.of(context).maybePop();
                      context.push('/cities');
                    },
                  ),
                  onTapSearch: () => openSearch(),
                  onTapField: () => openSearch(),
                ),
              ),
              SliverToBoxAdapter(
                child: PsShortcutGrid(
                  items: buildCategoryShortcuts(
                    categories: categories,
                    onTap: (category) => openShows(
                      categoryId: category.id,
                      title: category.name,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: HomeBannerFloor(
                  onTap: (slide) {
                    if (slide.showId != null) {
                      context.push('/show/${slide.showId}');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${slide.title} · 运营活动页（演示）')),
                      );
                    }
                  },
                ),
              ),
              const SliverToBoxAdapter(child: HomeGuaranteeFloor()),
              if (shows.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: PsEmptyState(
                      title: '$city 暂无演出',
                      description: HomeLocalizations.of(context).homePage_176,
                      icon: LucideIcons.building2,
                      actionLabel: HomeLocalizations.of(context).homePage_178,
                      onAction: () =>
                          ref.read(selectedCityProvider.notifier).select(HomeLocalizations.of(context).cityListPage_57),
                    ),
                  ),
                )
              else ...<Widget>[
                SliverToBoxAdapter(
                  child: HomeChoicenessFloor(
                    groups: groups,
                    onTapShow: openShow,
                  ),
                ),
                SliverToBoxAdapter(
                  child: HomeShowFloor(
                    title: HomeLocalizations.of(context).homePage_193,
                    description: HomeLocalizations.of(context).homePage_194,
                    shows: hotShows.take(8).toList(growable: false),
                    onTapShow: openShow,
                    onTapMore: () => openShows(),
                  ),
                ),
                for (final (categoryId, desc) in _categoryFloors)
                  SliverToBoxAdapter(
                    child: HomeShowFloor(
                      title: _floorTitle(categoryId),
                      description: desc,
                      shows: shows
                          .where((show) => show.categoryId == categoryId)
                          .toList(growable: false),
                      onTapShow: openShow,
                      onTapMore: () => openShows(
                        categoryId: categoryId,
                        title: _floorTitle(categoryId),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: HomeVenuesFloor(
                    venues: venues,
                    showsById: showsById,
                    onTapVenue: (venue) => context.push(
                      '/venue/${Uri.encodeComponent(venue.name)}',
                    ),
                    onTapShow: openShow,
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 24,
                    bottom: PsFloatingTabBar.bottomClearance(context),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(LucideIcons.sparkles,
                              size: 14, color: colors.textDisabled),
                          const SizedBox(width: 4),
                          Text(
                            HomeLocalizations.of(context).homePage_241,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        HomeLocalizations.of(context).homePage_251,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _floorTitle(int categoryId) {
    return switch (categoryId) {
      1 => '演唱会',
      2 => '话剧歌剧',
      3 => '音乐会',
      4 => '儿童亲子',
      _ => '演出',
    };
  }

  static List<String> _hints(List<ShowSummary> shows) {
    final sorted = <ShowSummary>[...shows]
      ..sort((a, b) => b.wishCount.compareTo(a.wishCount));
    return sorted
        .take(5)
        .map(
          (show) => show.title.length > 14
              ? '${show.title.substring(0, 14)}…'
              : show.title,
        )
        .toList(growable: false);
  }
}

/// 首页加载态（代码绘制的进度指示 + 骨架屏）。
class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold({required this.topPadding, required this.city});

  final double topPadding;
  final String city;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return AdaptiveScaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: topPadding + 60),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: colors.brand,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '正在加载 $city 的演出…',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 首页错误态（可重试）。
class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({
    required this.topPadding,
    required this.city,
    required this.error,
    required this.onRetry,
  });

  final double topPadding;
  final String city;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: topPadding + 60),
              child: PsEmptyState(
                title: HomeLocalizations.of(context).homePage_363,
                description: '无法获取 $city 的演出数据\n${error.toString()}',
                icon: LucideIcons.wifiOff,
                actionLabel: AppLocalizations.of(context).actionRetry,
                onAction: onRetry,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
