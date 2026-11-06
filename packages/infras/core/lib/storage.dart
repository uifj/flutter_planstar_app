/// 存储门面：三个端口 + 无单例的 `AppStore` + 按用户隔离的装饰器。
///
/// 端口与适配器分离：本包只有契约与内存实现，SharedPreferences /
/// flutter_secure_storage 适配器由应用组合根提供，因此本包零 Flutter 依赖。
library;

export 'src/storage/app_store.dart';
export 'src/storage/json_list_store.dart';
export 'src/storage/memory_stores.dart';
export 'src/storage/stores.dart';
