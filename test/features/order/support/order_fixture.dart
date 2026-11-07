import 'package:core/domain.dart';
import 'package:planstar/features/order/domain/domain.dart';

/// 构造一张已提交、待支付的订单，供持久化/缓存测试复用。
TicketOrder buildSubmittedOrder({
  String orderId = '1001',
  String orderNumber = 'PN20261107000001',
  String showId = '9001',
  String sessionId = '8001',
  String tierId = '7001',
  String tierName = '内场 A 区',
  int unitPriceCents = 68000,
  int quantity = 2,
  DateTime? now,
}) {
  final DateTime submittedAt = now ?? DateTime(2026, 11, 7, 10);
  final Money unitPrice = Money.fromMinorUnits(unitPriceCents);
  final Money goodsTotal = unitPrice * quantity;

  final TicketOrder order = TicketOrder.create(
    id: TicketOrderId(orderId),
    number: OrderNumber(orderNumber),
    showId: ShowId(showId),
    sessionId: SessionId(sessionId),
    now: submittedAt,
  ).requireData;

  order.addLine(
    OrderLine(
      id: TicketTierId(tierId),
      tierName: tierName,
      unitPrice: unitPrice,
      quantity: Quantity(quantity),
    ),
  );
  order.acceptAgreement();
  order.attachQuote(
    OrderQuote(
      goodsTotal: goodsTotal,
      postage: Money.zero(),
      splitFee: Money.zero(),
      discountApplied: Money.zero(),
      totalAmount: goodsTotal,
      giftCardApplied: Money.zero(),
      speedPackCash: Money.zero(),
      speedPackBalance: Money.zero(),
      paymentAmount: goodsTotal,
    ),
  );
  order.submit(submittedAt);
  return order;
}
