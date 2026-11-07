import 'package:core/domain.dart';
import 'package:core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planstar/app/network/data_source_policy.dart';
import 'package:planstar/app/network/network_providers.dart';
import 'package:planstar/features/order/domain/domain.dart';
import 'package:planstar/features/order/payment/pay_info.dart';
import 'package:planstar/features/order/payment/pay_providers.dart';
import 'package:planstar/features/order/payment/pay_repository.dart';
import 'package:planstar/features/order/payment/planstar_pay_api.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePayRepository implements PayRepository {
  _FakePayRepository({required this.created, required this.details});

  final PaymentOrder created;
  final List<PaymentOrder> details;
  int createCalls = 0;
  int detailCalls = 0;

  @override
  Future<Result<PaymentOrder>> createPayment({
    required String orderNumber,
    required PaymentChannel channel,
  }) async {
    createCalls++;
    return Success<PaymentOrder>(created);
  }

  @override
  Future<Result<PaymentOrder>> fetchPaymentDetail({
    required String payNo,
    String? orderNumber,
  }) async {
    final PaymentOrder next = details[detailCalls.clamp(0, details.length - 1)];
    detailCalls++;
    return Success<PaymentOrder>(next);
  }
}

PaymentOrder _payment(
  PaymentStatus status, {
  required DateTime expireAt,
}) {
  return PaymentOrder(
    payNo: 'PAY-1',
    orderNumber: 'PN20261107000001',
    amount: Money.fromMinorUnits(136000),
    channel: 'wxpay',
    status: status,
    payParams: const <String, dynamic>{},
    expireAt: expireAt,
    paidAt: status == PaymentStatus.success ? DateTime(2026, 11, 7, 10, 1) : null,
    thirdTradeNo: '',
  );
}

void main() {
  const DataSourcePolicy remotePolicy = DataSourcePolicy(isDemo: false);
  final DateTime now = DateTime(2026, 11, 7, 10);
  final PayArg arg = (
    orderNumber: 'PN20261107000001',
    amount: Money.fromMinorUnits(136000),
    showTitle: '测试演出',
  );

  ProviderContainer buildContainer(_FakePayRepository repository) {
    return ProviderContainer(
      overrides: <Override>[
        dataSourcePolicyProvider.overrideWithValue(remotePolicy),
        payRepositoryProvider.overrideWithValue(repository),
        payPollIntervalProvider.overrideWithValue(Duration.zero),
        payClockProvider.overrideWithValue(() => now),
      ],
    );
  }

  test('pending → success', () async {
    final repository = _FakePayRepository(
      created: _payment(
        PaymentStatus.pending,
        expireAt: now.add(const Duration(minutes: 10)),
      ),
      details: <PaymentOrder>[
        _payment(
          PaymentStatus.success,
          expireAt: now.add(const Duration(minutes: 10)),
        ),
      ],
    );
    final container = buildContainer(repository);
    addTearDown(container.dispose);

    final controller = container.read(payControllerProvider(arg).notifier);
    final PayResult result = await controller.pay();

    expect(result, isA<PaySuccess>());
    expect(controller.state.status, PayStatus.success);
    expect(repository.createCalls, 1);
    expect(repository.detailCalls, 1);
  });

  test('pending → expired', () async {
    final repository = _FakePayRepository(
      created: _payment(
        PaymentStatus.pending,
        expireAt: now.add(const Duration(minutes: 10)),
      ),
      details: <PaymentOrder>[
        _payment(
          PaymentStatus.expired,
          expireAt: now.add(const Duration(minutes: 10)),
        ),
      ],
    );
    final container = buildContainer(repository);
    addTearDown(container.dispose);

    final controller = container.read(payControllerProvider(arg).notifier);
    final PayResult result = await controller.pay();

    expect(result, isA<PayFailure>());
    expect(controller.state.status, PayStatus.failure);
    expect(controller.state.leftSeconds, 0);
  });

  test('pending → failed', () async {
    final repository = _FakePayRepository(
      created: _payment(
        PaymentStatus.pending,
        expireAt: now.add(const Duration(minutes: 10)),
      ),
      details: <PaymentOrder>[
        _payment(
          PaymentStatus.failed,
          expireAt: now.add(const Duration(minutes: 10)),
        ),
      ],
    );
    final container = buildContainer(repository);
    addTearDown(container.dispose);

    final controller = container.read(payControllerProvider(arg).notifier);
    final PayResult result = await controller.pay();

    expect(result, isA<PayFailure>());
    expect(controller.state.status, PayStatus.failure);
    expect(controller.state.errorMessage, isNotNull);
  });
}
