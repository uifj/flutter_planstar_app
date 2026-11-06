/// RetryInterceptor 测试：重试行为 + 计数不泄漏到请求头。
library;

import 'dart:io';

import 'package:core/network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  late HttpServer server;
  late Dio dio;
  late List<Map<String, String>> receivedHeaders;
  int hangTimes = 0; // 前 N 次请求挂起以触发 receiveTimeout。

  setUp(() async {
    receivedHeaders = <Map<String, String>>[];
    hangTimes = 0;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((HttpRequest req) async {
      final headers = <String, String>{};
      req.headers.forEach((String name, List<String> values) {
        headers[name] = values.join(',');
      });
      receivedHeaders.add(headers);
      if (receivedHeaders.length <= hangTimes) {
        await Future<void>.delayed(const Duration(seconds: 3));
      }
      req.response.write('ok');
      await req.response.close();
    });
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:${server.port}',
        receiveTimeout: const Duration(seconds: 1),
      ),
    );
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retryDelays: const <Duration>[
          Duration(milliseconds: 10),
          Duration(milliseconds: 10),
          Duration(milliseconds: 10),
        ],
      ),
    );
  });

  tearDown(() async {
    dio.close(force: true);
    await server.close(force: true);
  });

  test('超时触发重试并最终成功；请求头中不含 retry_attempt', () async {
    hangTimes = 1; // 首次挂起超时，第二次成功。
    final Response<String> response = await dio.get<String>('/x');

    expect(response.data, 'ok');
    expect(receivedHeaders, hasLength(2), reason: '原始 1 次 + 重试 1 次');
    for (final headers in receivedHeaders) {
      expect(
        headers.keys.map((String k) => k.toLowerCase()),
        isNot(contains('retry_attempt')),
        reason: '重试计数是内部元数据，不得泄漏到 HTTP 请求头',
      );
    }
  });

  test('重试次数受 maxRetries / 延迟表约束（全部超时 → 共 4 次请求后失败）',
      () async {
    hangTimes = 99;
    await expectLater(
      dio.get<String>('/x'),
      throwsA(isA<DioException>()),
    );
    expect(receivedHeaders, hasLength(4), reason: '原始 1 次 + 3 次重试');
  });

  test('业务错误（4xx）不重试', () async {
    final Dio badDio = Dio(
      BaseOptions(baseUrl: 'http://localhost:${server.port}'),
    );
    addTearDown(() => badDio.close(force: true));
    badDio.interceptors.add(
      RetryInterceptor(
        dio: badDio,
        retryDelays: const <Duration>[Duration(milliseconds: 10)],
      ),
    );

    // 服务端正常返回 200，但用 validateStatus 把 200 判成失败，
    // 走 badResponse 分支——属于业务失败而非瞬时网络错误。
    await expectLater(
      badDio.get<String>(
        '/x',
        options: Options(validateStatus: (int? status) => false),
      ),
      throwsA(isA<DioException>()),
    );
    expect(receivedHeaders, hasLength(1), reason: 'badResponse 不应重试');
  });
}
