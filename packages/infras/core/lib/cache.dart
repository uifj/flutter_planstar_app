/// HTTP 缓存：五策略 + 存储端口 + 带 scope 的稳定缓存键。
///
/// 缓存键**强制带 scope**（userId），未给 scope 直接不缓存——换账号不会串号。
/// 未配规则的请求**一律不缓存**；`onlyNetwork` **不写**缓存。
library;

export 'src/cache/cache_entry.dart';
export 'src/cache/cache_key.dart' show anonymousScope, buildCacheKey, encodeJsonBody;
export 'src/cache/cache_policy.dart';
export 'src/cache/cache_store.dart';
export 'src/cache/network_cache_interceptor.dart';
