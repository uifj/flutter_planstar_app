/// `AggregateRoot`：一致性边界，也是**外部访问聚合的唯一入口**。
///
/// 一个聚合 = 1 个根实体 + 0~3 个子实体/值对象。规则：
/// - 聚合内部的不变量由根在**同一个事务**里保证；
/// - 外部代码只能拿到根，子实体不单独加载、不单独保存；
/// - 跨聚合只靠 id 引用，一致性是最终一致（用领域事件推动）。
library;

import 'domain_event.dart';
import 'entity.dart';

/// 聚合根。
///
/// 事件收集器是**实例级**的（不是 static）：企划星 Android 侧用全 App 共享的静态
/// `HashMap`（`PNLogBean`）收集埋点，两个页面同时操作会互相污染，测试也无法并行。
abstract class AggregateRoot<TId> extends Entity<TId> {
  AggregateRoot(super.id);

  final List<DomainEvent> _domainEvents = <DomainEvent>[];

  /// 尚未被取走的领域事件（只读视图）。
  List<DomainEvent> get domainEvents => List<DomainEvent>.unmodifiable(_domainEvents);

  /// 是否攒了待分发的事件。
  bool get hasDomainEvents => _domainEvents.isNotEmpty;

  /// 记录一个事件。**只能在聚合内部**（状态已经改完之后）调用。
  ///
  /// 只在**跨聚合/跨层**有意义时才发事件；聚合内部的计算（比如改数量后重算小计）
  /// 直接调私有方法，不要发事件——那是"用事件写 if"的反模式。
  void raiseDomainEvent(DomainEvent event) => _domainEvents.add(event);

  /// 取走并清空事件。
  ///
  /// 由仓储/工作单元在**保存成功后**调用，避免"事件发了但事务回滚"。
  List<DomainEvent> pullDomainEvents() {
    if (_domainEvents.isEmpty) return const <DomainEvent>[];
    final drained = List<DomainEvent>.of(_domainEvents);
    _domainEvents.clear();
    return drained;
  }
}
