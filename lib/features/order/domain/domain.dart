/// 订单领域层的公开出口。
///
/// 外层（application / presentation）只 import 这一个文件，不直接摸 `src` 级别的路径——
/// 这样重构目录时改动只发生在这里。
library;

export 'aggregates/ticket_order.dart';
export 'events/order_lifecycle_events.dart';
export 'events/order_paid.dart';
export 'events/order_placed.dart';
export 'policies/purchase_limit_policy.dart';
export 'repositories/ticket_order_repository.dart';
export 'services/order_pricing_service.dart';
export 'services/order_quote.dart';
export 'value_objects/delivery.dart';
export 'value_objects/discount.dart';
export 'value_objects/ids.dart';
export 'value_objects/order_number.dart';
export 'value_objects/order_status.dart';
export 'value_objects/order_type.dart';
export 'value_objects/payment_channel.dart';
export 'value_objects/speed_pack.dart';
export 'value_objects/visitor.dart';
