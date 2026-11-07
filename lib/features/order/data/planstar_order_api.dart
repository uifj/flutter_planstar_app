import 'dart:math';

import 'package:core/domain.dart';
import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:dio/dio.dart';

import '../../../app/network/api_paths.dart';
import '../domain/aggregates/ticket_order.dart';
import '../domain/policies/purchase_limit_policy.dart';
import '../domain/services/order_quote.dart';
import '../domain/value_objects/delivery.dart';
import '../domain/value_objects/ids.dart';
import '../domain/value_objects/order_number.dart';
import '../domain/value_objects/order_status.dart';
import '../domain/value_objects/order_type.dart';
import '../domain/value_objects/payment_channel.dart';

/// 订单 API。
///
/// ## 端点
///
/// | 用途 | 方法 | 路径 |
/// |---|---|---|
/// | 订单列表 | GET | `v1/order/list` |
/// | 订单详情 | GET | `v1/order/detail` |
/// | 确认订单信息 | POST | `v1/unifiedOrder/confirm` |
/// | 下单 | POST | `v3/unifiedOrder/makeOrder` |
///
/// 支付（`v1/unifiedPay/payDetail`、`v1/unifiedPay/pay`）后端未实现，
/// 支付页仍是本地模拟流程。
///
/// `OrderService.fetchOrderList(status, orderType, pageIndex, pageSize)`
/// 对应 `GET v1/order/list?status=&orderType=&pageIndex=&pageSize=`。
final class PlanstarOrderApi {
  PlanstarOrderApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  /// 订单列表。
  Future<Result<List<TicketOrder>>> fetchOrderList({
    int? status,
    int? orderType,
    int pageIndex = 1,
    int pageSize = 20,
  }) {
    return _client.get<List<TicketOrder>>(
      ApiPaths.orderList,
      queryParameters: <String, dynamic>{
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        'status': ?status,
        'orderType': ?orderType,
      },
      envelope: const PassthroughEnvelope(),
      parser: _parseOrderList,
    );
  }

