import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluwx/fluwx.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';

import 'sdk_config.dart';

/// 第三方 SDK（百度地图 / JPush / 微信 fluwx）的初始化骨架。
///
/// 设计原则：**先有隐私同意，再初始化第三方 SDK**。
/// 因此所有初始化都挂在 [sdkBootstrapProvider] 上，而它 watch
/// [privacyConsentProvider] —— 用户同意后 provider 自动重算并真正发起初始化。
///
/// 平台守卫：这三个插件只支持 Android/iOS，Web 与桌面直接跳过
/// （否则 MethodChannel 会抛 MissingPluginException）。
bool get _nativeMobileSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// 隐私政策同意状态。
class PrivacyConsentController extends Notifier<bool> {
  @override
  bool build() => false; // 冷启动由 SplashPage 读取持久化结果后调用 grant()。

  /// 用户点击"同意"后调用，触发 [sdkBootstrapProvider] 重算并初始化。
  void grant() => state = true;

  void revoke() => state = false;
}

final privacyConsentProvider = NotifierProvider<PrivacyConsentController, bool>(
  PrivacyConsentController.new,
);

/// 微信 fluwx 实例（分享 / 登录 / 支付）。单例，全局共享。
final fluwxProvider = Provider<Fluwx>((ref) => Fluwx());

/// 极光推送实例。单例，全局共享。
final jpushProvider = Provider<JPushFlutterInterface>(
  (ref) => JPush.newJPush(),
);

/// 百度地图隐私合规 + 坐标类型。
///
/// `setAgreePrivacy` 必须在**任何**地图/定位接口之前调用；Android 的 AK 在清单里，
/// 只需设坐标类型，iOS 直接以代码设 AK + 坐标类型。
void initBaiduMap() {
  BMFMapSDK.setAgreePrivacy(true);
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    BMFMapSDK.setApiKeyAndCoordType(
      SdkConfig.baiduMapKeyIos,
      BMF_COORD_TYPE.BD09LL,
    );
  } else {
    BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);
  }
}

/// 极光推送：Android / iOS 调 `setup` 即完成初始化
/// （`init()` 仅鸿蒙实现类有，jpush_flutter 3.6.0 的 `JPushFlutterInterface` 不含 init）。
void initJPush(JPushFlutterInterface jpush) {
  jpush.setup(
    appKey: SdkConfig.jpushAppKey,
    channel: SdkConfig.jpushChannel,
    production: SdkConfig.isProduction,
    debug: !SdkConfig.isProduction,
  );
}

/// 微信：注册 AppID（尽早调用）。`universalLink` 仅 iOS 生效。
Future<void> initFluwx(Fluwx fluwx) async {
  await fluwx.registerApi(
    appId: SdkConfig.wechatAppId,
    universalLink: SdkConfig.wechatUniversalLink,
  );
}

/// 编排入口：在同意隐私后按平台依次初始化。
///
/// 在根 Widget 里 `ref.watch(sdkBootstrapProvider)` 即可触发；未同意 / 非移动
/// 平台时它直接返回，不产生副作用。初始化各自 try/catch，单个 SDK 失败不影响
/// 其余能力（例如微信未登记签名的 debug 包）。
final sdkBootstrapProvider = FutureProvider<void>((ref) async {
  if (!ref.watch(privacyConsentProvider)) return;
  if (!_nativeMobileSupported) return;

  try {
    initBaiduMap();
  } catch (_) {
    /* 地图初始化失败：降级为无地图，不阻断启动 */
  }

  try {
    initJPush(ref.read(jpushProvider));
  } catch (_) {
    /* 推送失败：不影响主流程 */
  }

  try {
    await initFluwx(ref.read(fluwxProvider));
  } catch (_) {
    /* 微信注册失败：分享/登录不可用，其余照常 */
  }
});
