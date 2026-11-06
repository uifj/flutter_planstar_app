import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/show_summary.dart';
import '../../discover/application/feed_providers.dart';
import '../../discover/domain/feed_post.dart';
import '../domain/search_models.dart';

/// 搜索历史（企划星的 `sp_search_history`）。
///
/// ## 为什么是内存态
///
/// 企划星把历史存在 `SharedPreferences` 里。这里没有落盘，原因和 `themeMode`
/// 一样：`package:core/storage.dart` 的 `AppStore` 是异步初始化的，而 `Notifier.build()`
/// 是同步的。接真实持久化时把 [build] 换成读 `appStore.preferences`，
/// 并在 [add] / [remove] / [clear] 里写回即可——**页面读的接口不变**。
class SearchHistoryController extends Notifier<List<String>> {
  /// 最多保留条数（企划星是 10）。
  static const int maxEntries = 10;

  @override
  List<String> build() => const <String>['剧院魅影', '周杰伦', '上海大剧院'];

  /// 记一条搜索词：去重后置顶，超出上限的从尾部丢弃。
  void add(String word) {
    final String trimmed = word.trim();
    if (trimmed.isEmpty) return;
    state = <String>[
      trimmed,
      ...state.where((String item) => item != trimmed),
    ].take(maxEntries).toList(growable: false);
  }

  /// 删单条。
  void remove(String word) {
    state = state.where((String item) => item != word).toList(growable: false);
  }

  /// 清空。
  void clear() => state = const <String>[];
}

/// 搜索历史。
final searchHistoryProvider =
    NotifierProvider<SearchHistoryController, List<String>>(
  SearchHistoryController.new,
);

/// 热搜榜。
///
/// 企划星来自 `v1/search/hot`。这里写死一份，且**词与演示演出库对得上**
/// （搜「剧院魅影」能出结果）——热搜点了是空页，比没有热搜更糟。
final hotKeywordsProvider = Provider<List<HotKeyword>>(
  (ref) => const <HotKeyword>[
    HotKeyword(word: '剧院魅影', hitCount: 32800, hot: true),
    HotKeyword(word: '周杰伦', hitCount: 26400, hot: true),
    HotKeyword(word: '演唱会', hitCount: 18700, hot: true),
    HotKeyword(word: '上海大剧院', hitCount: 9600),
    HotKeyword(word: '话剧', hitCount: 8200),
    HotKeyword(word: '音乐节', hitCount: 6100),
    HotKeyword(word: '亲子', hitCount: 4300),
    HotKeyword(word: '交响', hitCount: 2900),
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
/// 对演出匹配 标题 / 艺人 / 场馆 / 城市 / 分类名 / 角标；对动态匹配
/// 标题 / 作者 / 角标。**不做拼音与分词**——企划星那套是服务端的
/// Elasticsearch，客户端复刻不出等价结果，假装能搜只会让"搜不到"变成 bug。
final searchResultsProvider =
    Provider.family<SearchResults, String>((ref, String rawQuery) {
  final String query = rawQuery.trim().toLowerCase();
  if (query.isEmpty) {
    return const SearchResults(
      shows: <ShowSummary>[],
      feeds: <FeedPost>[],
    );
  }

  final List<ShowSummary> shows = ref
      .watch(cityShowsProvider)
      .valueOrNull
      ?.where((ShowSummary show) => _matchesShow(show, query))
      .toList(growable: false) ??
      const <ShowSummary>[];

  final List<FeedPost> feeds = ref
      .watch(feedControllerProvider)
      .where((FeedPost post) => _matchesFeed(post, query))
      .toList(growable: false);

  return SearchResults(shows: shows, feeds: feeds);
});

bool _matchesShow(ShowSummary show, String query) {
  return show.title.toLowerCase().contains(query) ||
      show.artist.toLowerCase().contains(query) ||
      show.venue.toLowerCase().contains(query) ||
      show.city.toLowerCase().contains(query) ||
      show.categoryName.toLowerCase().contains(query) ||
      show.tags.any((String tag) => tag.toLowerCase().contains(query));
}

bool _matchesFeed(FeedPost post, String query) {
  return post.title.toLowerCase().contains(query) ||
      post.author.toLowerCase().contains(query) ||
      (post.tag?.toLowerCase().contains(query) ?? false);
}
