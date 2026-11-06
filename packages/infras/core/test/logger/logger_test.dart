import 'package:core/logger.dart';
import 'package:test/test.dart';

/// 会抛异常的 sink，用于验证"日志失败不影响业务"。
class _ThrowingSink implements LogSink {
  @override
  void write(LogRecord record) => throw StateError('sink 坏了');
}

void main() {
  group('默认级别按构建模式决定（修 30-05）', () {
    test('release 只留 warn 及以上', () {
      final level = AppLogger.defaultLevelFor(isReleaseMode: true);
      expect(level, LogLevel.warn);
      expect(level.allows(LogLevel.debug), isFalse);
      expect(level.allows(LogLevel.info), isFalse);
      expect(level.allows(LogLevel.warn), isTrue);
      expect(level.allows(LogLevel.error), isTrue);
    });

    test('非 release 放行 debug', () {
      final level = AppLogger.defaultLevelFor(isReleaseMode: false);
      expect(level, LogLevel.debug);
      expect(level.allows(LogLevel.debug), isTrue);
      expect(level.allows(LogLevel.info), isTrue);
    });

    test('off 什么都不放行', () {
      expect(LogLevel.off.allows(LogLevel.error), isFalse);
      expect(LogLevel.off.allows(LogLevel.off), isFalse);
    });
  });

  group('级别过滤', () {
    test('warn 级别下 info 不落 sink、error 落', () {
      final sink = MemoryLogSink();
      final logger = AppLogger(sinks: <LogSink>[sink], level: LogLevel.warn);

      logger.info('不该出现');
      logger.error('该出现');

      expect(sink.records.length, 1);
      expect(sink.records.single.message, '该出现');
      expect(sink.records.single.level, LogLevel.error);
    });

    test('isEnabled 与 log 行为一致', () {
      final logger = AppLogger(sinks: const <LogSink>[], level: LogLevel.info);
      expect(logger.isEnabled(LogLevel.debug), isFalse);
      expect(logger.isEnabled(LogLevel.info), isTrue);
    });
  });

  group('结构化字段', () {
    test('error / stackTrace / fields 都被记录', () {
      final sink = MemoryLogSink();
      final logger = AppLogger(sinks: <LogSink>[sink], level: LogLevel.debug);
      final error = StateError('炸了');

      logger.error(
        '下单失败',
        error: error,
        stackTrace: StackTrace.current,
        fields: <String, Object?>{'orderId': 'A1', 'amount': 880},
      );

      final record = sink.records.single;
      expect(record.error, same(error));
      expect(record.stackTrace, isNotNull);
      expect(record.fields['orderId'], 'A1');
      expect(record.fields['amount'], 880);
    });

    test('toString 含级别与标签', () {
      final sink = MemoryLogSink();
      final logger = AppLogger(sinks: <LogSink>[sink], level: LogLevel.debug)
          .child('order');
      logger.info('hi');
      final text = sink.records.single.toString();
      expect(text, contains('[INFO]'));
      expect(text, contains('(order)'));
      expect(text, contains('hi'));
    });
  });

  group('sink 编排', () {
    test('多个 sink 都收到', () {
      final a = MemoryLogSink();
      final b = MemoryLogSink();
      final logger = AppLogger(sinks: <LogSink>[a, b], level: LogLevel.debug);
      logger.info('x');
      expect(a.records.length, 1);
      expect(b.records.length, 1);
    });

    test('单个 sink 抛异常不影响其他 sink，也不抛给调用方', () {
      final healthy = MemoryLogSink();
      final logger = AppLogger(
        sinks: <LogSink>[_ThrowingSink(), healthy],
        level: LogLevel.debug,
      );

      // 不应抛。
      logger.info('x');
      expect(healthy.records.length, 1);
    });

    test('child 共享 sink 与级别，只换 tag', () {
      final sink = MemoryLogSink();
      final parent = AppLogger(sinks: <LogSink>[sink], level: LogLevel.info);
      final child = parent.child('cache');

      child.info('hit');
      expect(sink.records.single.tag, 'cache');
      expect(child.level, parent.level);
      expect(child.isEnabled(LogLevel.debug), isFalse, reason: '级别必须继承');
    });
  });

  test('ConsoleLogSink 可注入 printer（便于测试）', () {
    final lines = <String>[];
    final sink = ConsoleLogSink(printer: lines.add);
    sink.write(
      LogRecord(
        level: LogLevel.warn,
        message: '注意',
        timestamp: DateTime.utc(2026),
        tag: 'demo',
      ),
    );
    expect(lines.length, 1);
    expect(lines.single, contains('注意'));
  });
}
