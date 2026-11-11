/// 配置来源端口。
library;

import 'dart:convert';

/// 配置来源（远端 / 本地 JSON / 硬编码默认值）。
abstract interface class ConfigSource {
  /// 读取原始配置。失败请**抛异常**，由加载器收敛成 `Failure`。
  Future<Map<String, Object?>> load();
}

/// 硬编码配置源（测试 / 兜底）。
final class InMemoryConfigSource implements ConfigSource {
  /// 用给定数据创建。
  InMemoryConfigSource(this._data);

  final Map<String, Object?> _data;

  @override
  Future<Map<String, Object?>> load() async => _data;
}

/// JSON 文本配置源（远端响应、本地文件、测试字面量）。
///
/// 刻意补的缺口：若把"读 assets 里的 `default_config.json` 当引导配置"
/// 写死在配置管理器内部（读字节与解析 JSON 耦合在一起），
/// 那段读盘逻辑就既没法替换也没法测。
/// 这里把**读字节**这一步作为函数注入：
///
/// ```dart
/// // 应用侧（任意来源：远端响应 / 本地文件 / 编译期常量）
/// JsonConfigSource(() async => configJsonText);
/// // 测试侧（不碰 Flutter）
/// JsonConfigSource(() async => '{"apiBaseUrl": "https://example.test/"}');
/// ```
///
/// 因此本包保持**纯 Dart**（不依赖 Flutter），`dart test` 就能跑。
final class JsonConfigSource implements ConfigSource {
  /// 用读取函数创建。
  ///
  /// [read] 返回 JSON 文本；[label] 只用于报错信息（通常是资源路径）。
  JsonConfigSource(this.read, {this.label});

  /// 读取 JSON 文本。
  final Future<String> Function() read;

  /// 人类可读的来源标识（资源路径 / 文件名）。
  final String? label;

  @override
  Future<Map<String, Object?>> load() async {
    final String text = await read();
    final Object? decoded = jsonDecode(text);
    if (decoded is! Map<String, Object?>) {
      throw FormatException(
        '配置根节点必须是 JSON 对象${label == null ? '' : '（$label）'}',
      );
    }
    return decoded;
  }
}
