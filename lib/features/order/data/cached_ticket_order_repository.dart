import 'package:core/result.dart';

import '../domain/domain.dart';
import 'local_order_store.dart';

/// 数据新鲜度标记：远端失败并回退本地快照时置为 `true`。
abstract interface class OrderStaleness {
  bool get isStale;
}

/// 远端优先 + 本地快照兜底的订单仓储。
///
/// 读取：远端成功 → 刷新本地快照；远端失败 → 回退本地并标记 [isStale]。
/// 写入：远端成功后写本地（保存成功才由调用方分发领域事件）。
final class CachedTicketOrderRepository
    implements TicketOrderRepository, OrderStaleness {
  CachedTicketOrderRepository({
    required TicketOrderRepository remote,
    required LocalOrderStore local,
  }) : _remote = remote,
       _local = local;

  final TicketOrderRepository _remote;
  final LocalOrderStore _local;
  bool _isStale = false;

  @override
  bool get isStale => _isStale;

  @override
  Future<Result<List<TicketOrder>>> findAll() async {
    final Result<List<TicketOrder>> remote = await _remote.findAll();
    if (remote.isSuccess) {
      _isStale = false;
      try {
        await _local.saveAll(remote.requireData);
      } catch (_) {
        // 快照写失败不影响线上数据展示。
      }
      return remote;
    }

    final List<TicketOrder> cached = await _local.load();
    _isStale = true;
    if (cached.isNotEmpty) return Success<List<TicketOrder>>(cached);
    return Fail<List<TicketOrder>>(remote.failure!);
  }

  @override
  Future<Result<TicketOrder?>> findById(TicketOrderId id) async {
    final Result<TicketOrder?> remote = await _remote.findById(id);
    if (remote.isSuccess) {
      _isStale = false;
      final TicketOrder? order = remote.requireData;
      if (order != null) {
        try {
          await _local.upsert(order);
        } catch (_) {
          // 快照写失败不影响线上数据展示。
        }
      }
      return remote;
    }

    final List<TicketOrder> cached = await _local.load();
    _isStale = true;
    for (final TicketOrder order in cached) {
      if (order.id.value == id.value || order.number.value == id.value) {
        return Success<TicketOrder?>(order);
      }
    }
    return Fail<TicketOrder?>(remote.failure!);
  }

  @override
  Future<Result<void>> save(TicketOrder order) async {
    final Result<void> result = await _remote.save(order);
    if (result.isFailure) return result;

    try {
      await _local.upsert(order);
    } catch (_) {
      // 线下单已成功，本地快照失败不回滚线上保存。
    }
    _isStale = false;
    return result;
  }
}
