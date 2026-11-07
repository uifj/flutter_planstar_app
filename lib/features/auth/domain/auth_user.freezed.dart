// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthUser {

/// 用户 id。未登录时来源用 `-1` 表示（`AccountService.userId()`）。
@JsonKey(readValue: _readUserId) int get userId;/// 昵称。
@JsonKey(readValue: _readUserName) String? get userName;/// 头像 URL。空串表示没设置（来源 `UserBean.avatar` 默认 `""`）。
@JsonKey(readValue: _readAvatar) String get avatar;/// 个性签名。
@JsonKey(readValue: _readBio) String? get bio;/// 性别：0 未设置 / 1 男 / 2 女（来源 `UserBean.gender`）。
@JsonKey(readValue: _readGender) int get gender;/// 生日（毫秒时间戳）。0 表示未设置。
@JsonKey(readValue: _readBirthday) int get birthday;/// 手机号（服务端返回的可能是脱敏后的）。
@JsonKey(readValue: _readMobileNo) String? get mobileNo;/// 等级（"我的"页的等级胶囊）。
@JsonKey(readValue: _readLevel) int get level;/// 粉丝数。
@JsonKey(readValue: _readFollowerNum) int get followerNum;/// 关注数。
@JsonKey(readValue: _readFollowingNum) int get followingNum;/// 想看数。
@JsonKey(readValue: _readWantWatchNum) int get wantWatchNum;/// 是否兜礼用户（"兜礼"角标）。
@JsonKey(readValue: _readIsDouliUser) bool get isDouliUser;/// 等级图标 URL。
@JsonKey(readValue: _readBadgeIcon) String? get badgeIcon;
/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUserCopyWith<AuthUser> get copyWith => _$AuthUserCopyWithImpl<AuthUser>(this as AuthUser, _$identity);

  /// Serializes this AuthUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUser&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.mobileNo, mobileNo) || other.mobileNo == mobileNo)&&(identical(other.level, level) || other.level == level)&&(identical(other.followerNum, followerNum) || other.followerNum == followerNum)&&(identical(other.followingNum, followingNum) || other.followingNum == followingNum)&&(identical(other.wantWatchNum, wantWatchNum) || other.wantWatchNum == wantWatchNum)&&(identical(other.isDouliUser, isDouliUser) || other.isDouliUser == isDouliUser)&&(identical(other.badgeIcon, badgeIcon) || other.badgeIcon == badgeIcon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,userName,avatar,bio,gender,birthday,mobileNo,level,followerNum,followingNum,wantWatchNum,isDouliUser,badgeIcon);



}

