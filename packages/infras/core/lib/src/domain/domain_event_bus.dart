/// 领域事件的分发：聚合只负责"记下来"，谁听、听完做什么由订阅方决定。
///
/// 这样聚合不用知道埋点、推送、读模型的存在——企划星 Android 侧的
/// `OrderConfirmActivity.order()` 把下单、埋点、跳转、toast 全写在一个 200 行方法里，
/// 就是这个耦合的后果。
library;

import 'dart:async';

import 'domain_event.dart';

/// 事件处理器。
typedef DomainEventHandler<T extends DomainEvent> = FutureOr<void> Function(T event);

/// 分发端口。应用层依赖这个接口，测试里可以换成记录器。
abstract interface class DomainEventDispatcher {
  /// 按注册顺序分发。[events] 为空时应当是零开销。
  Future<void> dispatch(Iterable<DomainEvent> events);
}

/// 进程内实现：按**运行时类型**精确匹配处理器。
///
/// 为什么按 `runtimeType` 精确匹配而不是 `is`：事件类有继承时，`is` 会让
/// "监听 `OrderPlaced`" 的处理器收到所有子类事件，订阅关系变得不可推理。
/// 需要"监听一族事件"时，注册多个处理器，或用同一个基类各自定义事件。
final class DomainEventBus implements DomainEventDispatcher {
  DomainEventBus({this.onHandlerError});

  /// 处理器抛异常时的出口。为 `null` 时异常向上冒泡（测试里默认如此，避免静默失败）。
  ///
  /// 应用侧应传入一个"记录并继续"的实现：埋点失败不该让下单失败。
  final void Function(Object error, StackTrace stackTrace, DomainEvent event)? onHandlerError;

  final Map<Type, List<Future<void> Function(DomainEvent)>> _handlers =
      <Type, List<Future<void> Function(DomainEvent)>>{};

  /// 注册处理器。返回取消注册的函数（便于 Provider 释放时清理）。
  void Function() on<T extends DomainEvent>(DomainEventHandler<T> handler) {
    final list = _handlers.putIfAbsent(
      T,
      () => <Future<void> Function(DomainEvent)>[],
    );
    // 包一层 async：处理器可能是同步的，统一成 Future 才能 await 串行执行。
    Future<void> registered(DomainEvent event) async => handler(event as T);
    list.add(registered);
    return () => list.remove(registered);
  }

  /// 是否有处理器关心 [event]。
  bool hasHandlersFor(DomainEvent event) => (_handlers[event.runtimeType] ?? const []).isNotEmpty;

  @override
  Future<void> dispatch(Iterable<DomainEvent> events) async {
    for (final event in events) {
      final handlers = _handlers[event.runtimeType];
      if (handlers == null || handlers.isEmpty) continue;
      // 复制一份：处理器内部可能注册/注销处理器。
      for (final handler in List<Future<void> Function(DomainEvent)>.of(handlers)) {
        try {
          await handler(event);
        } catch (error, stackTrace) {
          final onError = onHandlerError;
          if (onError == null) rethrow;
          onError(error, stackTrace, event);
        }
      }
    }
  }
}
