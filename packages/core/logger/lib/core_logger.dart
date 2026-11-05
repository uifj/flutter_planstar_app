/// 日志：级别按构建模式决定 + sink 注入 + 无全局可变状态。
///
/// 设计来源：`stone_core` 的 `logger/src/*`
/// （见 `wiki_zh/30-flutter-adoptable-designs.md` §7 与 30-05）。
///
/// 相对来源的**刻意改动**：
/// 1. `minLevel` 不再无条件 `debug`（30-05）——release 只留 warn 及以上，
///    且映射做成纯函数 [AppLogger.defaultLevelFor] 以便测试两种分支。
/// 2. 级别与 sink 都是构造参数，**没有 `static` 可变字段**。
/// 3. 单个 sink 抛异常会被吞掉：日志失败不该让业务失败。
library;

export 'src/app_logger.dart';
export 'src/log_level.dart';
export 'src/log_sink.dart';
