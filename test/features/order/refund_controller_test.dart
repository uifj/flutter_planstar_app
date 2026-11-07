import 'package:core/domain.dart';
import 'package:core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planstar/app/network/data_source_policy.dart';
import 'package:planstar/app/network/network_providers.dart';
import 'package:planstar/features/order/refund/refund_providers.dart';
import 'package:planstar/features/order/refund/refund_repository.dart';
import 'package:planstar/features/order/refund/refund_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRefundRepository implements RefundRepository {
  int submitCalls = 0;
  int loadRuleCalls = 0;
  RefundOrder? existing;

  @override
  Future<Result<RefundRuleInfo>> loadRule(String orderNumber) async {
    loadRuleCalls++;
    return Success<RefundRuleInfo>(
      RefundRuleInfo(
        orderId: '1001',
        refundableAmount: Money.fromMinorUnits(136000),
        ruleText: '演出前 48 小时可退',
        expectedArrivalDays: 3,
        canRefund: true,
      ),
    );
  }

  @override
  Future<Result<RefundOrder>> submit({
    required String orderId,
    required RefundReason reason,
    String? reasonText,
  }) async {
    submitCalls++;
    // 对齐服务端按 orderId 幂等：重复提交返回同一个退款单。
    existing ??= RefundOrder(
      refundNo: 'REFUND-1',
      orderId: orderId,
      refundableAmount: Money.fromMinorUnits(136000),
      status: 'pending',
      expectedArrivalDays: 3,
    );
    return Success<RefundOrder>(existing!);
  }

  @override
  Future<Result<RefundOrder>> fetchRefund(String orderId) async =>
      Success<RefundOrder>(existing!);
}

void main() {
  const DataSourcePolicy remotePolicy = DataSourcePolicy(isDemo: false);
  final RefundArg arg = (
    orderNumber: 'PN20261107000001',
    orderAmount: Money.fromMinorUnits(136000),
  );

  test('同一订单重复提交只产生一个退款单', () async {
    final repository = _FakeRefundRepository();
    final container = ProviderContainer(
      overrides: <Override>[
        dataSourcePolicyProvider.overrideWithValue(remotePolicy),
        refundRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      refundControllerProvider(arg).notifier,
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.loadingRule, isFalse);
    expect(controller.state.orderId, '1001');
    expect(controller.state.canSubmit, isTrue);

    // 并发双击：第二次在进入 await 前就被 submitting 拦截。
    await Future.wait<void>(<Future<void>>[
      controller.submit(),
      controller.submit(),
    ]);

    expect(repository.submitCalls, 1);
    expect(controller.state.status, RefundStatus.submitted);
    expect(controller.state.refundNo, 'REFUND-1');
    expect(controller.state.expectedArrivalDays, 3);

    // 已提交后再次调用不会再发请求。
    await controller.submit();
    expect(repository.submitCalls, 1);
  });
}
