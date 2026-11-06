/// FormPostUploader 测试：本地 HttpServer 验证表单字段契约与错误映射。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/result.dart';
import 'package:core/upload.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  late HttpServer server;
  late String endpoint;
  late List<String> receivedBodies;
  int statusCode = 200;

  setUp(() async {
    receivedBodies = <String>[];
    statusCode = 200;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    endpoint = 'localhost:${server.port}';
    server.listen((HttpRequest req) async {
      receivedBodies.add(await _decodeSafe(req));
      req.response.statusCode = statusCode;
      await req.response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
  });

  // 生产走 https；本地 server 是 http，经拦截器降级协议。
  Dio buildDio() {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          options.path = options.path.replaceFirst('https://', 'http://');
          handler.next(options);
        },
      ),
    );
    return dio;
  }

  OssFormUploadRequest request({Uint8List? bytes}) => OssFormUploadRequest(
        endpoint: endpoint,
        objectKey: 'LOG/uuid/upload-abc.zip',
        policy: 'policy-x',
        accessKeyId: 'ak-x',
        signature: 'sig-x',
        bytes: bytes ?? Uint8List.fromList(<int>[1, 2, 3]),
      );

  test('表单字段契约逐字保真（key/policy/OSSAccessKeyId/'
      'success_action_status/signature/file）', () async {
    final uploader = FormPostUploader(dio: buildDio());
    final Result<void> result = await uploader.upload(request());

    expect(result.isSuccess, isTrue);
    final body = receivedBodies.single;
    expect(body, contains('name="key"'));
    expect(body, contains('LOG/uuid/upload-abc.zip'));
    expect(body, contains('name="policy"'));
    expect(body, contains('policy-x'));
    expect(body, contains('name="OSSAccessKeyId"'));
    expect(body, contains('ak-x'));
    expect(body, contains('name="success_action_status"'));
    expect(body, contains('200'));
    expect(body, contains('name="signature"'));
    expect(body, contains('sig-x'));
    expect(body, contains('name="file"'));
  });

  test('进度回调', () async {
    var progressed = false;
    final uploader = FormPostUploader(dio: buildDio());
    final Result<void> result = await uploader.upload(
      request(bytes: Uint8List.fromList(List<int>.filled(2048, 7))),
      onProgress: (int sent, int total) {
        if (sent > 0) {
          progressed = true;
        }
      },
    );

    expect(result.isSuccess, isTrue);
    expect(progressed, isTrue);
  });

  test('非 200 → HTTP_ERROR（server Failure）', () async {
    statusCode = 403;
    final uploader = FormPostUploader(dio: buildDio());
    final Result<void> result = await uploader.upload(request());

    expect(result.isFailure, isTrue);
    expect(result.failure!.code, 'HTTP_ERROR');
    expect(result.failure!.statusCode, 403);
  });

  test('dispose 后 upload → input Failure（不发请求）；dispose 幂等', () async {
    final uploader = FormPostUploader(dio: buildDio());
    uploader.dispose();
    uploader.dispose();

    final Result<void> result = await uploader.upload(request());

    expect(result.isFailure, isTrue);
    expect(result.failure!.type, FailureType.validation);
    expect(receivedBodies, isEmpty);
  });

  test('取消 → REQUEST_CANCELLED', () async {
    final CancelToken token = CancelToken()..cancel();
    final uploader = FormPostUploader(dio: buildDio());
    final Result<void> result = await uploader.upload(
      request(),
      cancelToken: token,
    );

    expect(result.isFailure, isTrue);
    expect(result.failure!.code, 'REQUEST_CANCELLED');
  });
}

/// 读取请求体（multipart 含二进制段，容错解码）。
Future<String> _decodeSafe(HttpRequest req) async {
  final bytes = <int>[];
  await for (final chunk in req) {
    bytes.addAll(chunk);
  }
  return utf8.decode(bytes, allowMalformed: true);
}
