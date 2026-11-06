/// `core`：平台无关内核。
///
/// 本包**零 Flutter 依赖**，可在纯 Dart 环境（`dart test` / CLI / 后台任务）
/// 使用。层内按子库划分，导入时优先用窄口径子库，避免把整包 API 都带进作用域：
///
/// | 子库 | 内容 |
/// |---|---|
/// | `core/result.dart` | `Result` / `Failure` / `FailureType` |
/// | `core/domain.dart` | Entity / AggregateRoot / ValueObject / Money / 领域事件 |
/// | `core/network.dart` | 响应信封 + ApiClient（永不抛）+ Dio 工厂 + 重试拦截器 |
/// | `core/cache.dart` | HTTP 缓存策略 + 带 scope 的缓存键 |
/// | `core/upload.dart` | 分片上传引擎 + OSS 表单直传 + AsyncSemaphore |
/// | `core/storage.dart` | KeyValueStore / SecureStore 端口 + AppStore 门面 |
/// | `core/config.dart` | ConfigSource 端口 + 不可变 AppConfig + 幂等加载 |
/// | `core/logger.dart` | 级别 + sink 注入的结构化日志 |
///
/// 平台适配器（SharedPreferences / flutter_secure_storage）不在本包内，
/// 由应用组合根实现并注入，以保持本包可纯 Dart 编译。
library;

export 'cache.dart';
export 'config.dart';
export 'domain.dart';
export 'logger.dart';
export 'network.dart';
export 'result.dart';
export 'storage.dart';
export 'upload.dart';
