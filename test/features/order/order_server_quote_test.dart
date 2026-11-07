import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/order/data/planstar_order_api.dart';
import 'package:planstar/features/order/domain/domain.dart';

void main() {
  test('服务端报价按分解析，并成为展示金额来源', () {
    final quote = OrderServerQuote.tryParse(<String, dynamic>{
      'quoteId': 'Q-1',
      'totalAmount': 68000,
      'payAmount': 63000,
      'expiresAt': '2026-11-07T12:00:00Z',
    });

    expect(quote, isNotNull);
    expect(quote!.quoteId, 'Q-1');
    expect(quote.totalAmount.minorUnits, 68000);

    final display = quote.toDisplayQuote();
    expect(display.totalAmount.minorUnits, 68000);
    expect(display.paymentAmount.minorUnits, 63000);
    expect(display.discountApplied.minorUnits, 5000);
  });

  test('没有金额字段时返回 null，调用方回退本地报价', () {
    expect(
      OrderServerQuote.tryParse(<String, dynamic>{'quoteId': 'Q-2'}),
      isNull,
    );
  });

  test('幂等键不重复（时间戳 + 随机数）', () {
    final first = PlanstarOrderApi.newIdempotencyKey();
    final second = PlanstarOrderApi.newIdempotencyKey();
    expect(first, isNot(second));
    expect(first.startsWith('ps-'), isTrue);
  });
}
