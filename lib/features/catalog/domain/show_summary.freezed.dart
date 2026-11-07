// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'show_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TicketTier {

@JsonKey(readValue: _readTierName) String get name;@JsonKey(readValue: _readTierPrice, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents) Money get price;@JsonKey(readValue: _readTierNote) String? get note;@JsonKey(readValue: _readTierRemaining) int? get remaining;@JsonKey(readValue: _readTierRewardType) String get rewardType;@JsonKey(readValue: _readTierItems, fromJson: _stringList) List<String> get items;@JsonKey(readValue: _readTierEstimatedDeliveryTime) String get estimatedDeliveryTime;
/// Create a copy of TicketTier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketTierCopyWith<TicketTier> get copyWith => _$TicketTierCopyWithImpl<TicketTier>(this as TicketTier, _$identity);

  /// Serializes this TicketTier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketTier&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.note, note) || other.note == note)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.rewardType, rewardType) || other.rewardType == rewardType)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.estimatedDeliveryTime, estimatedDeliveryTime) || other.estimatedDeliveryTime == estimatedDeliveryTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,note,remaining,rewardType,const DeepCollectionEquality().hash(items),estimatedDeliveryTime);

@override
String toString() {
  return 'TicketTier(name: $name, price: $price, note: $note, remaining: $remaining, rewardType: $rewardType, items: $items, estimatedDeliveryTime: $estimatedDeliveryTime)';
}


}

/// @nodoc
abstract mixin class $TicketTierCopyWith<$Res>  {
  factory $TicketTierCopyWith(TicketTier value, $Res Function(TicketTier) _then) = _$TicketTierCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readTierName) String name,@JsonKey(readValue: _readTierPrice, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents) Money price,@JsonKey(readValue: _readTierNote) String? note,@JsonKey(readValue: _readTierRemaining) int? remaining,@JsonKey(readValue: _readTierRewardType) String rewardType,@JsonKey(readValue: _readTierItems, fromJson: _stringList) List<String> items,@JsonKey(readValue: _readTierEstimatedDeliveryTime) String estimatedDeliveryTime
});




}
/// @nodoc
class _$TicketTierCopyWithImpl<$Res>
    implements $TicketTierCopyWith<$Res> {
  _$TicketTierCopyWithImpl(this._self, this._then);

  final TicketTier _self;
  final $Res Function(TicketTier) _then;

/// Create a copy of TicketTier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? price = null,Object? note = freezed,Object? remaining = freezed,Object? rewardType = null,Object? items = null,Object? estimatedDeliveryTime = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Money,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int?,rewardType: null == rewardType ? _self.rewardType : rewardType // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<String>,estimatedDeliveryTime: null == estimatedDeliveryTime ? _self.estimatedDeliveryTime : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketTier].
extension TicketTierPatterns on TicketTier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketTier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketTier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketTier value)  $default,){
final _that = this;
switch (_that) {
case _TicketTier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketTier value)?  $default,){
final _that = this;
switch (_that) {
case _TicketTier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readTierName)  String name, @JsonKey(readValue: _readTierPrice, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents)  Money price, @JsonKey(readValue: _readTierNote)  String? note, @JsonKey(readValue: _readTierRemaining)  int? remaining, @JsonKey(readValue: _readTierRewardType)  String rewardType, @JsonKey(readValue: _readTierItems, fromJson: _stringList)  List<String> items, @JsonKey(readValue: _readTierEstimatedDeliveryTime)  String estimatedDeliveryTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketTier() when $default != null:
return $default(_that.name,_that.price,_that.note,_that.remaining,_that.rewardType,_that.items,_that.estimatedDeliveryTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readTierName)  String name, @JsonKey(readValue: _readTierPrice, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents)  Money price, @JsonKey(readValue: _readTierNote)  String? note, @JsonKey(readValue: _readTierRemaining)  int? remaining, @JsonKey(readValue: _readTierRewardType)  String rewardType, @JsonKey(readValue: _readTierItems, fromJson: _stringList)  List<String> items, @JsonKey(readValue: _readTierEstimatedDeliveryTime)  String estimatedDeliveryTime)  $default,) {final _that = this;
switch (_that) {
case _TicketTier():
return $default(_that.name,_that.price,_that.note,_that.remaining,_that.rewardType,_that.items,_that.estimatedDeliveryTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readTierName)  String name, @JsonKey(readValue: _readTierPrice, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents)  Money price, @JsonKey(readValue: _readTierNote)  String? note, @JsonKey(readValue: _readTierRemaining)  int? remaining, @JsonKey(readValue: _readTierRewardType)  String rewardType, @JsonKey(readValue: _readTierItems, fromJson: _stringList)  List<String> items, @JsonKey(readValue: _readTierEstimatedDeliveryTime)  String estimatedDeliveryTime)?  $default,) {final _that = this;
switch (_that) {
case _TicketTier() when $default != null:
return $default(_that.name,_that.price,_that.note,_that.remaining,_that.rewardType,_that.items,_that.estimatedDeliveryTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TicketTier extends TicketTier {
  const _TicketTier({@JsonKey(readValue: _readTierName) required this.name, @JsonKey(readValue: _readTierPrice, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents) required this.price, @JsonKey(readValue: _readTierNote) this.note, @JsonKey(readValue: _readTierRemaining) this.remaining, @JsonKey(readValue: _readTierRewardType) this.rewardType = '', @JsonKey(readValue: _readTierItems, fromJson: _stringList) final  List<String> items = const <String>[], @JsonKey(readValue: _readTierEstimatedDeliveryTime) this.estimatedDeliveryTime = ''}): _items = items,super._();
  factory _TicketTier.fromJson(Map<String, dynamic> json) => _$TicketTierFromJson(json);

@override@JsonKey(readValue: _readTierName) final  String name;
@override@JsonKey(readValue: _readTierPrice, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents) final  Money price;
@override@JsonKey(readValue: _readTierNote) final  String? note;
@override@JsonKey(readValue: _readTierRemaining) final  int? remaining;
@override@JsonKey(readValue: _readTierRewardType) final  String rewardType;
 final  List<String> _items;
@override@JsonKey(readValue: _readTierItems, fromJson: _stringList) List<String> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(readValue: _readTierEstimatedDeliveryTime) final  String estimatedDeliveryTime;

/// Create a copy of TicketTier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketTierCopyWith<_TicketTier> get copyWith => __$TicketTierCopyWithImpl<_TicketTier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketTierToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketTier&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.note, note) || other.note == note)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.rewardType, rewardType) || other.rewardType == rewardType)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.estimatedDeliveryTime, estimatedDeliveryTime) || other.estimatedDeliveryTime == estimatedDeliveryTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,note,remaining,rewardType,const DeepCollectionEquality().hash(_items),estimatedDeliveryTime);

@override
String toString() {
  return 'TicketTier(name: $name, price: $price, note: $note, remaining: $remaining, rewardType: $rewardType, items: $items, estimatedDeliveryTime: $estimatedDeliveryTime)';
}


}

/// @nodoc
abstract mixin class _$TicketTierCopyWith<$Res> implements $TicketTierCopyWith<$Res> {
  factory _$TicketTierCopyWith(_TicketTier value, $Res Function(_TicketTier) _then) = __$TicketTierCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readTierName) String name,@JsonKey(readValue: _readTierPrice, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents) Money price,@JsonKey(readValue: _readTierNote) String? note,@JsonKey(readValue: _readTierRemaining) int? remaining,@JsonKey(readValue: _readTierRewardType) String rewardType,@JsonKey(readValue: _readTierItems, fromJson: _stringList) List<String> items,@JsonKey(readValue: _readTierEstimatedDeliveryTime) String estimatedDeliveryTime
});




}
/// @nodoc
class __$TicketTierCopyWithImpl<$Res>
    implements _$TicketTierCopyWith<$Res> {
  __$TicketTierCopyWithImpl(this._self, this._then);

  final _TicketTier _self;
  final $Res Function(_TicketTier) _then;

/// Create a copy of TicketTier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? price = null,Object? note = freezed,Object? remaining = freezed,Object? rewardType = null,Object? items = null,Object? estimatedDeliveryTime = null,}) {
  return _then(_TicketTier(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Money,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int?,rewardType: null == rewardType ? _self.rewardType : rewardType // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<String>,estimatedDeliveryTime: null == estimatedDeliveryTime ? _self.estimatedDeliveryTime : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProjectFaq {

@JsonKey(readValue: _readFaqQuestion) String get question;@JsonKey(readValue: _readFaqAnswer) String get answer;@JsonKey(readValue: _readFaqSort) int get sort;
/// Create a copy of ProjectFaq
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectFaqCopyWith<ProjectFaq> get copyWith => _$ProjectFaqCopyWithImpl<ProjectFaq>(this as ProjectFaq, _$identity);

  /// Serializes this ProjectFaq to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectFaq&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.sort, sort) || other.sort == sort));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,question,answer,sort);

@override
String toString() {
  return 'ProjectFaq(question: $question, answer: $answer, sort: $sort)';
}


}

/// @nodoc
abstract mixin class $ProjectFaqCopyWith<$Res>  {
  factory $ProjectFaqCopyWith(ProjectFaq value, $Res Function(ProjectFaq) _then) = _$ProjectFaqCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readFaqQuestion) String question,@JsonKey(readValue: _readFaqAnswer) String answer,@JsonKey(readValue: _readFaqSort) int sort
});




}
/// @nodoc
class _$ProjectFaqCopyWithImpl<$Res>
    implements $ProjectFaqCopyWith<$Res> {
  _$ProjectFaqCopyWithImpl(this._self, this._then);

  final ProjectFaq _self;
  final $Res Function(ProjectFaq) _then;

/// Create a copy of ProjectFaq
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? question = null,Object? answer = null,Object? sort = null,}) {
  return _then(_self.copyWith(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectFaq].
extension ProjectFaqPatterns on ProjectFaq {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectFaq value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectFaq() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectFaq value)  $default,){
final _that = this;
switch (_that) {
case _ProjectFaq():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectFaq value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectFaq() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFaqQuestion)  String question, @JsonKey(readValue: _readFaqAnswer)  String answer, @JsonKey(readValue: _readFaqSort)  int sort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectFaq() when $default != null:
return $default(_that.question,_that.answer,_that.sort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFaqQuestion)  String question, @JsonKey(readValue: _readFaqAnswer)  String answer, @JsonKey(readValue: _readFaqSort)  int sort)  $default,) {final _that = this;
switch (_that) {
case _ProjectFaq():
return $default(_that.question,_that.answer,_that.sort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readFaqQuestion)  String question, @JsonKey(readValue: _readFaqAnswer)  String answer, @JsonKey(readValue: _readFaqSort)  int sort)?  $default,) {final _that = this;
switch (_that) {
case _ProjectFaq() when $default != null:
return $default(_that.question,_that.answer,_that.sort);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectFaq implements ProjectFaq {
  const _ProjectFaq({@JsonKey(readValue: _readFaqQuestion) required this.question, @JsonKey(readValue: _readFaqAnswer) required this.answer, @JsonKey(readValue: _readFaqSort) this.sort = 0});
  factory _ProjectFaq.fromJson(Map<String, dynamic> json) => _$ProjectFaqFromJson(json);

@override@JsonKey(readValue: _readFaqQuestion) final  String question;
@override@JsonKey(readValue: _readFaqAnswer) final  String answer;
@override@JsonKey(readValue: _readFaqSort) final  int sort;

/// Create a copy of ProjectFaq
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectFaqCopyWith<_ProjectFaq> get copyWith => __$ProjectFaqCopyWithImpl<_ProjectFaq>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectFaqToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectFaq&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.sort, sort) || other.sort == sort));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,question,answer,sort);

