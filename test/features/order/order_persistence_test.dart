import 'package:core/result.dart';
import 'package:core/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planstar/app/network/data_source_policy.dart';
import 'package:planstar/app/network/network_providers.dart';
import 'package:planstar/features/order/application/order_providers.dart';
import 'package:planstar/features/order/data/cached_ticket_order_repository.dart';
import 'package:planstar/features/order/data/local_order_store.dart';
import 'package:planstar/features/order/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/order_fixture.dart';

class _FailingOrderRepository implements TicketOrderRepository {
  @override
  Future<Result<List<TicketOrder>>> findAll() async => const Fail(
    Failure(code: 'NETWORK_DOWN', message: '断网', type: FailureType.network),
  );

  @override
  Future<Result<TicketOrder?>> findById(TicketOrderId id) async => const Fail(
    Failure(code: 'NETWORK_DOWN', message: '断网', type: FailureType.network),
  );

  @override
  Future<Result<void>> save(TicketOrder order) async => const Fail(
    Failure(code: 'NETWORK_DOWN', message: '断网', type: FailureType.network),
  );
}

class _RecordingOrderRepository implements TicketOrderRepository {
  final List<TicketOrder> saved = <TicketOrder>[];

  @override
  Future<Result<List<TicketOrder>>> findAll() async =>
      Success<List<TicketOrder>>(List<TicketOrder>.of(saved));

  @override
  Future<Result<TicketOrder?>> findById(TicketOrderId id) async {
    for (final order in saved) {
      if (order.id.value == id.value) return Success<TicketOrder?>(order);
    }
    return const Success<TicketOrder?>(null);
  }

  @override
  Future<Result<void>> save(TicketOrder order) async {
    saved.add(order);
    return const Success<void>(null);
  }
}

void main() {
  const DataSourcePolicy remotePolicy = DataSourcePolicy(isDemo: false);

  test('新建 ProviderContainer 读取同一 store 实例，订单仍然存在', () async {
    final KeyValueStore sharedStore = MemoryKeyValueStore();
    final TicketOrder order = buildSubmittedOrder();

    final first = ProviderContainer(
      overrides: <Override>[
        dataSourcePolicyProvider.overrideWithValue(remotePolicy),
        localOrderStoreProvider.overrideWithValue(
          LocalOrderStore(store: sharedStore, userId: 'anonymous'),
        ),
      ],
    );
    await first.read(localOrderStoreProvider).saveAll(<TicketOrder>[order]);
    first.dispose();

    // 模拟 App 重启：新容器、新 store 实例，但底层 KeyValueStore 相同。
    final second = ProviderContainer(
      overrides: <Override>[
        dataSourcePolicyProvider.overrideWithValue(remotePolicy),
        localOrderStoreProvider.overrideWithValue(
          LocalOrderStore(store: sharedStore, userId: 'anonymous'),
        ),
      ],
    );
    addTearDown(second.dispose);

    final List<TicketOrder> restored = await second
        .read(localOrderStoreProvider)
        .load();
    expect(restored, hasLength(1));
    expect(restored.single.number.value, 'PN20261107000001');
    expect(restored.single.status, OrderStatus.awaitingPayment);
  });

  test('远端失败时回退本地缓存并标记陈旧', () async {
    final KeyValueStore sharedStore = MemoryKeyValueStore();
    final LocalOrderStore local = LocalOrderStore(
      store: sharedStore,
      userId: 'anonymous',
    );
    final TicketOrder order = buildSubmittedOrder();

    final seeding = CachedTicketOrderRepository(
      remote: _RecordingOrderRepository(),
      local: local,
    );
    final Result<void> saved = await seeding.save(order);
    expect(saved.isSuccess, isTrue);

    final repository = CachedTicketOrderRepository(
      remote: _FailingOrderRepository(),
      local: local,
    );
    final Result<List<TicketOrder>> result = await repository.findAll();

    expect(result.isSuccess, isTrue);
    expect(result.requireData, hasLength(1));
    expect(result.requireData.single.id.value, '1001');
    expect(repository.isStale, isTrue);
  });

  test('远端恢复后清除陈旧标记并刷新快照', () async {
    final KeyValueStore sharedStore = MemoryKeyValueStore();
    final LocalOrderStore local = LocalOrderStore(
      store: sharedStore,
      userId: 'anonymous',
    );
    final TicketOrder cached = buildSubmittedOrder();
    await local.saveAll(<TicketOrder>[cached]);

    final stale = CachedTicketOrderRepository(
      remote: _FailingOrderRepository(),
      local: local,
    );
    await stale.findAll();
    expect(stale.isStale, isTrue);

    final freshOrder = buildSubmittedOrder(orderNumber: 'PN20261107000002');
    final repository = CachedTicketOrderRepository(
      remote: _RecordingOrderRepository()..saved.add(freshOrder),
      local: local,
    );
    final result = await repository.findAll();
    expect(result.requireData.single.number.value, 'PN20261107000002');
    expect(repository.isStale, isFalse);
    expect(await local.load(), hasLength(1));
  });
}
