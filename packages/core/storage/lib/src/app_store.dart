/// 存储门面：**没有单例**，全部构造注入。
library;

import 'stores.dart';

/// 应用存储门面。
///
/// 相对来源的**刻意改动**：`config.dart` / `hive_store.dart` /
/// `config_service_impl.dart` 三者都是单例（`XxxService.instance`），
/// 这里**一个单例都没有**。原因不是洁癖：
///
/// 1. 单例让测试无法隔离——跑第二个用例时上一个用例写的偏好还在；
/// 2. 单例让"切换账号/清空数据"变成隐藏的全局副作用；
/// 3. Riverpod 已经提供了作用域与生命周期管理，单例是重复造轮子。
///
/// 在应用层用 provider 暴露即可：
/// ```dart
/// final appStoreProvider = Provider<AppStore>((ref) => throw UnimplementedError());
/// // main() 里 overrideWithValue(...)
/// ```
final class AppStore {
  /// 用两个端口创建门面。
  const AppStore({required this.preferences, required this.secure});

  /// 普通偏好（非敏感、可清理）。
  final KeyValueStore preferences;

  /// 安全存储（token / 手机号 / 实名）。
  final SecureStore secure;

  /// 登出时调用。
  ///
  /// 默认**保留**普通偏好（很多是设备级配置，如字号、通知开关），只清安全
  /// 存储。要连偏好一起清（换账号/退出登录彻底重置）传 `keepPreferences: false`。
  ///
  /// `⚠` HTTP 缓存不在这里清——缓存键自带 scope，换账号天然不会串号；
  /// 需要主动释放空间时用 `core_cache` 的 `evictScope`。
  Future<void> onLogout({bool keepPreferences = true}) async {
    await secure.clear();
    if (!keepPreferences) {
      await preferences.clear();
    }
  }

  /// 取某个用户的偏好视图（键自动加 `用户: ` 前缀）。
  ///
  /// 搜索历史、浏览记录、草稿这类数据必须按用户隔离，否则换账号会看到
  /// 上一个用户的记录——与缓存串号（30-07）是同一类 bug。
  ScopedKeyValueStore forUser(String userId) =>
      ScopedKeyValueStore(preferences, userId);
}

/// 给所有键加 `scope:` 前缀的装饰器。
///
/// 这是"缓存键必须带 scope"这条教训在本地存储上的同构应用。
final class ScopedKeyValueStore implements KeyValueStore {
  /// 用内层存储与 [scope] 创建。
  ScopedKeyValueStore(this._inner, this.scope)
      : assert(scope.isNotEmpty, 'scope 不能为空');

  final KeyValueStore _inner;

  /// 隔离维度（通常是 userId）。
  final String scope;

  String _scoped(String key) => '$scope:$key';

  @override
  Future<String?> read(String key) => _inner.read(_scoped(key));

  @override
  Future<void> write(String key, String value) =>
      _inner.write(_scoped(key), value);

  @override
  Future<void> delete(String key) => _inner.delete(_scoped(key));

  /// 只清本 scope 的键，不动其他用户的。
  @override
  Future<void> clear() async {
    final prefix = '$scope:';
    final all = await _inner.keys();
    for (final key in all) {
      if (key.startsWith(prefix)) {
        await _inner.delete(key);
      }
    }
  }

  /// 只返回本 scope 的键（已去掉前缀）。
  @override
  Future<Set<String>> keys() async {
    final prefix = '$scope:';
    return (await _inner.keys())
        .where((String key) => key.startsWith(prefix))
        .map((String key) => key.substring(prefix.length))
        .toSet();
  }
}
