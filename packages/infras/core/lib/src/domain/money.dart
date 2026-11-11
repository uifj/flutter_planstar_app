/// `Money`：金额值对象。**内部一律用最小货币单位（分）的整数**，不用 `double`。
///
/// 为什么不用 `double`：金额若用 `double` 元直接相加
/// （商品总额 + 邮费 + 拆单服务费这类表达式），
/// 就得在外面再包一层精确算术与舍入工具；
/// 但**手写 `-` 的地方（礼品卡、加速包）很容易漏包**。
/// 结果是"有的路径精确、有的路径不精确"，而且只有金额恰好落在 `0.1 + 0.2` 这类
/// 二进制不可表示的位置时才暴露。
///
/// 用整数分之后，加减天然精确；只有"按比例打折"这一处需要显式舍入，
/// 舍入规则写死在 [percentage] / [scale] 里，不再散落在调用点。
library;

import 'value_object.dart';

/// 币种不匹配。**这是编程错误，不是业务错误**——所以抛异常而不是返回 `Result`。
///
/// 业务上的"金额不够"应该是 `Result.failure`；"把人民币和美元相加"是代码写错了。
final class CurrencyMismatchException implements Exception {
  const CurrencyMismatchException(this.left, this.right);

  final String left;
  final String right;

  @override
  String toString() => 'CurrencyMismatchException: 不能混算 $left 与 $right';
}

/// 金额。不可变、值相等、按分存储。
///
/// ```dart
/// final unit = Money.fromYuan(680);           // 星币 680 → 68000 分
/// final total = unit * 2 + Money.fromYuan(12); // 乘法只接受整数件数
/// expect(total.format(), '星币 1,372');
/// ```
final class Money extends ValueObject implements Comparable<Money> {
  const Money._(this.minorUnits, this.currency);

  /// 人民币（企划星只有这一种币种，但保留字段以免将来加港澳台/海外币种）。
  static const String cny = 'CNY';

  /// 零元。
  const Money.zero([this.currency = 'CNY']) : minorUnits = 0;

  /// 从最小单位（分）构造。负数允许——折扣、抵扣在中间态就是负数金额。
  factory Money.fromMinorUnits(int minorUnits, {String currency = cny}) {
    if (currency.trim().isEmpty) {
      throw ArgumentError.value(currency, 'currency', '币种不能为空');
    }
    return Money._(minorUnits, currency.toUpperCase());
  }

  /// 从"元"构造（**只用于边界**：接口返回、配置、测试）。
  ///
  /// 四舍五入到分，且舍入规则是"远离零"（`-0.005 → -0.01`）。
  factory Money.fromYuan(num yuan, {String currency = cny}) =>
      Money.fromMinorUnits(_roundHalfAwayFromZero(yuan * 100), currency: currency);

  /// 解析 `"1234.56"` / `"星币 1,234.56"` / `"¥1,234.56"` / `"-12"`。
  ///
  /// 解析失败返回 `null` 而不是抛异常——它用在反序列化边界上，
  /// 调用方需要把"字段脏了"翻译成 `Failure`。
  static Money? tryParse(String raw, {String currency = cny}) {
    final cleaned = raw
        .replaceAll('星币', '')
        .replaceAll(RegExp(r'[¥￥,\s]'), '');
    if (cleaned.isEmpty) return null;
    final parsed = num.tryParse(cleaned);
    if (parsed == null) return null;
    return Money.fromYuan(parsed, currency: currency);
  }

  /// 最小单位（分）。**这是唯一的事实来源**。
  final int minorUnits;

  /// ISO 4217 币种码。
  final String currency;

  /// 元（`double`）。**只在写 wire 时用**——企划星的 `MakeOrderRequestBody`
  /// 两个金额字段都是 `double` 元，转换必须发生在边界。
  double get yuan => minorUnits / 100;

  bool get isZero => minorUnits == 0;

  bool get isNegative => minorUnits < 0;

  bool get isPositive => minorUnits > 0;

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money._(minorUnits + other.minorUnits, currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money._(minorUnits - other.minorUnits, currency);
  }

  /// 乘以**整数件数**（单价 × 数量）。
  Money operator *(int quantity) => Money._(minorUnits * quantity, currency);

  /// 乘以一个系数（税率、折扣率）。四舍五入到分，远离零。
  Money scale(num factor) => Money._(_roundHalfAwayFromZero(minorUnits * factor), currency);

  /// 按万分比取比例（`8500` = 85%）。用整数入参避免调用方传 `0.85` 这种 `double`。
  Money percentage(int basisPoints) =>
      Money._(_roundHalfAwayFromZero(minorUnits * basisPoints / 10000), currency);

  /// 取绝对值。
  Money abs() => Money._(minorUnits.abs(), currency);

  /// 取反（用于展示"抵扣项"）。
  ///
  /// Dart 不允许同时重载二元 `-` 和一元 `-`，所以用命名方法而不是运算符。
  Money negated() => Money._(-minorUnits, currency);

  /// 下限钳到 0。企划星 `updatePrice` 里的 `if (paymentAmount < 0) paymentAmount = 0`。
  Money atLeastZero() => isNegative ? Money.zero(currency) : this;

  /// 两者取小。礼品卡抵扣额 = `min(余额, 应付)`。
  Money min(Money other) {
    _assertSameCurrency(other);
    return minorUnits <= other.minorUnits ? this : other;
  }

  /// 两者取大。
  Money max(Money other) {
    _assertSameCurrency(other);
    return minorUnits >= other.minorUnits ? this : other;
  }

  /// 求和。空集合返回 [Money.zero]。
  static Money sum(Iterable<Money> amounts, {String currency = cny}) {
    var total = Money.zero(currency);
    for (final amount in amounts) {
      total += amount;
    }
    return total;
  }

  /// 展示用：`星币 1,234.56`。整额省略小数（`星币 1,000`），负数前缀带符号
  /// （`-星币 12`）。符号与数字之间的空格由这里的固定格式决定，UI 只负责排版。
  String format({bool withSymbol = true}) {
    final sign = isNegative ? '-' : '';
    final absolute = minorUnits.abs();
    final yuanPart = absolute ~/ 100;
    final centPart = absolute % 100;
    final grouped = _groupThousands(yuanPart.toString());
    final number = centPart == 0
        ? grouped
        : '$grouped.${centPart.toString().padLeft(2, '0')}';
    return withSymbol ? '$sign星币 $number' : '$sign$number';
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  bool operator <(Money other) => compareTo(other) < 0;

  bool operator <=(Money other) => compareTo(other) <= 0;

  bool operator >(Money other) => compareTo(other) > 0;

  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  List<Object?> get props => <Object?>[minorUnits, currency];

  @override
  String toString() => format();

  void _assertSameCurrency(Money other) {
    if (other.currency != currency) {
      throw CurrencyMismatchException(currency, other.currency);
    }
  }
}

int _roundHalfAwayFromZero(num value) =>
    value < 0 ? -((-value).round()) : value.round();

String _groupThousands(String digits) {
  if (digits.length <= 3) return digits;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
