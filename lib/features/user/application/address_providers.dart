import 'package:core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/demo_address.dart';
import '../data/planstar_user_api.dart';
import '../domain/shipping_address.dart';
import 'user_api_providers.dart';

/// 收货地址列表。
///
/// demo 模式读本地演示数据；真实模式走 `v1/myaddress` 系列接口。
/// 三个动作（增 / 删 / 设默认）都返回可读错误文案，页面负责弹提示。
class AddressListController extends AsyncNotifier<List<ShippingAddress>> {
  PlanstarUserApi get _api => ref.read(planstarUserApiProvider);

  bool get _demo => ref.read(useDemoProvider);

  @override
  Future<List<ShippingAddress>> build() async {
    if (ref.watch(useDemoProvider)) return buildDemoAddresses();
    return _load();
  }

  Future<List<ShippingAddress>> _load() async {
    final result = await _api.fetchAddresses();
    return result.fold(
      onSuccess: (addresses) => addresses,
      onFailure: (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  /// 新增。失败返回提示文案，成功返回 null。
  Future<String?> add({
    required String name,
    required String mobile,
    required String region,
    required String detail,
  }) async {
    if (_demo) {
      final current = state.valueOrNull ?? const <ShippingAddress>[];
      final bool wasEmpty = current.isEmpty;
      final ShippingAddress address = ShippingAddress(
        id: 'addr-${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        mobile: mobile.trim(),
        region: region.trim(),
        detail: detail.trim(),
        isDefault: wasEmpty,
      );
      state = AsyncValue.data(<ShippingAddress>[...current, address]);
      return null;
    }

    final result = await _api.addAddress(
      ShippingAddress(
        id: '',
        name: name.trim(),
        mobile: mobile.trim(),
        region: region.trim(),
        detail: detail.trim(),
      ),
    );
    if (result.isFailure) return result.failure!.message;
    await refresh();
    return null;
  }

  /// 编辑（后端未提供 PUT，保留本地修改，重新进入页面后以服务端为准）。
  Future<String?> edit({
    required String id,
    required String name,
    required String mobile,
    required String region,
    required String detail,
  }) async {
    final current = state.valueOrNull ?? const <ShippingAddress>[];
    state = AsyncValue.data(<ShippingAddress>[
      for (final ShippingAddress item in current)
        if (item.id == id)
          ShippingAddress(
            id: item.id,
            name: name.trim(),
            mobile: mobile.trim(),
            region: region.trim(),
            detail: detail.trim(),
            isDefault: item.isDefault,
          )
        else
          item,
    ]);
    return null;
  }

  /// 删除；失败返回提示文案。
  Future<String?> remove(String id) async {
    if (_demo) {
      final current = state.valueOrNull ?? const <ShippingAddress>[];
      final List<ShippingAddress> next = current
          .where((ShippingAddress item) => item.id != id)
          .toList();
      final bool removedDefault = current.any(
        (ShippingAddress item) => item.id == id && item.isDefault,
      );
      if (removedDefault && next.isNotEmpty) {
        next[0] = next[0].copyWith(isDefault: true);
      }
      state = AsyncValue.data(next);
      return null;
    }

    final result = await _api.deleteAddress(id);
    if (result.isFailure) return result.failure!.message;
    await refresh();
    return null;
  }

  /// 设为默认：先本地置位，服务端失败再回滚刷新。
  Future<String?> setDefault(String id) async {
    final current = state.valueOrNull ?? const <ShippingAddress>[];
    state = AsyncValue.data(<ShippingAddress>[
      for (final ShippingAddress item in current)
        item.copyWith(isDefault: item.id == id),
    ]);
    if (_demo) return null;

    final result = await _api.setDefaultAddress(id);
    if (result.isFailure) {
      await refresh();
      return result.failure!.message;
    }
    return null;
  }
}

/// 收货地址列表。
final addressListProvider =
    AsyncNotifierProvider<AddressListController, List<ShippingAddress>>(
      AddressListController.new,
    );

/// 地址加载失败时的可读文案（页面空态用，不展示堆栈）。
String addressErrorText(Object error) {
  if (error is Failure) return error.message;
  return '地址加载失败，请检查网络后重试';
}
