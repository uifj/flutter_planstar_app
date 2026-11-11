import 'package:core/result.dart';

import '../aggregates/ticket_order.dart';
import '../value_objects/ids.dart';
import '../value_objects/order_number.dart';

/// 订单仓储 —— **端口**。
///
/// 一个聚合根一个仓储：只加载/保存整张订单，不为订单行单独开仓储
/// （订单行没有独立生命周期）。实现放在 `data/`，领域层只认这个接口。
///
/// 刻意不让 UI 层直接使用 `ApiClient`：一旦没有仓储接口，
/// "下单成功之后要做什么"（清缓存、发事件、埋点）
/// 就全写在页面里。有了仓储端口，这些都可以收在适配器里。
abstract interface class TicketOrderRepository {
  /// 按 id 取订单。不存在返回 `Success(null)`，而不是失败——
  /// "查不到"是正常结果，"查不到"和"查询出错"必须能区分。
  Future<Result<TicketOrder?>> findById(TicketOrderId id);

  /// 列表查询（我的订单）。
  ///
  /// 刻意**不**把"按状态过滤"做成参数：列表的状态筛选码（0/1/2/3）
  /// 是**第三套编码**（既不是 `OrderStatus` 的 wireCode，也不是服务端订单状态那套），
  /// 把它塞进仓储端口会把服务端的历史包袱固化到领域层。
  /// 过滤发生在应用层（`order_list_controller`），仓储只负责"把订单取回来"。
  Future<Result<List<TicketOrder>>> findAll();

  /// 保存（新增或更新）。
  ///
  /// 约定：**保存成功后**由调用方（或实现）取走 `order.pullDomainEvents()` 并分发。
  /// 顺序不能反——先发事件再保存，事务回滚时事件已经出去了。
  Future<Result<void>> save(TicketOrder order);
}

/// 订单号序列 —— **端口**。
///
/// 订单号要"当天递增且不重复"，这个能力属于存储（数据库序列 / Redis INCR），
/// 不属于领域。抽成端口后，值对象 [OrderNumber] 保持纯函数、可测。
abstract interface class OrderNumberSequence {
  /// 取下一个订单号。
  Future<Result<OrderNumber>> next(DateTime date);
}
