import 'dart:convert';

import 'package:core/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/show_summary.dart';
import '../../discover/application/feed_providers.dart';
import '../../discover/domain/feed_post.dart';
import '../domain/search_models.dart';
import '../domain/search_text_normalizer.dart';

/// 搜索历史在普通偏好里的键。
const String searchHistoryStorageKey = 'search_history';

/// 搜索历史的存储编解码。
///
/// 只依赖 `KeyValueStore` 端口，测试可以把 `AppStore.preferences`
/// 换成内存实现或 SharedPreferences mock。
final class SearchHistoryStorage {
  const SearchHistoryStorage(this._preferences);

  final KeyValueStore _preferences;

  /// 读取历史。`null` 表示**没有记录**（用默认词），空列表表示用户清空过。
  Future<List<String>?> read() async {
    try {
      final String? raw = await _preferences.read(searchHistoryStorageKey);
      if (raw == null) return null;
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<String>()
          .take(SearchHistoryController.maxEntries)
          .toList(growable: false);
    } catch (_) {
      // 数据损坏按"没有记录"处理，不让搜索页因一条脏数据打不开。
      return null;
    }
  }

  Future<void> write(List<String> words) async {
    try {
      await _preferences.write(searchHistoryStorageKey, jsonEncode(words));
    } catch (_) {
      // 落盘失败不影响当前会话的使用。
    }
  }
}

/// 搜索历史存储。
final searchHistoryStorageProvider = Provider<SearchHistoryStorage>(
  (ref) => SearchHistoryStorage(ref.watch(appStoreProvider).preferences),
);

/// 启动时异步读取一次历史。
///
/// `Notifier.build()` 是同步的，而存储是异步的；用这个 provider 把异步读取
/// 收敛到一处，[SearchHistoryController] 只同步消费它的值。页面读的仍然是
/// 同步的 `List<String>`，无需感知加载态。
final searchHistoryCacheProvider =
    AsyncNotifierProvider<SearchHistoryCache, List<String>?>(
      SearchHistoryCache.new,
    );

/// 历史缓存加载器。
class SearchHistoryCache extends AsyncNotifier<List<String>?> {
  @override
  Future<List<String>?> build() =>
      ref.watch(searchHistoryStorageProvider).read();
}

/// 搜索历史（企划星的 `sp_search_history`）。
///
/// 历史落盘到 `AppStore.preferences`。初始化时序：`build()` 先给默认词，
/// 异步缓存 [searchHistoryCacheProvider] 完成后 provider 重建，再用读到的
/// 历史替换；用户已经编辑过（[_userEdited]）时不覆盖，避免加载慢吞掉刚搜的词。
class SearchHistoryController extends Notifier<List<String>> {
  /// 最多保留条数（企划星是 10）。
  static const int maxEntries = 10;

  /// 没有落盘记录时的默认词。
  static const List<String> defaultWords = <String>['游戏企划', '同人画集', '面经企划'];

  List<String> _current = defaultWords;
  bool _userEdited = false;

  @override
  List<String> build() {
    final List<String>? cached = ref
        .watch(searchHistoryCacheProvider)
        .valueOrNull;
    if (!_userEdited && cached != null) {
      _current = cached;
    }
    return _current;
  }

  /// 记一条搜索词：去重后置顶，超出上限的从尾部丢弃。
  Future<void> add(String word) {
    final String trimmed = word.trim();
    if (trimmed.isEmpty) return Future<void>.value();
    return _commit(
      <String>[
        trimmed,
        ..._current.where((String item) => item != trimmed),
      ].take(maxEntries).toList(growable: false),
    );
  }

  /// 删单条。
  Future<void> remove(String word) => _commit(
    _current.where((String item) => item != word).toList(growable: false),
  );

  /// 清空。
  Future<void> clear() => _commit(const <String>[]);

  /// 先更新内存状态，再 fire-and-forget 落盘。
  Future<void> _commit(List<String> next) {
    _userEdited = true;
    _current = next;
    state = next;
    return ref.read(searchHistoryStorageProvider).write(next);
  }
}

/// 搜索历史。
final searchHistoryProvider =
    NotifierProvider<SearchHistoryController, List<String>>(
      SearchHistoryController.new,
    );

