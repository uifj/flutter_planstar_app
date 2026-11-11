/// 应用启动装配：配置 + 存储 + 请求上下文，**一次异步做完，再交给 UI**。
///
/// 刻意不把**同步 I/O 塞在构造函数/静态初始化里**：偏好数据一旦损坏，
/// 单例初始化会在每次启动时抛异常，且没有降级路径，App 直接起不来。
///
/// 这里的做法：
///
/// 1. 装配是一个**普通函数**，返回一个不可变对象，失败有明确兜底；
/// 2. `main()` 里 await 一次，然后把结果 override 进 Riverpod；
/// 3. 测试/预览**不 override**，默认拿到内存实现（[AppBootstrap.memory]），
///    因此 `flutter test` 不会碰任何平台通道。
library;

import 'dart:async';

import 'package:core/config.dart';
import 'package:core/storage.dart';
import 'package:flutter/foundation.dart';

import '../platform/prefs_key_value_store.dart';
import '../platform/secure_storage_store.dart';
import 'api_config.dart';
import 'device_identity.dart';
import 'ps_request_context.dart';

/// 设备标识在普通偏好里的键。
const String dvidStorageKey = 'dvid';

/// 会话令牌在安全存储里的键。
///
/// token 不能放进普通 `SharedPreferences`：那里的数据是**明文**，
/// 可被直接读取解码。这里放进 `flutter_secure_storage`
/// （Keystore/Keychain），是对该缺陷的刻意修正。
const String psSessionStorageKey = 'psSession';

/// 启动装配结果。
final class AppBootstrap {
  /// 创建装配结果。
  const AppBootstrap({
    required this.assetConfig,
    required this.store,
    required this.requestContext,
  });

  /// 配置恒为编译期默认值（本地 assets 已移除）。
  final AppConfig assetConfig;

  /// 存储门面（普通偏好 + 安全存储）。
  final AppStore store;

  /// 请求上下文（`dvid` / `psSession` / 经纬度）。
  final PsRequestContext requestContext;

  /// 由 [assetConfig] 解析出的 API 配置。
  ApiConfig get apiConfig => ApiConfig.resolve(asset: assetConfig);

  /// 纯内存装配：测试、预览、以及存储不可用时的兜底。
  ///
  /// `dvid` 仍然生成一个真值——少了它，请求头里就没有 `dvid`，
  /// 服务端会自己下发一个，行为上没差别但会让日志对不上。
  factory AppBootstrap.memory({Map<String, String>? preferences}) {
    final store = AppStore(
      preferences: MemoryKeyValueStore(preferences),
      secure: MemorySecureStore(),
    );
    return AppBootstrap(
      assetConfig: AppConfig.empty,
      store: store,
      requestContext: PsRequestContext(
        dvid: preferences?[dvidStorageKey] ?? generateDvid(),
      ),
    );
  }
}

/// 真实装配：打开存储、灌 `dvid` 与会话令牌。
///
/// **不抛异常**：任何一步失败都退化成可用状态（配置空 → 编译期默认值；
/// 存储不可用 → 内存实现）。启动期因为"读一个配置文件失败"就白屏，
/// 是必须避免的：所有读取路径都带 try/catch 兜底。
Future<AppBootstrap> loadAppBootstrap({
  ConfigSource? configSource,
  AppStore? store,
}) async {
  final AppConfig assetConfig = await _loadAssetConfig(configSource);
  final AppStore appStore = store ?? _openStore();

  String dvid = (await _readSafely(appStore.preferences, dvidStorageKey)) ?? '';
  if (dvid.isEmpty) {
    dvid = generateDvid();
    unawaited(_writeSafely(appStore.preferences, dvidStorageKey, dvid));
  }

  final String? psSession = await _readSafely(
    appStore.secure,
    psSessionStorageKey,
  );

  final context = PsRequestContext(dvid: dvid, psSession: psSession)
    ..onDeviceIdChanged = (String value) =>
        unawaited(_writeSafely(appStore.preferences, dvidStorageKey, value));

  return AppBootstrap(
    assetConfig: assetConfig,
    store: appStore,
    requestContext: context,
  );
}

Future<AppConfig> _loadAssetConfig(ConfigSource? configSource) async {
  // 本地 assets/ 已整体移除：不再读资源文件，配置全部来自编译期常量。
  // 保留可选 configSource 参数，方便测试注入自定义配置。
  if (configSource == null) return AppConfig.empty;
  final result = await ConfigLoader(configSource).load();
  return result.getOrElse((_) => AppConfig.empty);
}

AppStore _openStore() {
  try {
    return AppStore(
      preferences: PrefsKeyValueStore(),
      secure: SecureStorageStore(),
    );
  } catch (error) {
    // 平台插件缺失（桌面/Web 预览）或 Keystore 不可用。
    debugPrint('[bootstrap] 存储不可用，退化为内存实现：$error');
    return AppBootstrap.memory().store;
  }
}

Future<String?> _readSafely(KeyValueStore store, String key) async {
  try {
    return await store.read(key);
  } catch (error) {
    debugPrint('[bootstrap] 读取 $key 失败：$error');
    return null;
  }
}

Future<void> _writeSafely(KeyValueStore store, String key, String value) async {
  try {
    await store.write(key, value);
  } catch (error) {
    debugPrint('[bootstrap] 写入 $key 失败：$error');
  }
}
