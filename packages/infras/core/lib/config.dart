/// 配置：`ConfigSource` 端口 + 不可变 `AppConfig` + 幂等异步加载。
///
/// `AppConfig` 是纯值对象，异步只发生在 [ConfigLoader.load]；加载器并发安全
/// 且失败不挂起。
library;

export 'src/config/app_config.dart';
export 'src/config/config_loader.dart';
export 'src/config/config_source.dart';
