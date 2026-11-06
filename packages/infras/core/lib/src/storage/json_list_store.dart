/// 基于任意 [KeyValueStore] 的 JSON 列表存储（搜索历史 / 浏览记录 / 草稿）。
library;

import 'dart:convert';

import 'stores.dart';

/// 把一组对象以 JSON 数组形式存在单个键下。
///
/// 为什么不用 Hive/SQLite：这类数据量小（几十条）、读写频率低、
/// 结构简单，用 JSON 数组完全够，而且**任何 [KeyValueStore] 实现都能用**
/// （内存 / SharedPreferences / 文件）。真正需要索引或大表时再换。
final class JsonListStore<T> {
  /// 创建列表存储。
  JsonListStore({
    required KeyValueStore store,
    required this.key,
    required this.fromJson,
    required this.toJson,
    this.maxItems,
  }) : _store = store;

  final KeyValueStore _store;

  /// 存储键。
  final String key;

  /// 单条反序列化。
  final T Function(Map<String, Object?> json) fromJson;

  /// 单条序列化。
  final Map<String, Object?> Function(T value) toJson;

  /// 最多保留条数（超出时保留**最新的**）。`null` 表示不限。
  final int? maxItems;

  /// 读全部。
  ///
  /// 单条解析失败会**跳过该条**而不是整体失败：一条坏数据不该让用户的
  /// 全部历史消失。
  Future<List<T>> readAll() async {
    final raw = await _store.read(key);
    if (raw == null) {
      return <T>[];
    }
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return <T>[];
    }
    if (decoded is! List<Object?>) {
      return <T>[];
    }
    final result = <T>[];
    for (final item in decoded) {
      if (item is! Map<Object?, Object?>) {
        continue;
      }
      try {
        result.add(
          fromJson(
            item.map(
              (Object? k, Object? v) => MapEntry<String, Object?>('$k', v),
            ),
          ),
        );
      } catch (_) {
        // 单条坏了就跳过。
      }
    }
    return result;
  }

  /// 覆盖写入全部。
  Future<void> writeAll(List<T> items) async {
    final limit = maxItems;
    final kept = (limit != null && items.length > limit)
        ? items.sublist(items.length - limit)
        : items;
    await _store.write(key, jsonEncode(kept.map(toJson).toList()));
  }

  /// 追加一条到末尾（并按 [maxItems] 裁剪）。
  Future<void> append(T item) async {
    final items = await readAll();
    items.add(item);
    await writeAll(items);
  }

  /// 清空。
  Future<void> clear() => _store.delete(key);
}
