/// 存储门面：三个端口 + 无单例的 `AppStore` + 按用户隔离的装饰器。
///
/// 设计来源：`stone_core` 的 `config.dart` + `hive_store.dart` +
/// `config_service_impl.dart`（见 `wiki_zh/30-flutter-adoptable-designs.md` §7）。
///
/// 相对来源的**刻意改动**：
/// 1. **去掉全部单例**。来源三个类都是 `XxxService.instance`；这里构造注入，
///    生命周期交给 Riverpod。理由见 [AppStore] 的文档注释。
/// 2. 端口与适配器分离：`stores.dart` 只有契约，`adapters/` 才有
///    SharedPreferences / secure storage 的依赖。纯 Dart 环境只 import
///    `stores.dart` 也能编译。
/// 3. 增加 [ScopedKeyValueStore]——把"键必须带用户 scope"这条缓存教训
///    应用到本地存储（搜索历史、浏览记录必须按用户隔离）。
library;

export 'src/adapters/prefs_key_value_store.dart';
export 'src/adapters/secure_storage_store.dart';
export 'src/app_store.dart';
export 'src/json_list_store.dart';
export 'src/memory_stores.dart';
export 'src/stores.dart';
