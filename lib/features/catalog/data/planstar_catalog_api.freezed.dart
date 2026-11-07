// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planstar_catalog_api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RankingEntry {

@JsonKey(readValue: _readRank) int get rank;/// 指标值：热榜为支持人数，达成榜为达成率（千分比），冲刺榜为剩余天数。
@JsonKey(readValue: _readMetricValue) int get metricValue;@JsonKey(readValue: _readProject) ShowSummary get show;
/// Create a copy of RankingEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankingEntryCopyWith<RankingEntry> get copyWith => _$RankingEntryCopyWithImpl<RankingEntry>(this as RankingEntry, _$identity);

  /// Serializes this RankingEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankingEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.metricValue, metricValue) || other.metricValue == metricValue)&&(identical(other.show, show) || other.show == show));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,metricValue,show);

@override
String toString() {
  return 'RankingEntry(rank: $rank, metricValue: $metricValue, show: $show)';
}


}

/// @nodoc
abstract mixin class $RankingEntryCopyWith<$Res>  {
  factory $RankingEntryCopyWith(RankingEntry value, $Res Function(RankingEntry) _then) = _$RankingEntryCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readRank) int rank,@JsonKey(readValue: _readMetricValue) int metricValue,@JsonKey(readValue: _readProject) ShowSummary show
});


$ShowSummaryCopyWith<$Res> get show;

}
/// @nodoc
class _$RankingEntryCopyWithImpl<$Res>
    implements $RankingEntryCopyWith<$Res> {
  _$RankingEntryCopyWithImpl(this._self, this._then);

  final RankingEntry _self;
  final $Res Function(RankingEntry) _then;

/// Create a copy of RankingEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? metricValue = null,Object? show = null,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,metricValue: null == metricValue ? _self.metricValue : metricValue // ignore: cast_nullable_to_non_nullable
as int,show: null == show ? _self.show : show // ignore: cast_nullable_to_non_nullable
as ShowSummary,
  ));
}
/// Create a copy of RankingEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShowSummaryCopyWith<$Res> get show {
  
  return $ShowSummaryCopyWith<$Res>(_self.show, (value) {
    return _then(_self.copyWith(show: value));
  });
}
}


/// Adds pattern-matching-related methods to [RankingEntry].
extension RankingEntryPatterns on RankingEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankingEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankingEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankingEntry value)  $default,){
final _that = this;
switch (_that) {
case _RankingEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankingEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RankingEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readRank)  int rank, @JsonKey(readValue: _readMetricValue)  int metricValue, @JsonKey(readValue: _readProject)  ShowSummary show)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankingEntry() when $default != null:
return $default(_that.rank,_that.metricValue,_that.show);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readRank)  int rank, @JsonKey(readValue: _readMetricValue)  int metricValue, @JsonKey(readValue: _readProject)  ShowSummary show)  $default,) {final _that = this;
switch (_that) {
case _RankingEntry():
return $default(_that.rank,_that.metricValue,_that.show);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readRank)  int rank, @JsonKey(readValue: _readMetricValue)  int metricValue, @JsonKey(readValue: _readProject)  ShowSummary show)?  $default,) {final _that = this;
switch (_that) {
case _RankingEntry() when $default != null:
return $default(_that.rank,_that.metricValue,_that.show);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RankingEntry implements RankingEntry {
  const _RankingEntry({@JsonKey(readValue: _readRank) required this.rank, @JsonKey(readValue: _readMetricValue) required this.metricValue, @JsonKey(readValue: _readProject) required this.show});
  factory _RankingEntry.fromJson(Map<String, dynamic> json) => _$RankingEntryFromJson(json);

@override@JsonKey(readValue: _readRank) final  int rank;
/// 指标值：热榜为支持人数，达成榜为达成率（千分比），冲刺榜为剩余天数。
@override@JsonKey(readValue: _readMetricValue) final  int metricValue;
@override@JsonKey(readValue: _readProject) final  ShowSummary show;

/// Create a copy of RankingEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankingEntryCopyWith<_RankingEntry> get copyWith => __$RankingEntryCopyWithImpl<_RankingEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RankingEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankingEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.metricValue, metricValue) || other.metricValue == metricValue)&&(identical(other.show, show) || other.show == show));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,metricValue,show);

@override
String toString() {
  return 'RankingEntry(rank: $rank, metricValue: $metricValue, show: $show)';
}


}

/// @nodoc
abstract mixin class _$RankingEntryCopyWith<$Res> implements $RankingEntryCopyWith<$Res> {
  factory _$RankingEntryCopyWith(_RankingEntry value, $Res Function(_RankingEntry) _then) = __$RankingEntryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readRank) int rank,@JsonKey(readValue: _readMetricValue) int metricValue,@JsonKey(readValue: _readProject) ShowSummary show
});


@override $ShowSummaryCopyWith<$Res> get show;

}
/// @nodoc
class __$RankingEntryCopyWithImpl<$Res>
    implements _$RankingEntryCopyWith<$Res> {
  __$RankingEntryCopyWithImpl(this._self, this._then);

  final _RankingEntry _self;
  final $Res Function(_RankingEntry) _then;

/// Create a copy of RankingEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? metricValue = null,Object? show = null,}) {
  return _then(_RankingEntry(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,metricValue: null == metricValue ? _self.metricValue : metricValue // ignore: cast_nullable_to_non_nullable
as int,show: null == show ? _self.show : show // ignore: cast_nullable_to_non_nullable
as ShowSummary,
  ));
}

/// Create a copy of RankingEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShowSummaryCopyWith<$Res> get show {
  
  return $ShowSummaryCopyWith<$Res>(_self.show, (value) {
    return _then(_self.copyWith(show: value));
  });
}
}


