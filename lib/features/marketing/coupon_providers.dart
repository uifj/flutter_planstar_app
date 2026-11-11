import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coupon.dart';
import 'demo_coupons.dart';

/// 优惠券列表筛选 Tab。
enum CouponTab {
  /// 可使用。
  usable,

  /// 已使用。
  used,

  /// 已过期。
  expired,
}

/// 优惠券列表 Provider。
///
/// 目前只有演示数据；服务端券接口接上后把这里改成 `FutureProvider` 即可——
/// 返回值类型不变，页面不需要改。
final couponListProvider = Provider<List<Coupon>>(
  (ref) => DemoCoupons.generate(),
);

/// 按 Tab 筛选后的券列表。
final filteredCouponsProvider = Provider.family<List<Coupon>, CouponTab>((
  ref,
  tab,
) {
  final all = ref.watch(couponListProvider);
  return all.where((c) => c.status == _statusOf(tab)).toList();
});

CouponStatus _statusOf(CouponTab tab) => switch (tab) {
  CouponTab.usable => CouponStatus.usable,
  CouponTab.used => CouponStatus.used,
  CouponTab.expired => CouponStatus.expired,
};

/// 可用券数量（「我的」页资产卡用）。
final couponCountProvider = Provider<int>((ref) {
  final all = ref.watch(couponListProvider);
  return all.where((c) => c.status == CouponStatus.usable).length;
});

/// 兑换码输入状态。
class ExchangeState {
  const ExchangeState({
    this.code = '',
    this.submitting = false,
    this.result,
    this.error,
  });

  final String code;
  final bool submitting;
  final Coupon? result;
  final String? error;

  bool get canSubmit => code.trim().isNotEmpty && !submitting;

  ExchangeState copyWith({
    String? code,
    bool? submitting,
    Coupon? result,
    String? error,
  }) => ExchangeState(
    code: code ?? this.code,
    submitting: submitting ?? this.submitting,
    result: result ?? this.result,
    error: error,
  );
}

/// 兑换码输入 Controller。
///
/// 兑换交互：
/// - 输入框内容变化 → 启用/禁用提交按钮
/// - 点击兑换 → 提交兑换码 → 成功返回券对象
///
/// 这里用内存模拟：任意 8 位以上兑换码"成功"，
/// 生成一张演示券；短于 8 位"失败"。
class ExchangeController extends Notifier<ExchangeState> {
  @override
  ExchangeState build() => const ExchangeState();

  void updateCode(String value) {
    state = state.copyWith(code: value, error: null);
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;

    state = state.copyWith(submitting: true, error: null);

    // 模拟网络延迟。
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final code = state.code.trim();

    // 模拟兑换：8 位以上成功，否则失败。
    if (code.length >= 8) {
      final coupon = Coupon(
        id: 9999,
        title: '兑换码兑换券',
        desc: '通过兑换码获得',
        discountType: CouponDiscountType.amount,
        discountAmount: Money.fromMinorUnits(2000),
        discountRate: 0,
        requireAmount: Money.fromMinorUnits(8000),
        validFrom: DateTime.now(),
        validTo: DateTime.now().add(const Duration(days: 30)),
        status: CouponStatus.usable,
      );
      state = ExchangeState(result: coupon);
    } else {
      state = state.copyWith(submitting: false, error: 'invalid');
    }
  }

  void reset() {
    state = const ExchangeState();
  }
}

final exchangeControllerProvider =
    NotifierProvider<ExchangeController, ExchangeState>(ExchangeController.new);
