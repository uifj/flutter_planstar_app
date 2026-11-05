/// HTTP 缓存：五策略 + 存储端口 + 带 scope 的稳定缓存键。
///
/// 设计来源：`stone_core` 的 `network/cache/http_cache.dart`（112 行）+
/// `network_cache_interceptor.dart`（171 行）
/// （见 `wiki_zh/30-flutter-adoptable-designs.md` §2.3）。
///
/// 相对来源的**刻意改动**：
/// 1. 缓存键**强制带 scope**（userId），未给 scope 直接不缓存。来源的键不含
///    用户身份，换账号会串号（30-07）——这是本模块唯一"必须改才能用"的点。
/// 2. 未配规则的请求**一律不缓存**。来源也是请求级 opt-in，但这里连
///    "默认 TTL 兜底"都取消，避免漏配的接口被意外缓存。
/// 3. `onlyNetwork` **不写**缓存。来源的语义含糊（只读不写 vs 读写都不），
///    这里明确为读写都不做——支付/下单链路不留永不使用的脏数据。
/// 4. `onlyCache` 未命中通过 [CacheMiss]（实现 `FailureCarryingError`）
///    变成 `Failure(code: 'CACHE_MISS')`，不需要 `core_network` 反向依赖本包。
library;

export 'src/cache_entry.dart';
export 'src/cache_key.dart' show anonymousScope, buildCacheKey, encodeJsonBody;
export 'src/cache_policy.dart';
export 'src/cache_store.dart';
export 'src/network_cache_interceptor.dart';
