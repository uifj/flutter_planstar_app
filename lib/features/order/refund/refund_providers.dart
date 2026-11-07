import 'dart:async';

import 'package:core/domain.dart';
import 'package:core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import 'refund_repository.dart';
import 'refund_state.dart';

/// 退款申请参数。
typedef RefundArg = ({String orderNumber, Money orderAmount});

/// 退款仓储：真实环境走 `GET/POST /v1/order/{id}/refund`。
final refundRepositoryProvider = Provider<RefundRepository>(
  (ref) => RemoteRefundRepository(client: ref.watch(apiClientProvider)),
);

/// 退款 Controller。
///
/// 真实流程：读取订单详情的退款规则字段 → 提交 `POST /v1/order/{id}/refund`
/// → 展示服务端返回的可退金额与预计到账天数。不可退（409）时禁用提交。
class RefundController extends FamilyNotifier<RefundState, RefundArg> {
  bool _disposed = false;

  @override
  RefundState build(RefundArg arg) {
    ref.onDispose(() => _disposed = true);

    if (ref.read(dataSourcePolicyProvider).isDemo) {
      // 演示模式：不请求接口，金额直接来自路由参数（非真实退款规则）。
      return RefundState(refundableAmount: arg.orderAmount);
    }

    unawaited(_loadRule(arg));
    return const RefundState(loadingRule: true);
  }

  Future<void> _loadRule(RefundArg arg) async {
    final Result<RefundRuleInfo> result = await ref
        .read(refundRepositoryProvider)
        .loadRule(arg.orderNumber);
    if (_disposed) return;

    result.fold(
      onSuccess: (RefundRuleInfo info) {
        final bool allowed = info.canRefund ?? true;
        state = state.copyWith(
          loadingRule: false,
          orderId: info.orderId,
          refundableAmount: info.refundableAmount,
          ruleMessage: info.ruleText,
          expectedArrivalDays: info.expectedArrivalDays,
          notAllowed: !allowed,
          errorMessage: allowed ? null : (info.ruleText ?? '当前订单不支持退款'),
          clearError: allowed,
        );
      },
      onFailure: (Failure failure) {
        // 契约当前未提供退款规则字段；读取失败不阻断提交，由服务端最终校验。
        state = state.copyWith(
          loadingRule: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  void selectReason(RefundReason reason) {
    state = state.copyWith(reason: reason, clearError: true);
  }

  void updateCustomReason(String value) {
    state = state.copyWith(customReason: value, clearError: true);
  }

  Future<void> submit() async {
    // 提交中 / 已提交时直接返回，避免重复创建退款单（服务端也按 orderId 幂等）。
    if (!state.canSubmit) return;

    if (ref.read(dataSourcePolicyProvider).isDemo) {
      state = state.copyWith(
        status: RefundStatus.submitted,
        refundableAmount: state.refundableAmount ?? arg.orderAmount,
        expectedArrivalDays: 1,
        clearError: true,
      );
      return;
    }

    final String? orderId = state.orderId;
    if (orderId == null || orderId.isEmpty) {
      state = state.copyWith(
        status: RefundStatus.failed,
        errorMessage: '订单信息加载失败，请返回重试',
      );
      return;
    }

    state = state.copyWith(
      status: RefundStatus.submitting,
      clearError: true,
    );

    final Result<RefundOrder> result = await ref
        .read(refundRepositoryProvider)
        .submit(
          orderId: orderId,
          reason: state.reason,
          reasonText: state.reason == RefundReason.other
              ? state.customReason
              : null,
        );
    if (_disposed) return;

    result.fold(
      onSuccess: (RefundOrder refund) {
        state = state.copyWith(
          status: RefundStatus.submitted,
          refundNo: refund.refundNo,
          refundableAmount: refund.refundableAmount,
          expectedArrivalDays: refund.expectedArrivalDays,
          clearError: true,
        );
      },
      onFailure: (Failure failure) {
        final bool notAllowed =
            failure.statusCode == 409 ||
            failure.code == 'REFUND_NOT_ALLOWED';
        state = state.copyWith(
          status: RefundStatus.failed,
          notAllowed: notAllowed,
          ruleMessage: notAllowed ? failure.message : null,
          errorMessage: failure.message,
        );
      },
    );
  }

  void reset() {
    state = const RefundState();
  }
}

final refundControllerProvider =
    NotifierProvider.family<RefundController, RefundState, RefundArg>(
      RefundController.new,
    );
