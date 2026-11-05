/// 领域层原语包。
///
/// 这一层**零 Flutter import**：可以被纯 Dart 单测、CLI 工具、后台任务复用。
/// 依赖方向只能是 `feature → core_domain → core_result`，反向依赖一律拒绝。
///
/// 与 DDD 战术模式的对应：
/// | 概念 | 类型 |
/// |---|---|
/// | 身份 | [Entity] |
/// | 一致性边界 | [AggregateRoot] |
/// | 值对象 | [ValueObject]、[Money]、[Quantity] |
/// | 领域事件 | [DomainEvent]、[DomainEventBus] |
/// | 强类型 id | [IdGenerator]（配合 `extension type XxxId(String)`） |
library;

export 'src/aggregate_root.dart';
export 'src/domain_event.dart';
export 'src/domain_event_bus.dart';
export 'src/entity.dart';
export 'src/id_generator.dart';
export 'src/money.dart';
export 'src/quantity.dart';
export 'src/value_object.dart';
