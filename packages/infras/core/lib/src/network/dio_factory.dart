/// Dio 工厂：**唯一**创建 Dio 的地方。
///
/// 刻意不做单例（`getInstance()` + 隐式初始化顺序）。
/// 这里是一个纯函数：给参数，返回一个配好的 [Dio]，没有任何全局状态。
///
/// 三条刻意不做的事：
/// 1. **不设置 `badCertificateCallback`**。在 host 映射为空时 `return true`
///    ——等于信任一切证书，过不了应用市场审核。
/// 2. **不注入任何默认拦截器**。鉴权、缓存、埋点由调用方按需挂（见
///    `interceptors`），避免"默认链里塞了两个空壳"。
/// 3. **不改 `validateStatus`**。保持 dio 默认（仅 2xx 算成功），让 4xx/5xx 走
///    `DioException(badResponse)`，由 `ApiClient` 统一映射成 `Failure`。
library;

import 'package:dio/dio.dart';

/// 构建一个 Dio 实例。
///
/// [interceptors] 按传入顺序追加，因此顺序即语义：
/// 缓存 → 鉴权 → 重试（缓存命中应短路，不必等 token 逻辑）。
Dio buildDio({
  required String baseUrl,
  Duration connectTimeout = const Duration(seconds: 10),
  Duration receiveTimeout = const Duration(seconds: 30),
  Duration sendTimeout = const Duration(seconds: 30),
  Map<String, Object?>? headers,
  bool enableLogging = false,
  void Function(Object? object)? logPrint,
  List<Interceptor> interceptors = const <Interceptor>[],
  HttpClientAdapter? adapter,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: headers,
    ),
  );

  if (adapter != null) {
    dio.httpClientAdapter = adapter;
  }

  if (enableLogging) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        logPrint: logPrint ?? _defaultLogPrint,
      ),
    );
  }

  dio.interceptors.addAll(interceptors);
  return dio;
}

void _defaultLogPrint(Object? object) {
  // ignore: avoid_print
  print(object);
}