/// @nodoc
mixin _$BannerDto {

@JsonKey(fromJson: _toStringOrEmpty) String get id;@JsonKey(fromJson: _toStringOrEmpty) String get title;@JsonKey(fromJson: _toStringOrEmpty) String get image;@JsonKey(fromJson: _toStringOrNull) String? get url;@JsonKey(fromJson: _toStringOrNull) String? get showId;
/// Create a copy of BannerDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BannerDtoCopyWith<BannerDto> get copyWith => _$BannerDtoCopyWithImpl<BannerDto>(this as BannerDto, _$identity);

  /// Serializes this BannerDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BannerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.image, image) || other.image == image)&&(identical(other.url, url) || other.url == url)&&(identical(other.showId, showId) || other.showId == showId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,image,url,showId);

@override
String toString() {
  return 'BannerDto(id: $id, title: $title, image: $image, url: $url, showId: $showId)';
}


}

/// @nodoc
abstract mixin class $BannerDtoCopyWith<$Res>  {
  factory $BannerDtoCopyWith(BannerDto value, $Res Function(BannerDto) _then) = _$BannerDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toStringOrEmpty) String id,@JsonKey(fromJson: _toStringOrEmpty) String title,@JsonKey(fromJson: _toStringOrEmpty) String image,@JsonKey(fromJson: _toStringOrNull) String? url,@JsonKey(fromJson: _toStringOrNull) String? showId
});




}
/// @nodoc
class _$BannerDtoCopyWithImpl<$Res>
    implements $BannerDtoCopyWith<$Res> {
  _$BannerDtoCopyWithImpl(this._self, this._then);

  final BannerDto _self;
  final $Res Function(BannerDto) _then;

/// Create a copy of BannerDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? image = null,Object? url = freezed,Object? showId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,showId: freezed == showId ? _self.showId : showId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BannerDto].
extension BannerDtoPatterns on BannerDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BannerDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BannerDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BannerDto value)  $default,){
final _that = this;
switch (_that) {
case _BannerDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BannerDto value)?  $default,){
final _that = this;
switch (_that) {
case _BannerDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toStringOrEmpty)  String id, @JsonKey(fromJson: _toStringOrEmpty)  String title, @JsonKey(fromJson: _toStringOrEmpty)  String image, @JsonKey(fromJson: _toStringOrNull)  String? url, @JsonKey(fromJson: _toStringOrNull)  String? showId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BannerDto() when $default != null:
return $default(_that.id,_that.title,_that.image,_that.url,_that.showId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toStringOrEmpty)  String id, @JsonKey(fromJson: _toStringOrEmpty)  String title, @JsonKey(fromJson: _toStringOrEmpty)  String image, @JsonKey(fromJson: _toStringOrNull)  String? url, @JsonKey(fromJson: _toStringOrNull)  String? showId)  $default,) {final _that = this;
switch (_that) {
case _BannerDto():
return $default(_that.id,_that.title,_that.image,_that.url,_that.showId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toStringOrEmpty)  String id, @JsonKey(fromJson: _toStringOrEmpty)  String title, @JsonKey(fromJson: _toStringOrEmpty)  String image, @JsonKey(fromJson: _toStringOrNull)  String? url, @JsonKey(fromJson: _toStringOrNull)  String? showId)?  $default,) {final _that = this;
switch (_that) {
case _BannerDto() when $default != null:
return $default(_that.id,_that.title,_that.image,_that.url,_that.showId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BannerDto implements BannerDto {
  const _BannerDto({@JsonKey(fromJson: _toStringOrEmpty) required this.id, @JsonKey(fromJson: _toStringOrEmpty) required this.title, @JsonKey(fromJson: _toStringOrEmpty) required this.image, @JsonKey(fromJson: _toStringOrNull) this.url, @JsonKey(fromJson: _toStringOrNull) this.showId});
  factory _BannerDto.fromJson(Map<String, dynamic> json) => _$BannerDtoFromJson(json);

@override@JsonKey(fromJson: _toStringOrEmpty) final  String id;
@override@JsonKey(fromJson: _toStringOrEmpty) final  String title;
@override@JsonKey(fromJson: _toStringOrEmpty) final  String image;
@override@JsonKey(fromJson: _toStringOrNull) final  String? url;
@override@JsonKey(fromJson: _toStringOrNull) final  String? showId;

/// Create a copy of BannerDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BannerDtoCopyWith<_BannerDto> get copyWith => __$BannerDtoCopyWithImpl<_BannerDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BannerDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BannerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.image, image) || other.image == image)&&(identical(other.url, url) || other.url == url)&&(identical(other.showId, showId) || other.showId == showId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,image,url,showId);

@override
String toString() {
  return 'BannerDto(id: $id, title: $title, image: $image, url: $url, showId: $showId)';
}


}

/// @nodoc
abstract mixin class _$BannerDtoCopyWith<$Res> implements $BannerDtoCopyWith<$Res> {
  factory _$BannerDtoCopyWith(_BannerDto value, $Res Function(_BannerDto) _then) = __$BannerDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toStringOrEmpty) String id,@JsonKey(fromJson: _toStringOrEmpty) String title,@JsonKey(fromJson: _toStringOrEmpty) String image,@JsonKey(fromJson: _toStringOrNull) String? url,@JsonKey(fromJson: _toStringOrNull) String? showId
});




}
/// @nodoc
class __$BannerDtoCopyWithImpl<$Res>
    implements _$BannerDtoCopyWith<$Res> {
  __$BannerDtoCopyWithImpl(this._self, this._then);

  final _BannerDto _self;
  final $Res Function(_BannerDto) _then;

/// Create a copy of BannerDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? image = null,Object? url = freezed,Object? showId = freezed,}) {
  return _then(_BannerDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,showId: freezed == showId ? _self.showId : showId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
