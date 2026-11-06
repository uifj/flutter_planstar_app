/// better_auth 子树的日志器。
///
/// 来源经 `StoneLogger` 全局静态打日志；这里改用 core 的实例化 [AppLogger]，
/// 级别按构建模式注入，且不再有可被任意模块修改的全局状态。
library;

import 'package:core/logger.dart';
import 'package:flutter/foundation.dart';

/// 进程级日志器：控制台 sink，release 下只保留 warn 及以上。
final AppLogger betterAuthLogger = AppLogger(
  sinks: <LogSink>[ConsoleLogSink()],
  level: AppLogger.defaultLevelFor(isReleaseMode: kReleaseMode),
  tag: 'better_auth',
);
