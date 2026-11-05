import 'dart:async';

import 'package:core_config/core_config.dart';
import 'package:test/test.dart';

/// 可控数据源：统计调用次数，可切换成功/失败/延迟。
class _ControllableSource implements ConfigSource {
  int calls = 0;
  bool shouldFail = false;
  Completer<void>? gate;
  Map<String, Object?> data = <String, Object?>{'k': 'v'};

  @override
  Future<Map<String, Object?>> load() async {
    calls++;
    final g = gate;
    if (g != null) {
      await g.future;
    }
    if (shouldFail) {
      throw StateError('拉取失败');
    }
    return data;
  }
}

void main() {
  group('AppConfig 值对象', () {
    test('类型化读取', () {
      const config = AppConfig(<String, Object?>{
        's': 'text',
        'i': 42,
        'd': 1.5,
        'b': true,
        'strInt': '7',
      });
      expect(config.getString('s'), 'text');
      expect(config.getInt('i'), 42);
      expect(config.getDouble('d'), 1.5);
      expect(config.getBool('b'), isTrue);
      expect(config.getInt('strInt'), 7);
    });

    test('类型不符返回 null，不抛', () {
      const config = AppConfig(<String, Object?>{'s': 'text'});
      expect(config.getInt('s'), isNull);
      expect(config.getBool('s'), isNull);
      expect(config.getString('missing'), isNull);
    });

    test('JSON 里整数被解析成 double 时也能取到 int', () {
      const config = AppConfig(<String, Object?>{'i': 42.0});
      expect(config.getInt('i'), 42);
      expect(config.getInt('f'), isNull);
    });

    test('section 取子段', () {
      const config = AppConfig(<String, Object?>{
        'net': <String, Object?>{'timeout': 10},
      });
      expect(config.section('net').getInt('timeout'), 10);
      expect(config.section('nope').keys, isEmpty);
    });
  });

  group('ConfigLoader 幂等加载（修 30-13）', () {
    test('并发调用只触发一次数据源读取', () async {
      final source = _ControllableSource()..gate = Completer<void>();
      final loader = ConfigLoader(source);

      final futures = <Future<Object?>>[
        loader.load(),
        loader.load(),
        loader.load(),
      ];
      source.gate!.complete();
      await Future.wait(futures);

      expect(source.calls, 1, reason: '并发调用必须共享同一个 Future');
      expect(loader.isLoaded, isTrue);
    });

    test('成功后再次调用走缓存，不再读数据源', () async {
      final source = _ControllableSource();
      final loader = ConfigLoader(source);

      await loader.load();
      await loader.load();

      expect(source.calls, 1);
    });

    test('失败返回 Failure 而不是抛', () async {
      final source = _ControllableSource()..shouldFail = true;
      final loader = ConfigLoader(source);

      final result = await loader.load();

      expect(result.isFailure, isTrue);
      expect(result.failure!.code, 'CONFIG_LOAD_FAILED');
      expect(result.failure!.type.name, 'data');
      expect(loader.isLoaded, isFalse);
    });

    test('失败后下一次调用会重试，不会永久挂起（核心断言）', () async {
      final source = _ControllableSource()..shouldFail = true;
      final loader = ConfigLoader(source);

      final first = await loader.load();
      expect(first.isFailure, isTrue);

      // 修好数据源，再调一次——必须能成功，而不是卡死。
      source.shouldFail = false;
      final second = await loader
          .load()
          .timeout(const Duration(seconds: 2), onTimeout: () {
        fail('第二次加载挂起了：这正是 30-13 的缺陷');
      });

      expect(second.isSuccess, isTrue);
      expect(source.calls, 2, reason: '失败后应重新尝试');
      expect(loader.isLoaded, isTrue);
    });

    test('invalidate 后重新读取', () async {
      final source = _ControllableSource();
      final loader = ConfigLoader(source);

      await loader.load();
      loader.invalidate();
      expect(loader.isLoaded, isFalse);

      await loader.load();
      expect(source.calls, 2);
    });
  });
}
