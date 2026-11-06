/// 内存实现：测试、预览、以及"存储尚未初始化"时的安全兜底。
library;

import 'stores.dart';

/// 内存键值存储。
final class MemoryKeyValueStore implements KeyValueStore {
  /// 可用 [initial] 预置数据。
  MemoryKeyValueStore([Map<String, String>? initial])
      : _data = <String, String>{...?initial};

  final Map<String, String> _data;

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  Future<Set<String>> keys() async => _data.keys.toSet();
}

/// 内存安全存储（同样只用于测试/预览）。
final class MemorySecureStore implements SecureStore {
  /// 可用 [initial] 预置数据。
  MemorySecureStore([Map<String, String>? initial])
      : _data = <String, String>{...?initial};

  final Map<String, String> _data;

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  Future<Set<String>> keys() async => _data.keys.toSet();
}
