import 'package:core/network.dart';
import 'package:core/result.dart';

import '../../../app/network/api_paths.dart';
import '../domain/shipping_address.dart';

/// 用户 API。
///
/// ## 端点
///
/// | 用途 | 方法 | 路径 |
/// |---|---|---|
/// | 个人资料 | GET | `v1/user` |
/// | 地址列表 | GET | `v1/myaddress` |
/// | 添加地址 | POST | `v1/myaddress` |
/// | 删除地址 | DELETE | `v1/myaddress/{id}` |
/// | 设为默认地址 | POST | `v1/myaddress/default/{id}` |
///
/// 批量用户信息（`v1/user/users`）与修改资料（`PUT v1/user/baseInfo`）后端
/// 未实现，不封装。
final class PlanstarUserApi {
  PlanstarUserApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  /// 个人资料。
  Future<Result<UserProfileDto>> fetchProfile() {
    return _client.get<UserProfileDto>(
      ApiPaths.userProfile,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is! Map<String, dynamic>) {
          throw FormatException('用户资料不是对象：$data');
        }
        return UserProfileDto.fromJson(data);
      },
    );
  }

  /// 地址列表。
  Future<Result<List<ShippingAddress>>> fetchAddresses() {
    return _client.get<List<ShippingAddress>>(
      ApiPaths.addresses,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final list = data as List<dynamic>? ?? <dynamic>[];
        return list
            .whereType<Map<String, dynamic>>()
            .map(_parseAddress)
            .toList(growable: false);
      },
    );
  }

  /// 添加地址。
  Future<Result<ShippingAddress>> addAddress(ShippingAddress address) {
    return _client.post<ShippingAddress>(
      ApiPaths.addresses,
      data: _addressToJson(address),
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is! Map<String, dynamic>) throw FormatException('地址响应不是对象');
        return _parseAddress(data);
      },
    );
  }

  /// 删除地址。
  Future<Result<void>> deleteAddress(String id) {
    return _client.delete<void>(
      ApiPaths.addressDelete(id),
      envelope: const PassthroughEnvelope(),
      parser: (_) {},
    );
  }

  /// 设为默认地址。
  Future<Result<void>> setDefaultAddress(String id) {
    return _client.post<void>(
      ApiPaths.addressDefault(id),
      envelope: const PassthroughEnvelope(),
      parser: (_) {},
    );
  }

  static ShippingAddress _parseAddress(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['consignee']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? json['phone']?.toString() ?? '',
      region:
          json['region']?.toString() ??
          '${json['province']?.toString() ?? ''} ${json['city']?.toString() ?? ''} ${json['district']?.toString() ?? ''}'
              .trim(),
      detail: json['detail']?.toString() ?? json['address']?.toString() ?? '',
      isDefault: json['isDefault'] == true || json['default'] == true,
    );
  }

  static Map<String, dynamic> _addressToJson(ShippingAddress address) {
    return <String, dynamic>{
      'name': address.name,
      'mobile': address.mobile,
      'region': address.region,
      'detail': address.detail,
      'isDefault': address.isDefault,
    };
  }
}

/// 用户资料 DTO。
///
/// 企划星 `v1/user/` 返回的字段非常多，这里只提取 UI 需要的。
final class UserProfileDto {
  const UserProfileDto({
    required this.userId,
    required this.nickname,
    this.avatarUrl,
    this.mobile,
    this.level = 0,
    this.levelLabel = '',
    this.wannaSeeCount = 0,
    this.followCount = 0,
    this.couponCount = 0,
    this.walletBalance = 0,
  });

  final String userId;
  final String nickname;
  final String? avatarUrl;
  final String? mobile;
  final int level;
  final String levelLabel;
  final int wannaSeeCount;
  final int followCount;
  final int couponCount;
  final int walletBalance; // 单位：分

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      nickname:
          json['nickname']?.toString() ?? json['userName']?.toString() ?? '',
      avatarUrl: json['avatar']?.toString() ?? json['headImg']?.toString(),
      mobile: json['mobile']?.toString() ?? json['phone']?.toString(),
      level: json['level'] ?? json['userLevel'] ?? 0,
      levelLabel: json['levelLabel']?.toString() ?? '',
      wannaSeeCount: json['wannaSeeCount'] ?? json['followActivityCount'] ?? 0,
      followCount: json['followCount'] ?? json['followUserCount'] ?? 0,
      couponCount: json['couponCount'] ?? 0,
      walletBalance: json['walletBalance'] ?? json['balance'] ?? 0,
    );
  }
}
