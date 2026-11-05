/// 网络层：响应信封 + API 客户端 + Dio 工厂。
///
/// 设计来源：`stone_core` 的 `response_envelope.dart` / `api_client.dart` /
/// `http_manager.dart`（见 `wiki_zh/30-flutter-adoptable-designs.md` §2.2）。
///
/// 相对来源的**刻意改动**：
/// 1. 信封"缺 code 字段"不再默认当成功——改由 [MissingEnvelopePolicy] 显式选择
///    （来源的保守回退会让后端改字段名时静默成功，30-08）。
/// 2. 只有一套失败契约：全部走 `Result`。**不**提供抛 `RequestError` 的并行入口
///    （来源同时有 `HttpManager.request` 抛异常与 `ApiClient` 返 Result，30-02）。
/// 3. [buildDio] **不设置** `badCertificateCallback`——来源在无 host 映射时返回
///    `true`（信任一切证书），见 30-05 与 §5 第 5 条。
/// 4. `extractData` 用 `Object?` 而非 `dynamic`，配合 `strict-casts` 把类型错误
///    挡在编译期。
library;

export 'src/api_client.dart';
export 'src/dio_factory.dart';
export 'src/failure_carrying_error.dart';
export 'src/response_envelope.dart';
