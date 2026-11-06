/// OSS PostObject 表单直传（凭证由调用方注入）。
///
/// 移植自 `stone_core`，与 [MultipartUploadEngine] 互补：
/// 小文件一把梭走表单 POST，大文件走分片 PUT。
///
/// 相比来源的改动：
/// - **只接受字节**，不碰 `dart:io` 的 `File`——本包保持可在 Web / 纯 Dart
///   测试环境编译；读文件是宿主的事；
/// - 去掉「每次上传新建并 close Dio」的旧模式，Dio 必须由调用方注入复用；
/// - 失败统一返回 [Result]，**永不抛**。
library;

import 'dart:typed_data';

import 'package:core/logger.dart';
import 'package:core/result.dart';
import 'package:dio/dio.dart';

/// 一次 OSS PostObject 表单直传请求。
///
/// 字段契约逐字保留来源实现：
/// `key / policy / OSSAccessKeyId / success_action_status=200 / signature / file`。
final class OssFormUploadRequest {
  /// 创建请求。
  ///
  /// [endpoint] 是不含 scheme 的 OSS host（与来源 `'https://$url'` 拼接一致）。
  /// [objectKey] 同时用作表单 `key` 与 multipart 文件名。
  const OssFormUploadRequest({
    required this.endpoint,
    required this.objectKey,
    required this.policy,
    required this.accessKeyId,
    required this.signature,
    required this.bytes,
  });

  /// OSS endpoint host（不含 `https://`）。
  final String endpoint;

  /// 对象键。
  final String objectKey;

  /// PostObject 预签名 policy。
  final String policy;

  /// 预签名 AccessKeyId。
  final String accessKeyId;

  /// 预签名 signature。
  final String signature;

  /// 文件内容。
  final Uint8List bytes;
}

/// OSS 表单直传器。
final class FormPostUploader {
  /// 注入 Dio（超时 / 代理 / 证书策略由调用方统一配置）。
  ///
  /// 不提供默认 Dio：来源隐式自建实例，上传结束后 `close`，既浪费连接池，
  /// 也绕过了宿主的网络策略。这里要求显式注入。
  FormPostUploader({required Dio dio, this.logger}) : _dio = dio;

  final Dio _dio;

  /// 可选日志器。
  final AppLogger? logger;

  bool _disposed = false;

  /// 上传单个文件；成功条件为 HTTP 200（对齐来源）。
  Future<Result<void>> upload(
    OssFormUploadRequest request, {
    CancelToken? cancelToken,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (_disposed) {
      return Fail<void>(
        Failure.input(message: 'FormPostUploader 已释放，不能继续上传'),
      );
    }

    final file = MultipartFile.fromBytes(
      request.bytes,
      filename: request.objectKey,
    );
    final form = FormData.fromMap(<String, dynamic>{
      'key': request.objectKey,
      'policy': request.policy,
      'OSSAccessKeyId': request.accessKeyId,
      'success_action_status': '200',
      'signature': request.signature,
      'file': file,
    });

    try {
      final response = await _dio.post<dynamic>(
        'https://${request.endpoint}',
        data: form,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
      );
      if (response.statusCode == 200) {
        return const Success<void>(null);
      }
      return Fail<void>(
        Failure(
          code: 'HTTP_ERROR',
          message: '表单直传失败（HTTP ${response.statusCode}）',
          type: FailureType.server,
          statusCode: response.statusCode,
        ),
      );
    } on DioException catch (error) {
      logger?.error(
        '表单直传失败：${request.objectKey}',
        error: error,
        stackTrace: error.stackTrace,
      );
      return Fail<void>(_toFailure(error));
    } catch (error) {
      return Fail<void>(
        Failure(
          code: 'UPLOAD_ERROR',
          message: '表单直传失败：$error',
          type: FailureType.network,
          cause: error,
        ),
      );
    }
  }

  /// 释放状态（幂等）。释放后 [upload] 返回 input 类失败。
  ///
  /// **不**关闭注入的 Dio——它的生命周期归调用方。
  void dispose() {
    _disposed = true;
  }

  static Failure _toFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return Failure.timeout(message: '表单直传超时', cause: e);
      case DioExceptionType.cancel:
        return Failure.network(
          code: 'REQUEST_CANCELLED',
          message: '表单直传已取消',
          cause: e,
        );
      case DioExceptionType.badResponse:
        return Failure.server(
          code: 'HTTP_ERROR',
          message: '表单直传失败（HTTP ${e.response?.statusCode}）',
          statusCode: e.response?.statusCode,
          cause: e,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return Failure.network(
          message: e.message ?? '表单直传失败',
          cause: e,
        );
    }
  }
}
