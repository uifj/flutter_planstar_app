/// 分片上传引擎：并发编排 + 重试 + 进度节流 + 断点续传。
///
/// **本模块与业务协议无关。** 分片会话（initiate / 取凭证 / complete）与凭证
/// 获取留在业务层；引擎只消费 [PartUrlProvider] 注入的预签名上传目标。
///
/// 这就是 Clean DDD 里 `domain` 不依赖 `data` 的同构写法：
/// 引擎 = domain service，[PartUrlProvider] = port，OSS 签名 = adapter。
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:core/result.dart';
import 'package:dio/dio.dart';

import 'async_semaphore.dart';
import 'multipart_models.dart';

/// 「这个失败该不该重试」的判断回调。
///
/// 由调用方注入，因为"哪些错误可重试"属于**调用方的协议知识**：
/// 企划星 legacy（L879-884）里 OSS 原生错误码 3 / 32 是不可重试的，
/// 而 403 恰恰要重试（预签名过期，重新签名后即可成功）。引擎自己不猜。
typedef RetryDecider = bool Function(Failure failure);

/// 分片上传引擎。
///
/// 用法：
/// ```dart
/// final engine = MultipartUploadEngine(dio: dio);
/// final result = await engine.upload(
///   bytes: fileBytes,
///   partUrlProvider: (part) => api.signPart(uploadId, part), // 每次重试都会再调
///   onProgress: (p) => setState(() => _progress = p.fraction),
/// );
/// ```
final class MultipartUploadEngine {
  /// 创建引擎。
  MultipartUploadEngine({
    required Dio dio,
    this.config = const MultipartUploadConfig(),
    RetryDecider? isRetryable,
    DateTime Function()? clock,
  })  : _dio = dio,
        _isRetryable = isRetryable ?? defaultRetryDecider,
        _clock = clock ?? DateTime.now;

  final Dio _dio;
  final RetryDecider _isRetryable;
  final DateTime Function() _clock;

  /// 配置。
  final MultipartUploadConfig config;

  /// `application/octet-stream`。dio 的 `Headers` 没有这个常量，只能写字面量。
  static const String _octetStreamContentType = 'application/octet-stream';

  /// ETag 响应头名。dio 同样没有对应常量。
  static const String _etagHeader = 'etag';

  /// 默认重试判定。
  ///
  /// - 取消**不**重试；
  /// - 403 **要**重试（预签名过期 → 下次 [PartUrlProvider] 会给新签名）；
  /// - 其余按 [Failure.isRetryable]（只认超时与网络中断）。
  ///
  /// 服务端 5xx 不重试：分片 PUT 重发可能造成半写状态，交给上层决定。
  static bool defaultRetryDecider(Failure failure) {
    if (failure.code == 'REQUEST_CANCELLED') {
      return false;
    }
    if (failure.statusCode == 403) {
      return true;
    }
    return failure.isRetryable;
  }

