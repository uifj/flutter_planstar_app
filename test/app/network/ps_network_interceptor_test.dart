import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/app/network/ps_network_interceptor.dart';
import 'package:planstar/app/network/ps_request_context.dart';

/// 拦截器对一次性图形验证码 Cookie（`psCaptcha`）的捕获 / 回填 / 清除。
///
/// 全部用本地假 adapter 驱动，不依赖真实网络。
void main() {
  late PsRequestContext context;
  late _RecordingAdapter adapter;
  late Dio dio;

  setUp(() {
    context = PsRequestContext();
    adapter = _RecordingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      PsNetworkInterceptor(context: context, userAgent: 'PlanstarApi/test'),
    );
  });

  String? lastCookie() {
    final Object? cookie = adapter.requests.last.headers['Cookie'];
    return cookie is String ? cookie : null;
  }

  test('收到 Set-Cookie: psCaptcha=… 后捕获到上下文', () async {
    adapter.replies.add(
      const _Reply(
        headers: <String, List<String>>{
          'set-cookie': <String>['psCaptcha=abc; Path=/; HttpOnly'],
        },
      ),
    );

    await dio.get<List<int>>(
      'v1/user/captcha',
      options: Options(responseType: ResponseType.bytes),
    );

    expect(context.psCaptcha, 'abc');
  });

  test('后续请求的 Cookie 头同时带 psCaptcha 与 psSession', () async {
    adapter.replies
      ..add(
        const _Reply(
          headers: <String, List<String>>{
            'set-cookie': <String>['psCaptcha=abc; Path=/'],
          },
        ),
      )
      ..add(const _Reply());

    await dio.get<List<int>>(
      'v1/user/captcha',
      options: Options(responseType: ResponseType.bytes),
    );
    context.psSession = 'token';

    await dio.get<void>('v1/home/banners');

    final String? cookie = lastCookie();
    expect(cookie, isNotNull);
    expect(cookie, contains('psCaptcha=abc'));
    expect(cookie, contains('psSession=token'));
    // 拼接不得出现重复分号。
    expect(cookie, isNot(contains(';;')));
  });

  test('登录成功响应后清空 psCaptcha', () async {
    context.psCaptcha = 'abc';
    adapter.replies.add(const _Reply());

    await dio.post<void>('/v1/user/login?from=app', data: <String, Object?>{});

    expect(lastCookie(), contains('psCaptcha=abc'));
    expect(context.psCaptcha, isNull);
  });

  test('登录失败（DioException）后也清空 psCaptcha', () async {
    context.psCaptcha = 'abc';
    adapter.replies.add(
      const _Reply(status: 400, body: '{"message":"验证码不正确"}'),
    );

    await expectLater(
      dio.post<void>('v1/user/login', data: <String, Object?>{}),
      throwsA(isA<DioException>()),
    );

    expect(context.psCaptcha, isNull);
  });

  test('sendLoginCode 响应后清空 psCaptcha', () async {
    context.psCaptcha = 'abc';
    adapter.replies.add(const _Reply());

    await dio.post<void>(
      'v3/user/sendLoginCode',
      data: <String, Object?>{'ua': '13800000000'},
    );

    expect(context.psCaptcha, isNull);
  });

  test('普通 GET（banners）不清空 psCaptcha', () async {
    adapter.replies
      ..add(
        const _Reply(
          headers: <String, List<String>>{
            'set-cookie': <String>['psCaptcha=abc; Path=/'],
          },
        ),
      )
      ..add(const _Reply());

    await dio.get<List<int>>(
      'v1/user/captcha',
      options: Options(responseType: ResponseType.bytes),
    );
    await dio.get<void>('v1/home/banners');

    expect(context.psCaptcha, 'abc');
  });
}

final class _Reply {
  const _Reply({
    this.status = 200,
    this.body = '{}',
    this.headers = const <String, List<String>>{},
  });

  final int status;
  final String body;
  final Map<String, List<String>> headers;
}

final class _RecordingAdapter implements HttpClientAdapter {
  final List<_Reply> replies = <_Reply>[];
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final _Reply reply = replies.isEmpty ? const _Reply() : replies.removeAt(0);
    return ResponseBody.fromString(
      reply.body,
      reply.status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
        ...reply.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
