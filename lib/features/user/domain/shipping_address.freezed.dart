// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shipping_address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShippingAddress {

@JsonKey(readValue: _readId) String get id;@JsonKey(readValue: _readName) String get name;@JsonKey(readValue: _readMobile) String get mobile;@JsonKey(readValue: _readRegion) String get region;@JsonKey(readValue: _readDetail) String get detail;@JsonKey(readValue: _readIsDefault) bool get isDefault;
/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<ShippingAddress> get copyWith => _$ShippingAddressCopyWithImpl<ShippingAddress>(this as ShippingAddress, _$identity);

  /// Serializes this ShippingAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShippingAddress&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.region, region) || other.region == region)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,mobile,region,detail,isDefault);

@override
String toString() {
  return 'ShippingAddress(id: $id, name: $name, mobile: $mobile, region: $region, detail: $detail, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $ShippingAddressCopyWith<$Res>  {
  factory $ShippingAddressCopyWith(ShippingAddress value, $Res Function(ShippingAddress) _then) = _$ShippingAddressCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readId) String id,@JsonKey(readValue: _readName) String name,@JsonKey(readValue: _readMobile) String mobile,@JsonKey(readValue: _readRegion) String region,@JsonKey(readValue: _readDetail) String detail,@JsonKey(readValue: _readIsDefault) bool isDefault
});




}
/// @nodoc
class _$ShippingAddressCopyWithImpl<$Res>
    implements $ShippingAddressCopyWith<$Res> {
  _$ShippingAddressCopyWithImpl(this._self, this._then);

  final ShippingAddress _self;
  final $Res Function(ShippingAddress) _then;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? mobile = null,Object? region = null,Object? detail = null,Object? isDefault = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShippingAddress].
extension ShippingAddressPatterns on ShippingAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShippingAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShippingAddress value)  $default,){
final _that = this;
switch (_that) {
case _ShippingAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShippingAddress value)?  $default,){
final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readId)  String id, @JsonKey(readValue: _readName)  String name, @JsonKey(readValue: _readMobile)  String mobile, @JsonKey(readValue: _readRegion)  String region, @JsonKey(readValue: _readDetail)  String detail, @JsonKey(readValue: _readIsDefault)  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
return $default(_that.id,_that.name,_that.mobile,_that.region,_that.detail,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readId)  String id, @JsonKey(readValue: _readName)  String name, @JsonKey(readValue: _readMobile)  String mobile, @JsonKey(readValue: _readRegion)  String region, @JsonKey(readValue: _readDetail)  String detail, @JsonKey(readValue: _readIsDefault)  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _ShippingAddress():
return $default(_that.id,_that.name,_that.mobile,_that.region,_that.detail,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readId)  String id, @JsonKey(readValue: _readName)  String name, @JsonKey(readValue: _readMobile)  String mobile, @JsonKey(readValue: _readRegion)  String region, @JsonKey(readValue: _readDetail)  String detail, @JsonKey(readValue: _readIsDefault)  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
return $default(_that.id,_that.name,_that.mobile,_that.region,_that.detail,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShippingAddress extends ShippingAddress {
  const _ShippingAddress({@JsonKey(readValue: _readId) required this.id, @JsonKey(readValue: _readName) required this.name, @JsonKey(readValue: _readMobile) required this.mobile, @JsonKey(readValue: _readRegion) required this.region, @JsonKey(readValue: _readDetail) required this.detail, @JsonKey(readValue: _readIsDefault) this.isDefault = false}): super._();
  factory _ShippingAddress.fromJson(Map<String, dynamic> json) => _$ShippingAddressFromJson(json);

@override@JsonKey(readValue: _readId) final  String id;
@override@JsonKey(readValue: _readName) final  String name;
@override@JsonKey(readValue: _readMobile) final  String mobile;
@override@JsonKey(readValue: _readRegion) final  String region;
@override@JsonKey(readValue: _readDetail) final  String detail;
@override@JsonKey(readValue: _readIsDefault) final  bool isDefault;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShippingAddressCopyWith<_ShippingAddress> get copyWith => __$ShippingAddressCopyWithImpl<_ShippingAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShippingAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShippingAddress&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.region, region) || other.region == region)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,mobile,region,detail,isDefault);

@override
String toString() {
  return 'ShippingAddress(id: $id, name: $name, mobile: $mobile, region: $region, detail: $detail, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$ShippingAddressCopyWith<$Res> implements $ShippingAddressCopyWith<$Res> {
  factory _$ShippingAddressCopyWith(_ShippingAddress value, $Res Function(_ShippingAddress) _then) = __$ShippingAddressCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readId) String id,@JsonKey(readValue: _readName) String name,@JsonKey(readValue: _readMobile) String mobile,@JsonKey(readValue: _readRegion) String region,@JsonKey(readValue: _readDetail) String detail,@JsonKey(readValue: _readIsDefault) bool isDefault
});




}
/// @nodoc
class __$ShippingAddressCopyWithImpl<$Res>
    implements _$ShippingAddressCopyWith<$Res> {
  __$ShippingAddressCopyWithImpl(this._self, this._then);

  final _ShippingAddress _self;
  final $Res Function(_ShippingAddress) _then;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? mobile = null,Object? region = null,Object? detail = null,Object? isDefault = null,}) {
  return _then(_ShippingAddress(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
