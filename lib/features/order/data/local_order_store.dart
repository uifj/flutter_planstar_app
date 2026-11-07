import 'dart:async';
import 'dart:convert';

import 'package:core/storage.dart';

import '../domain/domain.dart';
import 'planstar_order_api.dart';

/// 订单本地快照（`shared_preferences` 等 [KeyValueStore] 实现均可）。
///
/// - 按用户 id 分区：换账号不会看到上一个账号的订单；
/// - 带 schema 版本号：结构变化时旧快照直接失效，走远端重新拉取；
/// - 写入串行化：连续多次 `saveAll` 不会互相覆盖；
/// - 读取失败安全降级为空列表。
final class LocalOrderStore {
  LocalOrderStore({required KeyValueStore store, required String userId})
    : _store = store,
      _userId = userId;

  /// 当前快照结构版本。字段变化时递增，旧快照自动作废。
  static const int schemaVersion = 1;

  final KeyValueStore _store;
  final String _userId;

  /// 串行写队列：所有写操作按提交顺序排队执行。
  Future<void> _writeQueue = Future<void>.value();

  String get storageKey => 'orders:v$schemaVersion:$_userId';

  /// 读取当前用户的订单快照。任何异常都降级为"没有缓存"。
  Future<List<TicketOrder>> load() async {
    try {
      final String? raw = await _store.read(storageKey);
      if (raw == null || raw.isEmpty) return const <TicketOrder>[];
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) return const <TicketOrder>[];
      final Object? version = decoded['schemaVersion'];
      if (version is! num || version.toInt() != schemaVersion) {
        return const <TicketOrder>[];
      }
      final Object? rows = decoded['orders'];
      if (rows is! List<Object?>) return const <TicketOrder>[];

      final List<TicketOrder> orders = <TicketOrder>[];
      for (final Object? row in rows) {
        if (row is! Map<Object?, Object?>) continue;
        final TicketOrder? order = PlanstarOrderApi.parseOrderJson(
          row.map(
            (Object? key, Object? value) => MapEntry<String, dynamic>('$key', value),
          ),
        );
        if (order != null) orders.add(order);
      }
      orders.sort((TicketOrder a, TicketOrder b) {
        final DateTime left = a.submittedAt ?? a.placedAt;
        final DateTime right = b.submittedAt ?? b.placedAt;
        return right.compareTo(left);
      });
      return orders;
    } catch (_) {
      return const <TicketOrder>[];
    }
  }

  /// 覆盖写入全部订单。
  Future<void> saveAll(List<TicketOrder> orders) {
    final List<TicketOrder> snapshot = List<TicketOrder>.of(orders);
    return _enqueue(() => _write(snapshot));
  }

  /// 新增或更新一张订单。
  Future<void> upsert(TicketOrder order) {
    return _enqueue(() async {
      final List<TicketOrder> current = await load();
      final Map<String, TicketOrder> merged = <String, TicketOrder>{
        for (final TicketOrder item in current) item.id.value: item,
      };
      merged[order.id.value] = order;
      final List<TicketOrder> next = merged.values.toList(growable: false);
      next.sort((TicketOrder a, TicketOrder b) {
        final DateTime left = a.submittedAt ?? a.placedAt;
        final DateTime right = b.submittedAt ?? b.placedAt;
        return right.compareTo(left);
      });
      await _write(next);
    });
  }

  Future<void> _write(List<TicketOrder> orders) {
    final String payload = jsonEncode(<String, Object?>{
      'schemaVersion': schemaVersion,
      'orders': orders
          .where((TicketOrder order) => order.status != OrderStatus.draft)
          .map(PlanstarOrderApi.orderToJson)
          .toList(growable: false),
    });
    return _store.write(storageKey, payload);
  }

  /// 排队执行写任务；前一次失败不会阻断后续任务。
  Future<void> _enqueue(Future<void> Function() task) {
    final Future<void> next = _writeQueue.then<void>(
      (_) => task(),
      onError: (Object error, StackTrace stackTrace) => task(),
    );
    _writeQueue = next.catchError((Object _) {});
    return next;
  }
}