@override
String toString() {
  return 'ProjectFaq(question: $question, answer: $answer, sort: $sort)';
}


}

/// @nodoc
abstract mixin class _$ProjectFaqCopyWith<$Res> implements $ProjectFaqCopyWith<$Res> {
  factory _$ProjectFaqCopyWith(_ProjectFaq value, $Res Function(_ProjectFaq) _then) = __$ProjectFaqCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readFaqQuestion) String question,@JsonKey(readValue: _readFaqAnswer) String answer,@JsonKey(readValue: _readFaqSort) int sort
});




}
/// @nodoc
class __$ProjectFaqCopyWithImpl<$Res>
    implements _$ProjectFaqCopyWith<$Res> {
  __$ProjectFaqCopyWithImpl(this._self, this._then);

  final _ProjectFaq _self;
  final $Res Function(_ProjectFaq) _then;

/// Create a copy of ProjectFaq
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? question = null,Object? answer = null,Object? sort = null,}) {
  return _then(_ProjectFaq(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ProjectReview {

@JsonKey(readValue: _readReviewUserName) String get userName;@JsonKey(readValue: _readReviewRating) int get rating;@JsonKey(readValue: _readReviewContent) String get content;@JsonKey(readValue: _readReviewImages, fromJson: _stringList) List<String> get images;@JsonKey(readValue: _readReviewIsShow) bool get isShow;@JsonKey(readValue: _readReviewIsAnonymous) bool get isAnonymous;@JsonKey(readValue: _readReviewLikeCount) int get likeCount;@JsonKey(readValue: _readReviewCreatedAt, fromJson: _dateTime) DateTime? get createdAt;
/// Create a copy of ProjectReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectReviewCopyWith<ProjectReview> get copyWith => _$ProjectReviewCopyWithImpl<ProjectReview>(this as ProjectReview, _$identity);

  /// Serializes this ProjectReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectReview&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.isShow, isShow) || other.isShow == isShow)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userName,rating,content,const DeepCollectionEquality().hash(images),isShow,isAnonymous,likeCount,createdAt);

@override
String toString() {
  return 'ProjectReview(userName: $userName, rating: $rating, content: $content, images: $images, isShow: $isShow, isAnonymous: $isAnonymous, likeCount: $likeCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProjectReviewCopyWith<$Res>  {
  factory $ProjectReviewCopyWith(ProjectReview value, $Res Function(ProjectReview) _then) = _$ProjectReviewCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readReviewUserName) String userName,@JsonKey(readValue: _readReviewRating) int rating,@JsonKey(readValue: _readReviewContent) String content,@JsonKey(readValue: _readReviewImages, fromJson: _stringList) List<String> images,@JsonKey(readValue: _readReviewIsShow) bool isShow,@JsonKey(readValue: _readReviewIsAnonymous) bool isAnonymous,@JsonKey(readValue: _readReviewLikeCount) int likeCount,@JsonKey(readValue: _readReviewCreatedAt, fromJson: _dateTime) DateTime? createdAt
});




}
/// @nodoc
class _$ProjectReviewCopyWithImpl<$Res>
    implements $ProjectReviewCopyWith<$Res> {
  _$ProjectReviewCopyWithImpl(this._self, this._then);

  final ProjectReview _self;
  final $Res Function(ProjectReview) _then;

/// Create a copy of ProjectReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userName = null,Object? rating = null,Object? content = null,Object? images = null,Object? isShow = null,Object? isAnonymous = null,Object? likeCount = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,isShow: null == isShow ? _self.isShow : isShow // ignore: cast_nullable_to_non_nullable
as bool,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectReview].
extension ProjectReviewPatterns on ProjectReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectReview value)  $default,){
final _that = this;
switch (_that) {
case _ProjectReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectReview value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readReviewUserName)  String userName, @JsonKey(readValue: _readReviewRating)  int rating, @JsonKey(readValue: _readReviewContent)  String content, @JsonKey(readValue: _readReviewImages, fromJson: _stringList)  List<String> images, @JsonKey(readValue: _readReviewIsShow)  bool isShow, @JsonKey(readValue: _readReviewIsAnonymous)  bool isAnonymous, @JsonKey(readValue: _readReviewLikeCount)  int likeCount, @JsonKey(readValue: _readReviewCreatedAt, fromJson: _dateTime)  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectReview() when $default != null:
return $default(_that.userName,_that.rating,_that.content,_that.images,_that.isShow,_that.isAnonymous,_that.likeCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readReviewUserName)  String userName, @JsonKey(readValue: _readReviewRating)  int rating, @JsonKey(readValue: _readReviewContent)  String content, @JsonKey(readValue: _readReviewImages, fromJson: _stringList)  List<String> images, @JsonKey(readValue: _readReviewIsShow)  bool isShow, @JsonKey(readValue: _readReviewIsAnonymous)  bool isAnonymous, @JsonKey(readValue: _readReviewLikeCount)  int likeCount, @JsonKey(readValue: _readReviewCreatedAt, fromJson: _dateTime)  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ProjectReview():
return $default(_that.userName,_that.rating,_that.content,_that.images,_that.isShow,_that.isAnonymous,_that.likeCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readReviewUserName)  String userName, @JsonKey(readValue: _readReviewRating)  int rating, @JsonKey(readValue: _readReviewContent)  String content, @JsonKey(readValue: _readReviewImages, fromJson: _stringList)  List<String> images, @JsonKey(readValue: _readReviewIsShow)  bool isShow, @JsonKey(readValue: _readReviewIsAnonymous)  bool isAnonymous, @JsonKey(readValue: _readReviewLikeCount)  int likeCount, @JsonKey(readValue: _readReviewCreatedAt, fromJson: _dateTime)  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ProjectReview() when $default != null:
return $default(_that.userName,_that.rating,_that.content,_that.images,_that.isShow,_that.isAnonymous,_that.likeCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectReview extends ProjectReview {
  const _ProjectReview({@JsonKey(readValue: _readReviewUserName) required this.userName, @JsonKey(readValue: _readReviewRating) required this.rating, @JsonKey(readValue: _readReviewContent) this.content = '', @JsonKey(readValue: _readReviewImages, fromJson: _stringList) final  List<String> images = const <String>[], @JsonKey(readValue: _readReviewIsShow) this.isShow = false, @JsonKey(readValue: _readReviewIsAnonymous) this.isAnonymous = false, @JsonKey(readValue: _readReviewLikeCount) this.likeCount = 0, @JsonKey(readValue: _readReviewCreatedAt, fromJson: _dateTime) this.createdAt}): _images = images,super._();
  factory _ProjectReview.fromJson(Map<String, dynamic> json) => _$ProjectReviewFromJson(json);

@override@JsonKey(readValue: _readReviewUserName) final  String userName;
@override@JsonKey(readValue: _readReviewRating) final  int rating;
@override@JsonKey(readValue: _readReviewContent) final  String content;
 final  List<String> _images;
@override@JsonKey(readValue: _readReviewImages, fromJson: _stringList) List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(readValue: _readReviewIsShow) final  bool isShow;
@override@JsonKey(readValue: _readReviewIsAnonymous) final  bool isAnonymous;
@override@JsonKey(readValue: _readReviewLikeCount) final  int likeCount;
@override@JsonKey(readValue: _readReviewCreatedAt, fromJson: _dateTime) final  DateTime? createdAt;

/// Create a copy of ProjectReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectReviewCopyWith<_ProjectReview> get copyWith => __$ProjectReviewCopyWithImpl<_ProjectReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectReview&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.isShow, isShow) || other.isShow == isShow)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userName,rating,content,const DeepCollectionEquality().hash(_images),isShow,isAnonymous,likeCount,createdAt);

@override
String toString() {
  return 'ProjectReview(userName: $userName, rating: $rating, content: $content, images: $images, isShow: $isShow, isAnonymous: $isAnonymous, likeCount: $likeCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectReviewCopyWith<$Res> implements $ProjectReviewCopyWith<$Res> {
  factory _$ProjectReviewCopyWith(_ProjectReview value, $Res Function(_ProjectReview) _then) = __$ProjectReviewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readReviewUserName) String userName,@JsonKey(readValue: _readReviewRating) int rating,@JsonKey(readValue: _readReviewContent) String content,@JsonKey(readValue: _readReviewImages, fromJson: _stringList) List<String> images,@JsonKey(readValue: _readReviewIsShow) bool isShow,@JsonKey(readValue: _readReviewIsAnonymous) bool isAnonymous,@JsonKey(readValue: _readReviewLikeCount) int likeCount,@JsonKey(readValue: _readReviewCreatedAt, fromJson: _dateTime) DateTime? createdAt
});




}
/// @nodoc
class __$ProjectReviewCopyWithImpl<$Res>
    implements _$ProjectReviewCopyWith<$Res> {
  __$ProjectReviewCopyWithImpl(this._self, this._then);

  final _ProjectReview _self;
  final $Res Function(_ProjectReview) _then;

/// Create a copy of ProjectReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userName = null,Object? rating = null,Object? content = null,Object? images = null,Object? isShow = null,Object? isAnonymous = null,Object? likeCount = null,Object? createdAt = freezed,}) {
  return _then(_ProjectReview(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,isShow: null == isShow ? _self.isShow : isShow // ignore: cast_nullable_to_non_nullable
as bool,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ProjectUpdate {

@JsonKey(readValue: _readUpdateTitle) String get title;@JsonKey(readValue: _readUpdateContent) String get content;@JsonKey(readValue: _readUpdatePublishTime, fromJson: _dateTime) DateTime? get publishTime;
/// Create a copy of ProjectUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectUpdateCopyWith<ProjectUpdate> get copyWith => _$ProjectUpdateCopyWithImpl<ProjectUpdate>(this as ProjectUpdate, _$identity);

  /// Serializes this ProjectUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectUpdate&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.publishTime, publishTime) || other.publishTime == publishTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,content,publishTime);

@override
String toString() {
  return 'ProjectUpdate(title: $title, content: $content, publishTime: $publishTime)';
}


}

/// @nodoc
abstract mixin class $ProjectUpdateCopyWith<$Res>  {
  factory $ProjectUpdateCopyWith(ProjectUpdate value, $Res Function(ProjectUpdate) _then) = _$ProjectUpdateCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readUpdateTitle) String title,@JsonKey(readValue: _readUpdateContent) String content,@JsonKey(readValue: _readUpdatePublishTime, fromJson: _dateTime) DateTime? publishTime
});




}
/// @nodoc
class _$ProjectUpdateCopyWithImpl<$Res>
    implements $ProjectUpdateCopyWith<$Res> {
  _$ProjectUpdateCopyWithImpl(this._self, this._then);

  final ProjectUpdate _self;
  final $Res Function(ProjectUpdate) _then;

/// Create a copy of ProjectUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? content = null,Object? publishTime = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,publishTime: freezed == publishTime ? _self.publishTime : publishTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectUpdate].
extension ProjectUpdatePatterns on ProjectUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectUpdate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectUpdate value)  $default,){
final _that = this;
switch (_that) {
case _ProjectUpdate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectUpdate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readUpdateTitle)  String title, @JsonKey(readValue: _readUpdateContent)  String content, @JsonKey(readValue: _readUpdatePublishTime, fromJson: _dateTime)  DateTime? publishTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectUpdate() when $default != null:
return $default(_that.title,_that.content,_that.publishTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readUpdateTitle)  String title, @JsonKey(readValue: _readUpdateContent)  String content, @JsonKey(readValue: _readUpdatePublishTime, fromJson: _dateTime)  DateTime? publishTime)  $default,) {final _that = this;
switch (_that) {
case _ProjectUpdate():
return $default(_that.title,_that.content,_that.publishTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readUpdateTitle)  String title, @JsonKey(readValue: _readUpdateContent)  String content, @JsonKey(readValue: _readUpdatePublishTime, fromJson: _dateTime)  DateTime? publishTime)?  $default,) {final _that = this;
switch (_that) {
case _ProjectUpdate() when $default != null:
return $default(_that.title,_that.content,_that.publishTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectUpdate implements ProjectUpdate {
  const _ProjectUpdate({@JsonKey(readValue: _readUpdateTitle) required this.title, @JsonKey(readValue: _readUpdateContent) required this.content, @JsonKey(readValue: _readUpdatePublishTime, fromJson: _dateTime) this.publishTime});
  factory _ProjectUpdate.fromJson(Map<String, dynamic> json) => _$ProjectUpdateFromJson(json);

@override@JsonKey(readValue: _readUpdateTitle) final  String title;
@override@JsonKey(readValue: _readUpdateContent) final  String content;
@override@JsonKey(readValue: _readUpdatePublishTime, fromJson: _dateTime) final  DateTime? publishTime;

/// Create a copy of ProjectUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectUpdateCopyWith<_ProjectUpdate> get copyWith => __$ProjectUpdateCopyWithImpl<_ProjectUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectUpdate&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.publishTime, publishTime) || other.publishTime == publishTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,content,publishTime);

@override
String toString() {
  return 'ProjectUpdate(title: $title, content: $content, publishTime: $publishTime)';
}


}

/// @nodoc
abstract mixin class _$ProjectUpdateCopyWith<$Res> implements $ProjectUpdateCopyWith<$Res> {
  factory _$ProjectUpdateCopyWith(_ProjectUpdate value, $Res Function(_ProjectUpdate) _then) = __$ProjectUpdateCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readUpdateTitle) String title,@JsonKey(readValue: _readUpdateContent) String content,@JsonKey(readValue: _readUpdatePublishTime, fromJson: _dateTime) DateTime? publishTime
});




}
/// @nodoc
class __$ProjectUpdateCopyWithImpl<$Res>
    implements _$ProjectUpdateCopyWith<$Res> {
  __$ProjectUpdateCopyWithImpl(this._self, this._then);

  final _ProjectUpdate _self;
  final $Res Function(_ProjectUpdate) _then;

/// Create a copy of ProjectUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? content = null,Object? publishTime = freezed,}) {
  return _then(_ProjectUpdate(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,publishTime: freezed == publishTime ? _self.publishTime : publishTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ShowSession {

@JsonKey(readValue: _readSessionStartsAt, fromJson: _dateTimeOrNow) DateTime get startsAt;@JsonKey(readValue: _readSessionTierSummary) String get tierSummary;@JsonKey(readValue: _readSessionSoldOut) bool get soldOut;
/// Create a copy of ShowSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowSessionCopyWith<ShowSession> get copyWith => _$ShowSessionCopyWithImpl<ShowSession>(this as ShowSession, _$identity);

  /// Serializes this ShowSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowSession&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.tierSummary, tierSummary) || other.tierSummary == tierSummary)&&(identical(other.soldOut, soldOut) || other.soldOut == soldOut));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startsAt,tierSummary,soldOut);

@override
String toString() {
  return 'ShowSession(startsAt: $startsAt, tierSummary: $tierSummary, soldOut: $soldOut)';
}


}

/// @nodoc
abstract mixin class $ShowSessionCopyWith<$Res>  {
  factory $ShowSessionCopyWith(ShowSession value, $Res Function(ShowSession) _then) = _$ShowSessionCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readSessionStartsAt, fromJson: _dateTimeOrNow) DateTime startsAt,@JsonKey(readValue: _readSessionTierSummary) String tierSummary,@JsonKey(readValue: _readSessionSoldOut) bool soldOut
});




}
/// @nodoc
class _$ShowSessionCopyWithImpl<$Res>
    implements $ShowSessionCopyWith<$Res> {
  _$ShowSessionCopyWithImpl(this._self, this._then);

  final ShowSession _self;
  final $Res Function(ShowSession) _then;

/// Create a copy of ShowSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startsAt = null,Object? tierSummary = null,Object? soldOut = null,}) {
  return _then(_self.copyWith(
startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,tierSummary: null == tierSummary ? _self.tierSummary : tierSummary // ignore: cast_nullable_to_non_nullable
as String,soldOut: null == soldOut ? _self.soldOut : soldOut // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShowSession].
extension ShowSessionPatterns on ShowSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShowSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShowSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShowSession value)  $default,){
final _that = this;
switch (_that) {
case _ShowSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShowSession value)?  $default,){
final _that = this;
switch (_that) {
case _ShowSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readSessionStartsAt, fromJson: _dateTimeOrNow)  DateTime startsAt, @JsonKey(readValue: _readSessionTierSummary)  String tierSummary, @JsonKey(readValue: _readSessionSoldOut)  bool soldOut)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShowSession() when $default != null:
return $default(_that.startsAt,_that.tierSummary,_that.soldOut);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readSessionStartsAt, fromJson: _dateTimeOrNow)  DateTime startsAt, @JsonKey(readValue: _readSessionTierSummary)  String tierSummary, @JsonKey(readValue: _readSessionSoldOut)  bool soldOut)  $default,) {final _that = this;
switch (_that) {
case _ShowSession():
return $default(_that.startsAt,_that.tierSummary,_that.soldOut);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readSessionStartsAt, fromJson: _dateTimeOrNow)  DateTime startsAt, @JsonKey(readValue: _readSessionTierSummary)  String tierSummary, @JsonKey(readValue: _readSessionSoldOut)  bool soldOut)?  $default,) {final _that = this;
switch (_that) {
case _ShowSession() when $default != null:
return $default(_that.startsAt,_that.tierSummary,_that.soldOut);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShowSession implements ShowSession {
  const _ShowSession({@JsonKey(readValue: _readSessionStartsAt, fromJson: _dateTimeOrNow) required this.startsAt, @JsonKey(readValue: _readSessionTierSummary) required this.tierSummary, @JsonKey(readValue: _readSessionSoldOut) this.soldOut = false});
  factory _ShowSession.fromJson(Map<String, dynamic> json) => _$ShowSessionFromJson(json);

@override@JsonKey(readValue: _readSessionStartsAt, fromJson: _dateTimeOrNow) final  DateTime startsAt;
@override@JsonKey(readValue: _readSessionTierSummary) final  String tierSummary;
@override@JsonKey(readValue: _readSessionSoldOut) final  bool soldOut;

/// Create a copy of ShowSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShowSessionCopyWith<_ShowSession> get copyWith => __$ShowSessionCopyWithImpl<_ShowSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShowSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShowSession&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.tierSummary, tierSummary) || other.tierSummary == tierSummary)&&(identical(other.soldOut, soldOut) || other.soldOut == soldOut));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startsAt,tierSummary,soldOut);

@override
String toString() {
  return 'ShowSession(startsAt: $startsAt, tierSummary: $tierSummary, soldOut: $soldOut)';
}


}

/// @nodoc
abstract mixin class _$ShowSessionCopyWith<$Res> implements $ShowSessionCopyWith<$Res> {
  factory _$ShowSessionCopyWith(_ShowSession value, $Res Function(_ShowSession) _then) = __$ShowSessionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readSessionStartsAt, fromJson: _dateTimeOrNow) DateTime startsAt,@JsonKey(readValue: _readSessionTierSummary) String tierSummary,@JsonKey(readValue: _readSessionSoldOut) bool soldOut
});




}
/// @nodoc
class __$ShowSessionCopyWithImpl<$Res>
    implements _$ShowSessionCopyWith<$Res> {
  __$ShowSessionCopyWithImpl(this._self, this._then);

  final _ShowSession _self;
  final $Res Function(_ShowSession) _then;

/// Create a copy of ShowSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startsAt = null,Object? tierSummary = null,Object? soldOut = null,}) {
  return _then(_ShowSession(
startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,tierSummary: null == tierSummary ? _self.tierSummary : tierSummary // ignore: cast_nullable_to_non_nullable
as String,soldOut: null == soldOut ? _self.soldOut : soldOut // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ShowSummary {

@JsonKey(readValue: _readShowId) String get id;@JsonKey(readValue: _readShowTitle) String get title;@JsonKey(readValue: _readShowArtist) String get artist;@JsonKey(readValue: _readShowCategoryId) int get categoryId;@JsonKey(readValue: _readShowCategoryName) String get categoryName;@JsonKey(readValue: _readShowCity) String get city;@JsonKey(readValue: _readShowVenue) String get venue;@JsonKey(readValue: _readShowVenueAddress) String get venueAddress;@JsonKey(readValue: _readShowFirstSessionAt, fromJson: _dateTimeOrNow) DateTime get firstSessionAt;@JsonKey(readValue: _readShowPriceFrom, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents) Money get priceFrom;@JsonKey(readValue: _readShowListPriceFrom, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) Money? get listPriceFrom;@JsonKey(readValue: _readShowDiscountPermille) int? get discountPermille;@JsonKey(readValue: _readShowTags, fromJson: _stringList) List<String> get tags;@JsonKey(readValue: _readShowWishCount) int get wishCount;@JsonKey(readValue: _readShowSoldOut) bool get soldOut;@JsonKey(readValue: _readShowProxyBuy) bool get proxyBuy; double get rating;@JsonKey(readValue: _readShowRatingCount) int get ratingCount;@JsonKey(readValue: _readShowDuration) String get duration;@JsonKey(readValue: _readShowIntro) String get intro;@JsonKey(readValue: _readShowSessions, fromJson: _sessionList) List<ShowSession> get sessions;@JsonKey(readValue: _readShowTiers, fromJson: _tierList) List<TicketTier> get tiers;@JsonKey(readValue: _readShowLineup, fromJson: _stringList) List<String> get lineup;@JsonKey(readValue: _readShowPurchaseNotice, fromJson: _stringList) List<String> get purchaseNotice;@JsonKey(readValue: _readShowGoalAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) Money? get goalAmount;@JsonKey(readValue: _readShowRaisedAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) Money? get raisedAmount;@JsonKey(readValue: _readShowSupporterCount) int get supporterCount;@JsonKey(readValue: _readShowDeadline, fromJson: _dateTime) DateTime? get deadline;@JsonKey(readValue: _readShowFundingStatus) String get fundingStatus;@JsonKey(readValue: _readShowRiskNote) String get riskNote;@JsonKey(readValue: _readShowDeliveryPlan) String get deliveryPlan;@JsonKey(readValue: _readShowFundUsage) String get fundUsage;@JsonKey(readValue: _readShowRefundRule) String get refundRule;@JsonKey(readValue: _readShowRefundDays) int get refundDays;@JsonKey(readValue: _readShowFaqs, fromJson: _faqList) List<ProjectFaq> get faqs;@JsonKey(readValue: _readShowReviews, fromJson: _reviewList) List<ProjectReview> get reviews; double get ratingAvg;@JsonKey(readValue: _readShowApiReviewCount) int get apiReviewCount;@JsonKey(readValue: _readShowApiShowCount) int get apiShowCount;@JsonKey(readValue: _readShowUpdates, fromJson: _updateList) List<ProjectUpdate> get updates;@JsonKey(readValue: _readShowCreatorVerified) bool get creatorVerified;@JsonKey(readValue: _readShowCreatorProjectNum) int get creatorProjectNum;@JsonKey(readValue: _readShowCreatorSuccessNum) int get creatorSuccessNum;@JsonKey(readValue: _readShowCreatorFulfillmentPermille) int get creatorFulfillmentPermille;@JsonKey(readValue: _readShowCreatorBio) String get creatorBio;
/// Create a copy of ShowSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowSummaryCopyWith<ShowSummary> get copyWith => _$ShowSummaryCopyWithImpl<ShowSummary>(this as ShowSummary, _$identity);

  /// Serializes this ShowSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.city, city) || other.city == city)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.venueAddress, venueAddress) || other.venueAddress == venueAddress)&&(identical(other.firstSessionAt, firstSessionAt) || other.firstSessionAt == firstSessionAt)&&(identical(other.priceFrom, priceFrom) || other.priceFrom == priceFrom)&&(identical(other.listPriceFrom, listPriceFrom) || other.listPriceFrom == listPriceFrom)&&(identical(other.discountPermille, discountPermille) || other.discountPermille == discountPermille)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.wishCount, wishCount) || other.wishCount == wishCount)&&(identical(other.soldOut, soldOut) || other.soldOut == soldOut)&&(identical(other.proxyBuy, proxyBuy) || other.proxyBuy == proxyBuy)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.intro, intro) || other.intro == intro)&&const DeepCollectionEquality().equals(other.sessions, sessions)&&const DeepCollectionEquality().equals(other.tiers, tiers)&&const DeepCollectionEquality().equals(other.lineup, lineup)&&const DeepCollectionEquality().equals(other.purchaseNotice, purchaseNotice)&&(identical(other.goalAmount, goalAmount) || other.goalAmount == goalAmount)&&(identical(other.raisedAmount, raisedAmount) || other.raisedAmount == raisedAmount)&&(identical(other.supporterCount, supporterCount) || other.supporterCount == supporterCount)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.fundingStatus, fundingStatus) || other.fundingStatus == fundingStatus)&&(identical(other.riskNote, riskNote) || other.riskNote == riskNote)&&(identical(other.deliveryPlan, deliveryPlan) || other.deliveryPlan == deliveryPlan)&&(identical(other.fundUsage, fundUsage) || other.fundUsage == fundUsage)&&(identical(other.refundRule, refundRule) || other.refundRule == refundRule)&&(identical(other.refundDays, refundDays) || other.refundDays == refundDays)&&const DeepCollectionEquality().equals(other.faqs, faqs)&&const DeepCollectionEquality().equals(other.reviews, reviews)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.apiReviewCount, apiReviewCount) || other.apiReviewCount == apiReviewCount)&&(identical(other.apiShowCount, apiShowCount) || other.apiShowCount == apiShowCount)&&const DeepCollectionEquality().equals(other.updates, updates)&&(identical(other.creatorVerified, creatorVerified) || other.creatorVerified == creatorVerified)&&(identical(other.creatorProjectNum, creatorProjectNum) || other.creatorProjectNum == creatorProjectNum)&&(identical(other.creatorSuccessNum, creatorSuccessNum) || other.creatorSuccessNum == creatorSuccessNum)&&(identical(other.creatorFulfillmentPermille, creatorFulfillmentPermille) || other.creatorFulfillmentPermille == creatorFulfillmentPermille)&&(identical(other.creatorBio, creatorBio) || other.creatorBio == creatorBio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,artist,categoryId,categoryName,city,venue,venueAddress,firstSessionAt,priceFrom,listPriceFrom,discountPermille,const DeepCollectionEquality().hash(tags),wishCount,soldOut,proxyBuy,rating,ratingCount,duration,intro,const DeepCollectionEquality().hash(sessions),const DeepCollectionEquality().hash(tiers),const DeepCollectionEquality().hash(lineup),const DeepCollectionEquality().hash(purchaseNotice),goalAmount,raisedAmount,supporterCount,deadline,fundingStatus,riskNote,deliveryPlan,fundUsage,refundRule,refundDays,const DeepCollectionEquality().hash(faqs),const DeepCollectionEquality().hash(reviews),ratingAvg,apiReviewCount,apiShowCount,const DeepCollectionEquality().hash(updates),creatorVerified,creatorProjectNum,creatorSuccessNum,creatorFulfillmentPermille,creatorBio]);

@override
String toString() {
  return 'ShowSummary(id: $id, title: $title, artist: $artist, categoryId: $categoryId, categoryName: $categoryName, city: $city, venue: $venue, venueAddress: $venueAddress, firstSessionAt: $firstSessionAt, priceFrom: $priceFrom, listPriceFrom: $listPriceFrom, discountPermille: $discountPermille, tags: $tags, wishCount: $wishCount, soldOut: $soldOut, proxyBuy: $proxyBuy, rating: $rating, ratingCount: $ratingCount, duration: $duration, intro: $intro, sessions: $sessions, tiers: $tiers, lineup: $lineup, purchaseNotice: $purchaseNotice, goalAmount: $goalAmount, raisedAmount: $raisedAmount, supporterCount: $supporterCount, deadline: $deadline, fundingStatus: $fundingStatus, riskNote: $riskNote, deliveryPlan: $deliveryPlan, fundUsage: $fundUsage, refundRule: $refundRule, refundDays: $refundDays, faqs: $faqs, reviews: $reviews, ratingAvg: $ratingAvg, apiReviewCount: $apiReviewCount, apiShowCount: $apiShowCount, updates: $updates, creatorVerified: $creatorVerified, creatorProjectNum: $creatorProjectNum, creatorSuccessNum: $creatorSuccessNum, creatorFulfillmentPermille: $creatorFulfillmentPermille, creatorBio: $creatorBio)';
}


}

/// @nodoc
abstract mixin class $ShowSummaryCopyWith<$Res>  {
  factory $ShowSummaryCopyWith(ShowSummary value, $Res Function(ShowSummary) _then) = _$ShowSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readShowId) String id,@JsonKey(readValue: _readShowTitle) String title,@JsonKey(readValue: _readShowArtist) String artist,@JsonKey(readValue: _readShowCategoryId) int categoryId,@JsonKey(readValue: _readShowCategoryName) String categoryName,@JsonKey(readValue: _readShowCity) String city,@JsonKey(readValue: _readShowVenue) String venue,@JsonKey(readValue: _readShowVenueAddress) String venueAddress,@JsonKey(readValue: _readShowFirstSessionAt, fromJson: _dateTimeOrNow) DateTime firstSessionAt,@JsonKey(readValue: _readShowPriceFrom, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents) Money priceFrom,@JsonKey(readValue: _readShowListPriceFrom, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) Money? listPriceFrom,@JsonKey(readValue: _readShowDiscountPermille) int? discountPermille,@JsonKey(readValue: _readShowTags, fromJson: _stringList) List<String> tags,@JsonKey(readValue: _readShowWishCount) int wishCount,@JsonKey(readValue: _readShowSoldOut) bool soldOut,@JsonKey(readValue: _readShowProxyBuy) bool proxyBuy, double rating,@JsonKey(readValue: _readShowRatingCount) int ratingCount,@JsonKey(readValue: _readShowDuration) String duration,@JsonKey(readValue: _readShowIntro) String intro,@JsonKey(readValue: _readShowSessions, fromJson: _sessionList) List<ShowSession> sessions,@JsonKey(readValue: _readShowTiers, fromJson: _tierList) List<TicketTier> tiers,@JsonKey(readValue: _readShowLineup, fromJson: _stringList) List<String> lineup,@JsonKey(readValue: _readShowPurchaseNotice, fromJson: _stringList) List<String> purchaseNotice,@JsonKey(readValue: _readShowGoalAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) Money? goalAmount,@JsonKey(readValue: _readShowRaisedAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) Money? raisedAmount,@JsonKey(readValue: _readShowSupporterCount) int supporterCount,@JsonKey(readValue: _readShowDeadline, fromJson: _dateTime) DateTime? deadline,@JsonKey(readValue: _readShowFundingStatus) String fundingStatus,@JsonKey(readValue: _readShowRiskNote) String riskNote,@JsonKey(readValue: _readShowDeliveryPlan) String deliveryPlan,@JsonKey(readValue: _readShowFundUsage) String fundUsage,@JsonKey(readValue: _readShowRefundRule) String refundRule,@JsonKey(readValue: _readShowRefundDays) int refundDays,@JsonKey(readValue: _readShowFaqs, fromJson: _faqList) List<ProjectFaq> faqs,@JsonKey(readValue: _readShowReviews, fromJson: _reviewList) List<ProjectReview> reviews, double ratingAvg,@JsonKey(readValue: _readShowApiReviewCount) int apiReviewCount,@JsonKey(readValue: _readShowApiShowCount) int apiShowCount,@JsonKey(readValue: _readShowUpdates, fromJson: _updateList) List<ProjectUpdate> updates,@JsonKey(readValue: _readShowCreatorVerified) bool creatorVerified,@JsonKey(readValue: _readShowCreatorProjectNum) int creatorProjectNum,@JsonKey(readValue: _readShowCreatorSuccessNum) int creatorSuccessNum,@JsonKey(readValue: _readShowCreatorFulfillmentPermille) int creatorFulfillmentPermille,@JsonKey(readValue: _readShowCreatorBio) String creatorBio
});




}
/// @nodoc
class _$ShowSummaryCopyWithImpl<$Res>
    implements $ShowSummaryCopyWith<$Res> {
  _$ShowSummaryCopyWithImpl(this._self, this._then);

  final ShowSummary _self;
  final $Res Function(ShowSummary) _then;

/// Create a copy of ShowSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? categoryId = null,Object? categoryName = null,Object? city = null,Object? venue = null,Object? venueAddress = null,Object? firstSessionAt = null,Object? priceFrom = null,Object? listPriceFrom = freezed,Object? discountPermille = freezed,Object? tags = null,Object? wishCount = null,Object? soldOut = null,Object? proxyBuy = null,Object? rating = null,Object? ratingCount = null,Object? duration = null,Object? intro = null,Object? sessions = null,Object? tiers = null,Object? lineup = null,Object? purchaseNotice = null,Object? goalAmount = freezed,Object? raisedAmount = freezed,Object? supporterCount = null,Object? deadline = freezed,Object? fundingStatus = null,Object? riskNote = null,Object? deliveryPlan = null,Object? fundUsage = null,Object? refundRule = null,Object? refundDays = null,Object? faqs = null,Object? reviews = null,Object? ratingAvg = null,Object? apiReviewCount = null,Object? apiShowCount = null,Object? updates = null,Object? creatorVerified = null,Object? creatorProjectNum = null,Object? creatorSuccessNum = null,Object? creatorFulfillmentPermille = null,Object? creatorBio = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,venueAddress: null == venueAddress ? _self.venueAddress : venueAddress // ignore: cast_nullable_to_non_nullable
as String,firstSessionAt: null == firstSessionAt ? _self.firstSessionAt : firstSessionAt // ignore: cast_nullable_to_non_nullable
as DateTime,priceFrom: null == priceFrom ? _self.priceFrom : priceFrom // ignore: cast_nullable_to_non_nullable
as Money,listPriceFrom: freezed == listPriceFrom ? _self.listPriceFrom : listPriceFrom // ignore: cast_nullable_to_non_nullable
as Money?,discountPermille: freezed == discountPermille ? _self.discountPermille : discountPermille // ignore: cast_nullable_to_non_nullable
as int?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,wishCount: null == wishCount ? _self.wishCount : wishCount // ignore: cast_nullable_to_non_nullable
as int,soldOut: null == soldOut ? _self.soldOut : soldOut // ignore: cast_nullable_to_non_nullable
as bool,proxyBuy: null == proxyBuy ? _self.proxyBuy : proxyBuy // ignore: cast_nullable_to_non_nullable
as bool,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String,intro: null == intro ? _self.intro : intro // ignore: cast_nullable_to_non_nullable
as String,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ShowSession>,tiers: null == tiers ? _self.tiers : tiers // ignore: cast_nullable_to_non_nullable
as List<TicketTier>,lineup: null == lineup ? _self.lineup : lineup // ignore: cast_nullable_to_non_nullable
as List<String>,purchaseNotice: null == purchaseNotice ? _self.purchaseNotice : purchaseNotice // ignore: cast_nullable_to_non_nullable
as List<String>,goalAmount: freezed == goalAmount ? _self.goalAmount : goalAmount // ignore: cast_nullable_to_non_nullable
as Money?,raisedAmount: freezed == raisedAmount ? _self.raisedAmount : raisedAmount // ignore: cast_nullable_to_non_nullable
as Money?,supporterCount: null == supporterCount ? _self.supporterCount : supporterCount // ignore: cast_nullable_to_non_nullable
as int,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,fundingStatus: null == fundingStatus ? _self.fundingStatus : fundingStatus // ignore: cast_nullable_to_non_nullable
as String,riskNote: null == riskNote ? _self.riskNote : riskNote // ignore: cast_nullable_to_non_nullable
as String,deliveryPlan: null == deliveryPlan ? _self.deliveryPlan : deliveryPlan // ignore: cast_nullable_to_non_nullable
as String,fundUsage: null == fundUsage ? _self.fundUsage : fundUsage // ignore: cast_nullable_to_non_nullable
as String,refundRule: null == refundRule ? _self.refundRule : refundRule // ignore: cast_nullable_to_non_nullable
as String,refundDays: null == refundDays ? _self.refundDays : refundDays // ignore: cast_nullable_to_non_nullable
as int,faqs: null == faqs ? _self.faqs : faqs // ignore: cast_nullable_to_non_nullable
as List<ProjectFaq>,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<ProjectReview>,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,apiReviewCount: null == apiReviewCount ? _self.apiReviewCount : apiReviewCount // ignore: cast_nullable_to_non_nullable
as int,apiShowCount: null == apiShowCount ? _self.apiShowCount : apiShowCount // ignore: cast_nullable_to_non_nullable
as int,updates: null == updates ? _self.updates : updates // ignore: cast_nullable_to_non_nullable
as List<ProjectUpdate>,creatorVerified: null == creatorVerified ? _self.creatorVerified : creatorVerified // ignore: cast_nullable_to_non_nullable
as bool,creatorProjectNum: null == creatorProjectNum ? _self.creatorProjectNum : creatorProjectNum // ignore: cast_nullable_to_non_nullable
as int,creatorSuccessNum: null == creatorSuccessNum ? _self.creatorSuccessNum : creatorSuccessNum // ignore: cast_nullable_to_non_nullable
as int,creatorFulfillmentPermille: null == creatorFulfillmentPermille ? _self.creatorFulfillmentPermille : creatorFulfillmentPermille // ignore: cast_nullable_to_non_nullable
as int,creatorBio: null == creatorBio ? _self.creatorBio : creatorBio // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ShowSummary].
extension ShowSummaryPatterns on ShowSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShowSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShowSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShowSummary value)  $default,){
final _that = this;
switch (_that) {
case _ShowSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShowSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ShowSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readShowId)  String id, @JsonKey(readValue: _readShowTitle)  String title, @JsonKey(readValue: _readShowArtist)  String artist, @JsonKey(readValue: _readShowCategoryId)  int categoryId, @JsonKey(readValue: _readShowCategoryName)  String categoryName, @JsonKey(readValue: _readShowCity)  String city, @JsonKey(readValue: _readShowVenue)  String venue, @JsonKey(readValue: _readShowVenueAddress)  String venueAddress, @JsonKey(readValue: _readShowFirstSessionAt, fromJson: _dateTimeOrNow)  DateTime firstSessionAt, @JsonKey(readValue: _readShowPriceFrom, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents)  Money priceFrom, @JsonKey(readValue: _readShowListPriceFrom, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull)  Money? listPriceFrom, @JsonKey(readValue: _readShowDiscountPermille)  int? discountPermille, @JsonKey(readValue: _readShowTags, fromJson: _stringList)  List<String> tags, @JsonKey(readValue: _readShowWishCount)  int wishCount, @JsonKey(readValue: _readShowSoldOut)  bool soldOut, @JsonKey(readValue: _readShowProxyBuy)  bool proxyBuy,  double rating, @JsonKey(readValue: _readShowRatingCount)  int ratingCount, @JsonKey(readValue: _readShowDuration)  String duration, @JsonKey(readValue: _readShowIntro)  String intro, @JsonKey(readValue: _readShowSessions, fromJson: _sessionList)  List<ShowSession> sessions, @JsonKey(readValue: _readShowTiers, fromJson: _tierList)  List<TicketTier> tiers, @JsonKey(readValue: _readShowLineup, fromJson: _stringList)  List<String> lineup, @JsonKey(readValue: _readShowPurchaseNotice, fromJson: _stringList)  List<String> purchaseNotice, @JsonKey(readValue: _readShowGoalAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull)  Money? goalAmount, @JsonKey(readValue: _readShowRaisedAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull)  Money? raisedAmount, @JsonKey(readValue: _readShowSupporterCount)  int supporterCount, @JsonKey(readValue: _readShowDeadline, fromJson: _dateTime)  DateTime? deadline, @JsonKey(readValue: _readShowFundingStatus)  String fundingStatus, @JsonKey(readValue: _readShowRiskNote)  String riskNote, @JsonKey(readValue: _readShowDeliveryPlan)  String deliveryPlan, @JsonKey(readValue: _readShowFundUsage)  String fundUsage, @JsonKey(readValue: _readShowRefundRule)  String refundRule, @JsonKey(readValue: _readShowRefundDays)  int refundDays, @JsonKey(readValue: _readShowFaqs, fromJson: _faqList)  List<ProjectFaq> faqs, @JsonKey(readValue: _readShowReviews, fromJson: _reviewList)  List<ProjectReview> reviews,  double ratingAvg, @JsonKey(readValue: _readShowApiReviewCount)  int apiReviewCount, @JsonKey(readValue: _readShowApiShowCount)  int apiShowCount, @JsonKey(readValue: _readShowUpdates, fromJson: _updateList)  List<ProjectUpdate> updates, @JsonKey(readValue: _readShowCreatorVerified)  bool creatorVerified, @JsonKey(readValue: _readShowCreatorProjectNum)  int creatorProjectNum, @JsonKey(readValue: _readShowCreatorSuccessNum)  int creatorSuccessNum, @JsonKey(readValue: _readShowCreatorFulfillmentPermille)  int creatorFulfillmentPermille, @JsonKey(readValue: _readShowCreatorBio)  String creatorBio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShowSummary() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.categoryId,_that.categoryName,_that.city,_that.venue,_that.venueAddress,_that.firstSessionAt,_that.priceFrom,_that.listPriceFrom,_that.discountPermille,_that.tags,_that.wishCount,_that.soldOut,_that.proxyBuy,_that.rating,_that.ratingCount,_that.duration,_that.intro,_that.sessions,_that.tiers,_that.lineup,_that.purchaseNotice,_that.goalAmount,_that.raisedAmount,_that.supporterCount,_that.deadline,_that.fundingStatus,_that.riskNote,_that.deliveryPlan,_that.fundUsage,_that.refundRule,_that.refundDays,_that.faqs,_that.reviews,_that.ratingAvg,_that.apiReviewCount,_that.apiShowCount,_that.updates,_that.creatorVerified,_that.creatorProjectNum,_that.creatorSuccessNum,_that.creatorFulfillmentPermille,_that.creatorBio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readShowId)  String id, @JsonKey(readValue: _readShowTitle)  String title, @JsonKey(readValue: _readShowArtist)  String artist, @JsonKey(readValue: _readShowCategoryId)  int categoryId, @JsonKey(readValue: _readShowCategoryName)  String categoryName, @JsonKey(readValue: _readShowCity)  String city, @JsonKey(readValue: _readShowVenue)  String venue, @JsonKey(readValue: _readShowVenueAddress)  String venueAddress, @JsonKey(readValue: _readShowFirstSessionAt, fromJson: _dateTimeOrNow)  DateTime firstSessionAt, @JsonKey(readValue: _readShowPriceFrom, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents)  Money priceFrom, @JsonKey(readValue: _readShowListPriceFrom, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull)  Money? listPriceFrom, @JsonKey(readValue: _readShowDiscountPermille)  int? discountPermille, @JsonKey(readValue: _readShowTags, fromJson: _stringList)  List<String> tags, @JsonKey(readValue: _readShowWishCount)  int wishCount, @JsonKey(readValue: _readShowSoldOut)  bool soldOut, @JsonKey(readValue: _readShowProxyBuy)  bool proxyBuy,  double rating, @JsonKey(readValue: _readShowRatingCount)  int ratingCount, @JsonKey(readValue: _readShowDuration)  String duration, @JsonKey(readValue: _readShowIntro)  String intro, @JsonKey(readValue: _readShowSessions, fromJson: _sessionList)  List<ShowSession> sessions, @JsonKey(readValue: _readShowTiers, fromJson: _tierList)  List<TicketTier> tiers, @JsonKey(readValue: _readShowLineup, fromJson: _stringList)  List<String> lineup, @JsonKey(readValue: _readShowPurchaseNotice, fromJson: _stringList)  List<String> purchaseNotice, @JsonKey(readValue: _readShowGoalAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull)  Money? goalAmount, @JsonKey(readValue: _readShowRaisedAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull)  Money? raisedAmount, @JsonKey(readValue: _readShowSupporterCount)  int supporterCount, @JsonKey(readValue: _readShowDeadline, fromJson: _dateTime)  DateTime? deadline, @JsonKey(readValue: _readShowFundingStatus)  String fundingStatus, @JsonKey(readValue: _readShowRiskNote)  String riskNote, @JsonKey(readValue: _readShowDeliveryPlan)  String deliveryPlan, @JsonKey(readValue: _readShowFundUsage)  String fundUsage, @JsonKey(readValue: _readShowRefundRule)  String refundRule, @JsonKey(readValue: _readShowRefundDays)  int refundDays, @JsonKey(readValue: _readShowFaqs, fromJson: _faqList)  List<ProjectFaq> faqs, @JsonKey(readValue: _readShowReviews, fromJson: _reviewList)  List<ProjectReview> reviews,  double ratingAvg, @JsonKey(readValue: _readShowApiReviewCount)  int apiReviewCount, @JsonKey(readValue: _readShowApiShowCount)  int apiShowCount, @JsonKey(readValue: _readShowUpdates, fromJson: _updateList)  List<ProjectUpdate> updates, @JsonKey(readValue: _readShowCreatorVerified)  bool creatorVerified, @JsonKey(readValue: _readShowCreatorProjectNum)  int creatorProjectNum, @JsonKey(readValue: _readShowCreatorSuccessNum)  int creatorSuccessNum, @JsonKey(readValue: _readShowCreatorFulfillmentPermille)  int creatorFulfillmentPermille, @JsonKey(readValue: _readShowCreatorBio)  String creatorBio)  $default,) {final _that = this;
switch (_that) {
case _ShowSummary():
return $default(_that.id,_that.title,_that.artist,_that.categoryId,_that.categoryName,_that.city,_that.venue,_that.venueAddress,_that.firstSessionAt,_that.priceFrom,_that.listPriceFrom,_that.discountPermille,_that.tags,_that.wishCount,_that.soldOut,_that.proxyBuy,_that.rating,_that.ratingCount,_that.duration,_that.intro,_that.sessions,_that.tiers,_that.lineup,_that.purchaseNotice,_that.goalAmount,_that.raisedAmount,_that.supporterCount,_that.deadline,_that.fundingStatus,_that.riskNote,_that.deliveryPlan,_that.fundUsage,_that.refundRule,_that.refundDays,_that.faqs,_that.reviews,_that.ratingAvg,_that.apiReviewCount,_that.apiShowCount,_that.updates,_that.creatorVerified,_that.creatorProjectNum,_that.creatorSuccessNum,_that.creatorFulfillmentPermille,_that.creatorBio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readShowId)  String id, @JsonKey(readValue: _readShowTitle)  String title, @JsonKey(readValue: _readShowArtist)  String artist, @JsonKey(readValue: _readShowCategoryId)  int categoryId, @JsonKey(readValue: _readShowCategoryName)  String categoryName, @JsonKey(readValue: _readShowCity)  String city, @JsonKey(readValue: _readShowVenue)  String venue, @JsonKey(readValue: _readShowVenueAddress)  String venueAddress, @JsonKey(readValue: _readShowFirstSessionAt, fromJson: _dateTimeOrNow)  DateTime firstSessionAt, @JsonKey(readValue: _readShowPriceFrom, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents)  Money priceFrom, @JsonKey(readValue: _readShowListPriceFrom, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull)  Money? listPriceFrom, @JsonKey(readValue: _readShowDiscountPermille)  int? discountPermille, @JsonKey(readValue: _readShowTags, fromJson: _stringList)  List<String> tags, @JsonKey(readValue: _readShowWishCount)  int wishCount, @JsonKey(readValue: _readShowSoldOut)  bool soldOut, @JsonKey(readValue: _readShowProxyBuy)  bool proxyBuy,  double rating, @JsonKey(readValue: _readShowRatingCount)  int ratingCount, @JsonKey(readValue: _readShowDuration)  String duration, @JsonKey(readValue: _readShowIntro)  String intro, @JsonKey(readValue: _readShowSessions, fromJson: _sessionList)  List<ShowSession> sessions, @JsonKey(readValue: _readShowTiers, fromJson: _tierList)  List<TicketTier> tiers, @JsonKey(readValue: _readShowLineup, fromJson: _stringList)  List<String> lineup, @JsonKey(readValue: _readShowPurchaseNotice, fromJson: _stringList)  List<String> purchaseNotice, @JsonKey(readValue: _readShowGoalAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull)  Money? goalAmount, @JsonKey(readValue: _readShowRaisedAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull)  Money? raisedAmount, @JsonKey(readValue: _readShowSupporterCount)  int supporterCount, @JsonKey(readValue: _readShowDeadline, fromJson: _dateTime)  DateTime? deadline, @JsonKey(readValue: _readShowFundingStatus)  String fundingStatus, @JsonKey(readValue: _readShowRiskNote)  String riskNote, @JsonKey(readValue: _readShowDeliveryPlan)  String deliveryPlan, @JsonKey(readValue: _readShowFundUsage)  String fundUsage, @JsonKey(readValue: _readShowRefundRule)  String refundRule, @JsonKey(readValue: _readShowRefundDays)  int refundDays, @JsonKey(readValue: _readShowFaqs, fromJson: _faqList)  List<ProjectFaq> faqs, @JsonKey(readValue: _readShowReviews, fromJson: _reviewList)  List<ProjectReview> reviews,  double ratingAvg, @JsonKey(readValue: _readShowApiReviewCount)  int apiReviewCount, @JsonKey(readValue: _readShowApiShowCount)  int apiShowCount, @JsonKey(readValue: _readShowUpdates, fromJson: _updateList)  List<ProjectUpdate> updates, @JsonKey(readValue: _readShowCreatorVerified)  bool creatorVerified, @JsonKey(readValue: _readShowCreatorProjectNum)  int creatorProjectNum, @JsonKey(readValue: _readShowCreatorSuccessNum)  int creatorSuccessNum, @JsonKey(readValue: _readShowCreatorFulfillmentPermille)  int creatorFulfillmentPermille, @JsonKey(readValue: _readShowCreatorBio)  String creatorBio)?  $default,) {final _that = this;
switch (_that) {
case _ShowSummary() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.categoryId,_that.categoryName,_that.city,_that.venue,_that.venueAddress,_that.firstSessionAt,_that.priceFrom,_that.listPriceFrom,_that.discountPermille,_that.tags,_that.wishCount,_that.soldOut,_that.proxyBuy,_that.rating,_that.ratingCount,_that.duration,_that.intro,_that.sessions,_that.tiers,_that.lineup,_that.purchaseNotice,_that.goalAmount,_that.raisedAmount,_that.supporterCount,_that.deadline,_that.fundingStatus,_that.riskNote,_that.deliveryPlan,_that.fundUsage,_that.refundRule,_that.refundDays,_that.faqs,_that.reviews,_that.ratingAvg,_that.apiReviewCount,_that.apiShowCount,_that.updates,_that.creatorVerified,_that.creatorProjectNum,_that.creatorSuccessNum,_that.creatorFulfillmentPermille,_that.creatorBio);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShowSummary extends ShowSummary {
  const _ShowSummary({@JsonKey(readValue: _readShowId) required this.id, @JsonKey(readValue: _readShowTitle) required this.title, @JsonKey(readValue: _readShowArtist) required this.artist, @JsonKey(readValue: _readShowCategoryId) required this.categoryId, @JsonKey(readValue: _readShowCategoryName) required this.categoryName, @JsonKey(readValue: _readShowCity) required this.city, @JsonKey(readValue: _readShowVenue) required this.venue, @JsonKey(readValue: _readShowVenueAddress) required this.venueAddress, @JsonKey(readValue: _readShowFirstSessionAt, fromJson: _dateTimeOrNow) required this.firstSessionAt, @JsonKey(readValue: _readShowPriceFrom, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents) required this.priceFrom, @JsonKey(readValue: _readShowListPriceFrom, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) this.listPriceFrom, @JsonKey(readValue: _readShowDiscountPermille) this.discountPermille, @JsonKey(readValue: _readShowTags, fromJson: _stringList) final  List<String> tags = const <String>[], @JsonKey(readValue: _readShowWishCount) this.wishCount = 0, @JsonKey(readValue: _readShowSoldOut) this.soldOut = false, @JsonKey(readValue: _readShowProxyBuy) this.proxyBuy = false, this.rating = 0, @JsonKey(readValue: _readShowRatingCount) this.ratingCount = 0, @JsonKey(readValue: _readShowDuration) this.duration = '', @JsonKey(readValue: _readShowIntro) this.intro = '', @JsonKey(readValue: _readShowSessions, fromJson: _sessionList) final  List<ShowSession> sessions = const <ShowSession>[], @JsonKey(readValue: _readShowTiers, fromJson: _tierList) final  List<TicketTier> tiers = const <TicketTier>[], @JsonKey(readValue: _readShowLineup, fromJson: _stringList) final  List<String> lineup = const <String>[], @JsonKey(readValue: _readShowPurchaseNotice, fromJson: _stringList) final  List<String> purchaseNotice = const <String>[], @JsonKey(readValue: _readShowGoalAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) this.goalAmount, @JsonKey(readValue: _readShowRaisedAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) this.raisedAmount, @JsonKey(readValue: _readShowSupporterCount) this.supporterCount = 0, @JsonKey(readValue: _readShowDeadline, fromJson: _dateTime) this.deadline, @JsonKey(readValue: _readShowFundingStatus) this.fundingStatus = '', @JsonKey(readValue: _readShowRiskNote) this.riskNote = '', @JsonKey(readValue: _readShowDeliveryPlan) this.deliveryPlan = '', @JsonKey(readValue: _readShowFundUsage) this.fundUsage = '', @JsonKey(readValue: _readShowRefundRule) this.refundRule = '', @JsonKey(readValue: _readShowRefundDays) this.refundDays = 7, @JsonKey(readValue: _readShowFaqs, fromJson: _faqList) final  List<ProjectFaq> faqs = const <ProjectFaq>[], @JsonKey(readValue: _readShowReviews, fromJson: _reviewList) final  List<ProjectReview> reviews = const <ProjectReview>[], this.ratingAvg = 0, @JsonKey(readValue: _readShowApiReviewCount) this.apiReviewCount = 0, @JsonKey(readValue: _readShowApiShowCount) this.apiShowCount = 0, @JsonKey(readValue: _readShowUpdates, fromJson: _updateList) final  List<ProjectUpdate> updates = const <ProjectUpdate>[], @JsonKey(readValue: _readShowCreatorVerified) this.creatorVerified = false, @JsonKey(readValue: _readShowCreatorProjectNum) this.creatorProjectNum = 0, @JsonKey(readValue: _readShowCreatorSuccessNum) this.creatorSuccessNum = 0, @JsonKey(readValue: _readShowCreatorFulfillmentPermille) this.creatorFulfillmentPermille = 0, @JsonKey(readValue: _readShowCreatorBio) this.creatorBio = ''}): _tags = tags,_sessions = sessions,_tiers = tiers,_lineup = lineup,_purchaseNotice = purchaseNotice,_faqs = faqs,_reviews = reviews,_updates = updates,super._();
  factory _ShowSummary.fromJson(Map<String, dynamic> json) => _$ShowSummaryFromJson(json);

@override@JsonKey(readValue: _readShowId) final  String id;
@override@JsonKey(readValue: _readShowTitle) final  String title;
@override@JsonKey(readValue: _readShowArtist) final  String artist;
@override@JsonKey(readValue: _readShowCategoryId) final  int categoryId;
@override@JsonKey(readValue: _readShowCategoryName) final  String categoryName;
@override@JsonKey(readValue: _readShowCity) final  String city;
@override@JsonKey(readValue: _readShowVenue) final  String venue;
@override@JsonKey(readValue: _readShowVenueAddress) final  String venueAddress;
@override@JsonKey(readValue: _readShowFirstSessionAt, fromJson: _dateTimeOrNow) final  DateTime firstSessionAt;
@override@JsonKey(readValue: _readShowPriceFrom, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents) final  Money priceFrom;
@override@JsonKey(readValue: _readShowListPriceFrom, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) final  Money? listPriceFrom;
@override@JsonKey(readValue: _readShowDiscountPermille) final  int? discountPermille;
 final  List<String> _tags;
@override@JsonKey(readValue: _readShowTags, fromJson: _stringList) List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(readValue: _readShowWishCount) final  int wishCount;
@override@JsonKey(readValue: _readShowSoldOut) final  bool soldOut;
@override@JsonKey(readValue: _readShowProxyBuy) final  bool proxyBuy;
@override@JsonKey() final  double rating;
@override@JsonKey(readValue: _readShowRatingCount) final  int ratingCount;
@override@JsonKey(readValue: _readShowDuration) final  String duration;
@override@JsonKey(readValue: _readShowIntro) final  String intro;
 final  List<ShowSession> _sessions;
@override@JsonKey(readValue: _readShowSessions, fromJson: _sessionList) List<ShowSession> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

 final  List<TicketTier> _tiers;
@override@JsonKey(readValue: _readShowTiers, fromJson: _tierList) List<TicketTier> get tiers {
  if (_tiers is EqualUnmodifiableListView) return _tiers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tiers);
}

 final  List<String> _lineup;
@override@JsonKey(readValue: _readShowLineup, fromJson: _stringList) List<String> get lineup {
  if (_lineup is EqualUnmodifiableListView) return _lineup;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lineup);
}

 final  List<String> _purchaseNotice;
