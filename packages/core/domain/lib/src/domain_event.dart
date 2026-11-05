/// `DomainEvent`：**已经发生的、领域内有意义的事**的过去式记录。
///
/// 三条约定：
/// 1. **命名用过去式**（`OrderPlaced` 而不是 `PlaceOrder`）——事件是事实，不是命令。
/// 2. **事件只描述发生了什么**，不描述"该做什么"。副作用由订阅方决定。
/// 3. **事件在同一事务内、同一个限界上下文内**。跨上下文请用集成事件（走消息总线），
///    否则会出现"事件发出了、事务回滚了"的幽灵通知。
library;

/// 领域事件基类。
///
/// 不用 `sealed`：各 feature 在自己的包里定义事件，不能要求一处穷举。
abstract class DomainEvent {
  const DomainEvent({required this.occurredAt});

  /// 事件发生时刻（领域时间，由聚合显式传入，便于测试重放）。
  final DateTime occurredAt;

  /// 稳定的事件名，用于日志 / 埋点 / 消息头。默认取运行时类型名。
  ///
  /// 覆写它可以避免"类改名 → 埋点断档"。
  String get eventName => runtimeType.toString();

  @override
  String toString() => '$eventName@${occurredAt.toIso8601String()}';
}
