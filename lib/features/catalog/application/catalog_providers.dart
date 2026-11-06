import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_catalog.dart';
import '../data/demo_categories.dart';
import '../data/planstar_catalog_api.dart';
import '../domain/show_category.dart';
import '../domain/show_summary.dart';
import 'catalog_api_providers.dart';

// ── 功能开关 ────────────────────────────────────────────────────────────

/// **演示模式开关**：为 `true` 时所有演出数据走本地假数据，
/// 为 `false` 时走真实接口。
///
/// 这是**临时开关**：等后端接口全部调通后删掉它，让代码始终走网络。
const bool _demoMode = true;

// ── 演出库 ──────────────────────────────────────────────────────────────

/// 演出库（全量）。
///
/// 换真实接口时把 [_demoMode] 改成 `false`。
/// 所有页面都从这一个人口读数据，所以"分页/缓存/离线"这类横切能力只需要在这里做一次。
final showCatalogProvider =
    AsyncNotifierProvider<ShowCatalogController, List<ShowSummary>>(
      ShowCatalogController.new,
    );

class ShowCatalogController extends AsyncNotifier<List<ShowSummary>> {
  @override
  Future<List<ShowSummary>> build() async {
    if (_demoMode) return buildDemoCatalog();

    final PlanstarCatalogApi api = ref.watch(planstarCatalogApiProvider);
    final result = await api.fetchShows(page: 1, pageSize: 100);
    return result.fold(
      onSuccess: (shows) => shows,
      onFailure: (failure) => throw failure, // AsyncValue 会捕获为 error 态
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (_demoMode) return buildDemoCatalog();
      final api = ref.read(planstarCatalogApiProvider);
      final result = await api.fetchShows(page: 1, pageSize: 100);
      return result.fold(
        onSuccess: (shows) => shows,
        onFailure: (failure) => throw failure,
      );
    });
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

/// 分类目录（编译期常量；本地 assets 已移除，不再运行时读资源）。
final showCategoriesProvider = FutureProvider<List<ShowCategory>>((ref) async {
  return demoCategories.where((c) => c.isActive).toList(growable: false);
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
