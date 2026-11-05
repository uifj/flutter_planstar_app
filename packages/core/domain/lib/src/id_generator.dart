/// 身份生成。抽成端口，聚合工厂就不必依赖 `Random` 或时钟。
///
/// 好处：测试里注入确定性生成器，断言"事件里的 id 是 X"；线上用时间前缀生成器，
/// 保证同一毫秒内生成的 id 仍然可排序（对分库分表/游标分页友好）。
library;

import 'dart:math';

/// id 生成端口。
abstract interface class IdGenerator {
  /// 生成一个新的全局唯一 id。
  String next();
}

/// UUIDv7 形态的 id：48 位毫秒时间戳 + 80 位随机数，十六进制小写。
///
/// 例：`0199f3c2a1b4` + 20 位随机 → 32 字符，**字典序 = 时间序**。
///
/// 与企划星的差别：企划星 94 个模型的 id 是 `int`（`wiki_zh/27` §10 第 13 条），
/// 超过 2,147,483,647 就溢出；这里用字符串，没有上限。
final class TimestampIdGenerator implements IdGenerator {
  TimestampIdGenerator({Random? random, DateTime Function()? clock})
      : _random = random ?? Random.secure(),
        _clock = clock ?? DateTime.now;

  final Random _random;
  final DateTime Function() _clock;

  @override
  String next() {
    final millis = _clock().millisecondsSinceEpoch;
    final buffer = StringBuffer(millis.toRadixString(16).padLeft(12, '0'));
    for (var i = 0; i < 10; i++) {
      buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}

/// 测试/演示用：固定序列。**不要**在生产代码里用。
final class SequentialIdGenerator implements IdGenerator {
  SequentialIdGenerator({this.prefix = 'id-', this.start = 1});

  final String prefix;
  int start;

  @override
  String next() => '$prefix${start++}';
}