/// @nodoc
abstract mixin class $AuthUserCopyWith<$Res>  {
  factory $AuthUserCopyWith(AuthUser value, $Res Function(AuthUser) _then) = _$AuthUserCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readUserId) int userId,@JsonKey(readValue: _readUserName) String? userName,@JsonKey(readValue: _readAvatar) String avatar,@JsonKey(readValue: _readBio) String? bio,@JsonKey(readValue: _readGender) int gender,@JsonKey(readValue: _readBirthday) int birthday,@JsonKey(readValue: _readMobileNo) String? mobileNo,@JsonKey(readValue: _readLevel) int level,@JsonKey(readValue: _readFollowerNum) int followerNum,@JsonKey(readValue: _readFollowingNum) int followingNum,@JsonKey(readValue: _readWantWatchNum) int wantWatchNum,@JsonKey(readValue: _readIsDouliUser) bool isDouliUser,@JsonKey(readValue: _readBadgeIcon) String? badgeIcon
});




}
/// @nodoc
class _$AuthUserCopyWithImpl<$Res>
    implements $AuthUserCopyWith<$Res> {
  _$AuthUserCopyWithImpl(this._self, this._then);

  final AuthUser _self;
  final $Res Function(AuthUser) _then;

/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? userName = freezed,Object? avatar = null,Object? bio = freezed,Object? gender = null,Object? birthday = null,Object? mobileNo = freezed,Object? level = null,Object? followerNum = null,Object? followingNum = null,Object? wantWatchNum = null,Object? isDouliUser = null,Object? badgeIcon = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,avatar: null == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int,birthday: null == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as int,mobileNo: freezed == mobileNo ? _self.mobileNo : mobileNo // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,followerNum: null == followerNum ? _self.followerNum : followerNum // ignore: cast_nullable_to_non_nullable
as int,followingNum: null == followingNum ? _self.followingNum : followingNum // ignore: cast_nullable_to_non_nullable
as int,wantWatchNum: null == wantWatchNum ? _self.wantWatchNum : wantWatchNum // ignore: cast_nullable_to_non_nullable
as int,isDouliUser: null == isDouliUser ? _self.isDouliUser : isDouliUser // ignore: cast_nullable_to_non_nullable
as bool,badgeIcon: freezed == badgeIcon ? _self.badgeIcon : badgeIcon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthUser].
extension AuthUserPatterns on AuthUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthUser value)  $default,){
final _that = this;
switch (_that) {
case _AuthUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthUser value)?  $default,){
final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readUserId)  int userId, @JsonKey(readValue: _readUserName)  String? userName, @JsonKey(readValue: _readAvatar)  String avatar, @JsonKey(readValue: _readBio)  String? bio, @JsonKey(readValue: _readGender)  int gender, @JsonKey(readValue: _readBirthday)  int birthday, @JsonKey(readValue: _readMobileNo)  String? mobileNo, @JsonKey(readValue: _readLevel)  int level, @JsonKey(readValue: _readFollowerNum)  int followerNum, @JsonKey(readValue: _readFollowingNum)  int followingNum, @JsonKey(readValue: _readWantWatchNum)  int wantWatchNum, @JsonKey(readValue: _readIsDouliUser)  bool isDouliUser, @JsonKey(readValue: _readBadgeIcon)  String? badgeIcon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that.userId,_that.userName,_that.avatar,_that.bio,_that.gender,_that.birthday,_that.mobileNo,_that.level,_that.followerNum,_that.followingNum,_that.wantWatchNum,_that.isDouliUser,_that.badgeIcon);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readUserId)  int userId, @JsonKey(readValue: _readUserName)  String? userName, @JsonKey(readValue: _readAvatar)  String avatar, @JsonKey(readValue: _readBio)  String? bio, @JsonKey(readValue: _readGender)  int gender, @JsonKey(readValue: _readBirthday)  int birthday, @JsonKey(readValue: _readMobileNo)  String? mobileNo, @JsonKey(readValue: _readLevel)  int level, @JsonKey(readValue: _readFollowerNum)  int followerNum, @JsonKey(readValue: _readFollowingNum)  int followingNum, @JsonKey(readValue: _readWantWatchNum)  int wantWatchNum, @JsonKey(readValue: _readIsDouliUser)  bool isDouliUser, @JsonKey(readValue: _readBadgeIcon)  String? badgeIcon)  $default,) {final _that = this;
switch (_that) {
case _AuthUser():
return $default(_that.userId,_that.userName,_that.avatar,_that.bio,_that.gender,_that.birthday,_that.mobileNo,_that.level,_that.followerNum,_that.followingNum,_that.wantWatchNum,_that.isDouliUser,_that.badgeIcon);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readUserId)  int userId, @JsonKey(readValue: _readUserName)  String? userName, @JsonKey(readValue: _readAvatar)  String avatar, @JsonKey(readValue: _readBio)  String? bio, @JsonKey(readValue: _readGender)  int gender, @JsonKey(readValue: _readBirthday)  int birthday, @JsonKey(readValue: _readMobileNo)  String? mobileNo, @JsonKey(readValue: _readLevel)  int level, @JsonKey(readValue: _readFollowerNum)  int followerNum, @JsonKey(readValue: _readFollowingNum)  int followingNum, @JsonKey(readValue: _readWantWatchNum)  int wantWatchNum, @JsonKey(readValue: _readIsDouliUser)  bool isDouliUser, @JsonKey(readValue: _readBadgeIcon)  String? badgeIcon)?  $default,) {final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that.userId,_that.userName,_that.avatar,_that.bio,_that.gender,_that.birthday,_that.mobileNo,_that.level,_that.followerNum,_that.followingNum,_that.wantWatchNum,_that.isDouliUser,_that.badgeIcon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthUser extends AuthUser {
  const _AuthUser({@JsonKey(readValue: _readUserId) required this.userId, @JsonKey(readValue: _readUserName) this.userName, @JsonKey(readValue: _readAvatar) this.avatar = '', @JsonKey(readValue: _readBio) this.bio, @JsonKey(readValue: _readGender) this.gender = 0, @JsonKey(readValue: _readBirthday) this.birthday = 0, @JsonKey(readValue: _readMobileNo) this.mobileNo, @JsonKey(readValue: _readLevel) this.level = 0, @JsonKey(readValue: _readFollowerNum) this.followerNum = 0, @JsonKey(readValue: _readFollowingNum) this.followingNum = 0, @JsonKey(readValue: _readWantWatchNum) this.wantWatchNum = 0, @JsonKey(readValue: _readIsDouliUser) this.isDouliUser = false, @JsonKey(readValue: _readBadgeIcon) this.badgeIcon}): super._();
  factory _AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);

/// 用户 id。未登录时来源用 `-1` 表示（`AccountService.userId()`）。
@override@JsonKey(readValue: _readUserId) final  int userId;
/// 昵称。
@override@JsonKey(readValue: _readUserName) final  String? userName;
/// 头像 URL。空串表示没设置（来源 `UserBean.avatar` 默认 `""`）。
@override@JsonKey(readValue: _readAvatar) final  String avatar;
/// 个性签名。
@override@JsonKey(readValue: _readBio) final  String? bio;
/// 性别：0 未设置 / 1 男 / 2 女（来源 `UserBean.gender`）。
@override@JsonKey(readValue: _readGender) final  int gender;
/// 生日（毫秒时间戳）。0 表示未设置。
@override@JsonKey(readValue: _readBirthday) final  int birthday;
/// 手机号（服务端返回的可能是脱敏后的）。
@override@JsonKey(readValue: _readMobileNo) final  String? mobileNo;
/// 等级（"我的"页的等级胶囊）。
@override@JsonKey(readValue: _readLevel) final  int level;
/// 粉丝数。
@override@JsonKey(readValue: _readFollowerNum) final  int followerNum;
/// 关注数。
@override@JsonKey(readValue: _readFollowingNum) final  int followingNum;
/// 想看数。
@override@JsonKey(readValue: _readWantWatchNum) final  int wantWatchNum;
/// 是否兜礼用户（"兜礼"角标）。
@override@JsonKey(readValue: _readIsDouliUser) final  bool isDouliUser;
/// 等级图标 URL。
@override@JsonKey(readValue: _readBadgeIcon) final  String? badgeIcon;

/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthUserCopyWith<_AuthUser> get copyWith => __$AuthUserCopyWithImpl<_AuthUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthUser&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.mobileNo, mobileNo) || other.mobileNo == mobileNo)&&(identical(other.level, level) || other.level == level)&&(identical(other.followerNum, followerNum) || other.followerNum == followerNum)&&(identical(other.followingNum, followingNum) || other.followingNum == followingNum)&&(identical(other.wantWatchNum, wantWatchNum) || other.wantWatchNum == wantWatchNum)&&(identical(other.isDouliUser, isDouliUser) || other.isDouliUser == isDouliUser)&&(identical(other.badgeIcon, badgeIcon) || other.badgeIcon == badgeIcon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,userName,avatar,bio,gender,birthday,mobileNo,level,followerNum,followingNum,wantWatchNum,isDouliUser,badgeIcon);



}

