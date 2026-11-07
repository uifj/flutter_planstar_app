// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planstar_user_api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfileDto {

@JsonKey(readValue: _readUserId) String get userId;@JsonKey(readValue: _readNickname) String get nickname;@JsonKey(readValue: _readAvatarUrl) String? get avatarUrl;@JsonKey(readValue: _readMobile) String? get mobile;@JsonKey(readValue: _readLevel) int get level;@JsonKey(readValue: _readLevelLabel) String get levelLabel;@JsonKey(readValue: _readWannaSeeCount) int get wannaSeeCount;@JsonKey(readValue: _readFollowCount) int get followCount;@JsonKey(readValue: _readCouponCount) int get couponCount;/// 单位：分
@JsonKey(readValue: _readWalletBalance) int get walletBalance;
/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileDtoCopyWith<UserProfileDto> get copyWith => _$UserProfileDtoCopyWithImpl<UserProfileDto>(this as UserProfileDto, _$identity);

  /// Serializes this UserProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.level, level) || other.level == level)&&(identical(other.levelLabel, levelLabel) || other.levelLabel == levelLabel)&&(identical(other.wannaSeeCount, wannaSeeCount) || other.wannaSeeCount == wannaSeeCount)&&(identical(other.followCount, followCount) || other.followCount == followCount)&&(identical(other.couponCount, couponCount) || other.couponCount == couponCount)&&(identical(other.walletBalance, walletBalance) || other.walletBalance == walletBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,nickname,avatarUrl,mobile,level,levelLabel,wannaSeeCount,followCount,couponCount,walletBalance);

@override
String toString() {
  return 'UserProfileDto(userId: $userId, nickname: $nickname, avatarUrl: $avatarUrl, mobile: $mobile, level: $level, levelLabel: $levelLabel, wannaSeeCount: $wannaSeeCount, followCount: $followCount, couponCount: $couponCount, walletBalance: $walletBalance)';
}


}

/// @nodoc
abstract mixin class $UserProfileDtoCopyWith<$Res>  {
  factory $UserProfileDtoCopyWith(UserProfileDto value, $Res Function(UserProfileDto) _then) = _$UserProfileDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readUserId) String userId,@JsonKey(readValue: _readNickname) String nickname,@JsonKey(readValue: _readAvatarUrl) String? avatarUrl,@JsonKey(readValue: _readMobile) String? mobile,@JsonKey(readValue: _readLevel) int level,@JsonKey(readValue: _readLevelLabel) String levelLabel,@JsonKey(readValue: _readWannaSeeCount) int wannaSeeCount,@JsonKey(readValue: _readFollowCount) int followCount,@JsonKey(readValue: _readCouponCount) int couponCount,@JsonKey(readValue: _readWalletBalance) int walletBalance
});




}
/// @nodoc
class _$UserProfileDtoCopyWithImpl<$Res>
    implements $UserProfileDtoCopyWith<$Res> {
  _$UserProfileDtoCopyWithImpl(this._self, this._then);

  final UserProfileDto _self;
  final $Res Function(UserProfileDto) _then;

/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? nickname = null,Object? avatarUrl = freezed,Object? mobile = freezed,Object? level = null,Object? levelLabel = null,Object? wannaSeeCount = null,Object? followCount = null,Object? couponCount = null,Object? walletBalance = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,levelLabel: null == levelLabel ? _self.levelLabel : levelLabel // ignore: cast_nullable_to_non_nullable
as String,wannaSeeCount: null == wannaSeeCount ? _self.wannaSeeCount : wannaSeeCount // ignore: cast_nullable_to_non_nullable
as int,followCount: null == followCount ? _self.followCount : followCount // ignore: cast_nullable_to_non_nullable
as int,couponCount: null == couponCount ? _self.couponCount : couponCount // ignore: cast_nullable_to_non_nullable
as int,walletBalance: null == walletBalance ? _self.walletBalance : walletBalance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileDto].
extension UserProfileDtoPatterns on UserProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readUserId)  String userId, @JsonKey(readValue: _readNickname)  String nickname, @JsonKey(readValue: _readAvatarUrl)  String? avatarUrl, @JsonKey(readValue: _readMobile)  String? mobile, @JsonKey(readValue: _readLevel)  int level, @JsonKey(readValue: _readLevelLabel)  String levelLabel, @JsonKey(readValue: _readWannaSeeCount)  int wannaSeeCount, @JsonKey(readValue: _readFollowCount)  int followCount, @JsonKey(readValue: _readCouponCount)  int couponCount, @JsonKey(readValue: _readWalletBalance)  int walletBalance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
return $default(_that.userId,_that.nickname,_that.avatarUrl,_that.mobile,_that.level,_that.levelLabel,_that.wannaSeeCount,_that.followCount,_that.couponCount,_that.walletBalance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readUserId)  String userId, @JsonKey(readValue: _readNickname)  String nickname, @JsonKey(readValue: _readAvatarUrl)  String? avatarUrl, @JsonKey(readValue: _readMobile)  String? mobile, @JsonKey(readValue: _readLevel)  int level, @JsonKey(readValue: _readLevelLabel)  String levelLabel, @JsonKey(readValue: _readWannaSeeCount)  int wannaSeeCount, @JsonKey(readValue: _readFollowCount)  int followCount, @JsonKey(readValue: _readCouponCount)  int couponCount, @JsonKey(readValue: _readWalletBalance)  int walletBalance)  $default,) {final _that = this;
switch (_that) {
case _UserProfileDto():
return $default(_that.userId,_that.nickname,_that.avatarUrl,_that.mobile,_that.level,_that.levelLabel,_that.wannaSeeCount,_that.followCount,_that.couponCount,_that.walletBalance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readUserId)  String userId, @JsonKey(readValue: _readNickname)  String nickname, @JsonKey(readValue: _readAvatarUrl)  String? avatarUrl, @JsonKey(readValue: _readMobile)  String? mobile, @JsonKey(readValue: _readLevel)  int level, @JsonKey(readValue: _readLevelLabel)  String levelLabel, @JsonKey(readValue: _readWannaSeeCount)  int wannaSeeCount, @JsonKey(readValue: _readFollowCount)  int followCount, @JsonKey(readValue: _readCouponCount)  int couponCount, @JsonKey(readValue: _readWalletBalance)  int walletBalance)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileDto() when $default != null:
return $default(_that.userId,_that.nickname,_that.avatarUrl,_that.mobile,_that.level,_that.levelLabel,_that.wannaSeeCount,_that.followCount,_that.couponCount,_that.walletBalance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileDto implements UserProfileDto {
  const _UserProfileDto({@JsonKey(readValue: _readUserId) required this.userId, @JsonKey(readValue: _readNickname) required this.nickname, @JsonKey(readValue: _readAvatarUrl) this.avatarUrl, @JsonKey(readValue: _readMobile) this.mobile, @JsonKey(readValue: _readLevel) this.level = 0, @JsonKey(readValue: _readLevelLabel) this.levelLabel = '', @JsonKey(readValue: _readWannaSeeCount) this.wannaSeeCount = 0, @JsonKey(readValue: _readFollowCount) this.followCount = 0, @JsonKey(readValue: _readCouponCount) this.couponCount = 0, @JsonKey(readValue: _readWalletBalance) this.walletBalance = 0});
  factory _UserProfileDto.fromJson(Map<String, dynamic> json) => _$UserProfileDtoFromJson(json);

@override@JsonKey(readValue: _readUserId) final  String userId;
@override@JsonKey(readValue: _readNickname) final  String nickname;
@override@JsonKey(readValue: _readAvatarUrl) final  String? avatarUrl;
@override@JsonKey(readValue: _readMobile) final  String? mobile;
@override@JsonKey(readValue: _readLevel) final  int level;
@override@JsonKey(readValue: _readLevelLabel) final  String levelLabel;
@override@JsonKey(readValue: _readWannaSeeCount) final  int wannaSeeCount;
@override@JsonKey(readValue: _readFollowCount) final  int followCount;
@override@JsonKey(readValue: _readCouponCount) final  int couponCount;
/// 单位：分
@override@JsonKey(readValue: _readWalletBalance) final  int walletBalance;

/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileDtoCopyWith<_UserProfileDto> get copyWith => __$UserProfileDtoCopyWithImpl<_UserProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.level, level) || other.level == level)&&(identical(other.levelLabel, levelLabel) || other.levelLabel == levelLabel)&&(identical(other.wannaSeeCount, wannaSeeCount) || other.wannaSeeCount == wannaSeeCount)&&(identical(other.followCount, followCount) || other.followCount == followCount)&&(identical(other.couponCount, couponCount) || other.couponCount == couponCount)&&(identical(other.walletBalance, walletBalance) || other.walletBalance == walletBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,nickname,avatarUrl,mobile,level,levelLabel,wannaSeeCount,followCount,couponCount,walletBalance);

@override
String toString() {
  return 'UserProfileDto(userId: $userId, nickname: $nickname, avatarUrl: $avatarUrl, mobile: $mobile, level: $level, levelLabel: $levelLabel, wannaSeeCount: $wannaSeeCount, followCount: $followCount, couponCount: $couponCount, walletBalance: $walletBalance)';
}


}

