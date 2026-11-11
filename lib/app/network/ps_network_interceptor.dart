/// 企划星的请求头与会话拦截器。
///
/// 每个请求带的头与会话处理约定：
///
/// | 头 | 取值 |
/// |---|---|
/// | `User-Agent` | `ApiConfig.userAgent` |
/// | `dvid` | `PsRequestContext.dvid` |
/// | `X-Longitude` / `X-Latitude` | 仅当已定位（经纬度都 > 0） |
/// | `Cookie: psSession=…` | 显式拼（见下） |
/// | `Cookie: psCaptcha=…` | 显式拼（一次性，见下） |
/// | 401 → 登出 | 注册钩子，不在拦截器里直接登出 |
///
/// **为什么用显式 Cookie 而不是 cookie jar**：要带的 cookie 只有
/// `psSession` 与一次性的 `psCaptcha`，持久化整袋 cookie 不是需求。
/// 手写一个 cookie jar 要多一个依赖、还要处理域名/过期，收益为零。
/// 显式拼 `Cookie: …` 行为完全等价，且**可测**。
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

  /// 图形验证码 Cookie 名。
  static const String captchaHeader = 'psCaptcha';

  /// 消费图形验证码的登录路径。
  static const String loginPath = 'v1/user/login';

  /// 消费图形验证码的发码路径。
  static const String sendLoginCodePath = 'v3/user/sendLoginCode';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['User-Agent'] = userAgent;

    final String? dvid = context.dvid;
    if (dvid != null && dvid.isNotEmpty) {
      options.headers[deviceHeader] = dvid;
    }

    // 只有经纬度都 > 0 才发地理头。0 表示"没定位到"，发出去反而
    // 会让服务端以为用户在南大西洋。
    final double? lat = context.latitude;
    final double? lng = context.longitude;
    if (lat != null && lng != null && lat > 0 && lng > 0) {
      options.headers['X-Longitude'] = '$lng';
      options.headers['X-Latitude'] = '$lat';
    }

    final List<String> cookies = <String>[];
    final Object? existing = options.headers['Cookie'];
    if (existing is String) {
      final String trimmed = existing.trim().replaceAll(RegExp(r';+$'), '');
      if (trimmed.isNotEmpty) {
        cookies.add(trimmed);
      }
    }
    final String? psSession = context.psSession;
    if (psSession != null && psSession.isNotEmpty) {
      cookies.add('$sessionHeader=$psSession');
    }
    final String? psCaptcha = context.psCaptcha;
    if (psCaptcha != null && psCaptcha.isNotEmpty) {
      cookies.add('$captchaHeader=$psCaptcha');
    }
    if (cookies.isNotEmpty) {
      options.headers['Cookie'] = cookies.join('; ');
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _capture(response.headers);
    // 登录 / 发码会消费一次性图形验证码：成功路径也要清，避免下次
    // 拿同一个 id 去校验必然失败。
    if (_consumesCaptcha(response.requestOptions)) {
      context.clearCaptcha();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Response<dynamic>? response = err.response;
    if (response != null) {
      _capture(response.headers);
      // 失败（含验证码错误 / 风控）同样已消费，必须清空。
      if (_consumesCaptcha(response.requestOptions)) {
        context.clearCaptcha();
      }
      if (response.statusCode == 401) {
        context.onUnauthorized?.call();
      }
    }
    handler.next(err);
  }

  /// `POST v1/user/login` / `POST v3/user/sendLoginCode` 会消费 [captchaHeader]。
  ///
  /// 路径按 `options.path` 去掉 query 与前导/结尾斜杠后精确匹配，
  /// 因此 `v1/user/login?...`、`/v1/user/login` 都能命中。
  /// `GET v1/user/captcha` 不在其中，绝不清除。
  static bool _consumesCaptcha(RequestOptions options) {
    if (options.method.toUpperCase() != 'POST') {
      return false;
    }
    final String path = _normalizePath(options.path);
    return path == loginPath || path == sendLoginCodePath;
  }

  static String _normalizePath(String raw) {
    String path = Uri.tryParse(raw)?.path ?? raw;
    while (path.startsWith('/')) {
      path = path.substring(1);
    }
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path;
  }

  /// 从响应里捞 `psSession` / `dvid` / `psCaptcha`。
  ///
  /// `psSession` / `dvid` 两个来源都要看：
  /// - `psSession` 放在**自定义响应头**里；
  /// - 同一个值也会出现在 `Set-Cookie` 里（cookie jar 就是靠它工作的）。
  ///
  /// 只读响应头会在中间层剥掉自定义头时丢会话，只读 `Set-Cookie` 则依赖
  /// 服务端把 cookie 的 `Path/Domain` 配对——两处都读最稳。
  ///
  /// `psCaptcha` 优先取 `Set-Cookie`（后端就是这么下发的），自定义头仅作兼容。
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

    final String? psCaptcha =
        _cookieValue(headers, captchaHeader) ??
        _nonEmpty(headers.value(captchaHeader));
    if (psCaptcha != null) {
      context.psCaptcha = psCaptcha;
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
