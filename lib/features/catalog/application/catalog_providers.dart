import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/demo_catalog.dart';
import '../data/demo_categories.dart';
import '../data/planstar_catalog_api.dart';
import '../domain/show_category.dart';
import '../domain/show_summary.dart';
import 'catalog_api_providers.dart';

// ── 演出库 ──────────────────────────────────────────────────────────────

/// 演出库（全量）。
///
/// demo 与真实数据由 `useDemoProvider`（编译期 `PS_USE_DEMO`）决定，
/// 默认走网络；所有页面都从这一个人口读数据，分页/刷新只在这里做一次。
final showCatalogProvider =
    AsyncNotifierProvider<ShowCatalogController, List<ShowSummary>>(
      ShowCatalogController.new,
    );

class ShowCatalogController extends AsyncNotifier<List<ShowSummary>> {
  static const int _pageSize = 100;

  int _pageIndex = 1;
  bool _hasMore = true;
  String? _city;

  /// 是否还有下一页（给列表页做触底加载用）。
  bool get hasMore => _hasMore;

  @override
  Future<List<ShowSummary>> build() async {
    _pageIndex = 1;
    _hasMore = true;
    if (ref.watch(useDemoProvider)) {
      // 演示数据一次给全，不做分页。
      _hasMore = false;
      return buildDemoCatalog();
    }
    // 城市切换由 provider 重建承担：服务端按 city 过滤，避免超过一页后
    // 当前城市的数据被挤到后面几页而查不到。
    _city = ref.watch(selectedCityProvider);
    final first = await _fetchPage(1);
    // 首页数据不足一页即没有下一页，避免触底时多打一次空请求。
    _hasMore = first.length >= _pageSize;
    return first;
  }

  Future<List<ShowSummary>> _fetchPage(int pageIndex) async {
    final PlanstarCatalogApi api = ref.read(planstarCatalogApiProvider);
    final result = await api.fetchShows(
      city: _city,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    );
    return result.fold(
      onSuccess: (shows) => shows,
      onFailure: (failure) => throw failure, // AsyncValue 会捕获为 error 态
    );
  }

  Future<void> refresh() async {
    _pageIndex = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (ref.read(useDemoProvider)) {
        _hasMore = false;
        return buildDemoCatalog();
      }
      _city = ref.read(selectedCityProvider);
      final first = await _fetchPage(1);
      _hasMore = first.length >= _pageSize;
      return first;
    });
  }

  /// 加载下一页并追加到当前列表；失败时保留已有数据。
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    if (ref.read(useDemoProvider)) return;
    final current = state.valueOrNull;
    if (current == null) return;

    try {
      final next = await _fetchPage(_pageIndex + 1);
      _pageIndex += 1;
      if (next.isEmpty) {
        _hasMore = false;
        return;
      }
      state = AsyncValue.data(<ShowSummary>[...current, ...next]);
    } catch (_) {
      // 触底加载失败不覆盖已有列表，避免整页变错误态。
      _hasMore = false;
    }
  }
}

/// 按 id 取演出。查不到返回 `null`（不是抛异常）——深链带了脏 id 是正常情况。
final showByIdProvider = Provider.family<ShowSummary?, String>((ref, id) {
  final AsyncValue<List<ShowSummary>> asyncShows = ref.watch(
    showCatalogProvider,
  );
  final List<ShowSummary> shows =
      asyncShows.valueOrNull ?? const <ShowSummary>[];
  for (final show in shows) {
    if (show.id == id) return show;
  }
  return null;
});

// ── 城市 ────────────────────────────────────────────────────────────────

/// 当前城市。
final selectedCityProvider = NotifierProvider<SelectedCityController, String>(
  SelectedCityController.new,
);

class SelectedCityController extends Notifier<String> {
  @override
  String build() => '上海';

  void select(String city) => state = city;
}

/// 当前城市的演出。
final cityShowsProvider = Provider<AsyncValue<List<ShowSummary>>>((ref) {
  final city = ref.watch(selectedCityProvider);
  final AsyncValue<List<ShowSummary>> asyncShows = ref.watch(
    showCatalogProvider,
  );
  return asyncShows.whenData(
    (shows) => shows.where((show) => show.city == city).toList(growable: false),
  );
});

/// 当前城市是否有演出数据（用于区分"空态"与"加载中"）。
final cityHasDataProvider = Provider<bool>(
  (ref) => ref.watch(cityShowsProvider).valueOrNull?.isNotEmpty ?? false,
);

// ── 分类 ────────────────────────────────────────────────────────────────

/// 分类目录。
///
/// 后端没有独立的分类端点，真实模式下从活动列表的 `categoryId/categoryName`
/// 聚合；demo 模式继续用编译期分类数据。
final showCategoriesProvider = FutureProvider<List<ShowCategory>>((ref) async {
  if (ref.watch(useDemoProvider)) {
    return demoCategories.where((c) => c.isActive).toList(growable: false);
  }

  final shows = await ref.watch(showCatalogProvider.future);
  final seen = <int, ShowCategory>{};
  for (final show in shows) {
    if (show.categoryId == 0) continue;
    seen.putIfAbsent(
      show.categoryId,
      () => ShowCategory(
        id: show.categoryId,
        name: show.categoryName.isEmpty ? '其他' : show.categoryName,
        enName: '',
        pinyin: '',
        subTags: const <SubCategoryTag>[],
      ),
    );
  }
  return seen.values.toList(growable: false);
});

// ── 首页 Banner / 热门 ──────────────────────────────────────────────────

