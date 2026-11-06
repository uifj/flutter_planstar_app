/// 缓存存储端口 + 内存 LRU 实现。
library;

import 'dart:collection';

import 'cache_entry.dart';

/// 缓存存储端口（L2 磁盘层由上层实现：Hive / SQLite / 文件）。
///
/// 刻意只给内存实现：来源同样"故意不给磁盘实现"，因为 Hive/SQLite 属上层选型
/// （§2.3 第 3 条）。要在企划星侧落 L2，实现这五个方法即可，其余不用动。
abstract interface class HttpCacheStore {
  /// 读取。未命中返回 `null`；命中需**不**判过期（过期判断交给拦截器，
  /// 因为 `networkFirst` 需要用过期数据兜底）。
  Future<HttpCacheEntry?> read(String key);

  /// 写入（同 key 覆盖）。
  Future<void> write(String key, HttpCacheEntry entry);

  /// 删除单个键。
  Future<void> remove(String key);

  /// 清空全部。
  Future<void> clear();

  /// 枚举所有键。用于按 scope 清理与调试。
  Future<List<String>> keys();
}

/// 按 scope 清理缓存（登出 / 切换账号时调用）。
///
/// 返回被删除的条目数。放在端口外的自由函数里，是为了让任何
/// [HttpCacheStore] 实现都能复用，不必各自实现一遍。
Future<int> evictScope(HttpCacheStore store, String scope) async {
  final prefix = '$scope|';
  final all = await store.keys();
  var removed = 0;
  for (final key in all) {
    if (key.startsWith(prefix)) {
      await store.remove(key);
      removed++;
    }
  }
  return removed;
}

/// L1 内存 LRU。容量满时淘汰**最久未使用**的一条。
final class MemoryLruCacheStore implements HttpCacheStore {
  /// 创建内存缓存。
  MemoryLruCacheStore({this.capacity = defaultCapacity})
      : assert(capacity > 0, '容量必须为正数');

  /// 默认容量。对齐来源的 200 条。
  static const int defaultCapacity = 200;

  /// 最大条目数。
  final int capacity;

  /// `LinkedHashMap` 的迭代顺序即插入顺序，队尾 = 最近使用。
  final LinkedHashMap<String, HttpCacheEntry> _entries =
      LinkedHashMap<String, HttpCacheEntry>();

  /// 当前条目数（测试与监控用）。
  int get length => _entries.length;

  @override
  Future<HttpCacheEntry?> read(String key) async {
    final entry = _entries.remove(key);
    if (entry == null) {
      return null;
    }
    // 重新插入 = 移到队尾 = 标记为最近使用。这是 LRU 的全部实现。
    _entries[key] = entry;
    return entry;
  }

  @override
  Future<void> write(String key, HttpCacheEntry entry) async {
    _entries
      ..remove(key)
      ..[key] = entry;
    while (_entries.length > capacity) {
      _entries.remove(_entries.keys.first);
    }
  }

  @override
  Future<void> remove(String key) async {
    _entries.remove(key);
  }

  @override
  Future<void> clear() async {
    _entries.clear();
  }

  @override
  Future<List<String>> keys() async => _entries.keys.toList();

  /// 便于测试：当前所有键（按 LRU 顺序，最旧在前）。
  List<String> get debugKeys => _entries.keys.toList();
}