@override@JsonKey(readValue: _readShowPurchaseNotice, fromJson: _stringList) List<String> get purchaseNotice {
  if (_purchaseNotice is EqualUnmodifiableListView) return _purchaseNotice;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_purchaseNotice);
}

@override@JsonKey(readValue: _readShowGoalAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) final  Money? goalAmount;
@override@JsonKey(readValue: _readShowRaisedAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) final  Money? raisedAmount;
@override@JsonKey(readValue: _readShowSupporterCount) final  int supporterCount;
@override@JsonKey(readValue: _readShowDeadline, fromJson: _dateTime) final  DateTime? deadline;
@override@JsonKey(readValue: _readShowFundingStatus) final  String fundingStatus;
@override@JsonKey(readValue: _readShowRiskNote) final  String riskNote;
@override@JsonKey(readValue: _readShowDeliveryPlan) final  String deliveryPlan;
@override@JsonKey(readValue: _readShowFundUsage) final  String fundUsage;
@override@JsonKey(readValue: _readShowRefundRule) final  String refundRule;
@override@JsonKey(readValue: _readShowRefundDays) final  int refundDays;
 final  List<ProjectFaq> _faqs;
@override@JsonKey(readValue: _readShowFaqs, fromJson: _faqList) List<ProjectFaq> get faqs {
  if (_faqs is EqualUnmodifiableListView) return _faqs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_faqs);
}

 final  List<ProjectReview> _reviews;
