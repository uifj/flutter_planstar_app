// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_code_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SendCodeResponseDto {

/// 是否已下发。
@JsonKey(fromJson: _asBool) bool get success;/// 是否需要先过图形验证码。
@JsonKey(fromJson: _asBool) bool get needCaptcha;/// 失败原因（服务端原文，例如"发送失败"）。
@JsonKey(fromJson: _nonEmptyStringOrNull) String? get errorMsg;
/// Create a copy of SendCodeResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendCodeResponseDtoCopyWith<SendCodeResponseDto> get copyWith => _$SendCodeResponseDtoCopyWithImpl<SendCodeResponseDto>(this as SendCodeResponseDto, _$identity);

  /// Serializes this SendCodeResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendCodeResponseDto&&(identical(other.success, success) || other.success == success)&&(identical(other.needCaptcha, needCaptcha) || other.needCaptcha == needCaptcha)&&(identical(other.errorMsg, errorMsg) || other.errorMsg == errorMsg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,needCaptcha,errorMsg);

@override
String toString() {
  return 'SendCodeResponseDto(success: $success, needCaptcha: $needCaptcha, errorMsg: $errorMsg)';
}


}

/// @nodoc
abstract mixin class $SendCodeResponseDtoCopyWith<$Res>  {
  factory $SendCodeResponseDtoCopyWith(SendCodeResponseDto value, $Res Function(SendCodeResponseDto) _then) = _$SendCodeResponseDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _asBool) bool success,@JsonKey(fromJson: _asBool) bool needCaptcha,@JsonKey(fromJson: _nonEmptyStringOrNull) String? errorMsg
});




}
/// @nodoc
class _$SendCodeResponseDtoCopyWithImpl<$Res>
    implements $SendCodeResponseDtoCopyWith<$Res> {
  _$SendCodeResponseDtoCopyWithImpl(this._self, this._then);

  final SendCodeResponseDto _self;
  final $Res Function(SendCodeResponseDto) _then;

/// Create a copy of SendCodeResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? needCaptcha = null,Object? errorMsg = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,needCaptcha: null == needCaptcha ? _self.needCaptcha : needCaptcha // ignore: cast_nullable_to_non_nullable
as bool,errorMsg: freezed == errorMsg ? _self.errorMsg : errorMsg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SendCodeResponseDto].
extension SendCodeResponseDtoPatterns on SendCodeResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendCodeResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendCodeResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendCodeResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _SendCodeResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendCodeResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _SendCodeResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _asBool)  bool success, @JsonKey(fromJson: _asBool)  bool needCaptcha, @JsonKey(fromJson: _nonEmptyStringOrNull)  String? errorMsg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendCodeResponseDto() when $default != null:
return $default(_that.success,_that.needCaptcha,_that.errorMsg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _asBool)  bool success, @JsonKey(fromJson: _asBool)  bool needCaptcha, @JsonKey(fromJson: _nonEmptyStringOrNull)  String? errorMsg)  $default,) {final _that = this;
switch (_that) {
case _SendCodeResponseDto():
return $default(_that.success,_that.needCaptcha,_that.errorMsg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _asBool)  bool success, @JsonKey(fromJson: _asBool)  bool needCaptcha, @JsonKey(fromJson: _nonEmptyStringOrNull)  String? errorMsg)?  $default,) {final _that = this;
switch (_that) {
case _SendCodeResponseDto() when $default != null:
return $default(_that.success,_that.needCaptcha,_that.errorMsg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendCodeResponseDto implements SendCodeResponseDto {
  const _SendCodeResponseDto({@JsonKey(fromJson: _asBool) required this.success, @JsonKey(fromJson: _asBool) this.needCaptcha = false, @JsonKey(fromJson: _nonEmptyStringOrNull) this.errorMsg});
  factory _SendCodeResponseDto.fromJson(Map<String, dynamic> json) => _$SendCodeResponseDtoFromJson(json);

/// 是否已下发。
@override@JsonKey(fromJson: _asBool) final  bool success;
/// 是否需要先过图形验证码。
@override@JsonKey(fromJson: _asBool) final  bool needCaptcha;
/// 失败原因（服务端原文，例如"发送失败"）。
@override@JsonKey(fromJson: _nonEmptyStringOrNull) final  String? errorMsg;

/// Create a copy of SendCodeResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendCodeResponseDtoCopyWith<_SendCodeResponseDto> get copyWith => __$SendCodeResponseDtoCopyWithImpl<_SendCodeResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendCodeResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendCodeResponseDto&&(identical(other.success, success) || other.success == success)&&(identical(other.needCaptcha, needCaptcha) || other.needCaptcha == needCaptcha)&&(identical(other.errorMsg, errorMsg) || other.errorMsg == errorMsg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,needCaptcha,errorMsg);

@override
String toString() {
  return 'SendCodeResponseDto(success: $success, needCaptcha: $needCaptcha, errorMsg: $errorMsg)';
}


}

/// @nodoc
abstract mixin class _$SendCodeResponseDtoCopyWith<$Res> implements $SendCodeResponseDtoCopyWith<$Res> {
  factory _$SendCodeResponseDtoCopyWith(_SendCodeResponseDto value, $Res Function(_SendCodeResponseDto) _then) = __$SendCodeResponseDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _asBool) bool success,@JsonKey(fromJson: _asBool) bool needCaptcha,@JsonKey(fromJson: _nonEmptyStringOrNull) String? errorMsg
});




}
/// @nodoc
class __$SendCodeResponseDtoCopyWithImpl<$Res>
    implements _$SendCodeResponseDtoCopyWith<$Res> {
  __$SendCodeResponseDtoCopyWithImpl(this._self, this._then);

  final _SendCodeResponseDto _self;
  final $Res Function(_SendCodeResponseDto) _then;

/// Create a copy of SendCodeResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? needCaptcha = null,Object? errorMsg = freezed,}) {
  return _then(_SendCodeResponseDto(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,needCaptcha: null == needCaptcha ? _self.needCaptcha : needCaptcha // ignore: cast_nullable_to_non_nullable
as bool,errorMsg: freezed == errorMsg ? _self.errorMsg : errorMsg // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
