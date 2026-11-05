import 'package:core_result/core_result.dart';

/// 支付渠道（对齐企划星 `PayInfo.channels[].type` 与 `subjectType` 的用法）。
///
/// 注意企划星有**两套独立编码**：`orderType`（下单）与 `subjectType`（支付），
/// 混用会导致"改错一个就付不了款"（`wiki_zh/12` §3.5.7）。这里把它们分在两个
/// 枚举里：本枚举对应支付渠道，下单类型见 `OrderType`。
enum PaymentChannel {
  /// 微信支付。
  wechat('wxpay', '微信支付'),

  /// 支付宝。
  alipay('alipay', '支付宝'),

  /// 云闪付 / 银行卡。
  unionPay('unionpay', '银行卡'),

  /// 信用付（花呗分期 / 企划星信用购）。
  creditPay('creditpay', '信用付'),

  /// 余额 / 礼品卡全额支付。
  balance('balance', '余额支付');

  const PaymentChannel(this.wireCode, this.label);

  final String wireCode;
  final String label;

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
