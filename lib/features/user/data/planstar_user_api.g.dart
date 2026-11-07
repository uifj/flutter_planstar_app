// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planstar_user_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfileDto _$UserProfileDtoFromJson(
  Map<String, dynamic> json,
) => _UserProfileDto(
  userId: _readUserId(json, 'userId') as String,
  nickname: _readNickname(json, 'nickname') as String,
  avatarUrl: _readAvatarUrl(json, 'avatarUrl') as String?,
  mobile: _readMobile(json, 'mobile') as String?,
  level: (_readLevel(json, 'level') as num?)?.toInt() ?? 0,
  levelLabel: _readLevelLabel(json, 'levelLabel') as String? ?? '',
  wannaSeeCount:
      (_readWannaSeeCount(json, 'wannaSeeCount') as num?)?.toInt() ?? 0,
  followCount: (_readFollowCount(json, 'followCount') as num?)?.toInt() ?? 0,
  couponCount: (_readCouponCount(json, 'couponCount') as num?)?.toInt() ?? 0,
  walletBalance:
      (_readWalletBalance(json, 'walletBalance') as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserProfileDtoToJson(_UserProfileDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'avatarUrl': instance.avatarUrl,
      'mobile': instance.mobile,
      'level': instance.level,
      'levelLabel': instance.levelLabel,
      'wannaSeeCount': instance.wannaSeeCount,
      'followCount': instance.followCount,
      'couponCount': instance.couponCount,
      'walletBalance': instance.walletBalance,
    };
