import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/domain.dart';
import 'order_providers.dart';
/// 订单列表的状态筛选。
///
/// ## 为什么单独建一个枚举
///
/// 企划星的"我的订单"用的是**第三套编码**（`MyOrderFragment.addTabs`）：
///
/// | Tab | 传给服务端的 `status` |
/// |---|---|
/// | 全部 | 0 |
/// | 待付款 | 1 |
/// | 待发货 | 2 |
/// | 待收货 | 3 |
/// | 待评论 | （换 Fragment，不走订单接口） |
///
/// 这套 0–3 既不是 `OrderStatus.code`（1–7）也不是 `OrderUtils`（0/1/2/3/5/6/7），
/// 三套编码同时在代码库里，是这个项目最容易出错的地方之一
/// （`wiki_zh/27` §11.1）。
///
/// 这里的做法：**列表筛选是应用层的概念**，用独立枚举表达，
/// 并显式声明它和领域状态的关系（[matches]）。领域层不需要知道"待评论"
/// 这种纯展示口径。
enum OrderListFilter {
  all('全部'),
  awaitingPayment('待付款'),
  awaitingTickets('待发货'),
  ticketsInTransit('待收货'),
  awaitingReview('待评论');

  const OrderListFilter(this.label);

  final String label;

  /// 该筛选是否命中某个订单状态。
  ///
  /// ⚠ `待评论` 映射到 `completed`：领域模型里**没有**"已收货未评价"这个态
  /// （评价是另一个聚合）。原 App 的待评论页是独立 Fragment（`ReviewToDoListFragment`），
  /// 走的是评价接口而不是订单接口。这里退一步用"已完成"近似，
  /// 并在卡片上把按钮换成「去评价」——行为对得上，语义不假装。
  bool matches(OrderStatus status) => switch (this) {
        OrderListFilter.all => true,
        OrderListFilter.awaitingPayment => status == OrderStatus.awaitingPayment,
        OrderListFilter.awaitingTickets => status == OrderStatus.awaitingTickets,
        OrderListFilter.ticketsInTransit => status == OrderStatus.ticketsInTransit,
        OrderListFilter.awaitingReview => status == OrderStatus.completed,
      };
}

/// 当前选中的筛选。
final orderListFilterProvider = StateProvider<OrderListFilter>(
  (ref) => OrderListFilter.all,
);

/// 全部订单（按提交时间倒序，排序在仓储里做）。
final orderListProvider = FutureProvider<List<TicketOrder>>((ref) async {
  final repository = ref.watch(ticketOrderRepositoryProvider);
  final result = await repository.findAll();
  return result.requireData;
});

/// 按当前筛选过滤后的订单。
final filteredOrderListProvider = Provider<AsyncValue<List<TicketOrder>>>((ref) {
  final filter = ref.watch(orderListFilterProvider);
  return ref.watch(orderListProvider).whenData(
        (orders) => orders.where((order) => filter.matches(order.status)).toList(growable: false),
      );
});

/// 每个 tab 的订单数（角标用）。
///
/// 只算 `awaitingPayment` / `awaitingTickets` / `ticketsInTransit` / `awaitingReview`
/// 四个"需要用户处理"的态——「全部」不给数字，企划星也没给。
final orderStatusCountsProvider = Provider<Map<OrderListFilter, int>>((ref) {
  final orders = ref.watch(orderListProvider).valueOrNull ?? const <TicketOrder>[];
  return <OrderListFilter, int>{
    for (final filter in OrderListFilter.values)
      filter: filter == OrderListFilter.all
          ? 0
          : orders.where((order) => filter.matches(order.status)).length,
  };
});

/// 按订单号取订单（订单详情页用）。
///
/// 查不到返回 `null` 而不是抛异常：深链带了不存在的订单号是正常情况
/// （订单被删、链接过期），页面渲染空态比抛错更合适。
///
/// 复用 [orderListProvider] 而不是新增仓储方法：详情页与列表页必须看到
/// **同一份**订单状态——如果详情单独 `findByNumber`，用户从详情返回列表时
/// 就可能看到两个不同的状态。
final orderByNumberProvider =
    Provider.family<AsyncValue<TicketOrder?>, String>((ref, String number) {
  return ref.watch(orderListProvider).whenData((List<TicketOrder> orders) {
    for (final TicketOrder order in orders) {
      if (order.number.value == number) return order;
    }
    return null;
  });
});

/// 订单列表上的动作（支付 / 取消 / 确认收货）。
///
/// ## 为什么不是 Controller 的 `state`
///
/// 这些动作**不产生页面状态**，只产生"成功/失败"和一次列表刷新。
/// 做成返回 `String?`（`null` = 成功）的方法，页面拿到错误就弹 toast，
/// 拿到 `null` 就 `invalidate` 列表——没有中间态要维护。
///
/// 每个动作都走聚合的领域方法（`markPaid` / `cancel` / `complete`），
/// 所以状态迁移的合法性由领域层把关；页面不做任何 `if (status == 2)`。
final orderActionsProvider = Provider<OrderActions>(OrderActions.new);

/// 订单动作集合。
final class OrderActions {
  const OrderActions(this.ref);

  final Ref ref;

  /// 支付。成功后订单进入「待发货」。
  Future<String?> pay(TicketOrder order, PaymentChannel channel) async {
    final result = order.markPaid(now: DateTime.now(), channel: channel);
    if (result.isFailure) return result.failure!.message;
    return _persist(order);
  }

  /// 取消订单。
  Future<String?> cancel(TicketOrder order, String reason) async {
    final result = order.cancel(reason: reason, now: DateTime.now());
    if (result.isFailure) return result.failure!.message;
    return _persist(order);
  }

  /// 确认收货（→ 已完成）。
  Future<String?> confirmReceipt(TicketOrder order) async {
    final result = order.complete(DateTime.now());
    if (result.isFailure) return result.failure!.message;
    return _persist(order);
  }

  /// 保存 + 刷新列表。
  Future<String?> _persist(TicketOrder order) async {
    final repository = ref.read(ticketOrderRepositoryProvider);
    final saved = await repository.save(order);
    if (saved.isFailure) return saved.failure!.message;
    ref.invalidate(orderListProvider);
    return null;
  }
}
