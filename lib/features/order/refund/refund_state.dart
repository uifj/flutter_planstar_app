/// 退款原因。
///
/// 对齐 Android 退款 H5 页面中的原因选项。
/// 企划星的退款表单是 WebView（`m.planstar.com/order/refund.html`），
/// 原因选项由服务端下发。这里枚举常见原因，等接口接上后改为服务端下发。
enum RefundReason {
  /// 不需要了（计划变更）。
  notNeeded('不需要了', '计划变更，暂时不需要了'),

  /// 买错了（买错场次 / 票档）。
  boughtWrong('买错了', '买错了场次或票档'),

  /// 票价太贵。
  tooExpensive('票价太贵', '价格超出预算'),

  /// 找到更好的票源。
  foundBetter('找到更好的票源', '通过其他渠道购买了'),

  /// 其他原因。
  other('其他原因', '自定义说明');

  const RefundReason(this.label, this.description);

  final String label;
  final String description;
}

/// 退款状态。
enum RefundStatus {
  /// 待提交。
  idle,

  /// 提交中。
  submitting,

  /// 已提交（等待审核）。
  submitted,

  /// 失败。
  failed,
}

/// 退款申请状态。
class RefundState {
  const RefundState({
    this.reason = RefundReason.notNeeded,
    this.customReason = '',
    this.status = RefundStatus.idle,
    this.errorMessage,
  });

  final RefundReason reason;

  /// 自定义原因说明（`reason == RefundReason.other` 时使用）。
  final String customReason;

  final RefundStatus status;
  final String? errorMessage;

  /// 是否可提交（非提交中 / 非已提交）。
  bool get canSubmit =>
      status == RefundStatus.idle || status == RefundStatus.failed;

  /// 原因文案。
  String get reasonText {
    if (reason == RefundReason.other && customReason.isNotEmpty) {
      return customReason;
    }
    return reason.label;
  }

  RefundState copyWith({
    RefundReason? reason,
    String? customReason,
    RefundStatus? status,
    String? errorMessage,
  }) =>
      RefundState(
        reason: reason ?? this.reason,
        customReason: customReason ?? this.customReason,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );
}
