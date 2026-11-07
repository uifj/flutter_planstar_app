import 'package:core/domain.dart';
import 'package:core/result.dart';

import '../events/order_lifecycle_events.dart';
import '../events/order_paid.dart';
import '../events/order_placed.dart';
import '../policies/purchase_limit_policy.dart';
import '../services/order_quote.dart';
import '../value_objects/delivery.dart';
import '../value_objects/discount.dart';
import '../value_objects/ids.dart';
import '../value_objects/order_number.dart';
import '../value_objects/order_status.dart';
import '../value_objects/order_type.dart';
import '../value_objects/payment_channel.dart';
import '../value_objects/speed_pack.dart';
import '../value_objects/visitor.dart';

// 订单行是聚合**内部**的实体：它的可变方法只在同一 library 内可见，
// 外部只能通过聚合根改它。Dart 没有 friend class，`part` 是标准替代。
part 'order_line.dart';

/// 票务订单聚合根 —— 整个交易漏斗的一致性边界。
///
/// ## 边界怎么划的
///
/// 一个聚合 = **一张订单**（根）+ 它的订单行（子实体）+ 配送/优惠/礼品卡/加速包/
/// 观演人（值对象）。判据是"改这件事必须和改那件事一起成功"：
/// 改数量必须和重算金额一起；改配送方式必须和重算运费一起。
///
/// **不**放进聚合的：券/卡的余额（别的聚合）、演出余票（别的聚合）、支付流水。
/// 它们只通过 id 引用，一致性是最终一致——这正是企划星"订单页直接扣礼品卡余额"
/// 那类跨聚合写操作应该被拆开的地方。
///
/// ## 与企划星 Android 侧的对应
///
/// 原实现里这些状态散在 `OrderConfirmActivity` 的 20 多个成员变量上：
/// `mCounts` / `mTotalAmount` / `mPaymentAmount` / `mSelectStatus` / `mCurrentCoupon` /
/// `mCurrentGiftCard` / `mSpeedPackage` / `mIsProxyBuy` …… 每个方法都可能改其中几个，
/// 没有任何地方能回答"这张订单现在合法吗"。这里全部收进一个对象，且**每次变更
/// 都会让旧报价失效**（[attachQuote] 之前必须重算），从结构上消灭
/// "页面显示一个价、请求发另一个价"。
final class TicketOrder extends AggregateRoot<TicketOrderId> {
  TicketOrder._({
    required TicketOrderId id,
    required this.number,
    required this.showId,
    required this.sessionId,
    required this.orderType,
    required this.buyType,
    required this.placedAt,
    required this.paymentWindow,
    required this.purchaseLimit,
    required this.requiredVisitorCount,
    required DeliveryInfo delivery,
    required PurchaseLimitPolicy limitPolicy,
  }) : _delivery = delivery,
       _limitPolicy = limitPolicy,
       super(id);

  /// 创建一张草稿订单。
  ///
  /// 草稿是**客户端态**（没有 wire code）：真正的订单由服务端在 `makeOrder` 之后创建。
  /// 之所以先建草稿，是因为确认页的每一次改数量都要立刻重算金额，
  /// 不能等到提交才第一次计算。
  static Result<TicketOrder> create({
    required TicketOrderId id,
    required OrderNumber number,
    required ShowId showId,
    required SessionId sessionId,
    required DateTime now,
    OrderType orderType = OrderType.ticket,
    BuyType buyType = BuyType.normal,
    Duration paymentWindow = const Duration(minutes: 15),
    PurchaseLimit purchaseLimit = const PurchaseLimit.unlimited(),
    int requiredVisitorCount = 0,
    DeliveryInfo? delivery,
    PurchaseLimitPolicy limitPolicy = const PurchaseLimitPolicy(),
  }) {
    if (requiredVisitorCount < 0) {
      return _fail('ORDER_VISITOR_COUNT_INVALID', '实名支持人数量不能为负');
    }
    if (paymentWindow <= Duration.zero) {
      return _fail('ORDER_PAYMENT_WINDOW_INVALID', '支付时限必须为正');
    }
    return Success<TicketOrder>(
      TicketOrder._(
        id: id,
        number: number,
        showId: showId,
        sessionId: sessionId,
        orderType: orderType,
        buyType: buyType,
        placedAt: now,
        paymentWindow: paymentWindow,
        purchaseLimit: purchaseLimit,
        requiredVisitorCount: requiredVisitorCount,
        delivery: delivery ?? DeliveryInfo.electronic(),
        limitPolicy: limitPolicy,
      ),
    );
  }

