import 'package:core/domain.dart';
import 'package:core/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/app/network/network_providers.dart';
import 'package:planstar/features/catalog/application/catalog_providers.dart';
import 'package:planstar/features/catalog/domain/show_summary.dart';
import 'package:planstar/features/discover/application/feed_providers.dart';
import 'package:planstar/features/discover/domain/feed_post.dart';
import 'package:planstar/features/search/application/search_providers.dart';
import 'package:planstar/features/search/domain/search_text_normalizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

ShowSummary _show({
  required String id,
  required String title,
  required String categoryName,
  List<String> tags = const <String>[],
}) {
  return ShowSummary(
    id: id,
    title: title,
    artist: '星轨工作室',
    categoryId: 1,
    categoryName: categoryName,
    city: '上海',
    venue: '上海展览中心',
    venueAddress: '上海市黄浦区',
    firstSessionAt: DateTime(2026, 1, 1),
    priceFrom: Money.zero(),
    tags: tags,
  );
}

/// 三条可控的企划：只含「游戏」、同时含「游戏 + 企划」、两者都不含。
List<ShowSummary> _sampleShows() => <ShowSummary>[
  _show(id: 'game', title: '独立游戏展', categoryName: '展览', tags: <String>['游戏']),
  _show(
    id: 'project',
    title: '游戏企划：星轨',
    categoryName: '游戏企划',
    tags: <String>['独立'],
  ),
  _show(id: 'other', title: '手作市集', categoryName: '手作'),
];

/// 空动态流：搜索测试只关心企划，避免默认 FeedController 发真实网络请求。
class _EmptyFeedController extends FeedController {
  @override
  Future<List<FeedPost>> build() async => const <FeedPost>[];
}

/// 把老版 [SharedPreferences] 接到 [KeyValueStore] 端口上。
///
/// 生产代码用 `PrefsKeyValueStore`（`SharedPreferencesAsync`），但
/// `SharedPreferences.setMockInitialValues` 只 mock 老版接口；测试里用这层
/// 适配器即可验证「写入偏好 → 重新读取」这条持久化链路。
class _SharedPreferencesStore implements KeyValueStore {
  const _SharedPreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<Set<String>> keys() async => _prefs.getKeys();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer createResultsContainer() {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        cityShowsProvider.overrideWithValue(AsyncValue.data(_sampleShows())),
        feedControllerProvider.overrideWith(_EmptyFeedController.new),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('拼音与分词', () {
    test('youxi 与 yx 都能命中标题含「游戏」的企划', () {
      final ProviderContainer container = createResultsContainer();

      final SearchResults fullPinyin = container.read(
        searchResultsProvider('youxi'),
      );
      expect(
        fullPinyin.shows.map((show) => show.id),
        containsAll(<String>['game', 'project']),
      );

      final SearchResults initials = container.read(
        searchResultsProvider('yx'),
      );
      expect(
        initials.shows.map((show) => show.id),
        containsAll(<String>['game', 'project']),
      );
    });

    test('多个词按 AND 匹配', () {
      final ProviderContainer container = createResultsContainer();

      // 「游戏」单独命中两条，「游戏 + 企划」只剩下两个词都满足的那条。
      expect(
        container.read(searchResultsProvider('游戏')).shows.map((s) => s.id),
        containsAll(<String>['game', 'project']),
      );

      final SearchResults both = container.read(searchResultsProvider('游戏 企划'));
      expect(both.shows.map((show) => show.id), <String>['project']);

      final SearchResults none = container.read(
        searchResultsProvider('游戏 不存在的词'),
      );
      expect(none.isEmpty, isTrue);
    });

    test('查询归一化会小写并去掉标点', () {
      expect(tokenizeSearchQuery('  游戏，企划！ '), <String>['游戏', '企划']);
      expect(pinyinOf('游戏'), 'youxi');
      expect(pinyinInitialsOf('游戏'), 'yx');
    });
  });

  group('搜索历史', () {
    test('写入 mock SharedPreferences 后，重启容器仍能读到', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final AppStore store = AppStore(
        preferences: _SharedPreferencesStore(prefs),
        secure: MemorySecureStore(),
      );

      final ProviderContainer first = ProviderContainer(
        overrides: <Override>[appStoreProvider.overrideWithValue(store)],
      );
      addTearDown(first.dispose);

      // 等异步缓存读完（没有记录 → null，控制器继续用默认词）。
      await first.read(searchHistoryCacheProvider.future);

      final SearchHistoryController controller = first.read(
        searchHistoryProvider.notifier,
      );
      await controller.add('赛博朋克');
      expect(first.read(searchHistoryProvider).first, '赛博朋克');
      expect(prefs.getString(searchHistoryStorageKey), isNotNull);

      // 新容器 = 模拟重启，底层仍是同一份 SharedPreferences。
      final ProviderContainer second = ProviderContainer(
        overrides: <Override>[appStoreProvider.overrideWithValue(store)],
      );
      addTearDown(second.dispose);

      final List<String>? loaded = await second.read(
        searchHistoryCacheProvider.future,
      );
      expect(loaded, contains('赛博朋克'));
      expect(second.read(searchHistoryProvider), contains('赛博朋克'));
    });

    test('去重置顶、删除与清空保持原有行为', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          appStoreProvider.overrideWithValue(
            AppStore(
              preferences: _SharedPreferencesStore(prefs),
              secure: MemorySecureStore(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(searchHistoryCacheProvider.future);

      final SearchHistoryController controller = container.read(
        searchHistoryProvider.notifier,
      );
      for (var i = 0; i < 12; i++) {
        await controller.add('词$i');
      }
      await controller.add('词5');

      final List<String> history = container.read(searchHistoryProvider);
      expect(history.length, SearchHistoryController.maxEntries);
      expect(history.first, '词5');
      expect(history.where((String word) => word == '词5').length, 1);

      await controller.remove('词5');
      expect(container.read(searchHistoryProvider), isNot(contains('词5')));

      await controller.clear();
      expect(container.read(searchHistoryProvider), isEmpty);
    });
  });
}
