import 'dart:async';

import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/domain.dart';
import 'pay_info.dart';

/// 支付页面信息 Provider（按订单号分族）。
///
/// 企划星的 `PayActivity` 在 onCreate 里调 `GET v1/unifiedPay/payDetail`。
/// 本演示模式里用 [PayInfo.demo] 生成，金额由路由参数传入。
/// 接真实接口时改成 `FutureProvider.family`，走 `PayRepository`。
final payInfoProvider =
    Provider.family<PayInfo, ({String orderNumber, Money amount, String showTitle})>(
  (ref, params) {
    return PayInfo.demo(
      orderNumber: params.orderNumber,
      payAmount: params.amount,
      showTitle: params.showTitle,
    );
  },
);

/// 支付页面状态。
class PayState {
  const PayState({
    required this.info,
    this.selectedChannel,
    this.status = PayStatus.idle,
    this.errorMessage,
    this.leftSeconds,
  });

  /// 支付页面信息。
  final PayInfo info;

  /// 当前选中的支付渠道。
  final PaymentChannel? selectedChannel;

  /// 支付状态。
  final PayStatus status;

  /// 错误信息（status == failure 时有值）。
  final String? errorMessage;

  /// 倒计时剩余秒数。
  final int? leftSeconds;

  /// 是否可以发起支付。
  bool get canPay =>
      selectedChannel != null &&
      status != PayStatus.requesting &&
      status != PayStatus.paying;

  PayState copyWith({
    PaymentChannel? selectedChannel,
    PayStatus? status,
    String? errorMessage,
    int? leftSeconds,
  }) {
    return PayState(
      info: info,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      status: status ?? this.status,
      errorMessage: errorMessage,
      leftSeconds: leftSeconds ?? this.leftSeconds,
    );
  }
}

/// 支付页面控制器。
///
/// ## 与 Android 的差异
///
/// - **不做真实 SDK 调用**：企划星的 `PayActivity` 调微信 / 支付宝 / 银行 SDK，
///   这里只做**状态机演示**——选渠道 → 请求 → 模拟 SDK 调用 → 成功 / 失败。
///   理由是 SDK 集成需要 fluwx / tobias 包 + 平台配置，演示项目不引入。
///   但状态机本身是完整的：idle → requesting → paying → success / failure / cancelled，
///   接 SDK 时只需替换 `_invokeSdk` 方法。
/// - **倒计时**：企划星用 `leftTime` 字段做订单超时倒计时。这里也实现了，
///   超时后自动标记为 failure。
class PayController extends FamilyNotifier<PayState, ({String orderNumber, Money amount, String showTitle})> {
  Timer? _countdownTimer;

  @override
  PayState build(arg) {
    final info = ref.read(payInfoProvider(arg));

    // 默认选中第一个可用渠道（企划星也这样做）。
    final firstAvailable = info.channels.where((c) => c.available).firstOrNull;
    final state = PayState(
      info: info,
      selectedChannel: firstAvailable?.channel,
      leftSeconds: info.leftSeconds,
    );

    // 启动倒计时。
    _startCountdown(state.leftSeconds ?? 0);

    // 选中默认渠道后重建，让 UI 高亮。
    ref.onDispose(() => _countdownTimer?.cancel());
    return state;
  }

  /// 选择支付渠道。
  void selectChannel(PaymentChannel channel) {
    state = state.copyWith(selectedChannel: channel, errorMessage: null);
  }

  /// 发起支付。
  ///
  /// 流程：idle → requesting（请求支付参数）→ paying（SDK 调起）→ success / failure。
  Future<PayResult> pay() async {
    if (!state.canPay) return const PayFailure('当前状态不可支付');

    final channel = state.selectedChannel!;
    state = state.copyWith(status: PayStatus.requesting, errorMessage: null);

    // 模拟请求支付参数（POST v1/unifiedPay/pay）。
    await Future<void>.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(status: PayStatus.paying);

    // 模拟 SDK 调用。
    final result = await _invokeSdk(channel);

    switch (result) {
      case PaySuccess():
        state = state.copyWith(status: PayStatus.success);
        _countdownTimer?.cancel();
      case PayFailure(:final message):
        state = state.copyWith(status: PayStatus.failure, errorMessage: message);
      case PayCancelled():
        state = state.copyWith(status: PayStatus.cancelled);
    }

    return result;
  }

  /// 模拟第三方 SDK 调用。
  ///
  /// 接真实 SDK 时替换此方法：
  /// - 微信：`fluwx.payWithWeChat(...)` → 注册回调
  /// - 支付宝：`tobias.pay(paymentParams)` → 返回 result code
  /// - 银联：跳银联 SDK
  /// - 余额：直接调服务端确认
  Future<PayResult> _invokeSdk(PaymentChannel channel) async {
    // 模拟 SDK 延迟。
    await Future<void>.delayed(const Duration(seconds: 1));

    // 演示模式：所有渠道都成功。
    // 接真实 SDK 后：
    // - 微信成功码：errCode == 0
    // - 支付宝成功码：resultStatus == "9000"
    // - 银联成功码：respCode == "00"
    return const PaySuccess();
  }

  /// 启动倒计时。
  void _startCountdown(int seconds) {
    if (seconds <= 0) return;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.leftSeconds ?? 0;
      if (remaining <= 1) {
        timer.cancel();
        state = state.copyWith(
          leftSeconds: 0,
          status: PayStatus.failure,
          errorMessage: '支付超时，订单已自动取消',
        );
      } else {
        state = state.copyWith(leftSeconds: remaining - 1);
      }
    });
  }

  /// 格式化倒计时为 mm:ss。
  static String formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// 支付页面控制器 Provider。
final payControllerProvider =
    NotifierProvider.family<PayController, PayState, ({String orderNumber, Money amount, String showTitle})>(
  PayController.new,
);
