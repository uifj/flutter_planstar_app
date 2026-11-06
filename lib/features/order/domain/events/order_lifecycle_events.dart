import 'package:core/domain.dart';

import '../value_objects/ids.dart';
import '../value_objects/order_number.dart';
import '../value_objects/order_status.dart';

/// 订单已关闭（用户取消 / 超时未支付 / 风控关闭）。
final class OrderCancelled extends DomainEvent {
  const OrderCancelled({
    required this.orderId,
    required this.orderNumber,
    required this.reason,
    required super.occurredAt,
  });

  final TicketOrderId orderId;
  final OrderNumber orderNumber;

  /// 关闭原因（展示文案由 UI 层按 l10n 解析）。
  final OrderCancelReason reason;

  /// 是否因为支付超时自动关闭。
  bool get isTimeout => reason == OrderCancelReason.timeout;

  @override
  String get eventName => 'order.cancelled';

  @override
  String toString() => 'order.cancelled(${orderNumber.value}, $reason)';
}

/// 订单已寄出（纸质票）。
final class OrderShipped extends DomainEvent {
  const OrderShipped({
    required this.orderId,
    required this.trackingNumber,
    required super.occurredAt,
  });

  final TicketOrderId orderId;

  /// 快递单号（自取/电子票为空）。
  final String? trackingNumber;

  @override
  String get eventName => 'order.shipped';

  @override
  String toString() =>
      'order.shipped(${orderId.value}, ${trackingNumber ?? '无单号'})';
}

/// 订单已完成（票已确认收货 / 演出已结束）。
final class OrderCompleted extends DomainEvent {
  const OrderCompleted({required this.orderId, required super.occurredAt});

  final TicketOrderId orderId;

  @override
  String get eventName => 'order.completed';

  @override
  String toString() => 'order.completed(${orderId.value})';
}

/// 订单已退款。
final class OrderRefunded extends DomainEvent {
  const OrderRefunded({
    required this.orderId,
    required this.refundAmount,
    required this.reason,
    required super.occurredAt,
  });

  final TicketOrderId orderId;

  /// 退款金额。
  final Money refundAmount;

  /// 退款原因。
  final String reason;

  @override
  String get eventName => 'order.refunded';

  @override
  String toString() =>
      'order.refunded(${orderId.value}, ${refundAmount.format()}, $reason)';
}
