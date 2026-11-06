import 'package:core/domain.dart';
import 'package:core/result.dart';
import 'package:planstar/features/order/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// 测试夹具：一张草稿订单 + 一个报价服务。
final class _Fixture {
  _Fixture({int requiredVisitorCount = 0, PurchaseLimit? limit})
      : _now = DateTime(2026, 11, 1, 10) {
    order = TicketOrder.create(
      id: const TicketOrderId('order-1'),
      number: OrderNumber('PN20261101000123'),
      showId: const ShowId('10086'),
      sessionId: const SessionId('S-1'),
      now: _now,
      requiredVisitorCount: requiredVisitorCount,
      purchaseLimit: limit ?? const PurchaseLimit.unlimited(),
    ).requireData;
  }

  final DateTime _now;
  late final TicketOrder order;
  final OrderPricingService pricing = const OrderPricingService();

  static OrderLine line({
    String tierId = 'tier-1',
    String name = '内场 A 区',
    num price = 680,
    int quantity = 1,
  }) =>
      OrderLine(
        id: TicketTierId(tierId),
        tierName: name,
        unitPrice: Money.fromYuan(price),
        quantity: Quantity(quantity),
      );

  /// 算报价并挂到聚合上（模拟控制器的动作）。
  OrderQuote requote({DiscountSelection discount = DiscountSelection.none}) {
    final quote = pricing.quote(
      goodsTotal: order.goodsTotal,
      postage: order.delivery.postage,
      splitFee: Money.zero(),
      discount: discount,
      giftCard: order.giftCard,
      speedPack: order.speedPack,
    );
    order.attachQuote(quote);
    return quote;
  }

  DateTime get now => _now;
}

