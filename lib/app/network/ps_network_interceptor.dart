/// 企划星的请求头与会话拦截器。
///
/// 对齐来源 `OkHttpUtil.getClient()` 里的匿名 `Interceptor`（05 页 §3.1）：
///
/// | 头 | 来源写法 | 这里 |
/// |---|---|---|
/// | `User-Agent` | `HttpUtil.getAPIUserAgent()` | `ApiConfig.userAgent` |
/// | `dvid` | `OkHttpUtil.getDvid()` | `PsRequestContext.dvid` |
/// | `X-Longitude` / `X-Latitude` | 仅当经纬度 > 0 | 仅当已定位 |
/// | `Cookie: psSession=…` | OkHttp `CookieJar` 自动带 | 显式拼（见下） |
/// | 401 → 登出 | 拦截器里直接 `AccountService.logout()` | 改为注册钩子 |
///
/// **为什么用显式 Cookie 而不是 CookieJar**：企划星的会话只有一个 cookie
/// （`psSession`），Android 侧用 `PersistentCookieStore` 持久化整袋 cookie 是顺带
/// 的结果，不是需求。Flutter 这边手写一个 cookie jar 要多一个依赖、还要处理
/// 域名/过期，收益为零。显式拼 `Cookie: psSession=…` 行为完全等价，且**可测**。
library;

import 'package:dio/dio.dart';

import 'ps_request_context.dart';

/// 请求头 + 会话拦截器。
final class PsNetworkInterceptor extends Interceptor {
  /// 创建拦截器。
  PsNetworkInterceptor({required this.context, required this.userAgent});

  /// 运行时上下文（`dvid` / `psSession` / 经纬度）。
  final PsRequestContext context;

  /// `User-Agent` 头。
  final String userAgent;

  /// 会话令牌的响应头名。
  static const String sessionHeader = 'psSession';

  /// 设备标识的响应头名。
  static const String deviceHeader = 'dvid';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['User-Agent'] = userAgent;

    final String? dvid = context.dvid;
    if (dvid != null && dvid.isNotEmpty) {
      options.headers[deviceHeader] = dvid;
    }

    // 来源：只有经纬度都 > 0 才发地理头。0 表示"没定位到"，发出去反而
    // 会让服务端以为用户在南大西洋。
    final double? lat = context.latitude;
    final double? lng = context.longitude;
    if (lat != null && lng != null && lat > 0 && lng > 0) {
      options.headers['X-Longitude'] = '$lng';
      options.headers['X-Latitude'] = '$lat';
    }

    final String? psSession = context.psSession;
    if (psSession != null && psSession.isNotEmpty) {
      final Object? existing = options.headers['Cookie'];
      options.headers['Cookie'] = existing is String && existing.isNotEmpty
          ? '$existing; $sessionHeader=$psSession'
          : '$sessionHeader=$psSession';
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _capture(response.headers);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Response<dynamic>? response = err.response;
    if (response != null) {
      _capture(response.headers);
      if (response.statusCode == 401) {
        context.onUnauthorized?.call();
      }
    }
    handler.next(err);
  }

  /// 从响应里捞 `psSession` / `dvid`。
  ///
  /// 两个来源都要看：
  /// - 企划星把 `psSession` 放在**自定义响应头**里（来源
  ///   `AccountService.setPner(response.headers().get("psSession"))`）；
  /// - 同一个值也会出现在 `Set-Cookie` 里（CookieJar 就是靠它工作的）。
  ///
  /// 只读响应头会在中间层剥掉自定义头时丢会话，只读 `Set-Cookie` 则依赖
  /// 服务端把 cookie 的 `Path/Domain` 配对——两处都读最稳。
  void _capture(Headers headers) {
    final String? psSession =
        _nonEmpty(headers.value(sessionHeader)) ??
        _cookieValue(headers, sessionHeader);
    if (psSession != null && psSession != context.psSession) {
      context.psSession = psSession;
    }

    final String? dvid =
        _nonEmpty(headers.value(deviceHeader)) ??
        _cookieValue(headers, deviceHeader);
    if (dvid != null && dvid != context.dvid) {
      context.dvid = dvid;
      context.onDeviceIdChanged?.call(dvid);
    }
  }

  static String? _nonEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;

  /// 从 `Set-Cookie` 里取某个 cookie 的值。
  static String? _cookieValue(Headers headers, String name) {
    final List<String>? cookies = headers['set-cookie'];
    if (cookies == null) {
      return null;
    }
    for (final String raw in cookies) {
      for (final String part in raw.split(';')) {
        final String item = part.trim();
        final int eq = item.indexOf('=');
        if (eq <= 0) {
          continue;
        }
        if (item.substring(0, eq) == name) {
          return _nonEmpty(item.substring(eq + 1));
        }
      }
    }
    return null;
  }
}
