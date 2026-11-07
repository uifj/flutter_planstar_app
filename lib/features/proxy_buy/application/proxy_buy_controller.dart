import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/demo_proxy_buy_repository.dart';
import '../data/remote_proxy_buy_repository.dart';
import '../domain/proxy_buy.dart';
import '../domain/repositories/proxy_buy_repository.dart';

/// 代抢仓储：演示 / 真实数据源由全局 [DataSourcePolicy] 决定。
final proxyBuyRepositoryProvider = Provider<ProxyBuyRepository>((ref) {
  final policy = ref.watch(dataSourcePolicyProvider);
  return policy.pick(
    demo: DemoProxyBuyRepository.new,
    remote: () =>
        RemoteProxyBuyRepository(client: ref.watch(apiClientProvider)),
  );
});

/// 代抢页视图状态：页面只读这里，不再自己取数或算价。
final class ProxyBuyPageState {
  const ProxyBuyPageState({required this.info, required this.orders});

  final ProxyBuyInfo info;
  final List<ProxyBuyOrder> orders;

  ProxyBuyOrder? orderById(int id) =>
      orders.where((ProxyBuyOrder order) => order.id == id).firstOrNull;
}

/// 代抢页 Controller。
class ProxyBuyController extends AsyncNotifier<ProxyBuyPageState> {
  @override
  Future<ProxyBuyPageState> build() async {
    final repository = ref.watch(proxyBuyRepositoryProvider);
    final info = (await repository.fetchInfo()).fold(
      onSuccess: (ProxyBuyInfo value) => value,
      onFailure: (failure) => throw failure,
    );
    final orders = (await repository.fetchOrders()).fold(
      onSuccess: (List<ProxyBuyOrder> value) => value,
      onFailure: (failure) => throw failure,
    );
    return ProxyBuyPageState(info: info, orders: orders);
  }
}

final proxyBuyControllerProvider =
    AsyncNotifierProvider<ProxyBuyController, ProxyBuyPageState>(
      ProxyBuyController.new,
    );

/// 单条代抢订单（按 ID）。
final proxyBuyOrderByIdProvider =
    Provider.family<AsyncValue<ProxyBuyOrder?>, int>((ref, id) {
      return ref
          .watch(proxyBuyControllerProvider)
          .whenData((ProxyBuyPageState page) => page.orderById(id));
    });

/// 代抢提交状态。
sealed class ProxyBuySubmitState {
  const ProxyBuySubmitState();
  const factory ProxyBuySubmitState.initial() = _PBInitial;
  const factory ProxyBuySubmitState.submitting() = _PBSubmitting;
  const factory ProxyBuySubmitState.success(String orderNumber) = _PBSuccess;
  const factory ProxyBuySubmitState.error(String message) = _PBError;
}

class _PBInitial extends ProxyBuySubmitState {
  const _PBInitial();
}

class _PBSubmitting extends ProxyBuySubmitState {
  const _PBSubmitting();
}

class _PBSuccess extends ProxyBuySubmitState {
  const _PBSuccess(this.orderNumber);
  final String orderNumber;
}

class _PBError extends ProxyBuySubmitState {
  const _PBError(this.message);
  final String message;
}

/// 代抢提交 Controller。
///
/// 提交动作与订单号生成都在数据层；页面只转发事件。
class ProxyBuySubmitController extends Notifier<ProxyBuySubmitState> {
  @override
  ProxyBuySubmitState build() => const ProxyBuySubmitState.initial();

  Future<void> submit({
    required ProxyBuyInfo info,
    required int quantity,
    required ProxyBuyDeadline deadline,
    required Money ticketPrice,
  }) async {
    state = const ProxyBuySubmitState.submitting();
    final result = await ref
        .read(proxyBuyRepositoryProvider)
        .submit(
          info: info,
          ticketPrice: ticketPrice,
          quantity: quantity,
          deadline: deadline,
        );
    state = result.fold(
      onSuccess: ProxyBuySubmitState.success,
      onFailure: (failure) => ProxyBuySubmitState.error(failure.message),
    );
  }

  void reset() => state = const ProxyBuySubmitState.initial();
}

final proxyBuySubmitControllerProvider =
    NotifierProvider<ProxyBuySubmitController, ProxyBuySubmitState>(
      ProxyBuySubmitController.new,
    );
