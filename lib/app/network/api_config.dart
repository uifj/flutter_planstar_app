/// API 环境、base URL 与客户端标识。
///
/// 取值来源与优先级（高 → 低）：
///
/// 1. `--dart-define`（`PS_API_ENV` / `PS_API_BASE` / `PS_HTTP_LOG` / `PS_USE_DEMO`）——调试与 CI；
/// 2. 本文件里的编译期默认值。
///
/// 本地 `assets/` 已整体移除，不再从 `api_config.json` 运行时读配置。
/// 默认生产域名是后端实际部署的 `https://api.planstar.top/`；需要指向别的
/// 环境时用 `--dart-define=PS_API_BASE=https://<host>/` 覆盖，结尾斜杠必须有。
/// `⚠` beta 是**明文 HTTP**，只在调试环境用。
library;

import 'package:core/config.dart';

/// API 环境。
enum ApiEnvironment {
  /// 生产（HTTPS）。
  prod,

  /// Beta（**明文 HTTP**，来源如此）。
  beta,
}

/// API 与客户端标识配置（不可变）。
final class ApiConfig {
  /// 创建配置。
  const ApiConfig({
    required this.baseUrl,
    required this.environment,
    required this.clientType,
    required this.appVersion,
    required this.channel,
    required this.deviceBrand,
    required this.osVersion,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
    required this.enableLogging,
    this.useDemo = false,
  });

  /// 生产 API base（后端 Traefik 实际暴露的域名）。
  ///
  /// 可用 `--dart-define=PS_API_BASE=...` 覆盖（优先级更高）。
  static const String prodBaseUrl = 'https://api.planstar.top/';

  /// Beta API base（后端 Traefik 实际暴露的域名，**明文 HTTP**）。
  ///
  /// 可用 `--dart-define=PS_API_BASE=...` 覆盖（优先级更高）。
  static const String betaBaseUrl = 'http://apibeta.planstar.top/';

  /// Android 客户端类型（原 `PlanstarConstants.CLIENT_TYPE = 11`）。
  ///
  /// 登录请求体里的 `ct` 字段就是这个值。服务端按它决定返回哪些字段，
  /// 改成别的值（比如 iOS 的 10）会拿到不一样的数据形状。
  static const int androidClientType = 11;

  /// 默认版本号，与 `pubspec.yaml` 的 `version:` 保持一致。
  static const String defaultAppVersion = '1.0.1';

  /// 默认渠道（来源 Walle 渠道信息；调试包无渠道时 Android 侧拼 `null`）。
  static const String defaultChannel = 'developer-default';

  /// 默认设备品牌（UA 里的 `<brand>` 段）。
  static const String defaultDeviceBrand = 'Xiaomi';

  /// 默认 Android 版本（UA 里的 `Android/<osVersion>` 段）。
  static const String defaultOsVersion = '14';

  /// base URL，**必须以 `/` 结尾**：Dio 直接做字符串拼接，
  /// `https://api.planstar.top` + `v1/user/login` 会少一个斜杠。
  /// 可用 `--dart-define=PS_API_BASE=...` 覆盖。
  final String baseUrl;

  /// 当前环境。
  final ApiEnvironment environment;

  /// 客户端类型（登录请求体的 `ct`）。
  final int clientType;

  /// 客户端版本（UA 里的 `<versionName>` 段）。
  final String appVersion;

  /// 渠道。
  final String channel;

  /// 设备品牌。
  final String deviceBrand;

  /// 系统版本。
  final String osVersion;

  /// 连接超时。
  final Duration connectTimeout;

  /// 接收超时。
  final Duration receiveTimeout;

  /// 发送超时。
  final Duration sendTimeout;

  /// 是否打印请求/响应体。
  ///
  /// 来源把这个值**硬编码成 true**（`IS_DEV = true`），于是线上包会把
  /// 完整 body（含 `psSession`、手机号、实名信息）写进 logcat（05 页 §10）。
  /// 这里默认 **false**，只有显式打开才打印。
  final bool enableLogging;

  /// 是否使用本地演示数据（`PS_USE_DEMO=true`）。
  ///
  /// 生产默认 **false**：只有显式传参时才走 demo，避免打包后误用假数据。
  final bool useDemo;

  /// 解析配置。[asset] 是可选的外部配置（本地 assets 已移除，通常为空）。
  factory ApiConfig.resolve({AppConfig? asset}) {
    const String envOverride = String.fromEnvironment('PS_API_ENV');
    const String baseOverride = String.fromEnvironment('PS_API_BASE');
    const String logOverride = String.fromEnvironment('PS_HTTP_LOG');
    const String demoOverride = String.fromEnvironment('PS_USE_DEMO');

    final api = asset?.section('api') ?? AppConfig.empty;
    final client = asset?.section('client') ?? AppConfig.empty;
    final http = asset?.section('http') ?? AppConfig.empty;

    final envName = envOverride.isNotEmpty
        ? envOverride
        : (api.getString('environment') ?? 'prod');
    final environment = envName == 'beta'
        ? ApiEnvironment.beta
        : ApiEnvironment.prod;

    final assetBase = api.getString(
      environment == ApiEnvironment.beta ? 'betaBaseUrl' : 'prodBaseUrl',
    );
    final base = baseOverride.isNotEmpty
        ? baseOverride
        : (assetBase ??
              (environment == ApiEnvironment.beta ? betaBaseUrl : prodBaseUrl));

    return ApiConfig(
      baseUrl: base.endsWith('/') ? base : '$base/',
      environment: environment,
      clientType: api.getInt('clientType') ?? androidClientType,
      appVersion: client.getString('appVersion') ?? defaultAppVersion,
      channel: client.getString('channel') ?? defaultChannel,
      deviceBrand: client.getString('deviceBrand') ?? defaultDeviceBrand,
      osVersion: client.getString('osVersion') ?? defaultOsVersion,
      connectTimeout: Duration(
        milliseconds: http.getInt('connectTimeoutMs') ?? 20000,
      ),
      receiveTimeout: Duration(
        milliseconds: http.getInt('receiveTimeoutMs') ?? 20000,
      ),
      sendTimeout: Duration(
        milliseconds: http.getInt('sendTimeoutMs') ?? 20000,
      ),
      enableLogging: logOverride.isNotEmpty
          ? logOverride == 'true'
          : (http.getBool('enableLogging') ?? false),
      // 只认显式的 `PS_USE_DEMO=true`，缺省即生产数据。
      useDemo: demoOverride == 'true',
    );
  }

  /// 默认配置（仅编译期常量，无 dart-define）。
  factory ApiConfig.fallback() => ApiConfig.resolve();

  /// 请求头 `User-Agent`。
  ///
  /// 格式照抄来源 `HttpUtil.getAPIUserAgent()`：
  ///
  /// ```text
  /// PlanstarApi (com.planstar.app/1.0.1 Xiaomi developer-default Android/14)
  /// ```
  ///
  /// UA 里的包名同步改为 `com.planstar.app` 占位；`ct: 11` 仍声明
  /// "我是 Android"，两侧信息保持一致。
  String get userAgent =>
      'PlanstarApi (com.planstar.app/$appVersion $deviceBrand $channel '
      'Android/$osVersion)';

  @override
  String toString() =>
      'ApiConfig(${environment.name}, $baseUrl, ct=$clientType, '
      'log=$enableLogging)';
}
