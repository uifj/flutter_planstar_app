import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_address.dart';
import '../domain/shipping_address.dart';

/// 收货地址列表。
///
/// ## 三条不变量（由控制器保证，页面不做校验）
///
/// 1. **默认地址最多一个**：`setDefault` 会先全部置假再置真；
/// 2. **删掉默认地址后，第一条自动成为默认**——否则用户下单时没有默认项，
///    结算页会拿不到地址；
/// 3. **新增的地址不自动成为默认**（企划星的行为是"第一条自动默认"，
///    这里只在列表为空时这么做）。
///
/// 接真实接口时把 `build()` 换成 `AsyncNotifier` + `v1/address/list`，
/// 三个动作对应 `v1/address/add` / `delete` / `setDefault`，页面不变。
class AddressListController extends Notifier<List<ShippingAddress>> {
  @override
  List<ShippingAddress> build() => buildDemoAddresses();

  /// 新增。列表原本为空时，新地址自动成为默认。
  void add({
    required String name,
    required String mobile,
    required String region,
    required String detail,
  }) {
    final bool wasEmpty = state.isEmpty;
    final ShippingAddress address = ShippingAddress(
      id: 'addr-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      mobile: mobile.trim(),
      region: region.trim(),
      detail: detail.trim(),
      isDefault: wasEmpty,
    );
    state = <ShippingAddress>[...state, address];
  }

  /// 编辑。**不改 `isDefault`**——默认标记是独立动作（`setDefault`），
  /// 编辑表单里也没有这个开关，避免"编辑一次地址就把默认状态弄丢"。
  void update({
    required String id,
    required String name,
    required String mobile,
    required String region,
    required String detail,
  }) {
    state = <ShippingAddress>[
      for (final ShippingAddress item in state)
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
    ];
  }

  /// 删除。删的是默认地址时，把第一条顶上来。
  void remove(String id) {
    final List<ShippingAddress> next = state
        .where((ShippingAddress item) => item.id != id)
        .toList();
    final bool removedDefault = state.any(
      (ShippingAddress item) => item.id == id && item.isDefault,
    );
    if (removedDefault && next.isNotEmpty) {
      next[0] = next[0].copyWith(isDefault: true);
    }
    state = next;
  }

  /// 设为默认：先全部置假，再把目标置真。
  void setDefault(String id) {
    state = <ShippingAddress>[
      for (final ShippingAddress item in state)
        item.copyWith(isDefault: item.id == id),
    ];
  }
}

/// 收货地址列表。
final addressListProvider =
    NotifierProvider<AddressListController, List<ShippingAddress>>(
      AddressListController.new,
    );
