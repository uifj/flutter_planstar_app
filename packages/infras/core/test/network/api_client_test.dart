import 'dart:typed_data';

import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// 假的 Dio 适配器：按请求返回预置响应，不发真实网络。
final class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responder);

  final ResponseBody Function(RequestOptions options) responder;

  /// 最近一次请求（用于断言 envelope 覆盖等）。
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

/// 仅用于断言拦截器"被追加且保序"，不做任何事。
class _NoopInterceptor extends Interceptor {}

ResponseBody _json(String body, {int status = 200}) => ResponseBody.fromString(
      body,
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json; charset=utf-8'],
      },
    );

ApiClient _clientWith(
  ResponseBody Function(RequestOptions options) responder, {
  ResponseEnvelope? envelope,
  _FakeAdapter? adapter,
}) {
  final fake = adapter ?? _FakeAdapter(responder);
  final dio = buildDio(baseUrl: 'https://api.planstar.test', adapter: fake);
  return ApiClient(dio, envelope: envelope);
}

void main() {
  group('ResponseEnvelope', () {
    test('PassthroughEnvelope 永远成功，数据即原始 body', () {
      const env = PassthroughEnvelope();
      final body = <String, Object?>{'code': 500, 'data': 1};
      expect(env.isSuccess(body, 200), isTrue);
      expect(env.extractData(body), same(body));
    });

    test('RestCodeEnvelope 认 {0,200} 为成功', () {
      const env = RestCodeEnvelope();
      expect(env.isSuccess({'code': 0}, 200), isTrue);
      expect(env.isSuccess({'code': 200}, 200), isTrue);
      expect(env.isSuccess({'code': '0'}, 200), isTrue);
      expect(env.isSuccess({'code': 1001}, 200), isFalse);
    });

    test('RestCodeEnvelope 缺 code 键时默认判失败（修复静默成功）', () {
      const env = RestCodeEnvelope();
      expect(env.isSuccess({'data': 1}, 200), isFalse);
      final err = env.extractError({'data': 1}, 200);
      expect(err.code, 'MISSING_ENVELOPE');
      expect(err.message, contains('code'));
    });

    test('RestCodeEnvelope 可选择 assumeSuccess 兼容未包装接口', () {
      const env =
          RestCodeEnvelope(missingEnvelope: MissingEnvelopePolicy.assumeSuccess);
      expect(env.isSuccess({'data': 1}, 200), isTrue);
      expect(env.extractData({'data': 1}), {'data': 1});
    });

    test('code 键存在但不是数字 → 不猜，判失败', () {
      const env = RestCodeEnvelope();
      expect(env.isSuccess({'code': 'oops'}, 200), isFalse);
    });

    test('成功码集可配', () {
      const env = RestCodeEnvelope(successCodes: <int>{1});
      expect(env.isSuccess({'code': 1}, 200), isTrue);
      expect(env.isSuccess({'code': 0}, 200), isFalse);
    });
  });

  group('ApiClient 成功路径', () {
    test('Passthrough + parser 取字段', () async {
      final client = _clientWith(
        (_) => _json('{"data":{"name":"企划星"}}'),
        envelope: const PassthroughEnvelope(),
      );
      final result = await client.get<String>(
        '/user',
        parser: (data) {
          final map = data! as Map<Object?, Object?>;
          final inner = map['data']! as Map<Object?, Object?>;
          return inner['name']! as String;
        },
      );
      expect(result.isSuccess, isTrue);
      expect(result.requireData, '企划星');
    });

    test('RestCode 成功时只交数据段给 parser', () async {
      final client = _clientWith(
        (_) => _json('{"code":0,"message":"ok","data":{"id":7}}'),
        envelope: const RestCodeEnvelope(),
      );
      final result = await client.get<int>(
        '/show',
        parser: (data) => (data! as Map)['id']! as int,
      );
      expect(result.requireData, 7);
    });

    test('调用级信封覆盖构造级默认', () async {
      final client = _clientWith(
        (_) => _json('{"code":9999,"data":"raw"}'),
        envelope: const RestCodeEnvelope(),
      );

      final asRest = await client.get<String>('/x');
      expect(asRest.isFailure, isTrue);

      final asRaw = await client.get<String>(
        '/x',
        envelope: const PassthroughEnvelope(),
        parser: (data) => (data! as Map)['data']! as String,
      );
      expect(asRaw.requireData, 'raw');
    });
  });

  group('ApiClient 失败路径（全部返回 Failure，不抛）', () {
    test('业务码失败 → Failure.server 带业务码与 message', () async {
      final client = _clientWith(
        (_) => _json('{"code":1001,"message":"票已售罄","requestId":"r-1"}'),
        envelope: const RestCodeEnvelope(),
      );
      final result = await client.get<Object?>('/buy');

      final failure = result.failure!;
      expect(failure.type, FailureType.server);
      expect(failure.code, '1001');
      expect(failure.message, '票已售罄');
      expect(failure.requestId, 'r-1');
      expect(failure.isRetryable, isFalse);
    });

    test('HTTP 500 → SERVER_ERROR + statusCode，且不重试', () async {
      final client = _clientWith((_) => _json('{"message":"崩了"}', status: 500));
      final result = await client.get<Object?>('/x');

      expect(result.failure!.code, 'SERVER_ERROR');
      expect(result.failure!.statusCode, 500);
      expect(result.failure!.message, '崩了');
      expect(result.failure!.isRetryable, isFalse);
    });

    test('HTTP 401 → unauthorized，isAuthFailure 为真', () async {
      final client = _clientWith((_) => _json('{}', status: 401));
      final result = await client.get<Object?>('/me');

      expect(result.failure!.type, FailureType.authentication);
      expect(result.failure!.isAuthFailure, isTrue);
      expect(result.failure!.statusCode, 401);
    });

    test('HTTP 429 → TOO_MANY_REQUESTS', () async {
      final client = _clientWith((_) => _json('{}', status: 429));
      expect((await client.get<Object?>('/x')).failure!.code,
          'TOO_MANY_REQUESTS');
    });

    test('parser 抛异常 → PARSE_ERROR / FailureType.data', () async {
      final client = _clientWith(
        (_) => _json('{"code":0,"data":{"id":"不是数字"}}'),
        envelope: const RestCodeEnvelope(),
      );
      final result = await client.get<int>(
        '/show',
        parser: (data) => (data! as Map)['id']! as int,
      );

      expect(result.failure!.code, 'PARSE_ERROR');
      expect(result.failure!.type, FailureType.data);
    });

    test('适配器抛非 Dio 异常 → 仍收敛为 Failure', () async {
      final client = _clientWith((_) => throw StateError('boom'));
      final result = await client.get<Object?>('/x');

      expect(result.isFailure, isTrue);
      expect(result.failure!.code, isNotEmpty);
    });

    test('取消请求 → REQUEST_CANCELLED，且可重试', () async {
      final adapter = _FakeAdapter((_) => _json('{}'));
      final client = _clientWith(
        (_) => _json('{}'),
        adapter: adapter,
      );
      final token = CancelToken();
      token.cancel('用户返回');

      final result = await client.get<Object?>('/x', cancelToken: token);
      expect(result.failure!.code, 'REQUEST_CANCELLED');
      expect(result.failure!.isRetryable, isTrue);
    });
  });

  group('buildDio', () {
    test('不覆盖 validateStatus（4xx/5xx 走 DioException）', () {
      final dio = buildDio(baseUrl: 'https://api.planstar.test');
      expect(dio.options.validateStatus(200), isTrue);
      expect(dio.options.validateStatus(404), isFalse);
    });

    test('除 dio 自身内置的 ImplyContentTypeInterceptor 外不注入任何拦截器', () {
      // dio 5.10+ 在构造 Dio() 时自己会塞一个 ImplyContentTypeInterceptor，
      // 那不是 buildDio 注入的。所以基线取"裸 Dio() 的拦截器数量"，
      // 断言 buildDio 没有在其上再叠加——这样跨 dio 版本也不会误报。
      final baseline = Dio().interceptors.length;
      final dio = buildDio(baseUrl: 'https://api.planstar.test');
      expect(dio.interceptors.length, baseline);
    });

    test('显式传入的拦截器按序追加', () {
      final first = _NoopInterceptor();
      final second = _NoopInterceptor();
      final baseline = Dio().interceptors.length;
      final dio = buildDio(
        baseUrl: 'https://api.planstar.test',
        interceptors: <Interceptor>[first, second],
      );
      expect(dio.interceptors.length, baseline + 2);
      // 追加顺序必须与传入顺序一致（拦截器顺序会改变鉴权/重试语义）。
      expect(dio.interceptors[baseline], same(first));
      expect(dio.interceptors[baseline + 1], same(second));
    });

    test('超时默认值与来源对齐', () {
      final dio = buildDio(baseUrl: 'https://api.planstar.test');
      expect(dio.options.connectTimeout, const Duration(seconds: 10));
      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
      expect(dio.options.sendTimeout, const Duration(seconds: 30));
    });
  });
}
