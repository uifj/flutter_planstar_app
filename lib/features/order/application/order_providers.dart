import 'package:core/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/in_memory_order_number_sequence.dart';
import '../data/in_memory_ticket_order_repository.dart';
import '../domain/domain.dart';
import 'order_event_recorder.dart';
import 'order_history_seed.dart';

/// 金额计算领域服务（无状态，可以全局共享一个实例）。
final orderPricingServiceProvider = Provider<OrderPricingService>(
  (ref) => const OrderPricingService(),
);

/// 订单仓储（端口 → 内存适配器）。
///
/// 内存适配器在构造时灌入 6 张演示订单（覆盖全部业务状态），
/// 否则"我的订单"第一次打开就是空态，看不出列表能力。
///
/// 换真实实现时只改这一行：`ref.watch(apiClientProvider)` 构造
/// `HttpTicketOrderRepository`，种子数据一并删掉。
final ticketOrderRepositoryProvider = Provider<TicketOrderRepository>((ref) {
  return InMemoryTicketOrderRepository()
    ..seed(
      buildDemoOrderHistory(pricing: ref.watch(orderPricingServiceProvider)),
    );
});

/// 订单号序列。
final orderNumberSequenceProvider = Provider<OrderNumberSequence>(
  (ref) => InMemoryOrderNumberSequence(),
);

/// 领域事件记录器（演示订阅方）。
final orderEventRecorderProvider = Provider<OrderEventRecorder>(
  (ref) => OrderEventRecorder(),
);

/// 领域事件总线 + 订阅关系。
///
/// 注意 `onHandlerError`：埋点/日志失败**不该**让下单失败，所以这里把异常记录掉
/// 并继续。测试里则用默认的"冒泡"行为，避免静默失败被忽略。
final domainEventBusProvider = Provider<DomainEventBus>((ref) {
  final recorder = ref.watch(orderEventRecorderProvider);
  final bus = DomainEventBus(
    onHandlerError: (error, stackTrace, event) {
      debugPrint('[domain-event] ${event.eventName} 的处理器失败：$error');
    },
  );

  final unsubscribers = <void Function()>[
    bus.on<OrderPlaced>(recorder.record),
    bus.on<OrderPaid>(recorder.record),
    bus.on<OrderShipped>(recorder.record),
    bus.on<OrderCompleted>(recorder.record),
    bus.on<OrderCancelled>(recorder.record),
    bus.on<OrderRefunded>(recorder.record),
  ];

  ref.onDispose(() {
    for (final unsubscribe in unsubscribers) {
      unsubscribe();
    }
  });

  return bus;
});
