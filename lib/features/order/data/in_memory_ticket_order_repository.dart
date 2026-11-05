import 'package:core_result/core_result.dart';

import '../domain/domain.dart';

/// 内存仓储 —— **适配器**，实现领域层的 [TicketOrderRepository] 端口。
///
/// 真实实现会走 `core_network` 的 `ApiClient`（`GET v1/unifiedOrder/confirm`、
/// `POST v3/unifiedOrder/makeOrder`、`GET v1/unifiedPay/payDetail`），
/// 并在其中做 DTO ↔ 领域对象的转换（防腐层）。这里先用内存实现，
/// 让整条链路（聚合 → 报价 → 事件）能跑通、能测。
///
/// ⚠ 事务性说明：真实实现必须保证"保存成功才分发事件"。当前内存实现不会失败，
/// 所以 `save` 之后分发事件是安全的；换成网络实现时，应把"保存 + 取事件 + 分发"
/// 收进一个工作单元（Unit of Work），失败则整单回滚。
final class InMemoryTicketOrderRepository implements TicketOrderRepository {
  final Map<String, TicketOrder> _store = <String, TicketOrder>{};

  /// 已保存的订单数（测试/调试用）。
  int get count => _store.length;

  /// 批量灌入（演示数据 / 测试夹具）。
  ///
  /// 同步方法：种子数据在 `Provider` 构造时同步塞进来，
  /// 走 [save] 会返回一个没人等的 `Future`。
  void seed(Iterable<TicketOrder> orders) {
    for (final order in orders) {
      _store[order.id.value] = order;
    }
  }

  @override
  Future<Result<TicketOrder?>> findById(TicketOrderId id) async =>
      Success<TicketOrder?>(_store[id.value]);

  @override
  Future<Result<List<TicketOrder>>> findAll() async {
    // 按提交时间倒序——"我的订单"永远是最近下的在最上面。
    final orders = _store.values.toList(growable: false)
      ..sort((a, b) {
        final left = a.submittedAt ?? a.placedAt;
        final right = b.submittedAt ?? b.placedAt;
        return right.compareTo(left);
      });
    return Success<List<TicketOrder>>(orders);
  }

  @override
  Future<Result<void>> save(TicketOrder order) async {
    _store[order.id.value] = order;
    return const Success<void>(null);
  }
}
