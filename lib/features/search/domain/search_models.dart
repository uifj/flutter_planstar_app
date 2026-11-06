/// 搜索域模型。
///
/// 对应企划星的 `SearchActivity` + `SearchResultActivity` 两个页面用到的数据形状。
/// 这一层**不依赖 Flutter**：`SearchScope` 的文案放在枚举里是为了让页面与
/// 应用层共用一套口径，而不是各写一份 `['全部','演出','动态']`。
library;

/// 搜索结果的分域。
///
/// 企划星的结果页有「全部 / 演出 / 动态 / 商品」四栏（`SearchResultFragment`
/// 下面挂了 5 个 Fragment）。本项目只做了演出与动态两条链路，商品没有数据源，
/// 所以**只声明存在的两栏**——放一个永远空的「商品」栏等于给用户一个死入口。
enum SearchScope { all, shows, feeds }

/// 热搜词条目（`item_search_hot.xml`）。
final class HotKeyword {
  const HotKeyword({
    required this.word,
    required this.hitCount,
    this.hot = false,
  });

  /// 关键词。
  final String word;

  /// 热度（企划星显示的是搜索量）。
  final int hitCount;

  /// 是否标「热」（前 3 名带火焰标）。
  final bool hot;
}
