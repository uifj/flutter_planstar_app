import 'dart:typed_data';

import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 统一错误信封解析：JSON / text/plain / 401。
void main() {
  ApiClient clientReturning({
    required int status,
    required String body,
    required String contentType,
  }) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/'));
    dio.httpClientAdapter = _FakeAdapter(
      status: status,
      body: body,
      contentType: contentType,
    );
    return ApiClient(dio);
  }

  test('JSON 错误体保留 code / message / traceId', () async {
    final client = clientReturning(
      status: 409,
      body: '{"code":"SOLD_OUT","message":"票档已售罄","traceId":"trace-1"}',
      contentType: 'application/json',
    );

    final result = await client.get<Map<String, dynamic>>(
      'v1/test',
      parser: (data) => data as Map<String, dynamic>,
    );

    expect(result, isA<Fail<Map<String, dynamic>>>());
    final failure = result.failure!;
    expect(failure.code, 'SOLD_OUT');
    expect(failure.message, '票档已售罄');
    expect(failure.requestId, 'trace-1');
    expect(failure.statusCode, 409);
  });

  test('text/plain 错误体直接作为用户文案', () async {
    final client = clientReturning(
      status: 500,
      body: '验证码不正确',
      contentType: 'text/plain; charset=utf-8',
    );

    final result = await client.get<Map<String, dynamic>>(
      'v1/test',
      parser: (data) => data as Map<String, dynamic>,
    );

    expect(result.isFailure, isTrue);
    expect(result.failure!.message, '验证码不正确');
  });

  test('401 仍是认证失败，保留服务端文案', () async {
    final client = clientReturning(
      status: 401,
      body: '{"code":"TOKEN_EXPIRED","message":"登录已失效"}',
      contentType: 'application/json',
    );

    final result = await client.get<Map<String, dynamic>>(
      'v1/test',
      parser: (data) => data as Map<String, dynamic>,
    );

    final failure = result.failure!;
    expect(failure.type, FailureType.authentication);
    expect(failure.statusCode, 401);
    expect(failure.message, '登录已失效');
  });
}

final class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({
    required this.status,
    required this.body,
    required this.contentType,
  });

  final int status;
  final String body;
  final String contentType;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
