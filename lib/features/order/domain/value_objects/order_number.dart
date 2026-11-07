import 'package:core/domain.dart';

/// 订单号：`PN` + `yyyyMMdd` + 6 位序号，例 `PN20261101000123`。
///
/// 为什么要值对象：企划星侧订单号是散落的 `String`，前端没有任何格式校验，
/// 展示层（我的订单、支付页、客服工单）各自拼各自的。抽成值对象后，
/// 格式只在一处定义，且**非法订单号在构造时就被拒绝**，不会流到网络请求里。
final class OrderNumber extends ValueObject {
  OrderNumber(String raw) : value = _validate(raw);

  /// 生成：日期 + 当日序号。
  ///
  /// 序号由 `OrderNumberSequence` 端口提供，值对象本身不碰时钟/存储。
  factory OrderNumber.generate({
    required DateTime date,
    required int sequence,
  }) {
    if (sequence < 0 || sequence > 999999) {
      throw ArgumentError.value(sequence, 'sequence', '序号必须在 0..999999 之间');
    }
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return OrderNumber('PN$y$m$d${sequence.toString().padLeft(6, '0')}');
  }

  static final RegExp _pattern = RegExp(r'^PN\d{14,20}$');

  /// 订单号本体。
  final String value;

  static String _validate(String raw) {
    final trimmed = raw.trim().toUpperCase();
    if (!_pattern.hasMatch(trimmed)) {
      throw ArgumentError.value(raw, 'raw', '订单号格式应为 PN + 日期 + 序号');
    }
    return trimmed;
  }

  /// 下单日期段（`yyyyMMdd`）。
  String get datePart => value.substring(2, 10);

  @override
  List<Object?> get props => <Object?>[value];

  @override
  String toString() => value;
}
