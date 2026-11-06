/// 一条日志记录与 sink 端口。
library;

import 'log_level.dart';

/// 一条结构化日志。
final class LogRecord {
  /// 创建记录。
  const LogRecord({
    required this.level,
    required this.message,
    required this.timestamp,
    this.tag,
    this.error,
    this.stackTrace,
    this.fields = const <String, Object?>{},
  });

  /// 级别。
  final LogLevel level;

  /// 文案。
  final String message;

  /// 时间戳。
  final DateTime timestamp;

  /// 来源标签（通常是包名或类名）。
  final String? tag;

  /// 关联异常。
  final Object? error;

  /// 堆栈。
  final StackTrace? stackTrace;

  /// 结构化字段（便于后续接 Sentry / 自建上报）。
  final Map<String, Object?> fields;

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('[${level.name.toUpperCase()}]')
      ..write(' ${timestamp.toIso8601String()}');
    if (tag != null && tag!.isNotEmpty) {
      buffer.write(' ($tag)');
    }
    buffer.write(' $message');
    if (fields.isNotEmpty) {
      buffer.write(' $fields');
    }
    if (error != null) {
      buffer.write(' | error: $error');
    }
    return buffer.toString();
  }
}

/// 日志落地端（控制台 / 文件 / Sentry / 自建上报）。
abstract interface class LogSink {
  /// 写入一条记录。
  void write(LogRecord record);
}

/// 控制台 sink。
final class ConsoleLogSink implements LogSink {
  /// 创建 sink。[printer] 可替换（测试用）。
  ConsoleLogSink({void Function(String line)? printer})
      : _print = printer ?? _defaultPrint;

  final void Function(String line) _print;

  static void _defaultPrint(String line) {
    // ignore: avoid_print
    print(line);
  }

  @override
  void write(LogRecord record) {
    _print(record.toString());
    final stackTrace = record.stackTrace;
    if (stackTrace != null) {
      _print(stackTrace.toString());
    }
  }
}

/// 收集到内存里的 sink（测试断言用）。
final class MemoryLogSink implements LogSink {
  /// 已收集的记录。
  final List<LogRecord> records = <LogRecord>[];

  @override
  void write(LogRecord record) {
    records.add(record);
  }
}

/// 丢弃一切的 sink（测试里想静音时用）。
final class SilentLogSink implements LogSink {
  /// 创建 sink。
  const SilentLogSink();

  @override
  void write(LogRecord record) {}
}