@override@JsonKey(readValue: _readShowReviews, fromJson: _reviewList) List<ProjectReview> get reviews {
  if (_reviews is EqualUnmodifiableListView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviews);
}

@override@JsonKey() final  double ratingAvg;
@override@JsonKey(readValue: _readShowApiReviewCount) final  int apiReviewCount;
@override@JsonKey(readValue: _readShowApiShowCount) final  int apiShowCount;
 final  List<ProjectUpdate> _updates;
@override@JsonKey(readValue: _readShowUpdates, fromJson: _updateList) List<ProjectUpdate> get updates {
  if (_updates is EqualUnmodifiableListView) return _updates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_updates);
}

@override@JsonKey(readValue: _readShowCreatorVerified) final  bool creatorVerified;
@override@JsonKey(readValue: _readShowCreatorProjectNum) final  int creatorProjectNum;
@override@JsonKey(readValue: _readShowCreatorSuccessNum) final  int creatorSuccessNum;
@override@JsonKey(readValue: _readShowCreatorFulfillmentPermille) final  int creatorFulfillmentPermille;
@override@JsonKey(readValue: _readShowCreatorBio) final  String creatorBio;

/// Create a copy of ShowSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShowSummaryCopyWith<_ShowSummary> get copyWith => __$ShowSummaryCopyWithImpl<_ShowSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShowSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShowSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.city, city) || other.city == city)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.venueAddress, venueAddress) || other.venueAddress == venueAddress)&&(identical(other.firstSessionAt, firstSessionAt) || other.firstSessionAt == firstSessionAt)&&(identical(other.priceFrom, priceFrom) || other.priceFrom == priceFrom)&&(identical(other.listPriceFrom, listPriceFrom) || other.listPriceFrom == listPriceFrom)&&(identical(other.discountPermille, discountPermille) || other.discountPermille == discountPermille)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.wishCount, wishCount) || other.wishCount == wishCount)&&(identical(other.soldOut, soldOut) || other.soldOut == soldOut)&&(identical(other.proxyBuy, proxyBuy) || other.proxyBuy == proxyBuy)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.intro, intro) || other.intro == intro)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&const DeepCollectionEquality().equals(other._tiers, _tiers)&&const DeepCollectionEquality().equals(other._lineup, _lineup)&&const DeepCollectionEquality().equals(other._purchaseNotice, _purchaseNotice)&&(identical(other.goalAmount, goalAmount) || other.goalAmount == goalAmount)&&(identical(other.raisedAmount, raisedAmount) || other.raisedAmount == raisedAmount)&&(identical(other.supporterCount, supporterCount) || other.supporterCount == supporterCount)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.fundingStatus, fundingStatus) || other.fundingStatus == fundingStatus)&&(identical(other.riskNote, riskNote) || other.riskNote == riskNote)&&(identical(other.deliveryPlan, deliveryPlan) || other.deliveryPlan == deliveryPlan)&&(identical(other.fundUsage, fundUsage) || other.fundUsage == fundUsage)&&(identical(other.refundRule, refundRule) || other.refundRule == refundRule)&&(identical(other.refundDays, refundDays) || other.refundDays == refundDays)&&const DeepCollectionEquality().equals(other._faqs, _faqs)&&const DeepCollectionEquality().equals(other._reviews, _reviews)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.apiReviewCount, apiReviewCount) || other.apiReviewCount == apiReviewCount)&&(identical(other.apiShowCount, apiShowCount) || other.apiShowCount == apiShowCount)&&const DeepCollectionEquality().equals(other._updates, _updates)&&(identical(other.creatorVerified, creatorVerified) || other.creatorVerified == creatorVerified)&&(identical(other.creatorProjectNum, creatorProjectNum) || other.creatorProjectNum == creatorProjectNum)&&(identical(other.creatorSuccessNum, creatorSuccessNum) || other.creatorSuccessNum == creatorSuccessNum)&&(identical(other.creatorFulfillmentPermille, creatorFulfillmentPermille) || other.creatorFulfillmentPermille == creatorFulfillmentPermille)&&(identical(other.creatorBio, creatorBio) || other.creatorBio == creatorBio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,artist,categoryId,categoryName,city,venue,venueAddress,firstSessionAt,priceFrom,listPriceFrom,discountPermille,const DeepCollectionEquality().hash(_tags),wishCount,soldOut,proxyBuy,rating,ratingCount,duration,intro,const DeepCollectionEquality().hash(_sessions),const DeepCollectionEquality().hash(_tiers),const DeepCollectionEquality().hash(_lineup),const DeepCollectionEquality().hash(_purchaseNotice),goalAmount,raisedAmount,supporterCount,deadline,fundingStatus,riskNote,deliveryPlan,fundUsage,refundRule,refundDays,const DeepCollectionEquality().hash(_faqs),const DeepCollectionEquality().hash(_reviews),ratingAvg,apiReviewCount,apiShowCount,const DeepCollectionEquality().hash(_updates),creatorVerified,creatorProjectNum,creatorSuccessNum,creatorFulfillmentPermille,creatorBio]);

