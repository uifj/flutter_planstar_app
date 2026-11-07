import 'package:core/result.dart';

import '../domain/domain.dart';
import 'planstar_order_api.dart';

/// 远端订单仓储：`v1/order/list` / `v1/order/detail` / `v3/unifiedOrder/makeOrder`。
final class RemoteTicketOrderRepository implements TicketOrderRepository {
  RemoteTicketOrderRepository({required PlanstarOrderApi api}) : _api = api;

  final PlanstarOrderApi _api;

  @override
  Future<Result<List<TicketOrder>>> findAll() {
    return _api.fetchOrderList(pageIndex: 1, pageSize: 100);
  }

  @override
  Future<Result<TicketOrder?>> findById(TicketOrderId id) async {
    final Result<List<TicketOrder>> list = await findAll();
    if (list.isFailure) return Fail<TicketOrder?>(list.failure!);

    for (final TicketOrder order in list.requireData) {
      if (order.id.value == id.value || order.number.value == id.value) {
        return Success<TicketOrder?>(order);
      }
    }

    // 列表可能被分页截断；订单号形态再补一次详情查询。
    if (id.value.startsWith('PN')) {
      return _api.fetchOrderDetail(id.value);
    }
    return const Success<TicketOrder?>(null);
  }

  @override
  Future<Result<void>> save(TicketOrder order) async {
    final firstLine = order.lines.isEmpty ? null : order.lines.first;
    final OrderQuote? quote = order.quote;
    final Result<Map<String, dynamic>> result = await _api.makeOrder(
      <String, dynamic>{
        'activityId': order.showId.value,
        'activityEventId': order.sessionId.value,
        'orderType': order.orderType.wireCode,
        'quantity': order.totalTickets.value,
        'amount': quote?.paymentAmount.minorUnits ??
            order.goodsTotal.minorUnits,
        if (firstLine != null) 'ticketCategoryId': firstLine.id.value,
      },
      idempotencyKey: PlanstarOrderApi.newIdempotencyKey(),
    );
    if (result.isFailure) return Fail<void>(result.failure!);

    final TicketOrder? parsed = PlanstarOrderApi.parseOrderJson(
      result.requireData,
    );
    if (parsed == null) {
      return const Fail<void>(
        Failure(
          code: 'ORDER_PARSE_ERROR',
          message: '下单响应解析失败',
          type: FailureType.data,
        ),
      );
    }
    return const Success<void>(null);
  }
}
