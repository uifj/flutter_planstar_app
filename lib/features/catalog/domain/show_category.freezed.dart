// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'show_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubCategoryTag {

@JsonKey(readValue: _readSubCategoryId) int get id;@JsonKey(readValue: _readCategoryId) int get categoryId;@JsonKey(readValue: _readName) String get name;
/// Create a copy of SubCategoryTag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubCategoryTagCopyWith<SubCategoryTag> get copyWith => _$SubCategoryTagCopyWithImpl<SubCategoryTag>(this as SubCategoryTag, _$identity);

  /// Serializes this SubCategoryTag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubCategoryTag&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,name);

@override
String toString() {
  return 'SubCategoryTag(id: $id, categoryId: $categoryId, name: $name)';
}


}

/// @nodoc
abstract mixin class $SubCategoryTagCopyWith<$Res>  {
  factory $SubCategoryTagCopyWith(SubCategoryTag value, $Res Function(SubCategoryTag) _then) = _$SubCategoryTagCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readSubCategoryId) int id,@JsonKey(readValue: _readCategoryId) int categoryId,@JsonKey(readValue: _readName) String name
});




}
/// @nodoc
class _$SubCategoryTagCopyWithImpl<$Res>
    implements $SubCategoryTagCopyWith<$Res> {
  _$SubCategoryTagCopyWithImpl(this._self, this._then);

  final SubCategoryTag _self;
  final $Res Function(SubCategoryTag) _then;

/// Create a copy of SubCategoryTag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubCategoryTag].
extension SubCategoryTagPatterns on SubCategoryTag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubCategoryTag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubCategoryTag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubCategoryTag value)  $default,){
final _that = this;
switch (_that) {
case _SubCategoryTag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubCategoryTag value)?  $default,){
final _that = this;
switch (_that) {
case _SubCategoryTag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readSubCategoryId)  int id, @JsonKey(readValue: _readCategoryId)  int categoryId, @JsonKey(readValue: _readName)  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubCategoryTag() when $default != null:
return $default(_that.id,_that.categoryId,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readSubCategoryId)  int id, @JsonKey(readValue: _readCategoryId)  int categoryId, @JsonKey(readValue: _readName)  String name)  $default,) {final _that = this;
switch (_that) {
case _SubCategoryTag():
return $default(_that.id,_that.categoryId,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readSubCategoryId)  int id, @JsonKey(readValue: _readCategoryId)  int categoryId, @JsonKey(readValue: _readName)  String name)?  $default,) {final _that = this;
switch (_that) {
case _SubCategoryTag() when $default != null:
return $default(_that.id,_that.categoryId,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubCategoryTag implements SubCategoryTag {
  const _SubCategoryTag({@JsonKey(readValue: _readSubCategoryId) required this.id, @JsonKey(readValue: _readCategoryId) required this.categoryId, @JsonKey(readValue: _readName) required this.name});
  factory _SubCategoryTag.fromJson(Map<String, dynamic> json) => _$SubCategoryTagFromJson(json);

@override@JsonKey(readValue: _readSubCategoryId) final  int id;
@override@JsonKey(readValue: _readCategoryId) final  int categoryId;
@override@JsonKey(readValue: _readName) final  String name;

/// Create a copy of SubCategoryTag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubCategoryTagCopyWith<_SubCategoryTag> get copyWith => __$SubCategoryTagCopyWithImpl<_SubCategoryTag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubCategoryTagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubCategoryTag&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,name);

@override
String toString() {
  return 'SubCategoryTag(id: $id, categoryId: $categoryId, name: $name)';
}


}

/// @nodoc
abstract mixin class _$SubCategoryTagCopyWith<$Res> implements $SubCategoryTagCopyWith<$Res> {
  factory _$SubCategoryTagCopyWith(_SubCategoryTag value, $Res Function(_SubCategoryTag) _then) = __$SubCategoryTagCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readSubCategoryId) int id,@JsonKey(readValue: _readCategoryId) int categoryId,@JsonKey(readValue: _readName) String name
});




}
/// @nodoc
class __$SubCategoryTagCopyWithImpl<$Res>
    implements _$SubCategoryTagCopyWith<$Res> {
  __$SubCategoryTagCopyWithImpl(this._self, this._then);

  final _SubCategoryTag _self;
  final $Res Function(_SubCategoryTag) _then;

/// Create a copy of SubCategoryTag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = null,Object? name = null,}) {
  return _then(_SubCategoryTag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ShowCategory {

@JsonKey(readValue: _readShowCategoryId) int get id;@JsonKey(readValue: _readShowCategoryName) String get name;@JsonKey(readValue: _readShowCategoryEnName) String get enName;@JsonKey(readValue: _readShowCategoryPinyin) String get pinyin;@JsonKey(readValue: _readSubTags, fromJson: _subTagList) List<SubCategoryTag> get subTags;@JsonKey(readValue: _readShowCategoryStatus) int get status;
/// Create a copy of ShowCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowCategoryCopyWith<ShowCategory> get copyWith => _$ShowCategoryCopyWithImpl<ShowCategory>(this as ShowCategory, _$identity);

  /// Serializes this ShowCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.enName, enName) || other.enName == enName)&&(identical(other.pinyin, pinyin) || other.pinyin == pinyin)&&const DeepCollectionEquality().equals(other.subTags, subTags)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,enName,pinyin,const DeepCollectionEquality().hash(subTags),status);

@override
String toString() {
  return 'ShowCategory(id: $id, name: $name, enName: $enName, pinyin: $pinyin, subTags: $subTags, status: $status)';
}


}

/// @nodoc
abstract mixin class $ShowCategoryCopyWith<$Res>  {
  factory $ShowCategoryCopyWith(ShowCategory value, $Res Function(ShowCategory) _then) = _$ShowCategoryCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readShowCategoryId) int id,@JsonKey(readValue: _readShowCategoryName) String name,@JsonKey(readValue: _readShowCategoryEnName) String enName,@JsonKey(readValue: _readShowCategoryPinyin) String pinyin,@JsonKey(readValue: _readSubTags, fromJson: _subTagList) List<SubCategoryTag> subTags,@JsonKey(readValue: _readShowCategoryStatus) int status
});




}
/// @nodoc
class _$ShowCategoryCopyWithImpl<$Res>
    implements $ShowCategoryCopyWith<$Res> {
  _$ShowCategoryCopyWithImpl(this._self, this._then);

  final ShowCategory _self;
  final $Res Function(ShowCategory) _then;

/// Create a copy of ShowCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? enName = null,Object? pinyin = null,Object? subTags = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enName: null == enName ? _self.enName : enName // ignore: cast_nullable_to_non_nullable
as String,pinyin: null == pinyin ? _self.pinyin : pinyin // ignore: cast_nullable_to_non_nullable
as String,subTags: null == subTags ? _self.subTags : subTags // ignore: cast_nullable_to_non_nullable
as List<SubCategoryTag>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ShowCategory].
extension ShowCategoryPatterns on ShowCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShowCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShowCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShowCategory value)  $default,){
final _that = this;
switch (_that) {
case _ShowCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShowCategory value)?  $default,){
final _that = this;
switch (_that) {
case _ShowCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readShowCategoryId)  int id, @JsonKey(readValue: _readShowCategoryName)  String name, @JsonKey(readValue: _readShowCategoryEnName)  String enName, @JsonKey(readValue: _readShowCategoryPinyin)  String pinyin, @JsonKey(readValue: _readSubTags, fromJson: _subTagList)  List<SubCategoryTag> subTags, @JsonKey(readValue: _readShowCategoryStatus)  int status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShowCategory() when $default != null:
return $default(_that.id,_that.name,_that.enName,_that.pinyin,_that.subTags,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readShowCategoryId)  int id, @JsonKey(readValue: _readShowCategoryName)  String name, @JsonKey(readValue: _readShowCategoryEnName)  String enName, @JsonKey(readValue: _readShowCategoryPinyin)  String pinyin, @JsonKey(readValue: _readSubTags, fromJson: _subTagList)  List<SubCategoryTag> subTags, @JsonKey(readValue: _readShowCategoryStatus)  int status)  $default,) {final _that = this;
switch (_that) {
case _ShowCategory():
return $default(_that.id,_that.name,_that.enName,_that.pinyin,_that.subTags,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readShowCategoryId)  int id, @JsonKey(readValue: _readShowCategoryName)  String name, @JsonKey(readValue: _readShowCategoryEnName)  String enName, @JsonKey(readValue: _readShowCategoryPinyin)  String pinyin, @JsonKey(readValue: _readSubTags, fromJson: _subTagList)  List<SubCategoryTag> subTags, @JsonKey(readValue: _readShowCategoryStatus)  int status)?  $default,) {final _that = this;
switch (_that) {
case _ShowCategory() when $default != null:
return $default(_that.id,_that.name,_that.enName,_that.pinyin,_that.subTags,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShowCategory extends ShowCategory {
  const _ShowCategory({@JsonKey(readValue: _readShowCategoryId) required this.id, @JsonKey(readValue: _readShowCategoryName) required this.name, @JsonKey(readValue: _readShowCategoryEnName) required this.enName, @JsonKey(readValue: _readShowCategoryPinyin) required this.pinyin, @JsonKey(readValue: _readSubTags, fromJson: _subTagList) required final  List<SubCategoryTag> subTags, @JsonKey(readValue: _readShowCategoryStatus) this.status = 1}): _subTags = subTags,super._();
  factory _ShowCategory.fromJson(Map<String, dynamic> json) => _$ShowCategoryFromJson(json);

@override@JsonKey(readValue: _readShowCategoryId) final  int id;
@override@JsonKey(readValue: _readShowCategoryName) final  String name;
@override@JsonKey(readValue: _readShowCategoryEnName) final  String enName;
@override@JsonKey(readValue: _readShowCategoryPinyin) final  String pinyin;
 final  List<SubCategoryTag> _subTags;
@override@JsonKey(readValue: _readSubTags, fromJson: _subTagList) List<SubCategoryTag> get subTags {
  if (_subTags is EqualUnmodifiableListView) return _subTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subTags);
}

@override@JsonKey(readValue: _readShowCategoryStatus) final  int status;

/// Create a copy of ShowCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShowCategoryCopyWith<_ShowCategory> get copyWith => __$ShowCategoryCopyWithImpl<_ShowCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShowCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShowCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.enName, enName) || other.enName == enName)&&(identical(other.pinyin, pinyin) || other.pinyin == pinyin)&&const DeepCollectionEquality().equals(other._subTags, _subTags)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,enName,pinyin,const DeepCollectionEquality().hash(_subTags),status);

@override
String toString() {
  return 'ShowCategory(id: $id, name: $name, enName: $enName, pinyin: $pinyin, subTags: $subTags, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ShowCategoryCopyWith<$Res> implements $ShowCategoryCopyWith<$Res> {
  factory _$ShowCategoryCopyWith(_ShowCategory value, $Res Function(_ShowCategory) _then) = __$ShowCategoryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readShowCategoryId) int id,@JsonKey(readValue: _readShowCategoryName) String name,@JsonKey(readValue: _readShowCategoryEnName) String enName,@JsonKey(readValue: _readShowCategoryPinyin) String pinyin,@JsonKey(readValue: _readSubTags, fromJson: _subTagList) List<SubCategoryTag> subTags,@JsonKey(readValue: _readShowCategoryStatus) int status
});




}
/// @nodoc
class __$ShowCategoryCopyWithImpl<$Res>
    implements _$ShowCategoryCopyWith<$Res> {
  __$ShowCategoryCopyWithImpl(this._self, this._then);

  final _ShowCategory _self;
  final $Res Function(_ShowCategory) _then;

/// Create a copy of ShowCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? enName = null,Object? pinyin = null,Object? subTags = null,Object? status = null,}) {
  return _then(_ShowCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enName: null == enName ? _self.enName : enName // ignore: cast_nullable_to_non_nullable
as String,pinyin: null == pinyin ? _self.pinyin : pinyin // ignore: cast_nullable_to_non_nullable
as String,subTags: null == subTags ? _self._subTags : subTags // ignore: cast_nullable_to_non_nullable
as List<SubCategoryTag>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
