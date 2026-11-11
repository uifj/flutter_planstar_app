/// 存储端口：`KeyValueStore` / `SecureStore`。
library;

import 'dart:convert';

/// 普通键值存储端口（SharedPreferences / Hive / 文件 均可实现）。
///
/// 刻意只暴露 `String → String`：类型化的读写由扩展方法统一提供，
/// 避免每个实现各写一套 `getInt/getBool` 造成行为不一致。
abstract interface class KeyValueStore {
  /// 读。不存在返回 `null`。
  Future<String?> read(String key);

  /// 写（覆盖）。
  Future<void> write(String key, String value);

  /// 删。
  Future<void> delete(String key);

  /// 清空。
  Future<void> clear();

  /// 所有键。
  Future<Set<String>> keys();
}

/// 安全存储端口（token / 手机号 / 实名信息）。
///
/// 与 [KeyValueStore] **同契约但不同类型**：类型不同，才能让编译器拦住
/// "把 token 写进普通偏好"这种错误——普通偏好与安全存储混用
/// （两套工具类随意互换）就会留下这个问题。
abstract interface class SecureStore implements KeyValueStore {}

/// 类型化读写扩展。所有实现共享同一套编解码，行为一致。
extension KeyValueStoreX on KeyValueStore {
  /// 读字符串（等价于 [read]，便于链式阅读）。
  Future<String?> readString(String key) => read(key);

  /// 写字符串。
  Future<void> writeString(String key, String value) => write(key, value);

  /// 读整数。解析失败返回 `null`（不抛，存储不该让 App 崩）。
  Future<int?> readInt(String key) async {
    final raw = await read(key);
    return raw == null ? null : int.tryParse(raw);
  }

  /// 写整数。
  Future<void> writeInt(String key, int value) => write(key, '$value');

  /// 读布尔。
  Future<bool?> readBool(String key) async {
    final raw = await read(key);
    if (raw == null) {
      return null;
    }
    return raw == 'true' ? true : (raw == 'false' ? false : null);
  }

  /// 写布尔。
  Future<void> writeBool(String key, bool value) => write(key, '$value');

  /// 读 JSON。
  ///
  /// 解析失败或类型不符返回 `null`——**把"数据坏了"与"没有数据"都当作
  /// 未命中**，让上层走重新拉取，而不是抛异常。
  Future<Map<String, Object?>?> readJson(String key) async {
    final raw = await read(key);
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<Object?, Object?>
          ? decoded.map((Object? k, Object? v) => MapEntry<String, Object?>('$k', v))
          : null;
    } on FormatException {
      return null;
    }
  }

  /// 写 JSON。
  Future<void> writeJson(String key, Object? value) =>
      write(key, jsonEncode(value));
}
