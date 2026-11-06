/// `AppLogger`：级别 + 多 sink + 标签。
library;

import 'log_level.dart';
import 'log_sink.dart';

/// 应用日志器。
///
/// 相对来源的**刻意改动**（直指 30-05）：
///
/// 来源 `StoneLogger` 的 `minLevel = LogLevel.debug` 是**无条件赋值**，
/// 而它自己的注释写的是 "Defaults to debug in debug mode, info otherwise"——
/// 注释与代码不符，结果 **release 包也会打 debug 日志**（性能与隐私双输）。
///
/// 这里把"默认级别"做成一个纯函数 [defaultLevelFor]，由**装配方**传入
/// `isReleaseMode` 后决定 `level`，测试可以直接断言这个映射，不会因为
/// "只在真机上才生效"而漏掉。本包不读取 `kReleaseMode`，保持零 Flutter 依赖。
///
/// 另一个改动：**没有全局可变状态**。来源用 `static` 字段持有级别与 sink，
/// 于是"改级别"是一个谁都能改的全局副作用。这里级别与 sink 都是构造参数，
/// 想换就换一个实例——在 Riverpod 里就是 `overrideWithValue`。
final class AppLogger {
  /// 创建日志器。
  ///
  /// [level] 必须显式给出（通常是
  /// `AppLogger.defaultLevelFor(isReleaseMode: kReleaseMode)`），避免 release
  /// 包默认落到 debug 级别。
  AppLogger({
    required List<LogSink> sinks,
    required this.level,
    this.tag,
  }) : _sinks = List<LogSink>.unmodifiable(sinks);

  /// 内部复制构造，用于 [child]。
  AppLogger._({
    required List<LogSink> sinks,
    required this.level,
    required this.tag,
  }) : _sinks = sinks;

  final List<LogSink> _sinks;

  /// 当前级别（不可变；要改级别就换一个实例）。
  final LogLevel level;

  /// 来源标签。
  final String? tag;

  /// 按构建模式给默认级别。
  ///
  /// - release：只留 `warn` 及以上（错误与警告）；
  /// - 非 release：`debug` 及以上。
  ///
  /// 做成纯函数而不是内联 `kReleaseMode ? ... : ...`，是为了让测试能同时
  /// 覆盖两种分支——内联写法只能在真机 release 包上验证，等于没验证。
  static LogLevel defaultLevelFor({required bool isReleaseMode}) =>
      isReleaseMode ? LogLevel.warn : LogLevel.debug;

  /// 派生一个带标签的日志器，共享同一批 sink 与级别。
  AppLogger child(String tag) =>
      AppLogger._(sinks: _sinks, level: level, tag: tag);

  /// 是否允许输出 [candidate]。
  bool isEnabled(LogLevel candidate) => level.allows(candidate);

  /// 写一条日志。
  void log(
    LogLevel logLevel,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    if (!level.allows(logLevel)) {
      return;
    }
    final record = LogRecord(
      level: logLevel,
      message: message,
      timestamp: DateTime.now(),
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      fields: fields,
    );
    for (final sink in _sinks) {
      // 单个 sink 抛异常不能拖垮业务调用。
      try {
        sink.write(record);
      } catch (_) {
        // 吞掉：日志失败不该让业务失败。
      }
    }
  }

  /// 追踪。
  void trace(String message, {Map<String, Object?> fields = const <String, Object?>{}}) =>
      log(LogLevel.trace, message, fields: fields);

  /// 调试。
  void debug(String message, {Map<String, Object?> fields = const <String, Object?>{}}) =>
      log(LogLevel.debug, message, fields: fields);

  /// 信息。
  void info(String message, {Map<String, Object?> fields = const <String, Object?>{}}) =>
      log(LogLevel.info, message, fields: fields);

  /// 警告。
  void warn(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const <String, Object?>{},
  }) =>
      log(
        LogLevel.warn,
        message,
        error: error,
        stackTrace: stackTrace,
        fields: fields,
      );

  /// 错误。
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const <String, Object?>{},
  }) =>
      log(
        LogLevel.error,
        message,
        error: error,
        stackTrace: stackTrace,
        fields: fields,
      );
}
