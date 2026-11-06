import 'package:core/domain.dart';

/// 领域事件记录器 —— 演示"聚合不关心副作用"。
///
/// 真实项目里，`OrderPlaced` 的订阅方会是：
/// - 埋点（企划星 `PNLogger.clickOrderMakeorder` / `enterOrder`）；
/// - 支付倒计时启动；
/// - 订单列表 / 角标刷新；
/// - 广告归因回传（`PNADEventManager`）。
///
/// 这些订阅方现在都不在聚合里，加一个订阅方不需要改 `TicketOrder` 一行代码——
/// 这就是"事件解耦"的实际收益。
final class OrderEventRecorder {
  final List<DomainEvent> _events = <DomainEvent>[];

  /// 记录到的事件（按发生顺序）。
  List<DomainEvent> get events => List<DomainEvent>.unmodifiable(_events);

  /// 事件名序列，便于断言。
  List<String> get eventNames =>
      _events.map((event) => event.eventName).toList(growable: false);

  /// 记录一个事件。
  void record(DomainEvent event) => _events.add(event);

  /// 清空。
  void clear() => _events.clear();
}
