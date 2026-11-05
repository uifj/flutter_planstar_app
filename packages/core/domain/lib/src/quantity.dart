/// `Quantity`：件数。**永远非负、永远整数**。
///
/// 企划星 Android 侧的件数散落在 `int` 里（`mCounts`、`goods.count`、`idCard.count`），
/// 校验靠调用点各自 `if (count <= 0)`。抽成值对象后，"件数不能为负"
/// 只需要在一个地方保证。
library;

import 'value_object.dart';

/// 件数。
final class Quantity extends ValueObject implements Comparable<Quantity> {
  const Quantity._(this.value);

  /// 零件。
  static const Quantity zero = Quantity._(0);

  /// 构造并校验。
  ///
  /// 负数抛 [ArgumentError]——这是**编程错误**（用户输入应该先过
  /// [tryCreate] 或聚合的 `Result` 校验），不是业务错误。
  factory Quantity(int value) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value', '件数不能为负');
    }
    return Quantity._(value);
  }

  /// 安全构造：负数返回 `null`，供解析外部输入时用。
  static Quantity? tryCreate(int value) => value < 0 ? null : Quantity._(value);

  /// 件数。
  final int value;

  bool get isZero => value == 0;

  bool get isPositive => value > 0;

  Quantity operator +(Quantity other) => Quantity._(value + other.value);

  /// 减法。结果为负时抛 [StateError]——调用方必须先判断，
  /// 否则"1 张票减 2 张"会静默变成 -1 并流进金额计算。
  Quantity operator -(Quantity other) {
    if (other.value > value) {
      throw StateError('件数不足：$value - ${other.value}');
    }
    return Quantity._(value - other.value);
  }

  /// 是否超过上限（限购）。
  bool exceeds(Quantity limit) => value > limit.value;

  @override
  int compareTo(Quantity other) => value.compareTo(other.value);

  @override
  List<Object?> get props => <Object?>[value];

  @override
  String toString() => '$value';
}
