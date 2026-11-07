import 'package:core/domain.dart';
import 'package:core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/planstar_order_api.dart';
import '../domain/domain.dart';
import 'order_api_providers.dart';
import 'order_draft_seed.dart';
import 'order_providers.dart';

/// 确认页提示条的类型（文案由 UI 层按 l10n 解析）。
enum OrderNoticeCode {
  ticketTierMissing,
  noCampaign,
  noCoupon,
  noGiftCard,
  noSpeedPack,
  failure,
  saveFailed,
  priceChanged,
  submitted,
}

/// 确认页提示条。
class OrderNotice {
  const OrderNotice(this.code, {this.detail});

  final OrderNoticeCode code;

  /// `failure` / `saveFailed` 的原始错误信息，`submitted` 的订单号。
  final String? detail;
}

/// 确认订单页的视图状态。
///
/// 只有**一个**可变来源：[order]（聚合）。页面上的每个数字都从它派生，
/// 不存在"页面上存了一份金额、请求里存了另一份"的可能。
final class OrderConfirmState {
  const OrderConfirmState({
    required this.order,
    required this.quote,
    this.serverQuote,
    this.notice,
    this.submitting = false,
    this.submitted = false,
    this.placedOrderNumber,
    this.recentEvents = const <String>[],
  });

  /// 订单聚合（唯一事实来源）。
  final TicketOrder order;

  /// 本地预演报价（随聚合变化重算）。
  final OrderQuote quote;

  /// 服务端确认报价；有值时页面金额以它为准。
  final OrderServerQuote? serverQuote;

  /// 一次性提示（校验失败原因 / 成功文案）。
  final OrderNotice? notice;

  /// 是否正在提交。
  final bool submitting;

  /// 是否已提交成功。
  final bool submitted;

  /// 服务端返回的订单号（提交成功后展示与跳转用）。
  final String? placedOrderNumber;

  /// 最近分发的领域事件名（演示"聚合不关心副作用"）。
  final List<String> recentEvents;

  /// 页面展示用报价：服务端报价优先，本地报价兜底。
  OrderQuote get displayQuote => serverQuote?.toDisplayQuote() ?? quote;

  /// 提交按钮是否可用。
  bool get canSubmit =>
      order.isEditable &&
      order.agreementAccepted &&
      order.lines.isNotEmpty &&
      !submitting;

  OrderConfirmState copyWith({
    TicketOrder? order,
    OrderQuote? quote,
    Object? serverQuote = _sentinel,
    Object? notice = _sentinel,
    bool? submitting,
    bool? submitted,
    Object? placedOrderNumber = _sentinel,
    List<String>? recentEvents,
  }) {
    return OrderConfirmState(
      order: order ?? this.order,
      quote: quote ?? this.quote,
      serverQuote: identical(serverQuote, _sentinel)
          ? this.serverQuote
          : serverQuote as OrderServerQuote?,
      notice: identical(notice, _sentinel)
          ? this.notice
          : notice as OrderNotice?,
      submitting: submitting ?? this.submitting,
      submitted: submitted ?? this.submitted,
      placedOrderNumber: identical(placedOrderNumber, _sentinel)
          ? this.placedOrderNumber
          : placedOrderNumber as String?,
      recentEvents: recentEvents ?? this.recentEvents,
    );
  }
}

const Object _sentinel = Object();

