import 'package:core/network.dart';
import 'package:core/result.dart';

import '../domain/aggregates/ticket_order.dart';
import '../domain/policies/purchase_limit_policy.dart';
import '../domain/value_objects/delivery.dart';
import '../domain/value_objects/ids.dart';
import '../domain/value_objects/order_number.dart';
import '../domain/value_objects/order_type.dart';

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
/// | 支付详情 | GET | `v1/unifiedPay/payDetail` |
/// | 支付 | POST | `v1/unifiedPay/pay` |
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
      'v1/order/list',
      queryParameters: <String, dynamic>{
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        'status': ?status,
        'orderType': ?orderType,
      },
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is Map<String, dynamic>) {
          final inner = data['data'] ?? data['list'];
          if (inner is List) {
            return inner
                .whereType<Map<String, dynamic>>()
                .map(_parseOrder)
                .toList(growable: false);
          }
        }
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(_parseOrder)
              .toList(growable: false);
        }
        return const <TicketOrder>[];
      },
    );
  }

  /// 订单详情。
  Future<Result<TicketOrder?>> fetchOrderDetail(String orderNumber) {
    return _client.get<TicketOrder?>(
      'v1/order/detail',
      queryParameters: <String, dynamic>{'orderNumber': orderNumber},
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is! Map<String, dynamic>) return null;
        return _parseOrder(data);
      },
    );
  }

  /// 确认订单信息（进入确认页前的金额试算）。
  Future<Result<Map<String, dynamic>>> fetchConfirmInfo(
    Map<String, dynamic> body,
  ) {
    return _client.post<Map<String, dynamic>>(
      'v1/unifiedOrder/confirm',
      data: body,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is Map<String, dynamic>) return data;
        return <String, dynamic>{};
      },
    );
  }

  /// 下单。
  Future<Result<Map<String, dynamic>>> makeOrder(Map<String, dynamic> body) {
    return _client.post<Map<String, dynamic>>(
      'v3/unifiedOrder/makeOrder',
      data: body,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is Map<String, dynamic>) return data;
        return <String, dynamic>{};
      },
    );
  }

  static TicketOrder _parseOrder(Map<String, dynamic> json) {
    // 订单 JSON 映射到 TicketOrder。
    //
    // TicketOrder.create() 返回 Result<TicketOrder>；
    // 这里用 requireData 解包（如果校验失败会抛 StateError，
    // 被 ApiClient 的 try/catch 收敛成 Fail）。
    final id =
        TicketOrderId.tryParse(
          json['orderId']?.toString() ?? json['id']?.toString(),
        ) ??
        const TicketOrderId('');
    final number = OrderNumber(json['orderNumber']?.toString() ?? '');
    final showId =
        ShowId.tryParse(json['showId']?.toString()) ?? const ShowId('');
    final sessionId =
        SessionId.tryParse(json['sessionId']?.toString()) ??
        const SessionId('');
    final createTime =
        DateTime.tryParse(json['createTime']?.toString() ?? '') ??
        DateTime.now();

    return TicketOrder.create(
      id: id,
      number: number,
      showId: showId,
      sessionId: sessionId,
      now: createTime,
      orderType: OrderType.values.firstWhere(
        (t) => t.wireCode == (json['orderType'] ?? 1),
        orElse: () => OrderType.ticket,
      ),
      buyType: BuyType.values.firstWhere(
        (b) => b.wireCode == (json['buyType'] ?? 1),
        orElse: () => BuyType.normal,
      ),
      paymentWindow: const Duration(minutes: 15),
      purchaseLimit: const PurchaseLimit.unlimited(),
      requiredVisitorCount: 0,
      delivery: DeliveryInfo.electronic(),
      limitPolicy: const PurchaseLimitPolicy(),
    ).requireData;
  }
}
