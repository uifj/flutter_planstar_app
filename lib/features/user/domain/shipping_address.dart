import 'package:freezed_annotation/freezed_annotation.dart';

part 'shipping_address.freezed.dart';
part 'shipping_address.g.dart';

/// 收货地址。
///
/// 只建模"寄送线下回报"需要的字段。`tag`（家/公司）/ `longitude` / `latitude`
/// 都不收——经纬度是给地图选点用的，本项目没有地图选点；
/// `tag` 没有 UI 入口。
@freezed
abstract class ShippingAddress with _$ShippingAddress {
  const ShippingAddress._();

  const factory ShippingAddress({
    @JsonKey(readValue: _readId) required String id,
    @JsonKey(readValue: _readName) required String name,
    @JsonKey(readValue: _readMobile) required String mobile,
    @JsonKey(readValue: _readRegion) required String region,
    @JsonKey(readValue: _readDetail) required String detail,
    @JsonKey(readValue: _readIsDefault) @Default(false) bool isDefault,
  }) = _ShippingAddress;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      _$ShippingAddressFromJson(json);

  /// 完整地址。
  String get fullAddress => '$region $detail';

  /// 脱敏手机号：`138****8000`。
  String get maskedMobile {
    if (mobile.length < 7) return mobile;
    return '${mobile.substring(0, 3)}****${mobile.substring(mobile.length - 4)}';
  }
}

// ── JSON 兼容读取 ───────────────────────────────────────────────────────

Object? _readId(Map<dynamic, dynamic> json, String key) =>
    json['id']?.toString() ?? '';

Object? _readName(Map<dynamic, dynamic> json, String key) =>
    json['name']?.toString() ?? json['consignee']?.toString() ?? '';

Object? _readMobile(Map<dynamic, dynamic> json, String key) =>
    json['mobile']?.toString() ?? json['phone']?.toString() ?? '';

Object? _readRegion(Map<dynamic, dynamic> json, String key) =>
    json['region']?.toString() ??
    '${json['province']?.toString() ?? ''} '
            '${json['city']?.toString() ?? ''} '
            '${json['district']?.toString() ?? ''}'
        .trim();

Object? _readDetail(Map<dynamic, dynamic> json, String key) =>
    json['detail']?.toString() ?? json['address']?.toString() ?? '';

Object? _readIsDefault(Map<dynamic, dynamic> json, String key) =>
    json['isDefault'] == true || json['default'] == true;
