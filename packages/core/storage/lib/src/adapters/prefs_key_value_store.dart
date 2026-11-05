/// SharedPreferences 适配器。
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../stores.dart';

/// 用 [SharedPreferences] 实现 [KeyValueStore]。
///
/// 用 `SharedPreferencesAsync` 而不是老的 `getInstance()`：后者把全量数据
/// 常驻内存、且初始化是隐式单例；前者每次调用直接读写平台层，配合
/// Riverpod 的异步 provider 更自然。
final class PrefsKeyValueStore implements KeyValueStore {
  /// 创建适配器。可注入自定义实例（测试用）。
  PrefsKeyValueStore({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  @override
  Future<String?> read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> delete(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();

  @override
  Future<Set<String>> keys() async {
    final all = await _prefs.getKeys();
    return all.toSet();
  }
}