/// 热搜榜。
///
/// 企划星来自 `v1/search/hot`。这里写死一份，且**词与演示企划库对得上**
/// （搜「游戏企划」能出结果）——热搜点了是空页，比没有热搜更糟。
final hotKeywordsProvider = Provider<List<HotKeyword>>(
  (ref) => const <HotKeyword>[
    HotKeyword(word: '游戏企划', hitCount: 32800, hot: true),
    HotKeyword(word: '同人企划', hitCount: 26400, hot: true),
    HotKeyword(word: '画集设定集', hitCount: 18700, hot: true),
    HotKeyword(word: '面经企划', hitCount: 9600),
    HotKeyword(word: '桌游', hitCount: 8200),
    HotKeyword(word: '音乐影像', hitCount: 6100),
    HotKeyword(word: '小说企划', hitCount: 4300),
    HotKeyword(word: '秋招', hitCount: 2900),
  ],
);

/// 一次搜索的结果。
final class SearchResults {
  const SearchResults({required this.shows, required this.feeds});

  final List<ShowSummary> shows;
  final List<FeedPost> feeds;

  bool get isEmpty => shows.isEmpty && feeds.isEmpty;

  /// 命中总数。
  int get total => shows.length + feeds.length;

  /// 按分域取数量（tab 角标）。
  int countOf(SearchScope scope) => switch (scope) {
    SearchScope.all => total,
    SearchScope.shows => shows.length,
    SearchScope.feeds => feeds.length,
  };
}

/// 搜索结果，**按查询词分族**（`family`）。
///
/// ## 为什么用 family 而不是一个共享的 `queryProvider`
///
/// 共享 query 会让结果页必须在 `initState` 里把路由参数写回 provider，
/// 那会带来两个问题：一是首帧读到的是上一次的词（闪一下旧结果），
/// 二是"从 A 词进、返回、再从 B 词进"时状态归属不清。
/// 用 `family(query)` 后，**查询词就是路由参数**，provider 纯函数化，
/// 页面之间没有隐式耦合。
///
/// ## 匹配规则
///
/// 查询先按空白/标点切成多个词，词与词之间是 **AND**（每个词都要命中）。
/// 对企划匹配 标题 / 创作者 / 场地 / 城市 / 分类名 / 标签；对动态匹配
/// 标题 / 作者 / 角标。每个词在**原文、拼音全拼、拼音首字母**三个通道里
/// 任一命中即可（`游戏企划` 可被 `youxi` / `yx` 搜到）。原文匹配仍是
/// 大小写不敏感的 `contains`，不改变原有行为。
final searchResultsProvider = Provider.family<SearchResults, String>((
  ref,
  String rawQuery,
) {
  final List<String> tokens = tokenizeSearchQuery(rawQuery);
  if (tokens.isEmpty) {
    return const SearchResults(shows: <ShowSummary>[], feeds: <FeedPost>[]);
  }

  final Map<String, SearchTextIndex> showIndexes = ref.watch(
    _showSearchIndexProvider,
  );
  final Map<String, SearchTextIndex> feedIndexes = ref.watch(
    _feedSearchIndexProvider,
  );

  final List<ShowSummary> shows =
      ref
          .watch(cityShowsProvider)
          .valueOrNull
          ?.where(
            (ShowSummary show) =>
                showIndexes[show.id]?.matchesAll(tokens) ?? false,
          )
          .toList(growable: false) ??
      const <ShowSummary>[];

  final List<FeedPost> feeds =
      ref
          .watch(feedControllerProvider)
          .valueOrNull
          ?.where(
            (FeedPost post) =>
                feedIndexes[post.id]?.matchesAll(tokens) ?? false,
          )
          .toList(growable: false) ??
      const <FeedPost>[];

  return SearchResults(shows: shows, feeds: feeds);
});

/// 企划的检索索引。按 id 缓存，查询词变化时只做 `contains`，不重复转拼音。
final _showSearchIndexProvider = Provider<Map<String, SearchTextIndex>>((ref) {
  final List<ShowSummary> shows =
      ref.watch(cityShowsProvider).valueOrNull ?? const <ShowSummary>[];
  return <String, SearchTextIndex>{
    for (final ShowSummary show in shows)
      show.id: SearchTextIndex.fromFields(<String>[
        show.title,
        show.artist,
        show.venue,
        show.city,
        show.categoryName,
        ...show.tags,
      ]),
  };
});

/// 动态的检索索引（标题 / 作者 / 角标）。
final _feedSearchIndexProvider = Provider<Map<String, SearchTextIndex>>((ref) {
  final List<FeedPost> feeds =
      ref.watch(feedControllerProvider).valueOrNull ?? const <FeedPost>[];
  return <String, SearchTextIndex>{
    for (final FeedPost post in feeds)
      post.id: SearchTextIndex.fromFields(<String>[
        post.title,
        post.author,
        if (post.tag != null) post.tag!,
      ]),
  };
});