@override
String toString() {
  return 'ShowSummary(id: $id, title: $title, artist: $artist, categoryId: $categoryId, categoryName: $categoryName, city: $city, venue: $venue, venueAddress: $venueAddress, firstSessionAt: $firstSessionAt, priceFrom: $priceFrom, listPriceFrom: $listPriceFrom, discountPermille: $discountPermille, tags: $tags, wishCount: $wishCount, soldOut: $soldOut, proxyBuy: $proxyBuy, rating: $rating, ratingCount: $ratingCount, duration: $duration, intro: $intro, sessions: $sessions, tiers: $tiers, lineup: $lineup, purchaseNotice: $purchaseNotice, goalAmount: $goalAmount, raisedAmount: $raisedAmount, supporterCount: $supporterCount, deadline: $deadline, fundingStatus: $fundingStatus, riskNote: $riskNote, deliveryPlan: $deliveryPlan, fundUsage: $fundUsage, refundRule: $refundRule, refundDays: $refundDays, faqs: $faqs, reviews: $reviews, ratingAvg: $ratingAvg, apiReviewCount: $apiReviewCount, apiShowCount: $apiShowCount, updates: $updates, creatorVerified: $creatorVerified, creatorProjectNum: $creatorProjectNum, creatorSuccessNum: $creatorSuccessNum, creatorFulfillmentPermille: $creatorFulfillmentPermille, creatorBio: $creatorBio)';
}


}