/// 确认订单页控制器（应用层）。
///
/// 职责只有三件：**调聚合、算报价、把事件发出去**。
/// 不写业务规则——规则都在 [TicketOrder] 和 [OrderPricingService] 里，
/// 所以这段代码在单测里根本不需要 Widget 环境。
final class OrderConfirmController
    extends FamilyNotifier<OrderConfirmState, String> {
  OrderPricingService get _pricing => ref.read(orderPricingServiceProvider);
  TicketOrderRepository get _repository =>
      ref.read(ticketOrderRepositoryProvider);
  DomainEventBus get _bus => ref.read(domainEventBusProvider);

  /// 真实模式下重试建单复用同一个幂等键。
  String? _idempotencyKey;

  bool get _serverMode => !ref.read(useDemoProvider);

  @override
  OrderConfirmState build(String showId) {
    final seed = ref.watch(orderDraftSeedProvider(showId));
    final now = DateTime.now();

    // 草稿 id 用时间戳生成；真实订单 id 由服务端下发。
    final order = TicketOrder.create(
      id: TicketOrderId('draft-${now.microsecondsSinceEpoch}'),
      number: OrderNumber.generate(date: now, sequence: 1),
      showId: seed.showId,
      sessionId: seed.sessionId,
      now: now,
      requiredVisitorCount: seed.requiredVisitorCount,
      purchaseLimit: seed.purchaseLimit,
    ).requireData;

    // 默认选中第一个票档 1 张（企划星确认页的入口默认值）。
    if (seed.tiers.isNotEmpty) {
      final first = seed.tiers.first;
      order.addLine(
        OrderLine(
          id: first.id,
          tierName: first.name,
          unitPrice: first.price,
          quantity: Quantity(1),
        ),
      );
    }

    final quote = _quoteOf(order);
    if (order.lines.isNotEmpty) {
      order.attachQuote(quote);
    }

    if (_serverMode) {
      // 进入确认页即向服务端要一次报价；失败时静默回退本地预演。
      Future<void>.microtask(() => _refreshServerQuote());
    }

    return OrderConfirmState(order: order, quote: quote);
  }

  /// 加一张某票档。
  void increase(TicketTierId tierId) {
    final seed = ref.read(orderDraftSeedProvider(arg));
    final offer = _offerOf(seed, tierId);
    if (offer == null) {
      state = state.copyWith(
        notice: const OrderNotice(OrderNoticeCode.ticketTierMissing),
      );
      return;
    }
    _apply(
      state.order.addLine(
        OrderLine(
          id: offer.id,
          tierName: offer.name,
          unitPrice: offer.price,
          quantity: Quantity(1),
        ),
      ),
    );
  }

  /// 减一张某票档（减到 0 等于移除）。
  void decrease(TicketTierId tierId) {
    final line = _lineOf(tierId);
    if (line == null) return;
    final next = line.quantity.value - 1;
    _apply(
      state.order.changeLineQuantity(tierId, Quantity(next < 0 ? 0 : next)),
    );
  }

  /// 选择营销活动。
  void selectCampaign() {
    final seed = ref.read(orderDraftSeedProvider(arg));
    final campaign = seed.availableCampaign;
    if (campaign == null) {
      state = state.copyWith(
        notice: const OrderNotice(OrderNoticeCode.noCampaign),
      );
      return;
    }
    _apply(state.order.selectDiscount(campaign));
  }

  /// 选择优惠券（与营销活动**互斥**：选券会自动顶掉活动）。
  void selectCoupon() {
    final seed = ref.read(orderDraftSeedProvider(arg));
    final coupon = seed.availableCoupon;
    if (coupon == null) {
      state = state.copyWith(
        notice: const OrderNotice(OrderNoticeCode.noCoupon),
      );
      return;
    }
    _apply(state.order.selectDiscount(coupon));
  }

  /// 不使用优惠。
  void clearDiscount() =>
      _apply(state.order.selectDiscount(DiscountSelection.none));

  /// 使用礼品卡。
  void useGiftCard() {
    final giftCard = ref.read(orderDraftSeedProvider(arg)).giftCard;
    if (giftCard == null) {
      state = state.copyWith(
        notice: const OrderNotice(OrderNoticeCode.noGiftCard),
      );
      return;
    }
    _apply(state.order.applyGiftCard(giftCard));
  }

  /// 不用礼品卡。
  void clearGiftCard() => _apply(state.order.applyGiftCard(null));

  /// 买加速包（每张票一份）。
  void buySpeedPack() {
    final seed = ref.read(orderDraftSeedProvider(arg));
    final unitPrice = seed.speedPackUnitPrice;
    if (unitPrice == null) {
      state = state.copyWith(
        notice: const OrderNotice(OrderNoticeCode.noSpeedPack),
      );
      return;
    }
    _apply(
      state.order.selectSpeedPack(
        SpeedPack.forTickets(
          tickets: state.order.totalTickets.value,
          unitPrice: unitPrice,
          balanceAvailable: seed.speedPackBalance,
        ),
      ),
    );
  }

  /// 不买加速包。
  void clearSpeedPack() => _apply(state.order.selectSpeedPack(null));

  /// 勾选 / 取消交易协议。
  ///
  /// ⚠ 默认**不勾**。企划星侧 `OrderConfirmViewModule` 构造时 `postValue(true)`，
  /// 进页面就是勾上的（合规红旗 M5-01）。这里把默认值反过来，且必须用户主动点。
  void toggleAgreement() {
    final order = state.order;
    _apply(
      order.agreementAccepted
          ? order.revokeAgreement()
          : order.acceptAgreement(),
    );
  }

  /// 选择实名观演人（演示用：固定一位）。
  ///
  /// 真实实现会拉起企划星的观演人列表（`GET v1/user/realName`），
  /// 选完把 `List<Visitor>` 交给聚合。
  void assignDemoVisitor() {
    _apply(
      state.order.assignVisitors(<Visitor>[
        Visitor(
          id: const VisitorId('visitor-1'),
          name: '张票友',
          idCard: IdCardNumber(
            type: IdCardType.idCard,
            number: '310101199003074511',
          ),
        ),
      ]),
    );
  }

  /// 提交订单：服务端报价 → 聚合校验 → 建单 → 分发领域事件。
  Future<void> submit() async {
    if (state.submitting) return;

    state = state.copyWith(submitting: true, notice: null);

    final order = state.order;

    if (_serverMode) {
      // 提交前再确认一次价格；最终金额以服务端报价为准。
      final beforeTotal = state.displayQuote.totalAmount;
      final serverQuote = await _refreshServerQuote(showFailure: true);
      if (serverQuote == null) {
        state = state.copyWith(
          submitting: false,
          notice:
              state.notice ??
              const OrderNotice(
                OrderNoticeCode.saveFailed,
                detail: '无法获取最新价格，请稍后重试',
              ),
        );
        return;
      }
      if (serverQuote.toDisplayQuote().totalAmount != beforeTotal) {
        state = state.copyWith(
          submitting: false,
          notice: const OrderNotice(OrderNoticeCode.priceChanged),
        );
        return;
      }
    }

    final submitted = order.submit(DateTime.now());
    if (submitted.isFailure) {
      state = state.copyWith(
        submitting: false,
        notice: OrderNotice(
          OrderNoticeCode.failure,
          detail: submitted.failure!.message,
        ),
      );
      return;
    }

    if (_serverMode) {
      final result = await ref
          .read(planstarOrderApiProvider)
          .makeOrder(
            _makeOrderBody(state.serverQuote),
            idempotencyKey: _idempotencyKey ??=
                PlanstarOrderApi.newIdempotencyKey(),
          );
      if (result.isFailure) {
        state = state.copyWith(
          submitting: false,
          notice: OrderNotice(
            OrderNoticeCode.saveFailed,
            detail: _readableMessage(result.failure!),
          ),
        );
        return;
      }
      _idempotencyKey = null;
      await _bus.dispatch(order.pullDomainEvents());
      final number = _orderNumberOf(result.requireData) ?? order.number.value;
      state = state.copyWith(
        submitting: false,
        submitted: true,
        placedOrderNumber: number,
        notice: OrderNotice(OrderNoticeCode.submitted, detail: number),
        recentEvents: ref.read(orderEventRecorderProvider).eventNames,
      );
      return;
    }

    final saved = await _repository.save(order);
    if (saved.isFailure) {
      // ⚠ 内存实现不会走到这里。接真实网络实现时，这一步必须和上面的 submit
      // 在同一个事务里（失败则回滚聚合状态），否则会出现"本地已提交、服务端没建单"。
      state = state.copyWith(
        submitting: false,
        notice: OrderNotice(
          OrderNoticeCode.saveFailed,
          detail: saved.failure!.message,
        ),
      );
      return;
    }

    // 先保存、后发事件：反过来会出现"事件已发出、事务回滚"的幽灵通知。
    await _bus.dispatch(order.pullDomainEvents());

    state = state.copyWith(
      submitting: false,
      submitted: true,
      placedOrderNumber: order.number.value,
      notice: OrderNotice(
        OrderNoticeCode.submitted,
        detail: order.number.value,
      ),
      recentEvents: ref.read(orderEventRecorderProvider).eventNames,
    );
  }

  /// 向服务端要一次报价并写入 state；失败可静默（预览）或写提示（提交）。
  Future<OrderServerQuote?> _refreshServerQuote({
    bool showFailure = false,
  }) async {
    try {
      if (!_serverMode) return null;
      final result = await ref
          .read(planstarOrderApiProvider)
          .fetchConfirmQuote(_confirmBody());
      if (result.isFailure) {
        if (showFailure) {
          state = state.copyWith(
            notice: OrderNotice(
              OrderNoticeCode.saveFailed,
              detail: _readableMessage(result.failure!),
            ),
          );
        }
        return null;
      }
      final quote = result.requireData;
      if (quote != null) {
        state = state.copyWith(serverQuote: quote);
      }
      return quote;
    } catch (_) {
      // 页面已销毁或响应异常：预览场景静默；提交场景保留可读提示。
      if (showFailure) {
        state = state.copyWith(
          notice: const OrderNotice(
            OrderNoticeCode.saveFailed,
            detail: '价格确认失败，请稍后重试',
          ),
        );
      }
      return null;
    }
  }

  /// 确认报价请求体：带上当前选择，服务端可据此重新计算。
  Map<String, dynamic> _confirmBody() {
    final order = state.order;
    final seed = ref.read(orderDraftSeedProvider(arg));
    return <String, dynamic>{
      'activityId': _asInt(order.showId.value),
      'activityEventId': _asInt(seed.sessionId.value),
      'orderType': order.orderType.wireCode,
      'quantity': order.totalTickets.value,
      'totalAmount': state.quote.totalAmount.minorUnits,
      'payAmount': state.quote.paymentAmount.minorUnits,
    };
  }

  /// 建单请求体；金额取服务端报价，缺失时回退本地预演。
  Map<String, dynamic> _makeOrderBody(OrderServerQuote? serverQuote) {
    final order = state.order;
    final seed = ref.read(orderDraftSeedProvider(arg));
    final quote = serverQuote?.toDisplayQuote() ?? state.quote;
    final visitorName = order.visitors.isEmpty
        ? '购票人'
        : order.visitors.first.name;
    return <String, dynamic>{
      'activityId': _asInt(order.showId.value),
      'activityEventId': _asInt(seed.sessionId.value),
      'orderType': order.orderType.wireCode,
      'quantity': order.totalTickets.value,
      'totalAmount': quote.totalAmount.minorUnits,
      'payAmount': quote.paymentAmount.minorUnits,
      if (serverQuote?.quoteId != null) 'quoteId': serverQuote!.quoteId,
      'name': visitorName,
      'phone': '',
    };
  }

  /// 从建单响应里取订单号（兼容裸模型 / `data` 嵌套）。
  String? _orderNumberOf(Map<String, dynamic> body) {
    final nested = body['data'] ?? body['order'];
    final source = nested is Map<String, dynamic> ? nested : body;
    final raw = source['orderNumber'] ?? source['orderNo'] ?? source['number'];
    return raw?.toString();
  }

  /// 服务端错误码 → 用户可读文案。
  String _readableMessage(Failure failure) {
    final code = failure.code.toUpperCase();
    if (code.contains('SOLD_OUT') || code.contains('STOCK')) {
      return '票档已售罄，请重新选择';
    }
    if (code.contains('PRICE') || code.contains('QUOTE')) {
      return '价格已变化，请确认最新金额后重试';
    }
    if (code.contains('NOT_FOUND')) return '订单不存在或已失效';
    return failure.message;
  }

  static int _asInt(String raw) => int.tryParse(raw) ?? 0;

  /// 关掉提示条。
  void dismissNotice() => state = state.copyWith(notice: null);

  // ── 内部 ────────────────────────────────────────────────────────────────

  void _apply(Result<void> result) {
    if (result.isFailure) {
      state = state.copyWith(
        notice: OrderNotice(
          OrderNoticeCode.failure,
          detail: result.failure!.message,
        ),
      );
      return;
    }

    final order = state.order;
    final quote = _quoteOf(order);
    if (order.lines.isNotEmpty) {
      order.attachQuote(quote);
    }
    // 订单内容变化后旧的服务端报价立即失效。
    state = OrderConfirmState(order: order, quote: quote);
    if (_serverMode) {
      Future<void>.microtask(() => _refreshServerQuote());
    }
  }

  /// 用领域服务算一次报价。
  ///
  /// 拆单费固定 0：企划星的 `bizParam.splitOrderContext.splitOrderFee` 只在
  /// 跨仓拆单时出现，本切片没有跨仓商品。
  OrderQuote _quoteOf(TicketOrder order) => _pricing.quote(
    goodsTotal: order.goodsTotal,
    postage: order.delivery.postage,
    splitFee: Money.zero(),
    discount: order.discount,
    giftCard: order.giftCard,
    speedPack: order.speedPack,
  );

  TicketTierOffer? _offerOf(OrderDraftSeed seed, TicketTierId tierId) {
    for (final offer in seed.tiers) {
      if (offer.id == tierId) return offer;
    }
    return null;
  }

  OrderLine? _lineOf(TicketTierId tierId) {
    for (final line in state.order.lines) {
      if (line.id == tierId) return line;
    }
    return null;
  }
}

/// 确认订单页控制器 Provider（按演出 id 分族）。
final orderConfirmControllerProvider =
    NotifierProvider.family<OrderConfirmController, OrderConfirmState, String>(
      OrderConfirmController.new,
    );
