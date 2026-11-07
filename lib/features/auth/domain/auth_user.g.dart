// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => _AuthUser(
  userId: (_readUserId(json, 'userId') as num).toInt(),
  userName: _readUserName(json, 'userName') as String?,
  avatar: _readAvatar(json, 'avatar') as String? ?? '',
  bio: _readBio(json, 'bio') as String?,
  gender: (_readGender(json, 'gender') as num?)?.toInt() ?? 0,
  birthday: (_readBirthday(json, 'birthday') as num?)?.toInt() ?? 0,
  mobileNo: _readMobileNo(json, 'mobileNo') as String?,
  level: (_readLevel(json, 'level') as num?)?.toInt() ?? 0,
  followerNum: (_readFollowerNum(json, 'followerNum') as num?)?.toInt() ?? 0,
  followingNum: (_readFollowingNum(json, 'followingNum') as num?)?.toInt() ?? 0,
  wantWatchNum: (_readWantWatchNum(json, 'wantWatchNum') as num?)?.toInt() ?? 0,
  isDouliUser: _readIsDouliUser(json, 'isDouliUser') as bool? ?? false,
  badgeIcon: _readBadgeIcon(json, 'badgeIcon') as String?,
);

Map<String, dynamic> _$AuthUserToJson(_AuthUser instance) => <String, dynamic>{
  'userId': instance.userId,
  'userName': instance.userName,
  'avatar': instance.avatar,
  'bio': instance.bio,
  'gender': instance.gender,
  'birthday': instance.birthday,
  'mobileNo': instance.mobileNo,
  'level': instance.level,
  'followerNum': instance.followerNum,
  'followingNum': instance.followingNum,
  'wantWatchNum': instance.wantWatchNum,
  'isDouliUser': instance.isDouliUser,
  'badgeIcon': instance.badgeIcon,
};
