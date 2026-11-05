/// 配置：`ConfigSource` 端口 + 不可变 `AppConfig` + 幂等异步加载。
///
/// 设计来源：`app_common` 的 `AppBuilder` 配置对象形状
/// （见 `wiki_zh/30-flutter-adoptable-designs.md` §3.5 与 §7）。
///
/// 相对来源的**刻意改动**：
/// 1. 去单例、去异步构造。来源在构造函数里发异步读（30-12），
///    造成同一字段"先 JSON 值后本地值"两个真相；这里 [AppConfig] 是纯值对象，
///    异步只发生在 [ConfigLoader.load]。
/// 2. 加载器**并发安全且失败不挂起**（30-13）。这是本包存在的主要理由，
///    细节见 [ConfigLoader] 的文档注释。
library;

export 'src/app_config.dart';
export 'src/config_loader.dart';
export 'src/config_source.dart';
