/// 分片上传引擎：`PartUrlProvider` 端口 + 并发编排 + 进度节流 + 断点续传。
///
/// 设计来源：`stone_core` 的 `network/multipart/`（`multipart_upload_models.dart`
/// 132 行 + `multipart_uploader.dart` 526 行）
/// （见 `wiki_zh/30-flutter-adoptable-designs.md` §2.4）。
///
/// 相对来源的**刻意改动**：
/// 1. `_Semaphore` → 公开的 [AsyncSemaphore]。来源带 `_` 前缀无法 import，
///    只能复制 34 行；这里直接导出，供上传以外的并发场景复用。
/// 2. 引擎只接受 `Uint8List`，不碰 `dart:io` 的 `File`——保持本包可在 Web
///    与纯 Dart 测试环境运行。读文件是调用方的事。
/// 3. 取消与失败都走 [Result]，**不抛**。来源的取消路径会抛异常。
/// 4. 默认重试判定里显式让 **403 可重试**（预签名过期），这是
///    [PartUrlProvider] 存在的意义所在。
library;

export 'src/async_semaphore.dart';
export 'src/multipart_models.dart';
export 'src/upload_engine.dart';
