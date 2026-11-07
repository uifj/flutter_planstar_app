import 'package:core/domain.dart';
import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/network/api_paths.dart';
import '../../marketing/wallet.dart';
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
/// | 签到状态 | GET | `v1/user/signIn` |
/// | 签到 | POST | `v1/user/signIn` |
/// | 星币账户 | GET | `v1/moneyaccount` |
/// | 星币流水 | GET | `v1/moneyaccount/sequences` |
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

  /// 签到状态。
  Future<Result<SignInStatus>> fetchSignIn() {
    return _client.get<SignInStatus>(
      ApiPaths.userSignIn,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => SignInStatus.fromJson(_asMap(data)),
    );
  }

  /// 提交签到。
  Future<Result<SignInStatus>> signIn() {
    return _client.post<SignInStatus>(
      ApiPaths.userSignIn,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => SignInStatus.fromJson(_asMap(data)),
    );
  }

  /// 星币账户。
  Future<Result<WalletAccountInfo>> fetchWallet() {
    return _client.get<WalletAccountInfo>(
      ApiPaths.moneyAccount,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => WalletAccountInfo.fromJson(_asMap(data)),
    );
  }

  /// 星币流水。
  Future<Result<List<WalletTransaction>>> fetchWalletSequences() {
    return _client.get<List<WalletTransaction>>(
      ApiPaths.moneyAccountSequences,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final items = _asMap(data)['items'];
        if (items is! List<dynamic>) return const <WalletTransaction>[];
        return items
            .whereType<Map<String, dynamic>>()
            .map(WalletTransaction.fromJson)
            .toList(growable: false);
      },
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

/// 签到状态（`GET/POST v1/user/signIn`）。
///
/// 接口示例把 `todayReward` 给成 `100`、UI 文案是「+100 星币」，因此这里
/// 按**星币个数**保存，展示时再乘 100 转成 [Money] 的最小单位。
final class SignInStatus {
  const SignInStatus({
    required this.signed,
    required this.todayReward,
    required this.balance,
    this.alreadySigned = false,
    this.signedAt,
  });

  factory SignInStatus.fromJson(Map<String, dynamic> json) {
    return SignInStatus(
      signed: json['signed'] == true,
      todayReward: _asInt(json['todayReward']) ?? 0,
      balance: Money.fromMinorUnits(_asInt(json['balance']) ?? 0),
      alreadySigned: json['alreadySigned'] == true,
      signedAt: _asTime(json['signedAt']),
    );
  }

  /// 未登录 / 未签到的占位状态。
  static const SignInStatus guest = SignInStatus(
    signed: false,
    todayReward: 100,
    balance: Money.zero(),
  );

  /// 今天是否已签到。
  final bool signed;

  /// 今日签到奖励（星币个数）。
  final int todayReward;

  /// 当前星币余额（最小单位：分）。
  final Money balance;

  /// 本次提交是否属于重复签到。
  final bool alreadySigned;

  /// 签到时间。
  final DateTime? signedAt;

  /// 奖励金额（展示用）。
  Money get rewardMoney => Money.fromMinorUnits(todayReward * 100);
}

/// 星币账户（`GET v1/moneyaccount`）。
final class WalletAccountInfo {
  const WalletAccountInfo({
    required this.accountId,
    required this.balance,
    required this.currency,
    required this.status,
  });

  factory WalletAccountInfo.fromJson(Map<String, dynamic> json) {
    return WalletAccountInfo(
      accountId: _asInt(json['accountId']) ?? 0,
      balance: Money.fromMinorUnits(_asInt(json['balance']) ?? 0),
      currency: json['currency']?.toString() ?? '',
      status: _asInt(json['status']) ?? 0,
    );
  }

  final int accountId;
  final Money balance;
  final String currency;
  final int status;
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

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map<Object?, Object?>) {
    return value.map(
      (Object? key, Object? item) => MapEntry<String, dynamic>('$key', item),
    );
  }
  return const <String, dynamic>{};
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _asTime(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
