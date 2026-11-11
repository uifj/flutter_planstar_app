import 'package:core/domain.dart';

import '../value_objects/ids.dart';
import '../value_objects/order_number.dart';

/// 订单已提交（服务端已创建订单，进入待支付）。
///
/// 订阅方：埋点（建单点击事件）、
/// 支付倒计时启动、订单列表刷新。
///
/// ⚠ 命名是过去式：`OrderPlaced` 而不是 `PlaceOrder`——事件是**事实**，
/// 不是命令。命令会让人误以为可以"取消"它。
final class OrderPlaced extends DomainEvent {
  const OrderPlaced({
    required this.orderId,
    required this.orderNumber,
    required this.showId,
    required this.totalAmount,
    required this.paymentAmount,
    required this.requiresPayment,
    required super.occurredAt,
  });

  final TicketOrderId orderId;
  final OrderNumber orderNumber;
  final ShowId showId;

  /// 订单原价。
  final Money totalAmount;

  /// 用户实付。
  final Money paymentAmount;

  /// 是否还需要在线支付（实付 0 元时可以直接成单）。
  final bool requiresPayment;

  @override
  String get eventName => 'order.placed';

  @override
  String toString() =>
      'order.placed(${orderNumber.value}, 实付 ${paymentAmount.format()})';
}