  /// 订单详情。
  Future<Result<TicketOrder?>> fetchOrderDetail(String orderNumber) {
    return _client.get<TicketOrder?>(
      ApiPaths.orderDetail,
      queryParameters: <String, dynamic>{'orderNumber': orderNumber},
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final map = _unwrapMap(data);
        return map == null ? null : _tryParseOrder(map);
      },
    );
  }

  /// 确认订单并拿到服务端报价（进入确认页/提交前调用）。
  Future<Result<OrderServerQuote?>> fetchConfirmQuote(
    Map<String, dynamic> body,
  ) {
    return _client.post<OrderServerQuote?>(
      ApiPaths.orderConfirm,
      data: body,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final map = _unwrapMap(data);
        return map == null ? null : OrderServerQuote.tryParse(map);
      },
    );
  }

  /// 下单。
  ///
  /// `Idempotency-Key` 由调用方在重试期间保持不变，避免网络抖动重复建单；
  /// 未传时这里用时间戳 + 随机数兜底（不引入 uuid 依赖）。
  Future<Result<Map<String, dynamic>>> makeOrder(
    Map<String, dynamic> body, {
    String? idempotencyKey,
  }) {
    return _client.post<Map<String, dynamic>>(
      ApiPaths.orderMake,
      data: body,
      options: Options(
        headers: <String, dynamic>{
          'Idempotency-Key': idempotencyKey ?? newIdempotencyKey(),
        },
      ),
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final map = _unwrapMap(data);
        return map ?? <String, dynamic>{};
      },
    );
  }

  /// 生成幂等键：时间戳（微秒）+ 32 位随机数。
  static String newIdempotencyKey() {
    final int stamp = DateTime.now().microsecondsSinceEpoch;
    final String random = Random().nextInt(0xFFFFFFFF).toRadixString(16);
    return 'ps-$stamp-$random';
  }

  // ---------------------------------------------------------------------------
  // DTO 映射
  // ---------------------------------------------------------------------------

  static List<TicketOrder> _parseOrderList(Object? data) {
    Object? raw = data;
    if (data is Map<String, dynamic>) {
      raw = data['data'] ?? data['list'] ?? data['records'];
      if (raw is Map<String, dynamic>) {
        raw = raw['list'] ?? raw['records'] ?? raw['items'];
      }
    }
    if (raw is! List) return const <TicketOrder>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_tryParseOrder)
        .whereType<TicketOrder>()
        .toList(growable: false);
  }

  static Map<String, dynamic>? _unwrapMap(Object? data) {
    if (data is! Map<String, dynamic>) return null;
    final inner = data['data'] ?? data['order'] ?? data['result'];
    if (inner is Map<String, dynamic>) return inner;
    return data;
  }

  static TicketOrder? _tryParseOrder(Map<String, dynamic> json) {
    final DateTime createTime =
        _parseTime(json['createTime']) ?? DateTime.now();
    final String rawNumber =
        json['orderNumber']?.toString() ?? json['orderNo']?.toString() ?? '';
    final TicketOrderId id =
        TicketOrderId.tryParse(
          json['orderId']?.toString() ?? json['id']?.toString(),
        ) ??
        TicketOrderId(rawNumber);

    final OrderNumber number = _orderNumberOf(rawNumber, createTime, id);

    final TicketOrder created = TicketOrder.create(
      id: id,
      number: number,
      showId:
          ShowId.tryParse(json['showId']?.toString()) ??
          ShowId.tryParse(json['activityId']?.toString()) ??
          const ShowId(''),
      sessionId:
          SessionId.tryParse(json['sessionId']?.toString()) ??
          const SessionId(''),
      now: createTime,
      orderType: _orderTypeOf(_intOf(json['orderType'])),
      buyType: _buyTypeOf(_intOf(json['buyType'])),
      paymentWindow: const Duration(minutes: 15),
      purchaseLimit: const PurchaseLimit.unlimited(),
      requiredVisitorCount: 0,
      delivery: DeliveryInfo.electronic(),
      limitPolicy: const PurchaseLimitPolicy(),
    ).requireData;

    final List<OrderLine> lines = _linesOf(json);
    for (final line in lines) {
      final added = created.addLine(line);
      if (added.isFailure) return null;
    }

    final int lineTotal = created.goodsTotal.minorUnits;
    final int payCents = _intOf(
      json['payAmount'] ?? json['paymentAmount'] ?? json['amount'],
    );
    final int payment = payCents > 0 ? payCents : lineTotal;
    final int total = max(lineTotal, payment);
    final OrderQuote quote = OrderQuote(
      goodsTotal: Money.fromMinorUnits(lineTotal),
      postage: Money.fromMinorUnits(total - lineTotal),
      splitFee: Money.zero(),
      discountApplied: Money.fromMinorUnits(total - payment),
      totalAmount: Money.fromMinorUnits(total),
      giftCardApplied: Money.zero(),
      speedPackCash: Money.zero(),
      speedPackBalance: Money.zero(),
      paymentAmount: Money.fromMinorUnits(payment),
    );

    final int statusCode = _intOf(
      json['status'] ?? json['orderStatus'] ?? json['orderState'] ?? 2,
    );
    final OrderStatus status = OrderStatus.fromWire(
      statusCode,
    ).getOrElse((_) => OrderStatus.awaitingPayment);

    created.acceptAgreement();
    if (status == OrderStatus.cancelled) {
      created.cancel(reason: OrderCancelReason.timeout, now: createTime);
      return created;
    }
    if (created.attachQuote(quote).isFailure) return null;
    if (created.submit(createTime).isFailure) return null;

    if (status == OrderStatus.awaitingPayment) return created;

    created.markPaid(now: createTime, channel: PaymentChannel.wechat);
    if (status == OrderStatus.awaitingTickets) return created;

    created.markShipped(now: createTime);
    if (status == OrderStatus.ticketsInTransit) return created;

    if (status == OrderStatus.completed) {
      created.complete(createTime);
      return created;
    }

    if (status == OrderStatus.refunded) {
      created.refund(
        amount: quote.paymentAmount,
        reason: json['refundReason']?.toString() ?? '服务端退款',
        now: createTime,
      );
      return created;
    }
    return created;
  }

  static List<OrderLine> _linesOf(Map<String, dynamic> json) {
    final raw =
        json['items'] ??
        json['orderItems'] ??
        json['goodsList'] ??
        json['lines'];
    if (raw is List && raw.isNotEmpty) {
      final lines = <OrderLine>[];
      for (final item in raw.whereType<Map<String, dynamic>>()) {
        final int unit = _intOf(
          item['price'] ?? item['unitPrice'] ?? item['payAmount'],
        );
        final int count = _intOf(
          item['count'] ?? item['quantity'] ?? item['num'] ?? 1,
        );
        final String name =
            item['tierName']?.toString() ??
            item['ticketName']?.toString() ??
            item['name']?.toString() ??
            item['title']?.toString() ??
            '票档';
        lines.add(
          OrderLine(
            id: TicketTierId(
              item['ticketId']?.toString() ?? 'server-${lines.length}',
            ),
            tierName: name,
            unitPrice: Money.fromMinorUnits(unit),
            quantity: Quantity(count <= 0 ? 1 : count),
          ),
        );
      }
      if (lines.isNotEmpty) return lines;
    }

    final int total = _intOf(
      json['payAmount'] ?? json['paymentAmount'] ?? json['totalAmount'],
    );
    return <OrderLine>[
      OrderLine(
        id: const TicketTierId('server-0'),
        tierName: json['title']?.toString().isNotEmpty == true
            ? json['title'].toString()
            : '票务订单',
        unitPrice: Money.fromMinorUnits(total),
        quantity: Quantity(1),
      ),
    ];
  }

  static OrderNumber _orderNumberOf(
    String raw,
    DateTime createTime,
    TicketOrderId id,
  ) {
    try {
      return OrderNumber(raw);
    } catch (_) {
      // 服务端脏数据/本地幂等重试时兜底一个合法号，避免整页崩溃。
      final int seed = id.value.isEmpty ? 0 : id.value.hashCode.abs();
      return OrderNumber.generate(date: createTime, sequence: seed % 1000000);
    }
  }

  static OrderType _orderTypeOf(int wire) {
    for (final type in OrderType.values) {
      if (type.wireCode == wire) return type;
    }
    return OrderType.ticket;
  }

  static BuyType _buyTypeOf(int wire) {
    for (final type in BuyType.values) {
      if (type.wireCode == wire) return type;
    }
    return BuyType.normal;
  }

  static int _intOf(Object? raw) {
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }

  static DateTime? _parseTime(Object? raw) {
    if (raw is num) return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    return DateTime.tryParse(raw?.toString() ?? '');
  }
}
