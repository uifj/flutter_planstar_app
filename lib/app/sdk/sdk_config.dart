/// 第三方 SDK 的声明式配置。
///
/// 取值全部迁移自原 `com.planstar.app` 的清单与 `com.planstar.sso.wx`，
/// 便于与线上登记保持一致。这里的都是**客户端可见标识**（AppID / 地图 AK /
/// 推送 AppKey），不是服务端密钥；地图 AK 与「包名 + 签名」绑定。
class SdkConfig {
  const SdkConfig._();

  /// 微信开放平台 AppID（原 `com.planstar.sso.wx.APP_ID`）。
  static const String wechatAppId = 'wx337efcf7142c15ad';

  /// iOS 微信回调 Universal Link。
  /// `⚠` 占位值：上线前必须替换为在微信开放平台登记、且已在 Xcode 里
  /// 开启 Associated Domains（entitlements）的真实域名。Android 侧忽略此参数。
  static const String wechatUniversalLink = 'https://m.planstar.com/flutter/wx/';

  /// 极光推送 AppKey（原清单 `JPUSH_APPKEY`）与渠道。
  static const String jpushAppKey = 'baeccd5e33d6af24b55804f7';
  static const String jpushChannel = 'developer-default';

  /// 百度地图 iOS AK。Android 的 AK 走清单
  /// `com.baidu.lbsapi.API_KEY`，无需在此设置。
  static const String baiduMapKeyIos = 'noGiz1ZV4N3445UU0OWrmSPlQRqh2xmW';

  /// 是否生产环境：`false` → JPush 走测试环境、开 debug 日志。
  static const bool isProduction = false;
}
