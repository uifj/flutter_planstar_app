/// 网络层的 Riverpod 装配。
///
/// 依赖方向是单向的：`app/network` → `core_*`，**不**依赖 `features/*`。
/// 业务层从这里拿 [apiClientProvider]，而不是自己 new Dio——
/// "永不自建 HTTP 客户端"是同一条约束。
library;

import 'package:core/network.dart';
import 'package:core/storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'app_bootstrap.dart';
import 'data_source_policy.dart';
import 'ps_network_interceptor.dart';
import 'ps_request_context.dart';

/// 启动装配结果。
///
/// 默认是内存实现，所以**测试不需要任何 override**；`main()` 里用
/// `loadAppBootstrap()` 的真实结果覆盖它。
final appBootstrapProvider = Provider<AppBootstrap>(
  (ref) => AppBootstrap.memory(),
);

/// 存储门面。
final appStoreProvider = Provider<AppStore>(
  (ref) => ref.watch(appBootstrapProvider).store,
);

/// API 配置（环境 / base URL / UA / 超时）。
final apiConfigProvider = Provider<ApiConfig>(
  (ref) => ref.watch(appBootstrapProvider).apiConfig,
);

/// 全局数据源策略（demo / 真实接口）。
///
/// 业务层统一读这个 provider，不要直接判断 `useDemoProvider`。
final dataSourcePolicyProvider = Provider<DataSourcePolicy>(
  (ref) => DataSourcePolicy(isDemo: ref.watch(useDemoProvider)),
);

/// 是否使用演示数据；仅当 `--dart-define=PS_USE_DEMO=true` 时为 true。
///
/// **仅限 `app/network` 内部使用**——它是 [dataSourcePolicyProvider] 的
/// 底层实现。业务层请用 `dataSourcePolicyProvider`（架构测试会拦截）。
final useDemoProvider = Provider<bool>(
  (ref) => ref.watch(apiConfigProvider).useDemo,
);

/// 请求上下文（`dvid` / `psSession` / 经纬度）。
final pnRequestContextProvider = Provider<PsRequestContext>(
  (ref) => ref.watch(appBootstrapProvider).requestContext,
);

/// 全局 Dio。
final dioProvider = Provider<Dio>((ref) {
  final ApiConfig config = ref.watch(apiConfigProvider);
  final PsRequestContext context = ref.watch(pnRequestContextProvider);
  return buildDio(
    baseUrl: config.baseUrl,
    connectTimeout: config.connectTimeout,
    receiveTimeout: config.receiveTimeout,
    sendTimeout: config.sendTimeout,
    enableLogging: config.enableLogging,
    // 顺序即语义：先挂业务头（UA/dvid/Cookie），再让日志看最终请求。
    interceptors: <Interceptor>[
      PsNetworkInterceptor(context: context, userAgent: config.userAgent),
    ],
  );
});

/// 全局 API 客户端。
///
/// 默认信封是 [PassthroughEnvelope]——这不是偷懒，是**实测结果**：
///
/// - `GET /v1/cities` 直接返回 JSON **数组**（`[{"cityId":1,…}]`）；
/// - `POST /v1/user/login` 直接返回登录结果模型（`{needCaptcha,newUser,user}`）；
/// - 失败时返回 `4xx/5xx` + `text/plain` 正文（`验证码不正确`）。
///
/// 也就是说企划星的多数接口是**裸模型 + HTTP 状态码表意**，而不是
/// `{code,message,data}` 信封。硬套 [RestCodeEnvelope] 会让每个接口都报
/// `MISSING_ENVELOPE`。真遇到带信封的接口，用调用级参数覆盖：
///
/// ```dart
/// api.get('/v2/xxx', envelope: const RestCodeEnvelope());
/// ```
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);
