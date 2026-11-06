/// 日志：级别注入 + sink 注入 + 无全局可变状态。
///
/// 级别由装配方显式传入（推荐 `AppLogger.defaultLevelFor(isReleaseMode: ...)`），
/// 本包不读取 `kReleaseMode`，以保持零 Flutter 依赖。
library;

export 'src/logger/app_logger.dart';
export 'src/logger/log_level.dart';
export 'src/logger/log_sink.dart';
