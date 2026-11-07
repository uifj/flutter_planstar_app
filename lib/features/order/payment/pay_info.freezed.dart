// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pay_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PayInfo {

 String get orderNumber; Money get payAmount; int get leftSeconds; List<PayChannelOption> get channels; List<PayDetailLine> get detailLines; String get showTitle;
/// Create a copy of PayInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayInfoCopyWith<PayInfo> get copyWith => _$PayInfoCopyWithImpl<PayInfo>(this as PayInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayInfo&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.payAmount, payAmount) || other.payAmount == payAmount)&&(identical(other.leftSeconds, leftSeconds) || other.leftSeconds == leftSeconds)&&const DeepCollectionEquality().equals(other.channels, channels)&&const DeepCollectionEquality().equals(other.detailLines, detailLines)&&(identical(other.showTitle, showTitle) || other.showTitle == showTitle));
}


@override
int get hashCode => Object.hash(runtimeType,orderNumber,payAmount,leftSeconds,const DeepCollectionEquality().hash(channels),const DeepCollectionEquality().hash(detailLines),showTitle);

@override
String toString() {
  return 'PayInfo(orderNumber: $orderNumber, payAmount: $payAmount, leftSeconds: $leftSeconds, channels: $channels, detailLines: $detailLines, showTitle: $showTitle)';
}


}

/// @nodoc
abstract mixin class $PayInfoCopyWith<$Res>  {
  factory $PayInfoCopyWith(PayInfo value, $Res Function(PayInfo) _then) = _$PayInfoCopyWithImpl;
@useResult
$Res call({
 String orderNumber, Money payAmount, int leftSeconds, List<PayChannelOption> channels, List<PayDetailLine> detailLines, String showTitle
});




}
/// @nodoc
class _$PayInfoCopyWithImpl<$Res>
    implements $PayInfoCopyWith<$Res> {
  _$PayInfoCopyWithImpl(this._self, this._then);

  final PayInfo _self;
  final $Res Function(PayInfo) _then;

/// Create a copy of PayInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderNumber = null,Object? payAmount = null,Object? leftSeconds = null,Object? channels = null,Object? detailLines = null,Object? showTitle = null,}) {
  return _then(_self.copyWith(
orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,payAmount: null == payAmount ? _self.payAmount : payAmount // ignore: cast_nullable_to_non_nullable
as Money,leftSeconds: null == leftSeconds ? _self.leftSeconds : leftSeconds // ignore: cast_nullable_to_non_nullable
as int,channels: null == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as List<PayChannelOption>,detailLines: null == detailLines ? _self.detailLines : detailLines // ignore: cast_nullable_to_non_nullable
as List<PayDetailLine>,showTitle: null == showTitle ? _self.showTitle : showTitle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PayInfo].
extension PayInfoPatterns on PayInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayInfo value)  $default,){
final _that = this;
switch (_that) {
case _PayInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PayInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String orderNumber,  Money payAmount,  int leftSeconds,  List<PayChannelOption> channels,  List<PayDetailLine> detailLines,  String showTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayInfo() when $default != null:
return $default(_that.orderNumber,_that.payAmount,_that.leftSeconds,_that.channels,_that.detailLines,_that.showTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String orderNumber,  Money payAmount,  int leftSeconds,  List<PayChannelOption> channels,  List<PayDetailLine> detailLines,  String showTitle)  $default,) {final _that = this;
switch (_that) {
case _PayInfo():
return $default(_that.orderNumber,_that.payAmount,_that.leftSeconds,_that.channels,_that.detailLines,_that.showTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String orderNumber,  Money payAmount,  int leftSeconds,  List<PayChannelOption> channels,  List<PayDetailLine> detailLines,  String showTitle)?  $default,) {final _that = this;
switch (_that) {
case _PayInfo() when $default != null:
return $default(_that.orderNumber,_that.payAmount,_that.leftSeconds,_that.channels,_that.detailLines,_that.showTitle);case _:
  return null;

}
}

}

/// @nodoc


class _PayInfo implements PayInfo {
  const _PayInfo({required this.orderNumber, required this.payAmount, required this.leftSeconds, required final  List<PayChannelOption> channels, required final  List<PayDetailLine> detailLines, required this.showTitle}): _channels = channels,_detailLines = detailLines;
  

@override final  String orderNumber;
@override final  Money payAmount;
@override final  int leftSeconds;
 final  List<PayChannelOption> _channels;
@override List<PayChannelOption> get channels {
  if (_channels is EqualUnmodifiableListView) return _channels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_channels);
}

 final  List<PayDetailLine> _detailLines;
@override List<PayDetailLine> get detailLines {
  if (_detailLines is EqualUnmodifiableListView) return _detailLines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_detailLines);
}

@override final  String showTitle;

