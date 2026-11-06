import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_proxy_buy.dart';
import 'proxy_buy.dart';

/// 代抢信息 Provider。
/// 对齐 Android `ActivityBean.proxyBuyInfo`。
final proxyBuyInfoProvider = Provider<ProxyBuyInfo>(
  (ref) => DemoProxyBuy.info,
);

/// 代抢订单列表 Provider。
/// 对齐 Android `v1/proxyBuyOrder/myOrders`（模拟）。
final proxyBuyOrdersProvider = Provider<List<ProxyBuyOrder>>(
  (ref) => DemoProxyBuy.orders,
);

/// 代抢订单详情。
final proxyBuyOrderByIdProvider =
    Provider.family<ProxyBuyOrder?, int>((ref, id) {
  final orders = ref.watch(proxyBuyOrdersProvider);
  return orders.where((ProxyBuyOrder o) => o.id == id).firstOrNull;
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
/// 对齐 Android `ProxyBuyConfirmActivity` → `OrderService.orderPinTuan`（或 unifiedOrder）：
/// - 提交代抢订单（模拟）。
class ProxyBuySubmitController extends Notifier<ProxyBuySubmitState> {
  @override
  ProxyBuySubmitState build() => const ProxyBuySubmitState.initial();

  Future<void> submit({
    required Money ticketPrice,
    required int quantity,
    required ProxyBuyDeadline deadline,
    required ProxyBuyInfo info,
  }) async {
    state = const ProxyBuySubmitState.submitting();

    await Future<void>.delayed(const Duration(milliseconds: 800));

    final orderNumber =
        'PB${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    state = ProxyBuySubmitState.success(orderNumber);
  }

  void reset() => state = const ProxyBuySubmitState.initial();
}

final proxyBuySubmitControllerProvider =
    NotifierProvider<ProxyBuySubmitController, ProxyBuySubmitState>(
  ProxyBuySubmitController.new,
);