/// 首页 Banner；demo 模式返回空列表，由页面继续用内置视觉兜底。
final homeBannersProvider = FutureProvider<List<BannerDto>>((ref) async {
  if (ref.watch(useDemoProvider)) return const <BannerDto>[];
  final result = await ref.watch(planstarCatalogApiProvider).fetchBanners();
  return result.getOrElse((_) => const <BannerDto>[]);
});

/// 热门演出；demo 模式按想看人数排序，真实模式走 `/v1/activities/hot`。
final hotShowsProvider = FutureProvider<List<ShowSummary>>((ref) async {
  if (ref.watch(useDemoProvider)) {
    final city = ref.watch(selectedCityProvider);
    final shows = await ref.watch(showCatalogProvider.future);
    final sorted = shows.where((show) => show.city == city).toList()
      ..sort((a, b) => b.wishCount.compareTo(a.wishCount));
    return sorted;
  }
  final result = await ref
      .watch(planstarCatalogApiProvider)
      .fetchHotShows(pageIndex: 1, pageSize: 20);
  return result.getOrElse((_) => const <ShowSummary>[]);
});

/// 演出详情（真实模式调用 `/v3/activities/{id}`，失败时由页面回退到列表数据）。
final showDetailProvider = FutureProvider.family<ShowSummary?, String>((
  ref,
  id,
) async {
  if (ref.watch(useDemoProvider)) return ref.watch(showByIdProvider(id));
  final result = await ref
      .watch(planstarCatalogApiProvider)
      .fetchShowDetail(id);
  return result.getOrElse((_) => null);
});

/// 演出完整信息：详情接口优先，列表项兜底。
///
/// 列表接口（`/v1/activities`）不返回 `tiers`，只用列表项会让选票页和
/// 确认订单页拿不到票档（表现为「暂无票档信息」、订单无行、提交按钮禁用）。
/// 这里统一从详情接口取票档/场次，详情未返回或失败时退回列表数据。
final showFullProvider = Provider.family<ShowSummary?, String>((ref, id) {
  final summary = ref.watch(showByIdProvider(id));
  if (ref.watch(useDemoProvider)) return summary;
  final detail = ref.watch(showDetailProvider(id)).valueOrNull;
  return detail ?? summary;
});

// ── 精选推荐 ────────────────────────────────────────────────────────────

/// 精选推荐：按分类分组后的演出（首页「精选」楼层每个 tab 一组）。
final choicenessGroupsProvider = Provider<AsyncValue<List<ChoicenessGroup>>>((
  ref,
) {
  final AsyncValue<List<ShowSummary>> asyncShows = ref.watch(cityShowsProvider);
  return asyncShows.whenData((shows) {
    final byCategory = <int, List<ShowSummary>>{};
    for (final show in shows) {
      byCategory.putIfAbsent(show.categoryId, () => <ShowSummary>[]).add(show);
    }

    final groups = <ChoicenessGroup>[];
    for (final entry in byCategory.entries) {
      final items = <ShowSummary>[...entry.value]
        ..sort((a, b) => b.wishCount.compareTo(a.wishCount));
      groups.add(
        ChoicenessGroup(
          categoryId: entry.key,
          categoryName: items.first.categoryName,
          shows: items.take(8).toList(growable: false),
        ),
      );
    }
    groups.sort(
      (a, b) => b.shows.first.wishCount.compareTo(a.shows.first.wishCount),
    );
    return groups;
  });
});

/// 精选楼层的一个 tab。
final class ChoicenessGroup {
  const ChoicenessGroup({
    required this.categoryId,
    required this.categoryName,
    required this.shows,
  });

  final int categoryId;
  final String categoryName;
  final List<ShowSummary> shows;
}

// ── 场馆 ────────────────────────────────────────────────────────────────

/// 热门场馆（从当前城市的演出里聚合出来）。
final popularVenuesProvider = Provider<AsyncValue<List<VenueSummary>>>((ref) {
  final AsyncValue<List<ShowSummary>> asyncShows = ref.watch(cityShowsProvider);
  return asyncShows.whenData((shows) {
    final byVenue = <String, List<ShowSummary>>{};
    for (final show in shows) {
      byVenue.putIfAbsent(show.venue, () => <ShowSummary>[]).add(show);
    }

    final venues = <VenueSummary>[
      for (final entry in byVenue.entries)
        VenueSummary(
          id: entry.key,
          name: entry.key,
          city: entry.value.first.city,
          address: entry.value.first.venueAddress,
          showCount: entry.value.length,
          showIds:
              (entry.value.toList()..sort(
                    (a, b) => a.firstSessionAt.compareTo(b.firstSessionAt),
                  ))
                  .take(2)
                  .map((show) => show.id)
                  .toList(growable: false),
        ),
    ];
    venues.sort((a, b) => b.showCount.compareTo(a.showCount));
    return venues;
  });
});

/// 按场馆名取场馆。查不到返回 `null`——深链带脏名字是正常情况。
final venueByNameProvider = Provider.family<AsyncValue<VenueSummary?>, String>((
  ref,
  name,
) {
  final AsyncValue<List<VenueSummary>> asyncVenues = ref.watch(
    popularVenuesProvider,
  );
  return asyncVenues.whenData((venues) {
    for (final venue in venues) {
      if (venue.name == name) return venue;
    }
    return null;
  });
});

/// 某场馆在当前城市的全部演出（按首场时间升序）。
final venueShowsProvider =
    Provider.family<AsyncValue<List<ShowSummary>>, String>((ref, name) {
      final AsyncValue<List<ShowSummary>> asyncShows = ref.watch(
        cityShowsProvider,
      );
      return asyncShows.whenData((shows) {
        final result = shows.where((show) => show.venue == name).toList()
          ..sort((a, b) => a.firstSessionAt.compareTo(b.firstSessionAt));
        return List<ShowSummary>.unmodifiable(result);
      });
    });
