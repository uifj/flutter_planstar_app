import 'package:core/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/proxy_buy/domain/proxy_buy.dart';
import 'package:planstar/features/proxy_buy/domain/services/proxy_buy_pricing.dart';

void main() {
  group('ProxyBuyPricing 服务费分档', () {
    ProxyBuyPricing tieredPricing() => ProxyBuyPricing(<ProxyBuyFeeTier>[
      ProxyBuyFeeTier(
        minTicketPrice: Money.fromYuan(500),
        fee: Money.fromYuan(30),
      ),
      ProxyBuyFeeTier(
        minTicketPrice: Money.fromYuan(800),
        fee: Money.fromYuan(40),
      ),
      ProxyBuyFeeTier(minTicketPrice: Money.zero(), fee: Money.fromYuan(20)),
    ]);

    test('按单张票价命中对应档位（乱序传入也能正确排序）', () {
      final pricing = tieredPricing();

      expect(pricing.feeFor(Money.fromYuan(880)), Money.fromYuan(40));
      expect(pricing.feeFor(Money.fromYuan(800)), Money.fromYuan(40));
      expect(pricing.feeFor(Money.fromYuan(680)), Money.fromYuan(30));
      expect(pricing.feeFor(Money.fromYuan(500)), Money.fromYuan(30));
      expect(pricing.feeFor(Money.fromYuan(380)), Money.fromYuan(20));
    });

    test('总价 = 票价小计 + 服务费小计', () {
      final quote = tieredPricing().quote(
        ticketPrice: Money.fromYuan(880),
        quantity: 2,
      );

      expect(quote.unitServiceFee, Money.fromYuan(40));
      expect(quote.ticketAmount, Money.fromYuan(1760));
      expect(quote.serviceFee, Money.fromYuan(80));
      expect(quote.totalAmount, Money.fromYuan(1840));
      expect(
        tieredPricing().total(ticketPrice: Money.fromYuan(880), quantity: 2),
        Money.fromYuan(1840),
      );
    });

    test('单一费率保持原 calculateTotal 行为', () {
      final info = ProxyBuyInfo(
        proxyBuyFee: Money.fromYuan(30),
        ruleDesc: '规则',
        deadlines: const <ProxyBuyDeadline>[
          ProxyBuyDeadline(endValue: 1, desc: '开抢即抢'),
        ],
        turn: const ProxyBuyTurn(title: '第一场', timeStr: '2026-12-25 19:30'),
      );
      final pricing = ProxyBuyPricing.fromInfo(info);

      expect(
        pricing.total(ticketPrice: Money.fromYuan(880), quantity: 2),
        Money.fromYuan(1820),
      );
      expect(
        pricing
            .quote(ticketPrice: Money.fromYuan(580), quantity: 3)
            .totalAmount,
        Money.fromYuan(1830),
      );
    });

    test('票数非正数时拒绝报价', () {
      final pricing = ProxyBuyPricing.flat(Money.fromYuan(30));
      expect(
        () => pricing.quote(ticketPrice: Money.fromYuan(100), quantity: 0),
        throwsArgumentError,
      );
      expect(
        () => pricing.quote(ticketPrice: Money.fromYuan(100), quantity: -1),
        throwsArgumentError,
      );
    });

    test('没有档位时拒绝构造', () {
      expect(
        () => ProxyBuyPricing(const <ProxyBuyFeeTier>[]),
        throwsArgumentError,
      );
    });
  });
}
