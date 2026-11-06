/// 上传：分片引擎（`PartUrlProvider` 端口 + 并发编排 + 进度节流 + 断点续传）
/// 与 OSS 表单直传（小文件一把梭）。
///
/// 两者都只接受 `Uint8List`，不碰 `dart:io` 的 `File`——保持可在 Web 与纯 Dart
/// 测试环境运行。读文件是宿主的职责。取消与失败都走 `Result`，**不抛**。
library;

export 'src/upload/async_semaphore.dart';
export 'src/upload/form_post_uploader.dart';
export 'src/upload/multipart_models.dart';
export 'src/upload/upload_engine.dart';
