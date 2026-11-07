import 'package:core/result.dart';

import '../domain/domain.dart';
import 'planstar_pay_api.dart';

/// 支付端口：创建支付单 / 查询支付状态。
abstract interface class PayRepository {
  Future<Result<PaymentOrder>> createPayment({
    required String orderNumber,
    required PaymentChannel channel,
  });

  Future<Result<PaymentOrder>> fetchPaymentDetail({
    required String payNo,
    String? orderNumber,
  });
}

/// 真实支付仓储。
final class RemotePayRepository implements PayRepository {
  const RemotePayRepository({required PlanstarPayApi api}) : _api = api;

  final PlanstarPayApi _api;

  @override
  Future<Result<PaymentOrder>> createPayment({
    required String orderNumber,
    required PaymentChannel channel,
  }) {
    return _api.createPayment(
      orderNumber: orderNumber,
      channel: _payChannelCode(channel),
    );
  }

  @override
  Future<Result<PaymentOrder>> fetchPaymentDetail({
    required String payNo,
    String? orderNumber,
  }) {
    return _api.fetchPaymentDetail(
      payNo: payNo,
      orderNumber: orderNumber,
    );
  }

  /// `PaymentChannel` 是历史共用编码（微信为 `wxpay`）；
  /// 新支付接口的 `channel` 白名单是 `wechat / alipay / unionpay / balance`。
  static String _payChannelCode(PaymentChannel channel) => switch (channel) {
    PaymentChannel.wechat => 'wechat',
    PaymentChannel.alipay => 'alipay',
    PaymentChannel.unionPay => 'unionpay',
    PaymentChannel.balance => 'balance',
    PaymentChannel.creditPay => channel.wireCode,
  };
}
