/// flutter_secure_storage 适配器。
library;

import 'package:core/storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 用系统钥匙串 / Keystore 实现 [SecureStore]。
///
/// 只存真正敏感的东西：登录 token、手机号、实名信息。**不要**把普通偏好
/// 塞进来——每次读写都要过一次加解密 + 平台通道，比 SharedPreferences 慢
/// 一个量级。
final class SecureStorageStore implements SecureStore {
  /// 创建适配器。可注入自定义实例（测试用）。
  SecureStorageStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clear() => _storage.deleteAll();

  @override
  Future<Set<String>> keys() async {
    final all = await _storage.readAll();
    return all.keys.toSet();
  }
}
