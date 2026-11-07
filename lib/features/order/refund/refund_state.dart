import 'package:core/domain.dart';

/// 退款原因。
///
/// 对齐 Android 退款 H5 页面中的原因选项。
/// 企划星的退款表单是 WebView（`m.planstar.com/order/refund.html`），
/// 原因选项由服务端下发。这里枚举常见原因，等接口接上后改为服务端下发。
enum RefundReason {
  /// 不需要了（计划变更）。
  notNeeded,

  /// 买错了（买错场次 / 票档）。
  boughtWrong,

  /// 票价太贵。
  tooExpensive,

  /// 找到更好的票源。
  foundBetter,

  /// 其他原因。
  other,
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
    this.refundableAmount,
    this.ruleMessage,
    this.expectedArrivalDays,
    this.notAllowed = false,
    this.loadingRule = false,
    this.orderId,
    this.refundNo,
  });

  final RefundReason reason;

  /// 自定义原因说明（`reason == RefundReason.other` 时使用）。
  final String customReason;

  final RefundStatus status;
  final String? errorMessage;

  /// 服务端下发的可退金额；未下发时为 `null`（客户端不自行计算）。
  final Money? refundableAmount;

  /// 服务端下发的退款规则文案；未下发时为 `null`。
  final String? ruleMessage;

  /// 服务端下发的预计到账天数。
  final int? expectedArrivalDays;

  /// 规则不允许退款（如 409 / canRefund=false）。
  final bool notAllowed;

  /// 正在读取退款规则。
  final bool loadingRule;

  /// 订单 id（退款接口路径参数）。
  final String? orderId;

  /// 服务端返回的退款单号。
  final String? refundNo;

  /// 是否可提交（非提交中 / 非已提交 / 规则允许 / 规则已加载）。
  bool get canSubmit =>
      !loadingRule &&
      !notAllowed &&
      (status == RefundStatus.idle || status == RefundStatus.failed);

  RefundState copyWith({
    RefundReason? reason,
    String? customReason,
    RefundStatus? status,
    String? errorMessage,
    bool clearError = false,
    Money? refundableAmount,
    String? ruleMessage,
    bool clearRuleMessage = false,
    int? expectedArrivalDays,
    bool? notAllowed,
    bool? loadingRule,
    String? orderId,
    String? refundNo,
  }) => RefundState(
    reason: reason ?? this.reason,
    customReason: customReason ?? this.customReason,
    status: status ?? this.status,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    refundableAmount: refundableAmount ?? this.refundableAmount,
    ruleMessage: clearRuleMessage
        ? null
        : (ruleMessage ?? this.ruleMessage),
    expectedArrivalDays: expectedArrivalDays ?? this.expectedArrivalDays,
    notAllowed: notAllowed ?? this.notAllowed,
    loadingRule: loadingRule ?? this.loadingRule,
    orderId: orderId ?? this.orderId,
    refundNo: refundNo ?? this.refundNo,
  );
}
