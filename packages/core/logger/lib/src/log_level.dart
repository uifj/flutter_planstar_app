/// 日志级别。
library;

/// 日志级别。数值越大越严重。
enum LogLevel {
  /// 追踪（极细粒度，仅本地排查）。
  trace(0),

  /// 调试。
  debug(1),

  /// 信息。
  info(2),

  /// 警告。
  warn(3),

  /// 错误。
  error(4),

  /// 关闭全部输出。
  off(5);

  const LogLevel(this.severity);

  /// 严重程度，用于比较。
  final int severity;

  /// 当前级别是否允许输出 [candidate]。
  ///
  /// 级别是**阈值**：配置成 `warn` 时只放行 `warn` 与 `error`，
  /// 也就是 `candidate.severity >= severity`。
  bool allows(LogLevel candidate) =>
      this != LogLevel.off && candidate.severity >= severity;
}
