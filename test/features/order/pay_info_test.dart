import 'package:core/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/order/domain/domain.dart';
import 'package:planstar/features/order/payment/pay_info.dart';

void main() {
  test('支付渠道收敛为星币余额一种', () {
    final info = PayInfo.forOrder(
      orderNumber: 'P20261107001',
      payAmount: Money.fromMinorUnits(68000),
      showTitle: '测试支持',
    );

    expect(info.channels, hasLength(1));
    expect(info.channels.single.channel, PaymentChannel.balance);
    expect(info.channels.single.available, isTrue);
    expect(
      info.channels.map((PayChannelOption option) => option.channel),
      isNot(contains(PaymentChannel.wechat)),
    );
    expect(
      info.channels.map((PayChannelOption option) => option.channel),
      isNot(contains(PaymentChannel.alipay)),
    );
    expect(
      info.channels.map((PayChannelOption option) => option.channel),
      isNot(contains(PaymentChannel.unionPay)),
    );
  });
}
