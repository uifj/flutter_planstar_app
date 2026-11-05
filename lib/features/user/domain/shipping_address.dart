/// 收货地址（企划星 `AddressListActivity` + `item_address.xml`）。
///
/// 只建模"寄纸质票"需要的字段。企划星侧还有 `isDefault` / `tag`（家/公司）/
/// `longitude` / `latitude`——经纬度是给地图选点用的，本项目没有地图选点，
/// 所以不收；`tag` 没有 UI 入口，也不收。
final class ShippingAddress {
  const ShippingAddress({
    required this.id,
    required this.name,
    required this.mobile,
    required this.region,
    required this.detail,
    this.isDefault = false,
  });

  final String id;

  /// 收件人。
  final String name;

  /// 手机号（存完整值，展示时脱敏）。
  final String mobile;

  /// 省市区（`上海市 浦东新区`）。
  final String region;

  /// 详细地址。
  final String detail;

  /// 是否默认地址。**全列表最多一个为真**，由控制器保证。
  final bool isDefault;

  /// 完整地址。
  String get fullAddress => '$region $detail';

  /// 脱敏手机号：`138****8000`。
  String get maskedMobile {
    if (mobile.length < 7) return mobile;
    return '${mobile.substring(0, 3)}****${mobile.substring(mobile.length - 4)}';
  }

  ShippingAddress copyWith({bool? isDefault}) {
    return ShippingAddress(
      id: id,
      name: name,
      mobile: mobile,
      region: region,
      detail: detail,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