  /// 上传 [bytes]。
  ///
  /// [alreadyUploaded] 是断点续传时已完成的片号（1 基），这些片会被跳过；
  /// 引擎**不负责持久化**它——续传状态留在 feature 层（§2.4 落地改法）。
  /// [initialEtags] 配合 [alreadyUploaded] 使用，把上次拿到的 ETag 一起带回来，
  /// 这样调用方 complete 时能拼出完整的 ETag 列表。
  ///
  /// 返回 [Result]：**不抛异常**。取消也是一种 [Fail]，`code` 为
  /// `REQUEST_CANCELLED`。
  Future<Result<MultipartUploadResult>> upload({
    required Uint8List bytes,
    required PartUrlProvider partUrlProvider,
    Set<int> alreadyUploaded = const <int>{},
    Map<int, String> initialEtags = const <int, String>{},
    void Function(MultipartProgress progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (bytes.isEmpty) {
      return Fail<MultipartUploadResult>(
        Failure.input(message: '文件为空，无需上传'),
      );
    }

    final partCount = (bytes.length + config.partSize - 1) ~/ config.partSize;
    final semaphore = AsyncSemaphore(config.concurrency);
    final etags = <int, String>{...initialEtags};

    var uploadedBytes = 0;
    for (final part in alreadyUploaded) {
      if (part >= 1 && part <= partCount) {
        uploadedBytes += _partLength(part, partCount, bytes.length);
      }
    }
    var completedParts = alreadyUploaded.length;
    Failure? abortReason;
    var lastEmit = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    // 最后一片完成时会强制发一次；收尾不要再发一次，否则进度回调数量翻倍。
    var finalEmitted = false;

    void emitProgress({bool force = false}) {
      final callback = onProgress;
      if (callback == null) {
        return;
      }
      final now = _clock();
      if (!force && now.difference(lastEmit) < config.progressThrottle) {
        return;
      }
      lastEmit = now;
      callback(
        MultipartProgress(
          uploadedBytes: uploadedBytes,
          totalBytes: bytes.length,
          completedParts: completedParts,
          totalParts: partCount,
        ),
      );
    }

    Future<Result<int>> runPart(int partNumber) async {
      final granted = await semaphore.acquire();
      if (!granted) {
        return Fail<int>(_cancelledFailure());
      }
      try {
        final existingAbort = abortReason;
        if (existingAbort != null) {
          return Fail<int>(existingAbort);
        }

        final start = (partNumber - 1) * config.partSize;
        final end = math.min(start + config.partSize, bytes.length);
        // sublistView 不复制数据：20MiB 的分片不会额外占一份内存。
        final chunk = Uint8List.sublistView(bytes, start, end);
        Failure? lastFailure;

        for (var attempt = 0; attempt <= config.maxRetries; attempt++) {
          if (attempt > 0) {
            await Future<void>.delayed(config.retryDelay);
          }
          final aborted = abortReason;
          if (aborted != null) {
            return Fail<int>(aborted);
          }
          if (cancelToken?.isCancelled ?? false) {
            final cancelled = _cancelledFailure();
            abortReason ??= cancelled;
            return Fail<int>(cancelled);
          }

          try {
            // ✱ 每次尝试都重新取签名：凭证刷新的结构性保证。
            final target = await partUrlProvider(partNumber);
            final response = await _dio.put<void>(
              target.url,
              data: chunk,
              options: Options(
                headers: <String, Object?>{
                  ...target.headers,
                  Headers.contentLengthHeader: chunk.length,
                },
                contentType: _octetStreamContentType,
              ),
              cancelToken: cancelToken,
            );
            etags[partNumber] =
                response.headers.value(_etagHeader) ?? '';
            uploadedBytes += chunk.length;
            completedParts++;
            if (completedParts >= partCount) {
              finalEmitted = true;
              emitProgress(force: true);
            } else {
              emitProgress();
            }
            return Success<int>(partNumber);
          } on DioException catch (error) {
            final failure = _mapDioException(error);
            lastFailure = failure;
            final canRetry = attempt < config.maxRetries &&
                _isRetryable(failure) &&
                !(cancelToken?.isCancelled ?? false);
            if (!canRetry) {
              abortReason ??= failure;
              // 让还在排队的片立刻拿到 false，不要干等。
              semaphore.cancelAll();
              return Fail<int>(failure);
            }
          } catch (error) {
            final failure = Failure(
              code: 'UPLOAD_ERROR',
              message: '分片上传失败：$error',
              type: FailureType.network,
              cause: error,
            );
            lastFailure = failure;
            if (attempt >= config.maxRetries) {
              abortReason ??= failure;
              semaphore.cancelAll();
              return Fail<int>(failure);
            }
          }
        }
        final fallback = lastFailure ??
            Failure(
              code: 'UPLOAD_ERROR',
              message: '分片 $partNumber 上传失败',
              type: FailureType.network,
            );
        abortReason ??= fallback;
        return Fail<int>(fallback);
      } finally {
        semaphore.release();
      }
    }

    final results = await Future.wait(<Future<Result<int>>>[
      for (var part = 1; part <= partCount; part++)
        if (!alreadyUploaded.contains(part)) runPart(part),
    ]);

    // 优先报"真实失败原因"：并发中止时其余片会拿到 REQUEST_CANCELLED，
    // 那是连带结果，不是根因。
    for (final result in results) {
      final failure = result.failure;
      if (failure != null && failure.code != 'REQUEST_CANCELLED') {
        return Fail<MultipartUploadResult>(failure);
      }
    }
    final abort = abortReason;
    if (abort != null) {
      return Fail<MultipartUploadResult>(abort);
    }
    for (final result in results) {
      final failure = result.failure;
      if (failure != null) {
        return Fail<MultipartUploadResult>(failure);
      }
    }

    if (!finalEmitted) {
      emitProgress(force: true);
    }
    return Success<MultipartUploadResult>(
      MultipartUploadResult(
        etags: etags,
        partCount: partCount,
        totalBytes: bytes.length,
      ),
    );
  }

  int _partLength(int partNumber, int partCount, int totalBytes) {
    if (partNumber < partCount) {
      return config.partSize;
    }
    return totalBytes - (partCount - 1) * config.partSize;
  }

  static Failure _cancelledFailure() => Failure.network(
        code: 'REQUEST_CANCELLED',
        message: '上传已取消',
      );

  static Failure _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return Failure.timeout(message: '分片上传超时', cause: error);
      case DioExceptionType.cancel:
        return _cancelledFailure();
      case DioExceptionType.badCertificate:
        return Failure(
          code: 'BAD_CERTIFICATE',
          message: '服务端证书校验失败',
          type: FailureType.network,
          cause: error,
        );
      case DioExceptionType.connectionError:
        return Failure.network(message: '网络连接失败', cause: error);
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return Failure.server(
          code: 'UPLOAD_HTTP_${status ?? 0}',
          message: '分片上传失败（HTTP $status）',
          statusCode: status,
          cause: error,
        );
      case DioExceptionType.unknown:
        return Failure.network(
          message: error.message ?? '分片上传失败',
          cause: error,
        );
    }
  }
}
