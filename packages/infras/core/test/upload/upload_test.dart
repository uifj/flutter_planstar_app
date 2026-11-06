import 'dart:async';
import 'dart:typed_data';

import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:core/upload.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// 可编排的假适配器：按回调决定成功/失败，并统计并发峰值。
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responder);

  final FutureOr<ResponseBody> Function(RequestOptions options, int callIndex)
      responder;

  int calls = 0;
  int active = 0;
  int maxActive = 0;
  final List<RequestOptions> seen = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    seen.add(options);
    active++;
    if (active > maxActive) {
      maxActive = active;
    }
    try {
      return await responder(options, calls);
    } finally {
      active--;
    }
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _ok({String? etag}) => ResponseBody.fromString(
      '',
      200,
      headers: <String, List<String>>{
        if (etag != null) 'etag': <String>[etag],
      },
    );

ResponseBody _status(int status) => ResponseBody.fromString('', status);

Dio _dio(_FakeAdapter adapter) {
  final dio = buildDio(baseUrl: 'https://upload.planstar.test');
  dio.httpClientAdapter = adapter;
  return dio;
}

Uint8List _bytes(int length) => Uint8List.fromList(List<int>.filled(length, 7));

void main() {
  group('AsyncSemaphore 取消用返回值表达（§4.1）', () {
    test('许可用尽后等待，release 唤醒拿到 true', () async {
      final sem = AsyncSemaphore(1);
      expect(await sem.acquire(), isTrue);

      var woke = false;
      final waiter = sem.acquire().then((bool granted) {
        woke = true;
        return granted;
      });
      expect(woke, isFalse, reason: '没有许可时应该挂住');

      sem.release();
      expect(await waiter, isTrue);
    });

    test('cancelAll 让等待者拿到 false，而不是抛异常', () async {
      final sem = AsyncSemaphore(1);
      await sem.acquire();
      final waiter = sem.acquire();
      sem.cancelAll();
      // 关键：这里是 completes with false，不是 throws。
      expect(await waiter, isFalse);
      expect(sem.isCancelled, isTrue);
    });

    test('取消后新的 acquire 直接返回 false', () async {
      final sem = AsyncSemaphore(2)..cancelAll();
      expect(await sem.acquire(), isFalse);
      expect(sem.available, 0);
    });

    test('取消后 release 不回收许可（否则会复活已关闭的信号量）', () async {
      final sem = AsyncSemaphore(1);
      await sem.acquire();
      sem.cancelAll();
      sem.release();
      expect(sem.available, 0);
      expect(await sem.acquire(), isFalse);
    });
  });

  group('MultipartUploadEngine 基本流程', () {
    test('单分片成功，ETag 被记录', () async {
      final adapter = _FakeAdapter((_, _) => _ok(etag: 'etag-1'));
      final engine = MultipartUploadEngine(dio: _dio(adapter));

      final result = await engine.upload(
        bytes: _bytes(100),
        partUrlProvider: (part) async =>
            MultipartTarget(url: 'https://oss.test/p$part'),
      );

      expect(result.isSuccess, isTrue);
      expect(result.requireData.partCount, 1);
      expect(result.requireData.etags, <int, String>{1: 'etag-1'});
      expect(adapter.calls, 1);
    });

    test('分片数 = ceil(总长 / 分片大小)', () async {
      final adapter = _FakeAdapter((_, _) => _ok(etag: 'e'));
      final engine = MultipartUploadEngine(
        dio: _dio(adapter),
        config: const MultipartUploadConfig(partSize: 4, concurrency: 1),
      );

      final result = await engine.upload(
        bytes: _bytes(10), // 4 + 4 + 2
        partUrlProvider: (part) async =>
            MultipartTarget(url: 'https://oss.test/p$part'),
      );

      expect(result.requireData.partCount, 3);
      expect(adapter.calls, 3);
    });

    test('空文件直接失败，不发请求', () async {
      final adapter = _FakeAdapter((_, _) => _ok());
      final engine = MultipartUploadEngine(dio: _dio(adapter));
      final result = await engine.upload(
        bytes: Uint8List(0),
        partUrlProvider: (part) async =>
            MultipartTarget(url: 'https://oss.test/p$part'),
      );
      expect(result.isFailure, isTrue);
      expect(result.failure!.type, FailureType.validation);
      expect(adapter.calls, 0);
    });

    test('并发不超过配置值', () async {
      final adapter = _FakeAdapter((_, _) async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        return _ok(etag: 'e');
      });
      final engine = MultipartUploadEngine(
        dio: _dio(adapter),
        config: const MultipartUploadConfig(partSize: 1, concurrency: 3),
      );

      await engine.upload(
        bytes: _bytes(12),
        partUrlProvider: (part) async =>
            MultipartTarget(url: 'https://oss.test/p$part'),
      );

      expect(adapter.maxActive, lessThanOrEqualTo(3));
      expect(adapter.calls, 12);
    });
  });

  group('PartUrlProvider 每次重试都重新取签名（§2.4 核心）', () {
    test('403 后重新调用 provider，第二次成功', () async {
      var providerCalls = 0;
      final adapter = _FakeAdapter((_, callIndex) {
        // 第一次 403（预签名过期），之后成功。
        return callIndex == 1 ? _status(403) : _ok(etag: 'fresh');
      });
      final engine = MultipartUploadEngine(
        dio: _dio(adapter),
        config: const MultipartUploadConfig(
          retryDelay: Duration.zero,
          maxRetries: 2,
        ),
      );

      final result = await engine.upload(
        bytes: _bytes(10),
        partUrlProvider: (part) async {
          providerCalls++;
          return MultipartTarget(
            url: 'https://oss.test/p$part?sig=$providerCalls',
          );
        },
      );

      expect(result.isSuccess, isTrue, reason: '403 应被判定为可重试');
      expect(providerCalls, 2, reason: '重试必须重新取签名，而不是复用旧 URL');
      expect(adapter.calls, 2);
      expect(result.requireData.etags, <int, String>{1: 'fresh'});
    });

    test('重试时传给 PUT 的是新签名 URL', () async {
      var providerCalls = 0;
      final adapter = _FakeAdapter((_, callIndex) {
        return callIndex == 1 ? _status(403) : _ok(etag: 'e');
      });
      final engine = MultipartUploadEngine(
        dio: _dio(adapter),
        config: const MultipartUploadConfig(
          retryDelay: Duration.zero,
          maxRetries: 1,
        ),
      );

      await engine.upload(
        bytes: _bytes(4),
        partUrlProvider: (part) async {
          providerCalls++;
          return MultipartTarget(url: 'https://oss.test/p$part?sig=$providerCalls');
        },
      );

      expect(adapter.seen.first.uri.queryParameters['sig'], '1');
      expect(adapter.seen.last.uri.queryParameters['sig'], '2');
    });

    test('不可重试的错误（500）立即失败，不重试', () async {
      var providerCalls = 0;
      final adapter = _FakeAdapter((_, _) => _status(500));
      final engine = MultipartUploadEngine(
        dio: _dio(adapter),
        config: const MultipartUploadConfig(
          retryDelay: Duration.zero,
          maxRetries: 3,
        ),
      );

      final result = await engine.upload(
        bytes: _bytes(4),
        partUrlProvider: (part) async {
          providerCalls++;
          return MultipartTarget(url: 'https://oss.test/p$part');
        },
      );

      expect(result.isFailure, isTrue);
      expect(result.failure!.statusCode, 500);
      expect(providerCalls, 1, reason: '5xx 不该重试');
    });

    test('注入的自定义 RetryDecider 覆盖默认判断', () async {
      final adapter = _FakeAdapter((_, _) => _status(500));
      final engine = MultipartUploadEngine(
        dio: _dio(adapter),
        config: const MultipartUploadConfig(
          retryDelay: Duration.zero,
          maxRetries: 2,
        ),
        // 调用方的协议知识：这个场景下 500 也该重试。
        isRetryable: (failure) => failure.statusCode == 500,
      );

      final result = await engine.upload(
        bytes: _bytes(4),
        partUrlProvider: (part) async =>
            MultipartTarget(url: 'https://oss.test/p$part'),
      );

      expect(result.isFailure, isTrue);
      expect(adapter.calls, 3, reason: '首次 + 2 次重试');
    });
  });

  group('进度与断点续传', () {
    test('节流为 0 时每片都回调，且比例递增到 1', () async {
      final adapter = _FakeAdapter((_, _) => _ok(etag: 'e'));
      final engine = MultipartUploadEngine(
        dio: _dio(adapter),
        config: const MultipartUploadConfig(
          partSize: 1,
          concurrency: 1,
          progressThrottle: Duration.zero,
        ),
      );
      final seen = <double>[];
      final result = await engine.upload(
        bytes: _bytes(4),
        partUrlProvider: (part) async =>
            MultipartTarget(url: 'https://oss.test/p$part'),
        onProgress: (p) => seen.add(p.fraction),
      );

      expect(result.isSuccess, isTrue);
      expect(seen.length, 4);
      expect(seen.last, 1.0);
    });

    test('节流生效：固定时钟下只有首次与收尾两次回调', () async {
      final adapter = _FakeAdapter((_, _) => _ok(etag: 'e'));
      final frozen = DateTime.utc(2026, 1, 1);
      final engine = MultipartUploadEngine(
        dio: _dio(adapter),
        config: const MultipartUploadConfig(
          partSize: 1,
          concurrency: 1,
          progressThrottle: Duration(hours: 1),
        ),
        clock: () => frozen,
      );
      final seen = <MultipartProgress>[];
      await engine.upload(
        bytes: _bytes(3),
        partUrlProvider: (part) async =>
            MultipartTarget(url: 'https://oss.test/p$part'),
        onProgress: seen.add,
      );

      expect(seen.length, 2, reason: '首次放行 + 收尾强制，中间被节流掉');
      expect(seen.last.completedParts, 3);
    });

    test('断点续传：跳过已上传分片，并带上已有 ETag', () async {
      final adapter = _FakeAdapter((_, _) => _ok(etag: 'new'));
      final engine = MultipartUploadEngine(
        dio: _dio(adapter),
        config: const MultipartUploadConfig(partSize: 4, concurrency: 1),
      );

      final result = await engine.upload(
        bytes: _bytes(12), // 3 片
        alreadyUploaded: <int>{1, 2},
        initialEtags: <int, String>{1: 'old-1', 2: 'old-2'},
        partUrlProvider: (part) async =>
            MultipartTarget(url: 'https://oss.test/p$part'),
      );

      expect(adapter.calls, 1, reason: '只该传第 3 片');
      expect(
        result.requireData.etags,
        <int, String>{1: 'old-1', 2: 'old-2', 3: 'new'},
      );
    });
  });

  group('取消', () {
    test('取消令牌触发后返回 REQUEST_CANCELLED 而不是抛异常', () async {
      final adapter = _FakeAdapter((_, _) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return _ok(etag: 'e');
      });
      final engine = MultipartUploadEngine(
        dio: _dio(adapter),
        config: const MultipartUploadConfig(
          partSize: 1,
          concurrency: 1,
          maxRetries: 0,
          retryDelay: Duration.zero,
        ),
      );
      final token = CancelToken();

      final future = engine.upload(
        bytes: _bytes(5),
        cancelToken: token,
        partUrlProvider: (part) async =>
            MultipartTarget(url: 'https://oss.test/p$part'),
      );
      token.cancel('用户取消');
      final result = await future;

      expect(result.isFailure, isTrue);
      expect(result.failure!.code, 'REQUEST_CANCELLED');
    });
  });
}