/// @nodoc
abstract mixin class _$UserProfileDtoCopyWith<$Res> implements $UserProfileDtoCopyWith<$Res> {
  factory _$UserProfileDtoCopyWith(_UserProfileDto value, $Res Function(_UserProfileDto) _then) = __$UserProfileDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readUserId) String userId,@JsonKey(readValue: _readNickname) String nickname,@JsonKey(readValue: _readAvatarUrl) String? avatarUrl,@JsonKey(readValue: _readMobile) String? mobile,@JsonKey(readValue: _readLevel) int level,@JsonKey(readValue: _readLevelLabel) String levelLabel,@JsonKey(readValue: _readWannaSeeCount) int wannaSeeCount,@JsonKey(readValue: _readFollowCount) int followCount,@JsonKey(readValue: _readCouponCount) int couponCount,@JsonKey(readValue: _readWalletBalance) int walletBalance
});




}
/// @nodoc
class __$UserProfileDtoCopyWithImpl<$Res>
    implements _$UserProfileDtoCopyWith<$Res> {
  __$UserProfileDtoCopyWithImpl(this._self, this._then);

  final _UserProfileDto _self;
  final $Res Function(_UserProfileDto) _then;

/// Create a copy of UserProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? nickname = null,Object? avatarUrl = freezed,Object? mobile = freezed,Object? level = null,Object? levelLabel = null,Object? wannaSeeCount = null,Object? followCount = null,Object? couponCount = null,Object? walletBalance = null,}) {
  return _then(_UserProfileDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,levelLabel: null == levelLabel ? _self.levelLabel : levelLabel // ignore: cast_nullable_to_non_nullable
as String,wannaSeeCount: null == wannaSeeCount ? _self.wannaSeeCount : wannaSeeCount // ignore: cast_nullable_to_non_nullable
as int,followCount: null == followCount ? _self.followCount : followCount // ignore: cast_nullable_to_non_nullable
as int,couponCount: null == couponCount ? _self.couponCount : couponCount // ignore: cast_nullable_to_non_nullable
as int,walletBalance: null == walletBalance ? _self.walletBalance : walletBalance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
