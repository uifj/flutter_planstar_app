import 'package:core/domain.dart';

import 'ids.dart';

/// 证件类型（对齐企划星 `IdCardTypes`，`wiki_zh/modules/order-and-payment` §6.1）。
enum IdCardType {
  idCard(1),
  passport(2),
  hongKongPass(3),
  taiwanPass(4),
  hmtResidencePermit(5);

  const IdCardType(this.wireCode);

  final int wireCode;
}

/// 证件号。
///
/// ## 为什么要在值对象里校验
///
/// 企划星侧实名观演人的证件号**只判空**（`M5-07`，安全红旗）：`TextUtils.isEmpty` 之后
/// 直接进请求体。结果是脏数据一路流到出票环节，退改签时才发现姓名证件对不上。
///
/// 这里对身份证做 **GB 11643-1999 校验位**验算 + 出生日期合法性检查；
/// 护照/通行证做长度与字符集检查（没有公开校验位算法，不假装能校验）。
final class IdCardNumber extends ValueObject {
  IdCardNumber({required this.type, required String number})
    : value = _validate(type, number);

  static const List<int> _weights = <int>[
    7,
    9,
    10,
    5,
    8,
    4,
    2,
    1,
    6,
    3,
    7,
    9,
    10,
    5,
    8,
    4,
    2,
  ];
  static const String _checkChars = '10X98765432';
  static final RegExp _idPattern = RegExp(r'^\d{17}[\dX]$');
  static final RegExp _travelPattern = RegExp(r'^[A-Z0-9]{5,20}$');

  /// 证件类型。
  final IdCardType type;

  /// 证件号（身份证统一大写 `X`）。
  final String value;

  static String _validate(IdCardType type, String raw) {
    final normalized = raw.trim().toUpperCase();
    switch (type) {
      case IdCardType.idCard:
        if (!_idPattern.hasMatch(normalized)) {
          throw ArgumentError.value(raw, 'number', '身份证号应为 18 位（末位可为 X）');
        }
        if (!_isValidChecksum(normalized)) {
          throw ArgumentError.value(raw, 'number', '身份证校验位不正确');
        }
        if (!_hasValidBirthDate(normalized)) {
          throw ArgumentError.value(raw, 'number', '身份证里的出生日期不合法');
        }
        return normalized;
      case IdCardType.passport:
      case IdCardType.hongKongPass:
      case IdCardType.taiwanPass:
      case IdCardType.hmtResidencePermit:
        if (!_travelPattern.hasMatch(normalized)) {
          throw ArgumentError.value(
            raw,
            'number',
            '${type.name}号码应为 5–20 位字母数字',
          );
        }
        return normalized;
    }
  }

  static bool _isValidChecksum(String id) {
    var sum = 0;
    for (var i = 0; i < 17; i++) {
      sum += int.parse(id[i]) * _weights[i];
    }
    return _checkChars[sum % 11] == id[17];
  }

  static bool _hasValidBirthDate(String id) {
    final year = int.parse(id.substring(6, 10));
    final month = int.parse(id.substring(10, 12));
    final day = int.parse(id.substring(12, 14));
    if (year < 1900 || year > DateTime.now().year) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    final parsed = DateTime(year, month, day);
    return parsed.year == year && parsed.month == month && parsed.day == day;
  }

  /// 脱敏展示：保留前 3 位与后 4 位。
  String get masked =>
      '${value.substring(0, 3)}***********${value.substring(value.length - 4)}';

  @override
  List<Object?> get props => <Object?>[type, value];

  @override
  String toString() => '${type.name}($masked)';
}

/// 实名观演人。
///
/// 观演人是**值对象**而不是实体：同一个人（同证件号）在这一单里没有独立身份，
/// 换一张单子也还是"这个人"。企划星侧把它当 DTO 用，同一单里可以重复添加同一个人
/// （去重靠 UI 的选中态）——这里在聚合的 `assignVisitors` 里做去重。
final class Visitor extends ValueObject {
  Visitor({required this.id, required this.name, required this.idCard}) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', '观演人姓名不能为空');
    }
  }

  final VisitorId id;
  final String name;
  final IdCardNumber idCard;

  /// 去重键：同类型同证件号即同一个人。
  String get identityKey => '${idCard.type.wireCode}:${idCard.value}';

  @override
  List<Object?> get props => <Object?>[id, name, idCard];

  @override
  String toString() => '$name（${idCard.masked}）';
}