/// @nodoc
abstract mixin class _$ShowSummaryCopyWith<$Res> implements $ShowSummaryCopyWith<$Res> {
  factory _$ShowSummaryCopyWith(_ShowSummary value, $Res Function(_ShowSummary) _then) = __$ShowSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readShowId) String id,@JsonKey(readValue: _readShowTitle) String title,@JsonKey(readValue: _readShowArtist) String artist,@JsonKey(readValue: _readShowCategoryId) int categoryId,@JsonKey(readValue: _readShowCategoryName) String categoryName,@JsonKey(readValue: _readShowCity) String city,@JsonKey(readValue: _readShowVenue) String venue,@JsonKey(readValue: _readShowVenueAddress) String venueAddress,@JsonKey(readValue: _readShowFirstSessionAt, fromJson: _dateTimeOrNow) DateTime firstSessionAt,@JsonKey(readValue: _readShowPriceFrom, fromJson: _moneyFromCentsOrZero, toJson: _moneyToCents) Money priceFrom,@JsonKey(readValue: _readShowListPriceFrom, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) Money? listPriceFrom,@JsonKey(readValue: _readShowDiscountPermille) int? discountPermille,@JsonKey(readValue: _readShowTags, fromJson: _stringList) List<String> tags,@JsonKey(readValue: _readShowWishCount) int wishCount,@JsonKey(readValue: _readShowSoldOut) bool soldOut,@JsonKey(readValue: _readShowProxyBuy) bool proxyBuy, double rating,@JsonKey(readValue: _readShowRatingCount) int ratingCount,@JsonKey(readValue: _readShowDuration) String duration,@JsonKey(readValue: _readShowIntro) String intro,@JsonKey(readValue: _readShowSessions, fromJson: _sessionList) List<ShowSession> sessions,@JsonKey(readValue: _readShowTiers, fromJson: _tierList) List<TicketTier> tiers,@JsonKey(readValue: _readShowLineup, fromJson: _stringList) List<String> lineup,@JsonKey(readValue: _readShowPurchaseNotice, fromJson: _stringList) List<String> purchaseNotice,@JsonKey(readValue: _readShowGoalAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) Money? goalAmount,@JsonKey(readValue: _readShowRaisedAmount, fromJson: _moneyFromCentsOrNull, toJson: _moneyToCentsOrNull) Money? raisedAmount,@JsonKey(readValue: _readShowSupporterCount) int supporterCount,@JsonKey(readValue: _readShowDeadline, fromJson: _dateTime) DateTime? deadline,@JsonKey(readValue: _readShowFundingStatus) String fundingStatus,@JsonKey(readValue: _readShowRiskNote) String riskNote,@JsonKey(readValue: _readShowDeliveryPlan) String deliveryPlan,@JsonKey(readValue: _readShowFundUsage) String fundUsage,@JsonKey(readValue: _readShowRefundRule) String refundRule,@JsonKey(readValue: _readShowRefundDays) int refundDays,@JsonKey(readValue: _readShowFaqs, fromJson: _faqList) List<ProjectFaq> faqs,@JsonKey(readValue: _readShowReviews, fromJson: _reviewList) List<ProjectReview> reviews, double ratingAvg,@JsonKey(readValue: _readShowApiReviewCount) int apiReviewCount,@JsonKey(readValue: _readShowApiShowCount) int apiShowCount,@JsonKey(readValue: _readShowUpdates, fromJson: _updateList) List<ProjectUpdate> updates,@JsonKey(readValue: _readShowCreatorVerified) bool creatorVerified,@JsonKey(readValue: _readShowCreatorProjectNum) int creatorProjectNum,@JsonKey(readValue: _readShowCreatorSuccessNum) int creatorSuccessNum,@JsonKey(readValue: _readShowCreatorFulfillmentPermille) int creatorFulfillmentPermille,@JsonKey(readValue: _readShowCreatorBio) String creatorBio
});




}
/// @nodoc
class __$ShowSummaryCopyWithImpl<$Res>
    implements _$ShowSummaryCopyWith<$Res> {
  __$ShowSummaryCopyWithImpl(this._self, this._then);

  final _ShowSummary _self;
  final $Res Function(_ShowSummary) _then;

/// Create a copy of ShowSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? categoryId = null,Object? categoryName = null,Object? city = null,Object? venue = null,Object? venueAddress = null,Object? firstSessionAt = null,Object? priceFrom = null,Object? listPriceFrom = freezed,Object? discountPermille = freezed,Object? tags = null,Object? wishCount = null,Object? soldOut = null,Object? proxyBuy = null,Object? rating = null,Object? ratingCount = null,Object? duration = null,Object? intro = null,Object? sessions = null,Object? tiers = null,Object? lineup = null,Object? purchaseNotice = null,Object? goalAmount = freezed,Object? raisedAmount = freezed,Object? supporterCount = null,Object? deadline = freezed,Object? fundingStatus = null,Object? riskNote = null,Object? deliveryPlan = null,Object? fundUsage = null,Object? refundRule = null,Object? refundDays = null,Object? faqs = null,Object? reviews = null,Object? ratingAvg = null,Object? apiReviewCount = null,Object? apiShowCount = null,Object? updates = null,Object? creatorVerified = null,Object? creatorProjectNum = null,Object? creatorSuccessNum = null,Object? creatorFulfillmentPermille = null,Object? creatorBio = null,}) {
  return _then(_ShowSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,venueAddress: null == venueAddress ? _self.venueAddress : venueAddress // ignore: cast_nullable_to_non_nullable
as String,firstSessionAt: null == firstSessionAt ? _self.firstSessionAt : firstSessionAt // ignore: cast_nullable_to_non_nullable
as DateTime,priceFrom: null == priceFrom ? _self.priceFrom : priceFrom // ignore: cast_nullable_to_non_nullable
as Money,listPriceFrom: freezed == listPriceFrom ? _self.listPriceFrom : listPriceFrom // ignore: cast_nullable_to_non_nullable
as Money?,discountPermille: freezed == discountPermille ? _self.discountPermille : discountPermille // ignore: cast_nullable_to_non_nullable
as int?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,wishCount: null == wishCount ? _self.wishCount : wishCount // ignore: cast_nullable_to_non_nullable
as int,soldOut: null == soldOut ? _self.soldOut : soldOut // ignore: cast_nullable_to_non_nullable
as bool,proxyBuy: null == proxyBuy ? _self.proxyBuy : proxyBuy // ignore: cast_nullable_to_non_nullable
as bool,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String,intro: null == intro ? _self.intro : intro // ignore: cast_nullable_to_non_nullable
as String,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ShowSession>,tiers: null == tiers ? _self._tiers : tiers // ignore: cast_nullable_to_non_nullable
as List<TicketTier>,lineup: null == lineup ? _self._lineup : lineup // ignore: cast_nullable_to_non_nullable
as List<String>,purchaseNotice: null == purchaseNotice ? _self._purchaseNotice : purchaseNotice // ignore: cast_nullable_to_non_nullable
as List<String>,goalAmount: freezed == goalAmount ? _self.goalAmount : goalAmount // ignore: cast_nullable_to_non_nullable
as Money?,raisedAmount: freezed == raisedAmount ? _self.raisedAmount : raisedAmount // ignore: cast_nullable_to_non_nullable
as Money?,supporterCount: null == supporterCount ? _self.supporterCount : supporterCount // ignore: cast_nullable_to_non_nullable
as int,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,fundingStatus: null == fundingStatus ? _self.fundingStatus : fundingStatus // ignore: cast_nullable_to_non_nullable
as String,riskNote: null == riskNote ? _self.riskNote : riskNote // ignore: cast_nullable_to_non_nullable
as String,deliveryPlan: null == deliveryPlan ? _self.deliveryPlan : deliveryPlan // ignore: cast_nullable_to_non_nullable
as String,fundUsage: null == fundUsage ? _self.fundUsage : fundUsage // ignore: cast_nullable_to_non_nullable
as String,refundRule: null == refundRule ? _self.refundRule : refundRule // ignore: cast_nullable_to_non_nullable
as String,refundDays: null == refundDays ? _self.refundDays : refundDays // ignore: cast_nullable_to_non_nullable
as int,faqs: null == faqs ? _self._faqs : faqs // ignore: cast_nullable_to_non_nullable
as List<ProjectFaq>,reviews: null == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<ProjectReview>,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,apiReviewCount: null == apiReviewCount ? _self.apiReviewCount : apiReviewCount // ignore: cast_nullable_to_non_nullable
as int,apiShowCount: null == apiShowCount ? _self.apiShowCount : apiShowCount // ignore: cast_nullable_to_non_nullable
as int,updates: null == updates ? _self._updates : updates // ignore: cast_nullable_to_non_nullable
as List<ProjectUpdate>,creatorVerified: null == creatorVerified ? _self.creatorVerified : creatorVerified // ignore: cast_nullable_to_non_nullable
as bool,creatorProjectNum: null == creatorProjectNum ? _self.creatorProjectNum : creatorProjectNum // ignore: cast_nullable_to_non_nullable
as int,creatorSuccessNum: null == creatorSuccessNum ? _self.creatorSuccessNum : creatorSuccessNum // ignore: cast_nullable_to_non_nullable
as int,creatorFulfillmentPermille: null == creatorFulfillmentPermille ? _self.creatorFulfillmentPermille : creatorFulfillmentPermille // ignore: cast_nullable_to_non_nullable
as int,creatorBio: null == creatorBio ? _self.creatorBio : creatorBio // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