/// Create a copy of PayInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayInfoCopyWith<_PayInfo> get copyWith => __$PayInfoCopyWithImpl<_PayInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayInfo&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.payAmount, payAmount) || other.payAmount == payAmount)&&(identical(other.leftSeconds, leftSeconds) || other.leftSeconds == leftSeconds)&&const DeepCollectionEquality().equals(other._channels, _channels)&&const DeepCollectionEquality().equals(other._detailLines, _detailLines)&&(identical(other.showTitle, showTitle) || other.showTitle == showTitle));
}


@override
int get hashCode => Object.hash(runtimeType,orderNumber,payAmount,leftSeconds,const DeepCollectionEquality().hash(_channels),const DeepCollectionEquality().hash(_detailLines),showTitle);

@override
String toString() {
  return 'PayInfo(orderNumber: $orderNumber, payAmount: $payAmount, leftSeconds: $leftSeconds, channels: $channels, detailLines: $detailLines, showTitle: $showTitle)';
}


}

/// @nodoc
abstract mixin class _$PayInfoCopyWith<$Res> implements $PayInfoCopyWith<$Res> {
  factory _$PayInfoCopyWith(_PayInfo value, $Res Function(_PayInfo) _then) = __$PayInfoCopyWithImpl;
@override @useResult
$Res call({
 String orderNumber, Money payAmount, int leftSeconds, List<PayChannelOption> channels, List<PayDetailLine> detailLines, String showTitle
});




}
/// @nodoc
class __$PayInfoCopyWithImpl<$Res>
    implements _$PayInfoCopyWith<$Res> {
  __$PayInfoCopyWithImpl(this._self, this._then);

  final _PayInfo _self;
  final $Res Function(_PayInfo) _then;

/// Create a copy of PayInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderNumber = null,Object? payAmount = null,Object? leftSeconds = null,Object? channels = null,Object? detailLines = null,Object? showTitle = null,}) {
  return _then(_PayInfo(
orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,payAmount: null == payAmount ? _self.payAmount : payAmount // ignore: cast_nullable_to_non_nullable
as Money,leftSeconds: null == leftSeconds ? _self.leftSeconds : leftSeconds // ignore: cast_nullable_to_non_nullable
as int,channels: null == channels ? _self._channels : channels // ignore: cast_nullable_to_non_nullable
as List<PayChannelOption>,detailLines: null == detailLines ? _self._detailLines : detailLines // ignore: cast_nullable_to_non_nullable
as List<PayDetailLine>,showTitle: null == showTitle ? _self.showTitle : showTitle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$PayChannelOption {

/// 渠道。
 PaymentChannel get channel;/// 提示类型（展示文案由 UI 层按 l10n 解析）。
 PayChannelTip get tip;/// 是否可选。余额不足 / 未绑卡时为 false。
 bool get available;
/// Create a copy of PayChannelOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayChannelOptionCopyWith<PayChannelOption> get copyWith => _$PayChannelOptionCopyWithImpl<PayChannelOption>(this as PayChannelOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayChannelOption&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.tip, tip) || other.tip == tip)&&(identical(other.available, available) || other.available == available));
}


@override
int get hashCode => Object.hash(runtimeType,channel,tip,available);

@override
String toString() {
  return 'PayChannelOption(channel: $channel, tip: $tip, available: $available)';
}


}

/// @nodoc
abstract mixin class $PayChannelOptionCopyWith<$Res>  {
  factory $PayChannelOptionCopyWith(PayChannelOption value, $Res Function(PayChannelOption) _then) = _$PayChannelOptionCopyWithImpl;
@useResult
$Res call({
 PaymentChannel channel, PayChannelTip tip, bool available
});




}
/// @nodoc
class _$PayChannelOptionCopyWithImpl<$Res>
    implements $PayChannelOptionCopyWith<$Res> {
  _$PayChannelOptionCopyWithImpl(this._self, this._then);

  final PayChannelOption _self;
  final $Res Function(PayChannelOption) _then;

/// Create a copy of PayChannelOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channel = null,Object? tip = null,Object? available = null,}) {
  return _then(_self.copyWith(
channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as PaymentChannel,tip: null == tip ? _self.tip : tip // ignore: cast_nullable_to_non_nullable
as PayChannelTip,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PayChannelOption].
extension PayChannelOptionPatterns on PayChannelOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayChannelOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayChannelOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayChannelOption value)  $default,){
final _that = this;
switch (_that) {
case _PayChannelOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayChannelOption value)?  $default,){
final _that = this;
switch (_that) {
case _PayChannelOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PaymentChannel channel,  PayChannelTip tip,  bool available)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayChannelOption() when $default != null:
return $default(_that.channel,_that.tip,_that.available);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PaymentChannel channel,  PayChannelTip tip,  bool available)  $default,) {final _that = this;
switch (_that) {
case _PayChannelOption():
return $default(_that.channel,_that.tip,_that.available);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PaymentChannel channel,  PayChannelTip tip,  bool available)?  $default,) {final _that = this;
switch (_that) {
case _PayChannelOption() when $default != null:
return $default(_that.channel,_that.tip,_that.available);case _:
  return null;

}
}

}

/// @nodoc


