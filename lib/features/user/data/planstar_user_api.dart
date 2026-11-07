import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/network/api_paths.dart';
import '../domain/shipping_address.dart';

part 'planstar_user_api.freezed.dart';
part 'planstar_user_api.g.dart';

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
            .map(ShippingAddress.fromJson)
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
        return ShippingAddress.fromJson(data);
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
@freezed
abstract class UserProfileDto with _$UserProfileDto {
  const factory UserProfileDto({
    @JsonKey(readValue: _readUserId) required String userId,
    @JsonKey(readValue: _readNickname) required String nickname,
    @JsonKey(readValue: _readAvatarUrl) String? avatarUrl,
    @JsonKey(readValue: _readMobile) String? mobile,
    @JsonKey(readValue: _readLevel) @Default(0) int level,
    @JsonKey(readValue: _readLevelLabel) @Default('') String levelLabel,
    @JsonKey(readValue: _readWannaSeeCount) @Default(0) int wannaSeeCount,
    @JsonKey(readValue: _readFollowCount) @Default(0) int followCount,
    @JsonKey(readValue: _readCouponCount) @Default(0) int couponCount,

    /// 单位：分
    @JsonKey(readValue: _readWalletBalance) @Default(0) int walletBalance,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);
}

// ── JSON 兼容读取 ───────────────────────────────────────────────────────

Object? _readUserId(Map<dynamic, dynamic> json, String key) =>
    json['userId']?.toString() ?? json['id']?.toString() ?? '';

Object? _readNickname(Map<dynamic, dynamic> json, String key) =>
    json['nickname']?.toString() ?? json['userName']?.toString() ?? '';

Object? _readAvatarUrl(Map<dynamic, dynamic> json, String key) =>
    json['avatar']?.toString() ?? json['headImg']?.toString();

Object? _readMobile(Map<dynamic, dynamic> json, String key) =>
    json['mobile']?.toString() ?? json['phone']?.toString();

Object? _readLevel(Map<dynamic, dynamic> json, String key) =>
    json['level'] ?? json['userLevel'] ?? 0;

Object? _readLevelLabel(Map<dynamic, dynamic> json, String key) =>
    json['levelLabel']?.toString() ?? '';

Object? _readWannaSeeCount(Map<dynamic, dynamic> json, String key) =>
    json['wannaSeeCount'] ?? json['followActivityCount'] ?? 0;

Object? _readFollowCount(Map<dynamic, dynamic> json, String key) =>
    json['followCount'] ?? json['followUserCount'] ?? 0;

Object? _readCouponCount(Map<dynamic, dynamic> json, String key) =>
    json['couponCount'] ?? 0;

Object? _readWalletBalance(Map<dynamic, dynamic> json, String key) =>
    json['walletBalance'] ?? json['balance'] ?? 0;
