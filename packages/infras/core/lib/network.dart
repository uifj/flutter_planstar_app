/// 网络层：响应信封 + API 客户端 + Dio 工厂 + 重试拦截器。
///
/// 只有一套失败契约：全部走 `Result`。**不**提供抛异常的并行入口。
/// [buildDio] **不设置** `badCertificateCallback`——不存在"无 host 映射时信任
/// 一切证书"的隐式回退。
library;

export 'src/network/api_client.dart';
export 'src/network/dio_factory.dart';
export 'src/network/failure_carrying_error.dart';
export 'src/network/response_envelope.dart';
export 'src/network/retry_interceptor.dart';
