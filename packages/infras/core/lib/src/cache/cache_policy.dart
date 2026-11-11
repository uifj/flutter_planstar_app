/// 缓存策略五态与「路径 → 策略」规则表。
library;

/// 单个请求的缓存策略。
///
/// 决策表：
///
/// | 策略 | 场景 | 一致性 |
/// |---|---|---|
/// | [onlyNetwork] | 支付 / 下单 / 提交表单 / 座位图 | 强一致 |
/// | [cacheFirst] | 配置 / 城市 / 字典表 | TTL 内弱一致 |
/// | [networkFirst] | 详情 / 个人信息 | 较强，弱网兜底 |
/// | [cacheThenNetwork] | 首页信息流（SWR） | 最终一致 |
/// | [onlyCache] | 离线模式 | 依赖新鲜度 |
enum CachePolicy {
  /// 只走网络。**不读也不写**缓存——写也没有意义，只会留下永不使用的脏数据。
  onlyNetwork,

  /// 只读缓存，未命中即失败（不降级到网络）。用于明确的离线场景。
  onlyCache,

  /// 先读缓存，未过期则直接返回；否则走网络并回写。
  cacheFirst,

  /// 先走网络，失败时用缓存兜底（允许过期，但标记为 stale）。
  networkFirst,

  /// 立即返回缓存（塞进 `extra['staleResponse']`），同时走网络刷新。
  cacheThenNetwork,

  ;

  /// 是否可能从缓存读。
  bool get readsCache => this != CachePolicy.onlyNetwork;

  /// 网络成功（或兜底命中）后是否回写缓存。
  bool get writesCache =>
      this == CachePolicy.cacheFirst ||
      this == CachePolicy.networkFirst ||
      this == CachePolicy.cacheThenNetwork;
}

/// 一条路径规则：命中 [pathContains] 即采用 [policy] 与 [ttl]。
final class CacheRule {
  /// 创建规则。
  const CacheRule({
    required this.pathContains,
    required this.policy,
    this.ttl = const Duration(minutes: 5),
  });

  /// 路径子串。用子串而非正则：路径里出现版本号/前缀时更稳，也更好读。
  final String pathContains;

  /// 命中后采用的策略。
  final CachePolicy policy;

  /// 命中后采用的 TTL。
  final Duration ttl;

  /// 是否匹配 [path]。
  bool matches(String path) => path.contains(pathContains);

  @override
  String toString() => 'CacheRule($pathContains → ${policy.name}, ttl: $ttl)';
}

/// 「路径 → 策略」规则表。**未命中任何规则 = 不缓存**（fail closed）。
///
/// 故意不设"默认策略"：默认值是最容易被忽略的缓存 bug 来源。想让某个接口
/// 走缓存，必须在这里显式加一条，或在请求的 `extra` 里显式指定策略。
final class CachePolicyTable {
  /// 用给定规则创建表。**顺序即优先级，先匹配先赢。**
  const CachePolicyTable(this.rules);

  /// 规则列表，顺序即优先级。
  final List<CacheRule> rules;

  /// 查找第一条命中的规则；没有则返回 `null`（调用方按"不缓存"处理）。
  CacheRule? lookup(String path) {
    for (final rule in rules) {
      if (rule.matches(path)) {
        return rule;
      }
    }
    return null;
  }

  /// 企划星侧建议规则。
  ///
  /// `⚠` 路径片段是**按业务语义给的占位值**，接入真实接口时需与后端实际
  /// path 对齐（真实路径分散在各业务模块的 Api 常量里，容易漏改）。
  ///
  /// 顺序刻意把"实时性最高"的放前面：座位图一旦被缓存命中就会重复占座。
  static const CachePolicyTable planstar = CachePolicyTable(<CacheRule>[
    // 座位图：实时性最高，缓存会重复占座。
    CacheRule(pathContains: '/seat/', policy: CachePolicy.onlyNetwork),
    // 订单详情：下单/支付链路，强一致。
    CacheRule(pathContains: '/order/detail', policy: CachePolicy.onlyNetwork),
    // 企划详情：可容忍弱网兜底。
    CacheRule(
      pathContains: '/show/detail',
      policy: CachePolicy.networkFirst,
      ttl: Duration(minutes: 30),
    ),
    // 首页楼层：SWR，首屏用旧数据，同时刷新。
    CacheRule(
      pathContains: '/home/floor',
      policy: CachePolicy.cacheThenNetwork,
      ttl: Duration(minutes: 10),
    ),
    // 城市列表：低频变更，7 天。
    CacheRule(
      pathContains: '/city/list',
      policy: CachePolicy.cacheFirst,
      ttl: Duration(days: 7),
    ),
  ]);
}
