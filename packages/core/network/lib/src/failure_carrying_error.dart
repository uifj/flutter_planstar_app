/// 让拦截器能把「领域失败」原样穿过 Dio 交回 [ApiClient]。
library;

import 'package:core_result/core_result.dart';

/// 由拦截器实现，用于在 `DioException.error` 中携带一个**已经成型的** [Failure]。
///
/// 为什么需要它：Dio 的拦截器只能通过 `handler.reject(DioException(...))` 中断
/// 请求，而 `DioException` 的语义是"网络/传输出了事"。但拦截器想表达的东西常常
/// 不是网络问题——缓存未命中、熔断打开、离线模式禁止请求、本地限流……
///
/// 没有这个接口时只有两条烂路：
/// 1. 把领域失败伪装成 `DioExceptionType.unknown`，上层只能拿到
///    `code: 'UNKNOWN'`，丢失语义；
/// 2. 让 `core_network` 反过来 import 具体拦截器所在的包——依赖方向就倒了。
///
/// 有了它，`ApiClient` 在归一化异常时**第一件事**就是问一句"你是不是带了
/// 现成的 Failure"，是就直接用。于是拦截器包只依赖 `core_network` 的这一个
/// 接口，`core_network` 完全不知道缓存/熔断/离线的存在。
///
/// 实现方约定：[failure] 必须是终态，`ApiClient` 不会改写它的 code/type。
abstract interface class FailureCarryingError implements Exception {
  /// 已经成型的失败描述。
  Failure get failure;
}