/// @nodoc
abstract mixin class _$AuthUserCopyWith<$Res> implements $AuthUserCopyWith<$Res> {
  factory _$AuthUserCopyWith(_AuthUser value, $Res Function(_AuthUser) _then) = __$AuthUserCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readUserId) int userId,@JsonKey(readValue: _readUserName) String? userName,@JsonKey(readValue: _readAvatar) String avatar,@JsonKey(readValue: _readBio) String? bio,@JsonKey(readValue: _readGender) int gender,@JsonKey(readValue: _readBirthday) int birthday,@JsonKey(readValue: _readMobileNo) String? mobileNo,@JsonKey(readValue: _readLevel) int level,@JsonKey(readValue: _readFollowerNum) int followerNum,@JsonKey(readValue: _readFollowingNum) int followingNum,@JsonKey(readValue: _readWantWatchNum) int wantWatchNum,@JsonKey(readValue: _readIsDouliUser) bool isDouliUser,@JsonKey(readValue: _readBadgeIcon) String? badgeIcon
});




}
/// @nodoc
class __$AuthUserCopyWithImpl<$Res>
    implements _$AuthUserCopyWith<$Res> {
  __$AuthUserCopyWithImpl(this._self, this._then);

  final _AuthUser _self;
  final $Res Function(_AuthUser) _then;

/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? userName = freezed,Object? avatar = null,Object? bio = freezed,Object? gender = null,Object? birthday = null,Object? mobileNo = freezed,Object? level = null,Object? followerNum = null,Object? followingNum = null,Object? wantWatchNum = null,Object? isDouliUser = null,Object? badgeIcon = freezed,}) {
  return _then(_AuthUser(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,avatar: null == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int,birthday: null == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as int,mobileNo: freezed == mobileNo ? _self.mobileNo : mobileNo // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,followerNum: null == followerNum ? _self.followerNum : followerNum // ignore: cast_nullable_to_non_nullable
as int,followingNum: null == followingNum ? _self.followingNum : followingNum // ignore: cast_nullable_to_non_nullable
as int,wantWatchNum: null == wantWatchNum ? _self.wantWatchNum : wantWatchNum // ignore: cast_nullable_to_non_nullable
as int,isDouliUser: null == isDouliUser ? _self.isDouliUser : isDouliUser // ignore: cast_nullable_to_non_nullable
as bool,badgeIcon: freezed == badgeIcon ? _self.badgeIcon : badgeIcon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
