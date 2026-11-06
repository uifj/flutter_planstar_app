import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/domain.dart';
import 'refund_state.dart';

/// 退款申请参数。
typedef RefundArg = ({String orderNumber, Money orderAmount});

/// 退款 Controller。
///
/// ## 与 Android 的差异
///
/// 企划星的退款是 WebView（`m.planstar.com/order/refund.html?id=orderId`），
/// 原生侧只负责打开 H5。这里做原生退款表单：
/// - 原因选择（枚举单选）
/// - 自定义说明（选"其他"时输入）
/// - 提交（模拟 `PUT v1/order/{orderId}/refund`）
///
/// 遵循「假功能不做」约定：提交按钮真实可点，
/// 但提交结果是模拟的（1 秒延迟 → 成功提示），
/// 等 `PUT v1/order/{orderId}/refund` 接上后替换 `_submitRefund` 的实现即可。
class RefundController extends FamilyNotifier<RefundState, RefundArg> {
  @override
  RefundState build(RefundArg arg) => const RefundState();

  void selectReason(RefundReason reason) {
    state = state.copyWith(reason: reason, errorMessage: null);
  }

  void updateCustomReason(String value) {
    state = state.copyWith(customReason: value, errorMessage: null);
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;

    state = state.copyWith(status: RefundStatus.submitting, errorMessage: null);

    // 模拟网络延迟。
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    // 模拟提交成功。
    // 等 `PUT v1/order/{orderId}/refund` 接上后替换这里。
    state = state.copyWith(status: RefundStatus.submitted);
  }

  void reset() {
    state = const RefundState();
  }
}

final refundControllerProvider =
    NotifierProvider.family<RefundController, RefundState, RefundArg>(
      RefundController.new,
    );

/// 计算退款金额。
///
/// 对齐 Android `ActivityRefundRuleDetailBean`：
/// - `refundMode = FREE`：全额退款
/// - `refundMode = TICKET_AMOUNT_PERCENT`：按比例退款
/// - `refundMode = FORBIDDEN`：不可退
///
/// 这里简化为：待发货状态全额退，待收货状态退 80%，已完成不退。
/// 等接口接上后按服务端下发的 `refundRule` 计算。
Money refundAmountFor(OrderStatus status, Money orderAmount) {
  return switch (status) {
    OrderStatus.awaitingTickets => orderAmount, // 全额
    OrderStatus.ticketsInTransit => orderAmount.percentage(2000), // 80%
    _ => Money.zero(), // 不可退
  };
}
