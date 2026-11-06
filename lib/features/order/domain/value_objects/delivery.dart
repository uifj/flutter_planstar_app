import 'package:core/domain.dart';

/// 手机号（中国大陆 11 位）。
///
/// 企划星侧手机号是 `String`，校验散落在 `TextUtils.isEmpty` 和几个手写正则里。
/// 抽成值对象后，"能不能下单"不再取决于某个输入框有没有做校验。
final class PhoneNumber extends ValueObject {
  PhoneNumber(String raw) : value = _validate(raw);

  static final RegExp _pattern = RegExp(r'^1[3-9]\d{9}$');

  final String value;

  static String _validate(String raw) {
    final digits = raw.replaceAll(RegExp(r'[\s-]'), '');
    if (!_pattern.hasMatch(digits)) {
      throw ArgumentError.value(raw, 'raw', '手机号格式不正确');
    }
    return digits;
  }

  /// 脱敏展示：`138****8000`。
  String get masked => '${value.substring(0, 3)}****${value.substring(7)}';

  @override
  List<Object?> get props => <Object?>[value];

  @override
  String toString() => value;
}

/// 收货地址。
final class ShippingAddress extends ValueObject {
  ShippingAddress({
    required this.province,
    required this.city,
    required this.detail,
  }) {
    if (province.trim().isEmpty || city.trim().isEmpty || detail.trim().isEmpty) {
      throw ArgumentError('省 / 市 / 详细地址都不能为空');
    }
  }

  final String province;
  final String city;
  final String detail;

  /// 拼接成一行展示。
  String get full => '$province$city$detail';

  @override
  List<Object?> get props => <Object?>[province, city, detail];
}

/// 收件人。
final class Receiver extends ValueObject {
  Receiver({required this.name, required this.phone, required this.address}) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', '收件人不能为空');
    }
  }

  final String name;
  final PhoneNumber phone;
  final ShippingAddress address;

  @override
  List<Object?> get props => <Object?>[name, phone, address];
}

/// 取票方式。
///
/// 企划星 `DeliverType` 有 7 个值（还带个拼错的 `UNKOWN`），这里只保留真正
/// 影响金额与流程的三种：电子票（无运费）、快递（有运费、必须有收件人）、
/// 现场自取（无运费、无地址）。
enum DeliveryMethod {
  /// 电子票：出票后直接进"我的票夹"。
  electronic('电子票', requiresReceiver: false, requiresPostage: false),

  /// 纸质票快递。
  express('快递配送', requiresReceiver: true, requiresPostage: true),

  /// 现场自取。
  selfPickup('现场自取', requiresReceiver: false, requiresPostage: false);

  const DeliveryMethod(
    this.label, {
    required this.requiresReceiver,
    required this.requiresPostage,
  });

  final String label;

  /// 是否必须有收件人信息。
  final bool requiresReceiver;

  /// 是否产生运费。
  final bool requiresPostage;
}

/// 配送信息：方式 + 运费（+ 收件人）。
///
/// 运费是**订单总额的一部分**（企划星 `totalAmount = goodTotalAmount + postage + splitOrderFee`），
/// 所以它必须跟着配送方式走，而不是散在页面状态里。
final class DeliveryInfo extends ValueObject {
  DeliveryInfo({
    required this.method,
    required this.postage,
    this.receiver,
  }) {
    if (method.requiresReceiver && receiver == null) {
      throw ArgumentError('${method.label}必须提供收件人信息');
    }
    if (!method.requiresPostage && !postage.isZero) {
      throw ArgumentError('${method.label}不应产生运费');
    }
    if (postage.isNegative) {
      throw ArgumentError.value(postage, 'postage', '运费不能为负');
    }
  }

  /// 电子票（零运费、无收件人）。
  factory DeliveryInfo.electronic() =>
      DeliveryInfo(method: DeliveryMethod.electronic, postage: Money.zero());

  final DeliveryMethod method;

  /// 运费。
  final Money postage;

  /// 收件人（快递必填）。
  final Receiver? receiver;

  /// 展示文案：`快递配送（¥12.00）`。
  String describe() =>
      postage.isZero ? method.label : '${method.label}（${postage.format()}）';

  @override
  List<Object?> get props => <Object?>[method, postage, receiver];
}
