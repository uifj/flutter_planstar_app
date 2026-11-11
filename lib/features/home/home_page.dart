import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import '../../shared/ui/ps_floating_tab_bar.dart';
import '../../shared/ui/ps_shortcut_grid.dart';
import '../../app/network/network_providers.dart';
import '../catalog/application/catalog_providers.dart';
import '../catalog/data/demo_catalog.dart';
import '../catalog/data/planstar_catalog_api.dart';
import '../catalog/domain/show_category.dart';
import '../catalog/domain/show_summary.dart';
import 'application/home_shortcuts.dart';
import 'widgets/city_picker_sheet.dart';
import 'widgets/home_banner_floor.dart';
import 'widgets/home_choiceness_floor.dart';
import 'widgets/home_guarantee_floor.dart';
import 'widgets/home_header.dart';
import 'widgets/home_ranking_floor.dart';
import 'widgets/home_show_floor.dart';
import '../../l10n/l10n.dart';

/// 首页。
///
/// ## 楼层顺序
///
/// 首页楼层本可由服务端下发的楼层列表驱动，但服务端不给我们数据，
/// 所以这里固定成一套**稳定可读**的顺序：
///
/// 1. 顶部（logo + 服务承诺 + 搜索栏，可收起）
/// 2. 分类快捷入口（5 列 × 2 行，超一页带指示器）
/// 3. 运营 banner（80dp，4 秒轮播）
/// 4. 服务保障条（26dp）
/// 5. 精选企划（可横滑分类 tab + 105dp 企划卡）
/// 6. 正在支持的企划（76dp 卡片楼层）
/// 7. 企划榜单（热度 / 达成 / 冲刺三榜切换）
/// 8. 分类楼层 ×4（游戏 / 小说 / 同人 / 面经）
/// 9. 页脚 logo
///
/// ## 刻意不做的事（写在页面里，避免"看起来一样其实不同"）
///
/// - 没有"限时秒杀 / 品牌馆 / 城市日历 / 视频频道"这些运营楼层：
///   它们依赖服务端配置，没有数据源就无法正确渲染，硬造等于假功能。
/// - 分类快捷入口的图标用 Lucide 矢量图标（仓库里没有分类位图素材）。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// 分类楼层（分类 id）：游戏 / 小说 / 同人 / 面经四大主品类。
  static const List<int> _categoryFloorIds = <int>[1, 2, 3, 4];

  /// 从运营位链接里提取企划 id（`.../show/2001`）。
  static String? _showIdFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    return RegExp(r'/show/([^/?#]+)').firstMatch(url)?.group(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    // 企划数据没有城市维度（全国发行）：真实模式固定展示「全国」，
    // 且不提供城市切换入口；demo 数据仍按城市过滤。
    final policy = ref.watch(dataSourcePolicyProvider);
    final String city = policy.isDemo ? ref.watch(selectedCityProvider) : '全国';
    final AsyncValue<List<ShowSummary>> showsAsync = ref.watch(
      cityShowsProvider,
    );
    final AsyncValue<List<ChoicenessGroup>> groupsAsync = ref.watch(
      choicenessGroupsProvider,
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
          // 无分类时进全部企划列表。
          if (categoryId != null) {
            context.push('/category/$categoryId');
          } else {
            context.push('/shows');
          }
        }

        // 热门楼层优先用服务端 `v1/projects/hot`；首帧/失败时用当前列表
        // 按想看数兜底，避免楼层空着。
        final hotShows =
            ref.watch(hotShowsProvider).valueOrNull ??
            (<ShowSummary>[...shows]
              ..sort((a, b) => b.wishCount.compareTo(a.wishCount)));

        final groups = groupsAsync.valueOrNull ?? const <ChoicenessGroup>[];
        final banners =
            ref.watch(homeBannersProvider).valueOrNull ?? const <BannerDto>[];
        final bannerSlides = banners.isEmpty
            ? null
            : <BannerSlide>[
                for (final banner in banners)
                  BannerSlide(
                    title: banner.title.isEmpty
                        ? context.l10n.homeProjectPicked
                        : banner.title,
                    subtitle: context.l10n.homeProjectBannerSubtitle,
                    badge: '推荐',
                    colors: (Color(0xFFFF6AB9), Color(0xFFFE3870)),
                    showId: banner.showId ?? _showIdFromUrl(banner.url),
                    imageUrl: banner.image.isEmpty ? null : banner.image,
                  ),
              ];

        return AdaptiveScaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeHeader(
                  topPadding: topPadding,
                  city: city,
                  hints: hints,
                  onTapCity: policy.isDemo
                      ? () => CityPickerSheet.show(
                          context,
                          current: city,
                          onSelected: (next) {
                            ref
                                .read(selectedCityProvider.notifier)
                                .select(next);
                            if (!citiesWithData.contains(next)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.homePage_132(next),
                                  ),
                                ),
                              );
                            }
                          },
                          onMore: () {
                            Navigator.of(context).maybePop();
                            context.push('/cities');
                          },
                        )
                      : null,
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
                  slides: bannerSlides,
                  onTap: (slide) {
                    if (slide.showId != null) {
                      context.push('/show/${slide.showId}');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.homePage_163(slide.title)),
                        ),
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
                    child: policy.isDemo
                        ? PsEmptyState(
                            title: context.l10n.homePage_175(city),
                            description: context.l10n.homePage_176,
                            icon: LucideIcons.building2,
                            actionLabel: context.l10n.homePage_178,
                            onAction: () => ref
                                .read(selectedCityProvider.notifier)
                                .select(context.l10n.cityListPage_57),
                          )
                        : PsEmptyState(
                            title: context.l10n.homePage_175(city),
                            description: context.l10n.showListPage_79,
                            icon: LucideIcons.inbox,
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
                    title: context.l10n.homeHotProjectTitle,
                    description: context.l10n.homeHotProjectDesc,
                    shows: hotShows.take(8).toList(growable: false),
                    onTapShow: openShow,
                    onTapMore: () => openShows(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: HomeRankingFloor(shows: shows, onTapShow: openShow),
                ),
                for (final categoryId in _categoryFloorIds)
                  SliverToBoxAdapter(
                    child: HomeShowFloor(
                      title: _floorTitle(context, categoryId),
                      description: _categoryDescription(context, categoryId),
                      shows: shows
                          .where((show) => show.categoryId == categoryId)
                          .toList(growable: false),
                      onTapShow: openShow,
                      onTapMore: () => openShows(
                        categoryId: categoryId,
                        title: _floorTitle(context, categoryId),
                      ),
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
                          Icon(
                            LucideIcons.sparkles,
                            size: 14,
                            color: colors.textDisabled,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.homePage_241,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.homePage_251,
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

  static String _floorTitle(BuildContext context, int categoryId) {
    return switch (categoryId) {
      1 => context.l10n.homeFloorGame,
      2 => context.l10n.homeFloorNovel,
      3 => context.l10n.homeFloorDoujin,
      4 => context.l10n.homeFloorInterview,
      _ => context.l10n.homeFloorOther,
    };
  }

  static String _categoryDescription(BuildContext context, int categoryId) {
    return switch (categoryId) {
      1 => context.l10n.homeFloorGameDesc,
      2 => context.l10n.homeFloorNovelDesc,
      3 => context.l10n.homeFloorDoujinDesc,
      _ => context.l10n.homeFloorInterviewDesc,
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
                      context.l10n.homePage_323(city),
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
                title: context.l10n.homePage_363,
                description: context.l10n.homePage_364(
                  city,
                  psErrorMessage(error),
                ),
                icon: LucideIcons.wifiOff,
                actionLabel: context.l10n.actionRetry,
                onAction: onRetry,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
