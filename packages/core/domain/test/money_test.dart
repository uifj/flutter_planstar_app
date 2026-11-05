import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Money 构造与存储', () {
    test('以分为唯一事实来源', () {
      final money = Money.fromYuan(680);
      expect(money.minorUnits, 68000);
      expect(money.yuan, 680.0);
      expect(money.currency, 'CNY');
    });

    test('元→分按"远离零"舍入（对齐企划星 Utils.round 语义）', () {
      expect(Money.fromYuan(0.005).minorUnits, 1);
      expect(Money.fromYuan(-0.005).minorUnits, -1);
      expect(Money.fromYuan(12.344).minorUnits, 1234);
    });

    test('解析带符号/千分位/空格的金额', () {
      expect(Money.tryParse('¥1,234.56')?.minorUnits, 123456);
      expect(Money.tryParse(' 88 '), Money.fromYuan(88));
      expect(Money.tryParse('-12'), Money.fromYuan(-12));
      expect(Money.tryParse('abc'), isNull);
      expect(Money.tryParse(''), isNull);
    });
  });

  group('Money 运算', () {
    test('加减精确，不受二进制浮点影响', () {
      // 0.1 + 0.2 == 0.30000000000000004 的那个经典问题，在这里不存在
      final sum = Money.fromYuan(0.1) + Money.fromYuan(0.2);
      expect(sum.minorUnits, 30);
      expect(sum.format(), '¥0.30');
    });

    test('乘法只接受整数件数', () {
      expect((Money.fromYuan(680) * 2).minorUnits, 136000);
    });

    test('按万分比取比例并舍入到分', () {
      // 68000 分的 85% = 57800 分
      expect(Money.fromYuan(680).percentage(8500).minorUnits, 57800);
      // 1 分的 33.33% → 0.3333 分 → 舍入成 0
      expect(Money.fromMinorUnits(1).percentage(3333).minorUnits, 0);
      // 2 分的 33.33% → 0.6666 分 → 舍入成 1
      expect(Money.fromMinorUnits(2).percentage(3333).minorUnits, 1);
    });

    test('下限 0 / 取小 / 求和', () {
      final negative = Money.fromYuan(-30);
      expect(negative.atLeastZero(), Money.zero());
      expect(Money.fromYuan(50).min(Money.fromYuan(80)), Money.fromYuan(50));
      expect(
        Money.sum(<Money>[Money.fromYuan(1), Money.fromYuan(2)]),
        Money.fromYuan(3),
      );
    });

    test('币种不同直接抛异常（编程错误，不进 Result）', () {
      expect(
        () => Money.fromYuan(1, currency: 'USD') + Money.fromYuan(1),
        throwsA(isA<CurrencyMismatchException>()),
      );
    });
  });

  group('Money 展示', () {
    test('千分位与两位小数', () {
      expect(Money.fromYuan(1372).format(), '¥1,372.00');
      expect(Money.fromYuan(1234567.891).format(), '¥1,234,567.89');
      expect(Money.fromYuan(0.5).format(withSymbol: false), '0.50');
      expect(Money.fromYuan(-12).format(), '-¥12.00');
    });
  });
}