void main() {
  group('OrderPricingService：金额公式（对齐 updatePrice）', () {
    const pricing = OrderPricingService();

    test('原价 = 商品总额 + 运费 + 拆单费', () {
      final quote = pricing.quote(
        goodsTotal: Money.fromYuan(1360),
        postage: Money.fromYuan(12),
        splitFee: Money.fromYuan(3),
      );

      expect(quote.totalAmount, Money.fromYuan(1375));
      expect(quote.paymentAmount, Money.fromYuan(1375));
      expect(quote.discountApplied, Money.zero());
    });

    test('优惠券：减固定金额', () {
      final quote = pricing.quote(
        goodsTotal: Money.fromYuan(1360),
        postage: Money.fromYuan(12),
        splitFee: Money.zero(),
        discount: DiscountSelection.coupon(
          const CouponId('CP-1'),
          AmountDiscount(Money.fromYuan(50)),
        ),
      );

      expect(quote.discountApplied, Money.fromYuan(50));
      expect(quote.paymentAmount, Money.fromYuan(1322));
    });

    test('营销活动：按比例减并封顶', () {
      // 1372 的 10% = 137.20，封顶 100
      final capped = pricing.quote(
        goodsTotal: Money.fromYuan(1360),
        postage: Money.fromYuan(12),
        splitFee: Money.zero(),
        discount: DiscountSelection.campaign(
          const CampaignId('CM-1'),
          RateDiscount(1000, cap: Money.fromYuan(100)),
        ),
      );
      expect(capped.discountApplied, Money.fromYuan(100));
      expect(capped.paymentAmount, Money.fromYuan(1272));

      // 不封顶时按比例：1372 的 10% = 137.20
      final uncapped = pricing.quote(
        goodsTotal: Money.fromYuan(1360),
        postage: Money.fromYuan(12),
        splitFee: Money.zero(),
        discount: DiscountSelection.campaign(
          const CampaignId('CM-2'),
          RateDiscount(1000),
        ),
      );
      expect(uncapped.discountApplied, Money.fromYuan(137.20));
      expect(uncapped.paymentAmount, Money.fromYuan(1234.80));
    });

    test('优惠大于总额时钳到 0（原实现靠事后 if 兜底）', () {
      final quote = pricing.quote(
        goodsTotal: Money.fromYuan(30),
        postage: Money.zero(),
        splitFee: Money.zero(),
        discount: DiscountSelection.coupon(
          const CouponId('CP-BIG'),
          AmountDiscount(Money.fromYuan(50)),
        ),
      );

      expect(quote.discountApplied, Money.fromYuan(30));
      expect(quote.paymentAmount, Money.zero());
      expect(quote.requiresPayment, isFalse);
    });

    test('礼品卡抵扣 = min(余额, 应付)', () {
      final quote = pricing.quote(
        goodsTotal: Money.fromYuan(100),
        postage: Money.zero(),
        splitFee: Money.zero(),
        giftCard: GiftCardTender(
          id: const GiftCardId('GC-1'),
          balance: Money.fromYuan(80),
        ),
      );
      expect(quote.giftCardApplied, Money.fromYuan(80));
      expect(quote.paymentAmount, Money.fromYuan(20));

      final richer = pricing.quote(
        goodsTotal: Money.fromYuan(100),
        postage: Money.zero(),
        splitFee: Money.zero(),
        giftCard: GiftCardTender(
          id: const GiftCardId('GC-2'),
          balance: Money.fromYuan(500),
        ),
      );
      expect(richer.giftCardApplied, Money.fromYuan(100));
      expect(richer.paymentAmount, Money.zero());
    });

    test('加速包：余额先扣，现金部分加回应付（且不参与礼品卡抵扣）', () {
      final quote = pricing.quote(
        goodsTotal: Money.fromYuan(100),
        postage: Money.zero(),
        splitFee: Money.zero(),
        giftCard: GiftCardTender(
          id: const GiftCardId('GC-1'),
          balance: Money.fromYuan(100),
        ),
        speedPack: SpeedPack.forTickets(
          tickets: 2,
          unitPrice: Money.fromYuan(30),
          balanceAvailable: Money.fromYuan(30),
        ),
      );

      // 总加速包 60 = 余额 30 + 现金 30；礼品卡先把 100 抵光，现金 30 再加回来
      expect(quote.speedPackBalance, Money.fromYuan(30));
      expect(quote.speedPackCash, Money.fromYuan(30));
      expect(quote.giftCardApplied, Money.fromYuan(100));
      expect(quote.paymentAmount, Money.fromYuan(30));
    });

    test('拆解项与实付自洽（构造时自校验）', () {
      final quote = pricing.quote(
        goodsTotal: Money.fromYuan(680),
        postage: Money.fromYuan(12),
        splitFee: Money.zero(),
        discount: DiscountSelection.coupon(
          const CouponId('CP-1'),
          AmountDiscount(Money.fromYuan(50)),
        ),
      );
      expect(
        quote.paymentAmount,
        quote.totalAmount - quote.discountApplied - quote.giftCardApplied + quote.speedPackCash,
      );
    });
  });

  group('OrderStatus：单一入站映射 + 显式迁移', () {
    test('服务端 1 和 2 都映射到待支付（原 App 两套编码差 1 的解法）', () {
      expect(OrderStatus.fromWire(1).requireData, OrderStatus.awaitingPayment);
      expect(OrderStatus.fromWire(2).requireData, OrderStatus.awaitingPayment);
    });

    test('3–7 逐一对应', () {
      expect(OrderStatus.fromWire(3).requireData, OrderStatus.awaitingTickets);
      expect(OrderStatus.fromWire(4).requireData, OrderStatus.ticketsInTransit);
      expect(OrderStatus.fromWire(5).requireData, OrderStatus.completed);
      expect(OrderStatus.fromWire(6).requireData, OrderStatus.cancelled);
      expect(OrderStatus.fromWire(7).requireData, OrderStatus.refunded);
    });

    test('未知编码返回失败，而不是静默兜底', () {
      final result = OrderStatus.fromWire(99);
      expect(result.isFailure, isTrue);
      expect(result.failure!.code, 'ORDER_STATUS_UNKNOWN');
    });

    test('终态不可迁移', () {
      expect(OrderStatus.cancelled.canTransitionTo(OrderStatus.awaitingPayment), isFalse);
      expect(OrderStatus.refunded.canTransitionTo(OrderStatus.completed), isFalse);
      expect(OrderStatus.draft.canTransitionTo(OrderStatus.awaitingPayment), isTrue);
    });
  });

  group('值对象', () {
    test('订单号格式校验', () {
      expect(OrderNumber('PN20261101000123').datePart, '20261101');
      expect(() => OrderNumber('20261101000123'), throwsArgumentError);
      expect(
        OrderNumber.generate(date: DateTime(2026, 11, 1), sequence: 7).value,
        'PN20261101000007',
      );
    });

    test('身份证校验位（企划星侧只判空，M5-07）', () {
      final valid = IdCardNumber(type: IdCardType.idCard, number: '310101199003074511');
      expect(valid.masked, '310***********4511');

      expect(
        () => IdCardNumber(type: IdCardType.idCard, number: '310101199003074510'),
        throwsArgumentError,
      );
      expect(
        () => IdCardNumber(type: IdCardType.idCard, number: '31010119900307451'),
        throwsArgumentError,
      );
    });

    test('手机号与地址', () {
      expect(PhoneNumber('138-0013-8000').masked, '138****8000');
      expect(() => PhoneNumber('12345'), throwsArgumentError);
      expect(
        () => DeliveryInfo(
          method: DeliveryMethod.express,
          postage: Money.fromYuan(12),
        ),
        throwsArgumentError,
        reason: '快递必须有收件人',
      );
    });
  });

  group('TicketOrder 聚合：不变量', () {
    test('同票档合并数量，不同单价拒绝', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line(quantity: 1));
      f.order.addLine(_Fixture.line(quantity: 2));
      expect(f.order.lines, hasLength(1));
      expect(f.order.lines.single.quantity, Quantity(3));
      expect(f.order.goodsTotal, Money.fromYuan(2040));

      final conflict = f.order.addLine(_Fixture.line(price: 580, quantity: 1));
      expect(conflict.isFailure, isTrue);
      expect(conflict.failure!.code, 'ORDER_LINE_PRICE_CONFLICT');
    });

    test('单笔限购 6 张', () {
      final f = _Fixture(
        limit: PurchaseLimit(maxPerOrder: Quantity(6)),
      );
      final result = f.order.addLine(_Fixture.line(quantity: 7));
      expect(result.isFailure, isTrue);
      expect(result.failure!.code, 'ORDER_LIMIT_PER_ORDER');
      expect(result.failure!.message, contains('6'));
    });

    test('数量改成 0 等于移除，且旧报价作废', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line(quantity: 2));
      f.requote();
      expect(f.order.quote, isNotNull);

      f.order.changeLineQuantity(const TicketTierId('tier-1'), Quantity.zero);
      expect(f.order.lines, isEmpty);
      expect(f.order.quote, isNull, reason: '内容变了，报价必须失效');
    });

    test('没有勾协议不能提交（企划星默认勾选的反面）', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line());
      f.requote();

      final result = f.order.submit(f.now);
      expect(result.isFailure, isTrue);
      expect(result.failure!.code, 'ORDER_AGREEMENT_REQUIRED');
      expect(result.failure!.message, contains('《票务服务协议》'));
    });

    test('没有报价不能提交', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line());
      f.order.acceptAgreement();

      final result = f.order.submit(f.now);
      expect(result.failure!.code, 'ORDER_QUOTE_MISSING');
    });

    test('报价过期（改了数量没重算）不能提交', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line());
      f.requote();
      f.order.acceptAgreement();
      f.order.addLine(_Fixture.line(quantity: 1)); // 报价被作废

      expect(f.order.submit(f.now).failure!.code, 'ORDER_QUOTE_MISSING');

      // 重算后又能提交
      f.requote();
      expect(f.order.submit(f.now).isSuccess, isTrue);
    });

    test('实名人数必须严格匹配，且不能重复选同一人', () {
      final f = _Fixture(requiredVisitorCount: 2);
      f.order.addLine(_Fixture.line(quantity: 2));
      f.requote();
      f.order.acceptAgreement();

      final one = Visitor(
        id: const VisitorId('v1'),
        name: '张票友',
        idCard: IdCardNumber(type: IdCardType.idCard, number: '310101199003074511'),
      );
      expect(f.order.assignVisitors(<Visitor>[one]).failure!.code,
          'ORDER_VISITOR_COUNT_MISMATCH');

      expect(f.order.assignVisitors(<Visitor>[one, one]).failure!.code,
          'ORDER_VISITOR_DUPLICATED');

      final two = Visitor(
        id: const VisitorId('v2'),
        name: '李看戏',
        idCard: IdCardNumber(type: IdCardType.idCard, number: '11010519491231002X'),
      );
      expect(f.order.assignVisitors(<Visitor>[one, two]).isSuccess, isTrue);
      expect(f.order.submit(f.now).isSuccess, isTrue);
    });

    test('提交成功后状态迁移并发 OrderPlaced', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line(quantity: 2));
      f.requote();
      f.order.acceptAgreement();

      final result = f.order.submit(f.now);
      expect(result.isSuccess, isTrue);
      expect(f.order.status, OrderStatus.awaitingPayment);
      expect(f.order.isEditable, isFalse);

      final event = f.order.pullDomainEvents().single as OrderPlaced;
      expect(event.orderNumber.value, 'PN20261101000123');
      expect(event.totalAmount, Money.fromYuan(1360));
      expect(event.paymentAmount, Money.fromYuan(1360));
      expect(event.requiresPayment, isTrue);
      expect(f.order.hasDomainEvents, isFalse);
    });

    test('提交后不能再改', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line());
      f.requote();
      f.order.acceptAgreement();
      f.order.submit(f.now);

      expect(f.order.addLine(_Fixture.line()).failure!.code, 'ORDER_NOT_EDITABLE');
      expect(f.order.selectDiscount(DiscountSelection.none).failure!.code,
          'ORDER_NOT_EDITABLE');
    });

    test('支付：待支付 → 待发货，并发 OrderPaid', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line());
      f.requote();
      f.order.acceptAgreement();
      f.order.submit(f.now);
      f.order.pullDomainEvents();

      final paid = f.order.markPaid(
        now: f.now.add(const Duration(minutes: 3)),
        channel: PaymentChannel.wechat,
      );
      expect(paid.isSuccess, isTrue);
      expect(f.order.status, OrderStatus.awaitingTickets);
      expect(f.order.paidAt, isNotNull);

      final event = f.order.pullDomainEvents().single as OrderPaid;
      expect(event.paidAmount, Money.fromYuan(680));
      expect(event.channel, PaymentChannel.wechat);
    });

    test('非法迁移被拒（草稿不能直接发货）', () {
      final f = _Fixture();
      final result = f.order.markShipped(now: f.now);
      expect(result.isFailure, isTrue);
      expect(result.failure!.code, 'ORDER_STATUS_ILLEGAL');
    });

    test('未支付不能退款；已支付可退款', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line());
      f.requote();
      f.order.acceptAgreement();
      f.order.submit(f.now);

      expect(
        f.order.refund(amount: Money.fromYuan(680), reason: '不想要了', now: f.now)
            .failure!
            .code,
        'ORDER_NOT_REFUNDABLE',
      );

      f.order.markPaid(now: f.now, channel: PaymentChannel.alipay);
      final refunded =
          f.order.refund(amount: Money.fromYuan(680), reason: '演出取消', now: f.now);
      expect(refunded.isSuccess, isTrue);
      expect(f.order.status, OrderStatus.refunded);
      expect(f.order.pullDomainEvents().last, isA<OrderRefunded>());
    });

    test('支付超时自动关闭', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line());
      f.requote();
      f.order.acceptAgreement();
      f.order.submit(f.now);

      expect(
        f.order.expireIfUnpaid(f.now.add(const Duration(minutes: 5))).requireData,
        isFalse,
      );

      final expired = f.order.expireIfUnpaid(f.now.add(const Duration(minutes: 16)));
      expect(expired.requireData, isTrue);
      expect(f.order.status, OrderStatus.cancelled);

      final event = f.order.pullDomainEvents().last as OrderCancelled;
      expect(event.isTimeout, isTrue);
    });

    test('加速包份数不能超过票数', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line(quantity: 1));

      final result = f.order.selectSpeedPack(
        SpeedPack.forTickets(
          tickets: 3,
          unitPrice: Money.fromYuan(30),
          balanceAvailable: Money.zero(),
        ),
      );
      expect(result.failure!.code, 'SPEED_PACK_UNIT_INVALID');
    });
  });

  group('优惠三选一：sealed 类型保证互斥', () {
    test('选券后活动不再生效（只有一个 DiscountSelection 字段）', () {
      final f = _Fixture();
      f.order.addLine(_Fixture.line(quantity: 2));

      f.order.selectDiscount(
        DiscountSelection.campaign(
          const CampaignId('CM-1'),
          RateDiscount(1000),
        ),
      );
      f.order.selectDiscount(
        DiscountSelection.coupon(
          const CouponId('CP-1'),
          AmountDiscount(Money.fromYuan(50)),
        ),
      );

      expect(f.order.discount, isA<CouponSelection>());
      expect(f.order.discount.promotionId, 'CP-1');

      final quote = f.pricing.quote(
        goodsTotal: f.order.goodsTotal,
        postage: Money.zero(),
        splitFee: Money.zero(),
        discount: f.order.discount,
      );
      expect(quote.discountApplied, Money.fromYuan(50));
    });
  });

  group('领域事件总线', () {
    test('OrderPlaced 被投递给订阅方', () async {
      final bus = DomainEventBus();
      final received = <String>[];
      bus.on<OrderPlaced>((event) => received.add(event.orderNumber.value));

      final f = _Fixture();
      f.order.addLine(_Fixture.line());
      f.requote();
      f.order.acceptAgreement();
      f.order.submit(f.now);

      await bus.dispatch(f.order.pullDomainEvents());
      expect(received, <String>['PN20261101000123']);
    });
  });

  group('限购策略', () {
    const policy = PurchaseLimitPolicy();

    test('单笔上限', () {
      final result = policy.checkOrderQuantity(
        requested: Quantity(7),
        limit: PurchaseLimit(maxPerOrder: Quantity(6)),
      );
      expect(result.isFailure, isTrue);
    });

    test('账号累计上限（含已购数）', () {
      final result = policy.checkUserQuota(
        requested: Quantity(2),
        alreadyPurchased: Quantity(3),
        limit: PurchaseLimit(maxPerUser: Quantity(4)),
      );
      expect(result.isFailure, isTrue);
      expect(result.failure!.message, contains('还可购买 1 张'));
    });

    test('不限购时永远通过', () {
      expect(
        policy
            .checkOrderQuantity(
              requested: Quantity(999),
              limit: const PurchaseLimit.unlimited(),
            )
            .isSuccess,
        isTrue,
      );
    });
  });

  group('Result 契约', () {
    test('失败是返回值，不是异常', () {
      final f = _Fixture();
      expect(() => f.order.submit(f.now), returnsNormally);
      expect(f.order.submit(f.now), isA<Result<void>>());
    });
  });
}
