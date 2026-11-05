/// 响应信封测试：三内置信封单元 + ApiClient 集成（本地 HttpServer）。
library;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_core/network_core.dart';

void main() {
  group('RestCodeEnvelope 单元', () {
    const envelope = RestCodeEnvelope();

    test('code 命中成功码集 → 成功并提取 data 段', () {
      final body = {
        'code': 0,
        'message': 'ok',
        'data': {'id': 1},
      };
      expect(envelope.isSuccess(body, 200), isTrue);
      expect(envelope.extractData(body), {'id': 1});
    });

    test('业务码失败 → 提取 code/message', () {
      final body = {'code': 40001, 'message': 'token expired', 'data': null};
      expect(envelope.isSuccess(body, 200), isFalse);
      final err = envelope.extractError(body, 200);
      expect(err.code, '40001');
      expect(err.message, 'token expired');
    });

    test('字符串形式 code 兼容；非 Map / 缺 code 键保守直通', () {
      expect(envelope.isSuccess({'code': '200', 'data': 1}, 200), isTrue);
      expect(envelope.isSuccess([1, 2, 3], 200), isTrue);
      expect(envelope.extractData([1, 2, 3]), [1, 2, 3]);
      expect(envelope.isSuccess({'foo': 'bar'}, 200), isTrue);
      expect(envelope.extractData({'foo': 'bar'}), {'foo': 'bar'});
    });

    test('自定义键名与成功码集', () {
      const custom = RestCodeEnvelope(
        codeKey: 'errno',
        messageKey: 'msg',
        dataKey: 'result',
        successCodes: {1},
      );
      final body = {'errno': 1, 'msg': 'ok', 'result': 'x'};
      expect(custom.isSuccess(body, 200), isTrue);
      expect(custom.extractData(body), 'x');
    });
  });

  group('ApiClient 集成（本地 HttpServer）', () {
    late HttpServer server;
    late Dio dio;
    Map<String, dynamic> payload = {};

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) async {
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode(payload));
        await req.response.close();
      });
      dio = Dio(BaseOptions(baseUrl: 'http://localhost:${server.port}'));
    });

    tearDown(() async {
      dio.close(force: true);
      await server.close(force: true);
    });

    test('默认 Passthrough：行为与无信封层一致（信封字段原样透出）', () async {
      payload = {'code': 500, 'message': 'boom', 'data': null};
      final client = ApiClient(dio);
      final result = await client.get<Map<String, dynamic>>(
        '/x',
        parser: (data) => Map<String, dynamic>.from(data as Map),
      );
      expect(result.isSuccess, isTrue, reason: '直通信封不判业务码');
      expect(result.data['code'], 500);
    });

    test(
      '构造级 RestCodeEnvelope：业务码失败 → Failure(code/statusCode/cause)',
      () async {
        payload = {'code': 40001, 'message': 'token expired', 'data': null};
        final client = ApiClient(dio, envelope: const RestCodeEnvelope());
        final result = await client.get<dynamic>('/x');
        expect(result.isFailure, isTrue);
        expect(result.failure!.code, '40001');
        expect(result.failure!.message, 'token expired');
        expect(result.failure!.type, FailureType.server);
        expect(result.failure!.statusCode, 200);
        expect(result.failure!.cause, isA<EnvelopeError>());
      },
    );

    test('构造级信封成功：parser 收到的是 data 段', () async {
      payload = {
        'code': 0,
        'message': 'ok',
        'data': {'name': 'stow'},
      };
      final client = ApiClient(dio, envelope: const RestCodeEnvelope());
      final result = await client.get<String>(
        '/x',
        parser: (data) => (data as Map)['name'] as String,
      );
      expect(result.isSuccess, isTrue);
      expect(result.data, 'stow');
    });

    test('调用级信封覆盖构造级', () async {
      payload = {
        'ResultCode': 'Forbidden',
        'ResultMessage': 'no auth',
        'RequestId': 'r-1',
      };
      // 构造级 Passthrough（会成功），调用级 Pascal 信封（应失败）。
      final client = ApiClient(dio);
      final result = await client.post<dynamic>(
        '/x',
        envelope: const _PascalResultEnvelope(),
      );
      expect(result.isFailure, isTrue);
      expect(result.failure!.code, 'Forbidden');
      expect((result.failure!.cause as EnvelopeError?)?.requestId, 'r-1');
    });

    test(
      'requestWithParse + envelope：业务失败抛 RequestError(SERVER_ERROR)',
      () async {
        payload = {'code': 40001, 'message': 'token expired', 'data': null};
        final manager = HttpManager.getInstance();
        await expectLater(
          manager.requestWithParse<dynamic>(
            'http://localhost:${server.port}/x',
            (json) => json,
            envelope: const RestCodeEnvelope(),
          ),
          throwsA(
            isA<RequestError>()
                .having((e) => e.type, 'type', RequestErrorType.SERVER_ERROR)
                .having((e) => e.code, 'code', '40001')
                .having((e) => e.message, 'message', 'token expired'),
          ),
        );

        // 信封成功：jsonParse 收到 data 段。
        payload = {
          'code': 0,
          'data': {'name': 'stow'},
        };
        final parsed = await manager.requestWithParse<String>(
          'http://localhost:${server.port}/x',
          (json) => (json as Map)['name'] as String,
          envelope: const RestCodeEnvelope(),
        );
        expect(parsed, 'stow');
      },
    );

    test('parser 抛异常不逃逸 Result（归一 Failure.server）', () async {
      payload = {'code': 0, 'data': 'not a map'};
      final client = ApiClient(dio, envelope: const RestCodeEnvelope());
      final result = await client.get<int>(
        '/x',
        parser: (data) => (data as Map)['n'] as int, // 必然 cast 失败
      );
      expect(result.isFailure, isTrue);
      expect(result.failure!.type, FailureType.server);
    });
  });
}

/// 测试用信封：Pascal 键 ResultCode/ResultMessage/RequestId。
/// 原由库里的 WyotaEnvelope 承担；厂商类剥离后在此就地保留同等语义，
/// 使“调用级信封覆盖构造级”这条不变量继续有被测对象。
class _PascalResultEnvelope extends ResponseEnvelope {
  const _PascalResultEnvelope();

  static const Set<String> _ok = {'', '0', 'Success', 'success'};

  @override
  bool isSuccess(dynamic body, int? statusCode) {
    if (body is! Map) return true;
    final raw = body['ResultCode'];
    if (raw == null) return true;
    return _ok.contains('$raw');
  }

  @override
  dynamic extractData(dynamic body) => body;

  @override
  EnvelopeError extractError(dynamic body, int? statusCode) {
    if (body is! Map) return const EnvelopeError();
    return EnvelopeError(
      code: body['ResultCode']?.toString(),
      message: body['ResultMessage']?.toString(),
      requestId: body['RequestId']?.toString(),
    );
  }
}