  /// 订单号。
  final OrderNumber number;

  /// 演出 id。
  final ShowId showId;

  /// 场次 id。
  final SessionId sessionId;

  /// 下单类型。
  final OrderType orderType;

  /// 购买方式（普通 / 代购）。
  final BuyType buyType;

  /// 草稿创建时间。
  final DateTime placedAt;

  /// 支付时限（服务端 `PayInfo.leftTime` 的等价物）。
  final Duration paymentWindow;

  /// 限购规则。
  final PurchaseLimit purchaseLimit;

  /// 本单需要几位实名观演人（0 = 不需要实名）。
  final int requiredVisitorCount;

  final PurchaseLimitPolicy _limitPolicy;
  final List<OrderLine> _lines = <OrderLine>[];

  OrderStatus _status = OrderStatus.draft;
  DeliveryInfo _delivery;
  DiscountSelection _discount = DiscountSelection.none;
  GiftCardTender? _giftCard;
  SpeedPack? _speedPack;
  List<Visitor> _visitors = const <Visitor>[];
  OrderQuote? _quote;
  bool _agreementAccepted = false;
  DateTime? _submittedAt;
  DateTime? _paidAt;
  OrderCancelReason? _cancelReason;

  /// 当前状态。
  OrderStatus get status => _status;

  /// 订单行（只读）。
  List<OrderLine> get lines => List<OrderLine>.unmodifiable(_lines);

  /// 配送信息。
  DeliveryInfo get delivery => _delivery;

  /// 本单选择的优惠（营销 / 券 / 不用，三选一）。
  DiscountSelection get discount => _discount;

  /// 本单使用的礼品卡。
  GiftCardTender? get giftCard => _giftCard;

  /// 本单购买的加速包。
  SpeedPack? get speedPack => _speedPack;

  /// 实名观演人。
  List<Visitor> get visitors => List<Visitor>.unmodifiable(_visitors);

  /// 当前有效报价（改动后会被置空）。
  OrderQuote? get quote => _quote;

  /// 是否已勾选交易协议。
  bool get agreementAccepted => _agreementAccepted;

  /// 提交时间。
  DateTime? get submittedAt => _submittedAt;

  /// 支付时间。
  DateTime? get paidAt => _paidAt;

  /// 关闭原因。
  OrderCancelReason? get cancelReason => _cancelReason;

  /// 是否还能编辑（只有草稿可编辑）。
  bool get isEditable => _status == OrderStatus.draft;

  /// 商品总额 = 各行小计之和。
  Money get goodsTotal => Money.sum(_lines.map((line) => line.subtotal));

  /// 总票数。
  Quantity get totalTickets =>
      _lines.fold(Quantity.zero, (sum, line) => sum + line.quantity);

  /// 支付截止时刻（提交后才有意义）。
  DateTime get payDeadline => (_submittedAt ?? placedAt).add(paymentWindow);

