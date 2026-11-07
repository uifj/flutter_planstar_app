import 'package:core/domain.dart';

import '../domain/domain.dart';

/// 演示订单历史。
///
/// ## 为什么要有这个
///
/// 订单列表 / 用户中心的"待付款 2 / 待发货 1"角标，都需要**已经有订单**。
/// 如果只靠确认页下单才有数据，第一次进"我的订单"就是空态——那等于列表页
/// 没做完。
///
/// ## 为什么用聚合"走一遍流程"而不是直接 new 一个带状态的订单
///
/// 因为状态的合法性由聚合保证：`create → addLine → attachQuote → submit →
/// markPaid → markShipped → complete` 每一步都可能失败，走一遍流程得到的
/// 订单，其金额与状态一定是自洽的。直接造一个 `status = 待收货` 的对象
/// 会绕过全部校验，也就等于把演示数据写成了"另一套规则"。
///
/// 六张订单覆盖 `OrderStatus` 的全部业务态：
/// 待付款 / 待发货 / 待收货 / 已完成 / 已关闭 / 已退款。
///
/// ## 为什么是同步的
///
/// 仓储是 `Provider` 里同步构造的，种子必须在构造时就能塞进去。
/// 订单号因此直接用 `OrderNumber.generate` 生成，而不是走
/// `OrderNumberSequence` 端口——那个端口的存在意义是"运行期跨进程唯一"，
/// 一次性造 6 张演示单不需要它。
List<TicketOrder> buildDemoOrderHistory({
  required OrderPricingService pricing,
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final orders = <TicketOrder>[];
  var sequence = 0;

  /// 建一张订单并推进到目标状态。
  void place({
    required String id,
    required String showId,
    required String tierId,
    required String tierName,
    required int unitPrice,
    required int quantity,
    required Duration ago,
    int requiredVisitorCount = 0,
    Visitor? visitor,
    DiscountSelection discount = DiscountSelection.none,
    GiftCardTender? giftCard,
    SpeedPack? speedPack,
    required _Stage stage,
    OrderCancelReason? cancelReason,
  }) {
    final placedAt = reference.subtract(ago);
    sequence++;

    final order = TicketOrder.create(
      id: TicketOrderId(id),
      number: OrderNumber.generate(date: placedAt, sequence: sequence),
      showId: ShowId(showId),
      sessionId: SessionId('$showId-s1'),
      now: placedAt,
      requiredVisitorCount: requiredVisitorCount,
    ).requireData;

    order.addLine(
      OrderLine(
        id: TicketTierId(tierId),
        tierName: tierName,
        unitPrice: Money.fromYuan(unitPrice),
        quantity: Quantity(quantity),
      ),
    );

    if (visitor != null) {
      order.assignVisitors(<Visitor>[visitor]);
    }

    order.selectDiscount(discount);
    order.applyGiftCard(giftCard);
    order.selectSpeedPack(speedPack);
    order.acceptAgreement();

    final quote = pricing.quote(
      goodsTotal: order.goodsTotal,
      postage: Money.zero(),
      splitFee: Money.zero(),
      discount: discount,
      giftCard: giftCard,
      speedPack: speedPack,
    );
    order.attachQuote(quote);

    // 待付款之后的态都要先提交。
    order.submit(placedAt);

    // 支付：除"待付款"和"已关闭"之外的态都付过款。
    if (stage != _Stage.awaitingPayment && stage != _Stage.cancelled) {
      order.markPaid(
        now: placedAt.add(const Duration(minutes: 3)),
        channel: stage == _Stage.refunded
            ? PaymentChannel.unionPay
            : PaymentChannel.wechat,
      );
    }
    if (stage == _Stage.ticketsInTransit || stage == _Stage.completed) {
      order.markShipped(
        now: placedAt.add(const Duration(days: 1)),
        trackingNumber: 'SF1234567890',
      );
    }
    if (stage == _Stage.completed) {
      order.complete(placedAt.add(const Duration(days: 3)));
    }
    if (stage == _Stage.cancelled) {
      order.cancel(
        reason: cancelReason ?? OrderCancelReason.userCancelled,
        now: placedAt.add(const Duration(minutes: 12)),
      );
    }
    if (stage == _Stage.refunded) {
      order.refund(
        amount: order.quote!.paymentAmount,
        reason: '企划延期，全额退款',
        now: placedAt.add(const Duration(days: 2)),
      );
    }

    // 演示数据不需要重放事件；不清空的话聚合实例会一直持有它们。
    order.pullDomainEvents();
    orders.add(order);
  }

  final visitor = Visitor(
    id: const VisitorId('v-1'),
    name: '张小票',
    idCard: IdCardNumber(type: IdCardType.idCard, number: '310101199001011234'),
  );

  // 1) 待付款：10 分钟前提交，支付窗口 15 分钟 —— 列表里能看到倒计时。
  place(
    id: 'o-1',
    showId: '2001',
    tierId: 'tier-1',
    tierName: '内场 A 区',
    unitPrice: 680,
    quantity: 2,
    ago: const Duration(minutes: 10),
    requiredVisitorCount: 1,
    visitor: visitor,
    discount: CouponSelection(
      const CouponId('CP-2026-50'),
      AmountDiscount(Money.fromYuan(50)),
    ),
    stage: _Stage.awaitingPayment,
  );

  // 2) 待发货：已支付，活动折扣 + 礼品卡都用上（实付 ≠ 原价）。
  place(
    id: 'o-2',
    showId: '1001',
    tierId: 'tier-2',
    tierName: '内场 B 区',
    unitPrice: 1880,
    quantity: 2,
    ago: const Duration(days: 1, hours: 3),
    discount: CampaignSelection(
      const CampaignId('CM-9ZHE'),
      RateDiscount(900, cap: Money.fromYuan(300)),
    ),
    giftCard: GiftCardTender(
      id: const GiftCardId('GC-8888'),
      balance: Money.fromYuan(200),
    ),
    stage: _Stage.awaitingTickets,
  );

  // 3) 待收货：已寄出（纸质票快递）。
  place(
    id: 'o-3',
    showId: '1002',
    tierId: 'tier-3',
    tierName: '看台 1 层',
    unitPrice: 480,
    quantity: 2,
    ago: const Duration(days: 4),
    stage: _Stage.ticketsInTransit,
  );

  // 4) 已完成。
  place(
    id: 'o-4',
    showId: '5001',
    tierId: 'tier-1',
    tierName: '平日票',
    unitPrice: 249,
    quantity: 2,
    ago: const Duration(days: 12),
    stage: _Stage.completed,
  );

  // 5) 已关闭：未支付超时。
  place(
    id: 'o-5',
    showId: '7001',
    tierId: 'tier-2',
    tierName: '中区',
    unitPrice: 580,
    quantity: 1,
    ago: const Duration(days: 6),
    stage: _Stage.cancelled,
    cancelReason: OrderCancelReason.timeout,
  );

  // 6) 已退款。
  place(
    id: 'o-6',
    showId: '1003',
    tierId: 'tier-3',
    tierName: '看台 1 层',
    unitPrice: 880,
    quantity: 1,
    ago: const Duration(days: 9),
    stage: _Stage.refunded,
  );

  return orders;
}

/// 订单要推进到的终态。
enum _Stage {
  awaitingPayment,
  awaitingTickets,
  ticketsInTransit,
  completed,
  cancelled,
  refunded,
}