class _PayChannelOption implements PayChannelOption {
  const _PayChannelOption({required this.channel, required this.tip, required this.available});
  

/// 渠道。
@override final  PaymentChannel channel;
/// 提示类型（展示文案由 UI 层按 l10n 解析）。
@override final  PayChannelTip tip;
/// 是否可选。余额不足 / 未绑卡时为 false。
@override final  bool available;

/// Create a copy of PayChannelOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayChannelOptionCopyWith<_PayChannelOption> get copyWith => __$PayChannelOptionCopyWithImpl<_PayChannelOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayChannelOption&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.tip, tip) || other.tip == tip)&&(identical(other.available, available) || other.available == available));
}


@override
int get hashCode => Object.hash(runtimeType,channel,tip,available);

@override
String toString() {
  return 'PayChannelOption(channel: $channel, tip: $tip, available: $available)';
}


}

/// @nodoc
abstract mixin class _$PayChannelOptionCopyWith<$Res> implements $PayChannelOptionCopyWith<$Res> {
  factory _$PayChannelOptionCopyWith(_PayChannelOption value, $Res Function(_PayChannelOption) _then) = __$PayChannelOptionCopyWithImpl;
@override @useResult
$Res call({
 PaymentChannel channel, PayChannelTip tip, bool available
});




}
/// @nodoc
class __$PayChannelOptionCopyWithImpl<$Res>
    implements _$PayChannelOptionCopyWith<$Res> {
  __$PayChannelOptionCopyWithImpl(this._self, this._then);

  final _PayChannelOption _self;
  final $Res Function(_PayChannelOption) _then;

/// Create a copy of PayChannelOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channel = null,Object? tip = null,Object? available = null,}) {
  return _then(_PayChannelOption(
channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as PaymentChannel,tip: null == tip ? _self.tip : tip // ignore: cast_nullable_to_non_nullable
as PayChannelTip,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$PayDetailLine {

 PayDetailKind get kind; String get value;
/// Create a copy of PayDetailLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayDetailLineCopyWith<PayDetailLine> get copyWith => _$PayDetailLineCopyWithImpl<PayDetailLine>(this as PayDetailLine, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayDetailLine&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,kind,value);

@override
String toString() {
  return 'PayDetailLine(kind: $kind, value: $value)';
}


}

/// @nodoc
abstract mixin class $PayDetailLineCopyWith<$Res>  {
  factory $PayDetailLineCopyWith(PayDetailLine value, $Res Function(PayDetailLine) _then) = _$PayDetailLineCopyWithImpl;
@useResult
$Res call({
 PayDetailKind kind, String value
});




}
/// @nodoc
class _$PayDetailLineCopyWithImpl<$Res>
    implements $PayDetailLineCopyWith<$Res> {
  _$PayDetailLineCopyWithImpl(this._self, this._then);

  final PayDetailLine _self;
  final $Res Function(PayDetailLine) _then;

/// Create a copy of PayDetailLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? value = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PayDetailKind,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PayDetailLine].
extension PayDetailLinePatterns on PayDetailLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayDetailLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayDetailLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayDetailLine value)  $default,){
final _that = this;
switch (_that) {
case _PayDetailLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayDetailLine value)?  $default,){
final _that = this;
switch (_that) {
case _PayDetailLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PayDetailKind kind,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayDetailLine() when $default != null:
return $default(_that.kind,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PayDetailKind kind,  String value)  $default,) {final _that = this;
switch (_that) {
case _PayDetailLine():
return $default(_that.kind,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PayDetailKind kind,  String value)?  $default,) {final _that = this;
switch (_that) {
case _PayDetailLine() when $default != null:
return $default(_that.kind,_that.value);case _:
  return null;

}
}

}

/// @nodoc


class _PayDetailLine implements PayDetailLine {
  const _PayDetailLine({required this.kind, required this.value});
  

@override final  PayDetailKind kind;
@override final  String value;

/// Create a copy of PayDetailLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayDetailLineCopyWith<_PayDetailLine> get copyWith => __$PayDetailLineCopyWithImpl<_PayDetailLine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayDetailLine&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,kind,value);

@override
String toString() {
  return 'PayDetailLine(kind: $kind, value: $value)';
}


}

/// @nodoc
abstract mixin class _$PayDetailLineCopyWith<$Res> implements $PayDetailLineCopyWith<$Res> {
  factory _$PayDetailLineCopyWith(_PayDetailLine value, $Res Function(_PayDetailLine) _then) = __$PayDetailLineCopyWithImpl;
@override @useResult
$Res call({
 PayDetailKind kind, String value
});




}
/// @nodoc
class __$PayDetailLineCopyWithImpl<$Res>
    implements _$PayDetailLineCopyWith<$Res> {
  __$PayDetailLineCopyWithImpl(this._self, this._then);

  final _PayDetailLine _self;
  final $Res Function(_PayDetailLine) _then;

/// Create a copy of PayDetailLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? value = null,}) {
  return _then(_PayDetailLine(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PayDetailKind,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