  /// 距离支付超时还剩多久（已超时返回 [Duration.zero]）。
  Duration remainingPaymentTime(DateTime now) {
    final left = payDeadline.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  // ── 编辑（只在草稿态）────────────────────────────────────────────────────

  /// 加一个票档。同一票档会**合并**数量（企划星 `AddLine` 的等价语义）。
  ///
  /// 合并的前提是单价一致：同一票档出现两个单价说明服务端数据已经变了，
  /// 这时应该失败让用户重新拉确认页，而不是取其中一个价格。
  Result<void> addLine(OrderLine line) {
    final editable = _requireEditable();
    if (editable.isFailure) return editable;

    final nextTotal = totalTickets + line.quantity;
    final limitCheck = _limitPolicy.checkOrderQuantity(
      requested: nextTotal,
      limit: purchaseLimit,
    );
    if (limitCheck.isFailure) return limitCheck;

    final existing = _lineOrNull(line.id);
    if (existing == null) {
      _lines.add(line);
    } else if (existing.unitPrice != line.unitPrice) {
      return _fail('ORDER_LINE_PRICE_CONFLICT', '回报档位价格已变化，请重新确认订单');
    } else {
      existing._changeQuantity(existing.quantity + line.quantity);
    }

    _invalidateQuote();
    return const Success<void>(null);
  }

  /// 改某个票档的数量。数量为 0 等于移除。
  Result<void> changeLineQuantity(TicketTierId tierId, Quantity quantity) {
    final editable = _requireEditable();
    if (editable.isFailure) return editable;

    final line = _lineOrNull(tierId);
    if (line == null) {
      return _fail('ORDER_LINE_NOT_FOUND', '回报档位不存在：${tierId.value}');
    }

    if (quantity.isZero) {
      _lines.remove(line);
      _invalidateQuote();
      return const Success<void>(null);
    }

    final nextTotal = totalTickets - line.quantity + quantity;
    final limitCheck = _limitPolicy.checkOrderQuantity(
      requested: nextTotal,
      limit: purchaseLimit,
    );
    if (limitCheck.isFailure) return limitCheck;

    line._changeQuantity(quantity);
    _invalidateQuote();
    return const Success<void>(null);
  }

  /// 移除票档。
  Result<void> removeLine(TicketTierId tierId) {
    final line = _lineOrNull(tierId);
    if (line == null) {
      return _fail('ORDER_LINE_NOT_FOUND', '回报档位不存在：${tierId.value}');
    }
    return changeLineQuantity(tierId, Quantity.zero);
  }

  /// 选择优惠。**营销活动与券互斥**——由 `sealed` 类型保证，不可能同时选。
  Result<void> selectDiscount(DiscountSelection selection) {
    final editable = _requireEditable();
    if (editable.isFailure) return editable;
    _discount = selection;
    _invalidateQuote();
    return const Success<void>(null);
  }

  /// 使用礼品卡（`null` 表示不用）。
  Result<void> applyGiftCard(GiftCardTender? tender) {
    final editable = _requireEditable();
    if (editable.isFailure) return editable;
    _giftCard = tender;
    _invalidateQuote();
    return const Success<void>(null);
  }

  /// 购买加速包（`null` 表示不买）。
  ///
  /// 加速包按票买，份数不能超过票数（企划星 `speedPackage * mCounts` 的约束）。
  Result<void> selectSpeedPack(SpeedPack? pack) {
    final editable = _requireEditable();
    if (editable.isFailure) return editable;

    if (pack != null && pack.units > totalTickets.value) {
      return _fail(
        'SPEED_PACK_UNIT_INVALID',
        '加速包份数（${pack.units}）不能超过票数（${totalTickets.value}）',
      );
    }

    _speedPack = pack;
    _invalidateQuote();
    return const Success<void>(null);
  }

  /// 设置配送方式（会改变运费，因此报价失效）。
  Result<void> setDelivery(DeliveryInfo info) {
    final editable = _requireEditable();
    if (editable.isFailure) return editable;
    _delivery = info;
    _invalidateQuote();
    return const Success<void>(null);
  }

  /// 指定实名观演人。
  ///
  /// 三条不变量（企划星 `order()` 里是内联 if + toast）：
  /// 1. 同一人不能重复选（按证件号去重）；
  /// 2. 人数必须**严格等于**服务端要求的人数；
  /// 3. 不需要实名的场次不能塞观演人。
  Result<void> assignVisitors(List<Visitor> visitors) {
    final editable = _requireEditable();
    if (editable.isFailure) return editable;

    final unique = <String, Visitor>{
      for (final visitor in visitors) visitor.identityKey: visitor,
    }.values.toList(growable: false);

    if (unique.length != visitors.length) {
      return _fail('ORDER_VISITOR_DUPLICATED', '同一支持人不能重复选择');
    }
    if (requiredVisitorCount == 0 && unique.isNotEmpty) {
      return _fail('ORDER_VISITOR_NOT_REQUIRED', '本企划无需实名支持人');
    }
    if (requiredVisitorCount > 0 && unique.length != requiredVisitorCount) {
      return _fail(
        'ORDER_VISITOR_COUNT_MISMATCH',
        '本单需选择 $requiredVisitorCount 位支持人，已选 ${unique.length} 位',
      );
    }

    _visitors = unique;
    return const Success<void>(null);
  }

  /// 勾选交易协议。
  ///
  /// ⚠ 企划星侧默认 `postValue(true)`（进页面就是勾上的），这是合规红旗（`M5-01`）。
  /// 这里把"勾选"做成必须显式调用的动作，且 [submit] 会强制校验——
  /// **默认值在类型层面就不存在**，UI 想默认勾上得自己写一行。
  Result<void> acceptAgreement() {
    final editable = _requireEditable();
    if (editable.isFailure) return editable;
    _agreementAccepted = true;
    return const Success<void>(null);
  }

  /// 取消勾选。
  Result<void> revokeAgreement() {
    final editable = _requireEditable();
    if (editable.isFailure) return editable;
    _agreementAccepted = false;
    return const Success<void>(null);
  }

  /// 挂上一次报价。
  ///
  /// 必须与当前商品总额一致：报价是**快照**，商品变了它就不该被使用。
  Result<void> attachQuote(OrderQuote quote) {
    final editable = _requireEditable();
    if (editable.isFailure) return editable;

    if (_lines.isEmpty) {
      return _fail('ORDER_EMPTY', '请先选择回报档位');
    }
    if (quote.isStaleFor(goodsTotal)) {
      return _fail('ORDER_QUOTE_STALE', '报价与当前订单内容不一致，请重新计算');
    }

    _quote = quote;
    return const Success<void>(null);
  }

  // ── 生命周期 ─────────────────────────────────────────────────────────────

  /// 提交订单：草稿 → 待支付，并发 [OrderPlaced]。
  Result<void> submit(DateTime now) {
    final editable = _requireEditable();
    if (editable.isFailure) return editable;

    if (_lines.isEmpty) {
      return _fail('ORDER_EMPTY', '请先选择回报档位');
    }
    if (!_agreementAccepted) {
      return _fail('ORDER_AGREEMENT_REQUIRED', '请阅读并勾选${buyType.name}协议');
    }

    final currentQuote = _quote;
    if (currentQuote == null) {
      return _fail('ORDER_QUOTE_MISSING', '订单金额尚未计算');
    }
    if (currentQuote.isStaleFor(goodsTotal)) {
      return _fail('ORDER_QUOTE_STALE', '订单内容已变化，请重新确认金额');
    }
    if (requiredVisitorCount > 0 && _visitors.length != requiredVisitorCount) {
      return _fail(
        'ORDER_VISITOR_COUNT_MISMATCH',
        '请选择 $requiredVisitorCount 位支持人',
      );
    }

    final transition = _transitionTo(OrderStatus.awaitingPayment);
    if (transition.isFailure) return transition;

    _submittedAt = now;
    raiseDomainEvent(
      OrderPlaced(
        orderId: id,
        orderNumber: number,
        showId: showId,
        totalAmount: currentQuote.totalAmount,
        paymentAmount: currentQuote.paymentAmount,
        requiresPayment: currentQuote.requiresPayment,
        occurredAt: now,
      ),
    );
    return const Success<void>(null);
  }

  /// 支付成功：待支付 → 待发货，并发 [OrderPaid]。
  ///
  /// 真实链路的支付结果来自服务端回调 / SDK 回调，客户端只做"把结果记到聚合上"。
  Result<void> markPaid({
    required DateTime now,
    required PaymentChannel channel,
  }) {
    if (_status != OrderStatus.awaitingPayment) {
      return _fail('ORDER_NOT_PAYABLE', '当前状态（${_status.name}）不可支付');
    }
    final currentQuote = _quote;
    if (currentQuote == null) {
      return _fail('ORDER_QUOTE_MISSING', '订单金额缺失，无法确认支付结果');
    }

    final transition = _transitionTo(OrderStatus.awaitingTickets);
    if (transition.isFailure) return transition;

    _paidAt = now;
    raiseDomainEvent(
      OrderPaid(
        orderId: id,
        orderNumber: number,
        paidAmount: currentQuote.paymentAmount,
        channel: channel,
        occurredAt: now,
      ),
    );
    return const Success<void>(null);
  }

  /// 已发货：待发货 → 待收货。
  Result<void> markShipped({required DateTime now, String? trackingNumber}) {
    final transition = _transitionTo(OrderStatus.ticketsInTransit);
    if (transition.isFailure) return transition;

    raiseDomainEvent(
      OrderShipped(
        orderId: id,
        trackingNumber: trackingNumber,
        occurredAt: now,
      ),
    );
    return const Success<void>(null);
  }

  /// 已完成。
  Result<void> complete(DateTime now) {
    final transition = _transitionTo(OrderStatus.completed);
    if (transition.isFailure) return transition;

    raiseDomainEvent(OrderCompleted(orderId: id, occurredAt: now));
    return const Success<void>(null);
  }

  /// 关闭订单（用户取消 / 超时）。
  Result<void> cancel({
    required OrderCancelReason reason,
    required DateTime now,
  }) {
    final transition = _transitionTo(OrderStatus.cancelled);
    if (transition.isFailure) return transition;

    _cancelReason = reason;
    raiseDomainEvent(
      OrderCancelled(
        orderId: id,
        orderNumber: number,
        reason: reason,
        occurredAt: now,
      ),
    );
    return const Success<void>(null);
  }

  /// 退款：已支付 → 已退款。
  Result<void> refund({
    required Money amount,
    required String reason,
    required DateTime now,
  }) {
    if (!_status.isPaid) {
      return _fail('ORDER_NOT_REFUNDABLE', '未支付的订单不能退款');
    }
    final transition = _transitionTo(OrderStatus.refunded);
    if (transition.isFailure) return transition;

    raiseDomainEvent(
      OrderRefunded(
        orderId: id,
        refundAmount: amount,
        reason: reason,
        occurredAt: now,
      ),
    );
    return const Success<void>(null);
  }

  /// 到点自动关闭：待支付且已过 [payDeadline]。
  ///
  /// 返回是否真的关闭了。由调用方（定时器 / 页面 resume）驱动，
  /// 聚合本身不持有计时器——聚合里有时钟就是不可测的开始。
  Result<bool> expireIfUnpaid(DateTime now) {
    if (_status != OrderStatus.awaitingPayment || !now.isAfter(payDeadline)) {
      return const Success<bool>(false);
    }
    final result = cancel(reason: OrderCancelReason.timeout, now: now);
    if (result.isFailure) return Fail<bool>(result.failure!);
    return const Success<bool>(true);
  }

  // ── 内部 ─────────────────────────────────────────────────────────────────

  OrderLine? _lineOrNull(TicketTierId tierId) {
    for (final line in _lines) {
      if (line.id == tierId) return line;
    }
    return null;
  }

  /// 内容一变，旧报价立即作废——这是"两个金额分别设置"那类缺陷的结构性解法。
  void _invalidateQuote() => _quote = null;

  Result<void> _requireEditable() => isEditable
      ? const Success<void>(null)
      : _fail('ORDER_NOT_EDITABLE', '订单已提交，不能再修改');

  Result<void> _transitionTo(OrderStatus next) {
    if (!_status.canTransitionTo(next)) {
      return _fail(
        'ORDER_STATUS_ILLEGAL',
        '订单状态不允许从「${_status.name}」变为「${next.name}」',
      );
    }
    _status = next;
    return const Success<void>(null);
  }

  static Result<T> _fail<T>(String code, String message) => Fail<T>(
    Failure(code: code, message: message, type: FailureType.validation),
  );
}
