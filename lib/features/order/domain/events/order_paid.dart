import 'package:core/domain.dart';

import '../value_objects/ids.dart';
import '../value_objects/order_number.dart';
import '../value_objects/payment_channel.dart';

/// 订单已支付。
///
/// 订阅方：清空支付倒计时、刷新"我的订单"角标、发推送、
/// 触发下游出票（**另一个限界上下文** → 应走集成事件，不是这个）。
final class OrderPaid extends DomainEvent {
  const OrderPaid({
    required this.orderId,
    required this.orderNumber,
    required this.paidAmount,
    required this.channel,
    required super.occurredAt,
  });

  final TicketOrderId orderId;
  final OrderNumber orderNumber;

  /// 实付金额。
  final Money paidAmount;

  /// 支付渠道。
  final PaymentChannel channel;

  @override
  String get eventName => 'order.paid';

  @override
  String toString() =>
      'order.paid(${orderNumber.value}, ${paidAmount.format()} via ${channel.label})';
}
