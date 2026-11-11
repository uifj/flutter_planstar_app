import 'package:core/result.dart';

/// 支付渠道（对应 `PayInfo.channels[].type` 与 `subjectType` 的用法）。
///
/// 注意有**两套独立编码**：`orderType`（下单）与 `subjectType`（支付），
/// 混用会导致"改错一个就付不了款"。这里把它们分在两个
/// 枚举里：本枚举对应支付渠道，下单类型见 `OrderType`。
enum PaymentChannel {
  /// 微信支付。
  wechat('wxpay'),

  /// 支付宝。
  alipay('alipay'),

  /// 云闪付 / 银行卡。
  unionPay('unionpay'),

  /// 信用付（花呗分期 / 平台信用购）。
  creditPay('creditpay'),

  /// 余额 / 礼品卡全额支付。
  balance('balance');

  const PaymentChannel(this.wireCode);

  final String wireCode;

  static Result<PaymentChannel> fromWire(String code) {
    for (final channel in PaymentChannel.values) {
      if (channel.wireCode == code) return Success<PaymentChannel>(channel);
    }
    return Fail<PaymentChannel>(
      Failure(
        code: 'PAYMENT_CHANNEL_UNKNOWN',
        message: '未知支付渠道：$code',
        type: FailureType.data,
      ),
    );
  }
}
