import 'dart:async';

import 'package:core/domain.dart';
import 'package:core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../domain/domain.dart';
import 'pay_info.dart';
import 'pay_repository.dart';
import 'planstar_pay_api.dart';

/// 支付页面参数。
typedef PayArg = ({String orderNumber, Money amount, String showTitle});

/// 支付页面信息 Provider（按订单号分族）。
///
/// 真实金额、支付状态由 [PayRepository] 在创建支付单后拿到；
/// 这里只构造页面壳（金额来自路由参数，渠道为客户端能力声明）。
final payInfoProvider =
    Provider.family<
      PayInfo,
      ({String orderNumber, Money amount, String showTitle})
    >((ref, params) {
      return PayInfo.forOrder(
        orderNumber: params.orderNumber,
        payAmount: params.amount,
        showTitle: params.showTitle,
      );
    });

/// 支付仓储：真实环境走 `/v1/unifiedPay/*`。
final payRepositoryProvider = Provider<PayRepository>(
  (ref) => RemotePayRepository(
    api: PlanstarPayApi(client: ref.watch(apiClientProvider)),
  ),
);

/// 轮询间隔（测试可覆盖为 `Duration.zero`）。
final payPollIntervalProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);

/// 时钟（测试可注入固定时间，避免真实等待）。
final payClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// 支付页面状态。
class PayState {
  const PayState({
    required this.info,
    this.selectedChannel,
    this.status = PayStatus.idle,
    this.errorMessage,
    this.leftSeconds,
    this.networkUnavailable = false,
    this.payNo,
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

  /// 网络不可用（创建/轮询支付单时网络失败）。为 true 时禁用支付按钮。
  final bool networkUnavailable;

  /// 服务端支付单号（创建成功后回填）。
  final String? payNo;

  /// 是否可以发起支付。
  bool get canPay =>
      selectedChannel != null &&
      !networkUnavailable &&
      status != PayStatus.requesting &&
      status != PayStatus.paying &&
      status != PayStatus.success;

  PayState copyWith({
    PaymentChannel? selectedChannel,
    PayStatus? status,
    String? errorMessage,
    bool clearError = false,
    int? leftSeconds,
    bool? networkUnavailable,
    String? payNo,
  }) {
    return PayState(
      info: info,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      leftSeconds: leftSeconds ?? this.leftSeconds,
      networkUnavailable: networkUnavailable ?? this.networkUnavailable,
      payNo: payNo ?? this.payNo,
    );
  }
}

/// 支付页面控制器。
///
/// 真实流程：创建支付单 → 每 2 秒轮询 `payDetail`（截止 `expireAt`）→
/// success / failed / expired。演示模式只在 `PS_USE_DEMO=true` 时走明确标注的分支。
class PayController extends FamilyNotifier<PayState, PayArg> {
  Timer? _countdownTimer;
  bool _disposed = false;

  @override
  PayState build(arg) {
    final info = ref.read(payInfoProvider(arg));

    final firstAvailable = info.channels
        .where((option) => option.available)
        .firstOrNull;
    final state = PayState(
      info: info,
      selectedChannel: firstAvailable?.channel,
      leftSeconds: info.leftSeconds,
    );

    _startCountdown(state.leftSeconds ?? 0);
    ref.onDispose(() {
      _disposed = true;
      _countdownTimer?.cancel();
    });
    return state;
  }

  /// 选择支付渠道。
  void selectChannel(PaymentChannel channel) {
    state = state.copyWith(
      selectedChannel: channel,
      clearError: true,
      networkUnavailable: false,
    );
  }

  /// 网络错误后允许用户手动重试。
  void resetNetworkError() {
    state = state.copyWith(
      networkUnavailable: false,
      clearError: true,
      status: PayStatus.idle,
    );
  }

  /// 发起支付。
  Future<PayResult> pay() async {
    if (!state.canPay) return const PayFailure('当前状态不可支付');

    final PaymentChannel channel = state.selectedChannel!;

    // 演示模式：仅 `PS_USE_DEMO=true` 时进入，明确标注、不调任何 SDK/接口。
    if (ref.read(dataSourcePolicyProvider).isDemo) {
      return _payDemo();
    }

    state = state.copyWith(
      status: PayStatus.requesting,
      clearError: true,
      networkUnavailable: false,
    );

    final Result<PaymentOrder> created = await ref
        .read(payRepositoryProvider)
        .createPayment(orderNumber: arg.orderNumber, channel: channel);
    if (_disposed) return const PayCancelled();
    if (created.isFailure) return _applyFailure(created.failure!);

    final PaymentOrder first = created.requireData;
    _applyDeadline(first.expireAt);
    state = state.copyWith(
      status: PayStatus.paying,
      payNo: first.payNo,
      clearError: true,
    );

    PaymentOrder current = first;
    while (!_disposed) {
      final PayResult? terminal = _terminalResult(current);
      if (terminal != null) return terminal;

      final DateTime? expireAt = current.expireAt;
      if (expireAt != null &&
          !ref.read(payClockProvider)().isBefore(expireAt)) {
        return _expire();
      }

      await Future<void>.delayed(ref.read(payPollIntervalProvider));
      if (_disposed) return const PayCancelled();

      final Result<PaymentOrder> detail = await ref
          .read(payRepositoryProvider)
          .fetchPaymentDetail(
            payNo: current.payNo,
            orderNumber: arg.orderNumber,
          );
      if (_disposed) return const PayCancelled();
      if (detail.isFailure) return _applyFailure(detail.failure!);
      current = detail.requireData;
    }
    return const PayCancelled();
  }

  /// 演示分支：明确标注，不调起任何真实 SDK。
  Future<PayResult> _payDemo() async {
    state = state.copyWith(status: PayStatus.paying, clearError: true);
    _countdownTimer?.cancel();
    state = state.copyWith(status: PayStatus.success);
    return const PaySuccess();
  }

  PayResult? _terminalResult(PaymentOrder order) {
    switch (order.status) {
      case PaymentStatus.success:
        _countdownTimer?.cancel();
        state = state.copyWith(
          status: PayStatus.success,
          clearError: true,
          payNo: order.payNo,
        );
        return const PaySuccess();
      case PaymentStatus.failed:
        return _fail('支付失败，请更换支付方式后重试');
      case PaymentStatus.expired:
        return _expire();
      case PaymentStatus.pending:
        return null;
    }
  }

  PayResult _fail(String message) {
    state = state.copyWith(
      status: PayStatus.failure,
      errorMessage: message,
    );
    return PayFailure(message);
  }

  PayResult _expire() {
    _countdownTimer?.cancel();
    state = state.copyWith(
      status: PayStatus.failure,
      leftSeconds: 0,
      errorMessage: '支付已过期，请重新下单',
    );
    return const PayFailure('支付已过期，请重新下单');
  }

  PayResult _applyFailure(Failure failure) {
    final bool network =
        failure.type == FailureType.network ||
        failure.type == FailureType.timeout;
    final String message = network ? '网络不可用，请检查网络后重试' : failure.message;
    state = state.copyWith(
      status: PayStatus.failure,
      errorMessage: message,
      networkUnavailable: network,
    );
    return PayFailure(message);
  }

  void _applyDeadline(DateTime? expireAt) {
    if (expireAt == null) return;
    final int seconds = expireAt
        .difference(ref.read(payClockProvider)())
        .inSeconds;
    if (seconds <= 0) return;
    state = state.copyWith(leftSeconds: seconds);
    _startCountdown(seconds);
  }

  /// 启动倒计时。
  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    if (seconds <= 0) return;

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
    NotifierProvider.family<PayController, PayState, PayArg>(
      PayController.new,
    );
