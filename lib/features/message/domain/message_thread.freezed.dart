// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageThread {

@JsonKey(readValue: _readId) String get id;@JsonKey(readValue: _readTitle) String get title;@JsonKey(readValue: _readPreview) String get preview;@JsonKey(readValue: _readUpdatedAt, fromJson: _dateTimeOrNow) DateTime get updatedAt;@JsonKey(readValue: _readUnreadCount) int get unreadCount;@JsonKey(readValue: _readAvatar) String? get avatarFallbackUrl;@JsonKey(readValue: _readIsOfficial) bool get isOfficial;
/// Create a copy of MessageThread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageThreadCopyWith<MessageThread> get copyWith => _$MessageThreadCopyWithImpl<MessageThread>(this as MessageThread, _$identity);

  /// Serializes this MessageThread to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageThread&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.avatarFallbackUrl, avatarFallbackUrl) || other.avatarFallbackUrl == avatarFallbackUrl)&&(identical(other.isOfficial, isOfficial) || other.isOfficial == isOfficial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,preview,updatedAt,unreadCount,avatarFallbackUrl,isOfficial);

@override
String toString() {
  return 'MessageThread(id: $id, title: $title, preview: $preview, updatedAt: $updatedAt, unreadCount: $unreadCount, avatarFallbackUrl: $avatarFallbackUrl, isOfficial: $isOfficial)';
}


}

/// @nodoc
abstract mixin class $MessageThreadCopyWith<$Res>  {
  factory $MessageThreadCopyWith(MessageThread value, $Res Function(MessageThread) _then) = _$MessageThreadCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readId) String id,@JsonKey(readValue: _readTitle) String title,@JsonKey(readValue: _readPreview) String preview,@JsonKey(readValue: _readUpdatedAt, fromJson: _dateTimeOrNow) DateTime updatedAt,@JsonKey(readValue: _readUnreadCount) int unreadCount,@JsonKey(readValue: _readAvatar) String? avatarFallbackUrl,@JsonKey(readValue: _readIsOfficial) bool isOfficial
});




}
/// @nodoc
class _$MessageThreadCopyWithImpl<$Res>
    implements $MessageThreadCopyWith<$Res> {
  _$MessageThreadCopyWithImpl(this._self, this._then);

  final MessageThread _self;
  final $Res Function(MessageThread) _then;

/// Create a copy of MessageThread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? preview = null,Object? updatedAt = null,Object? unreadCount = null,Object? avatarFallbackUrl = freezed,Object? isOfficial = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,avatarFallbackUrl: freezed == avatarFallbackUrl ? _self.avatarFallbackUrl : avatarFallbackUrl // ignore: cast_nullable_to_non_nullable
as String?,isOfficial: null == isOfficial ? _self.isOfficial : isOfficial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageThread].
extension MessageThreadPatterns on MessageThread {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageThread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageThread() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageThread value)  $default,){
final _that = this;
switch (_that) {
case _MessageThread():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageThread value)?  $default,){
final _that = this;
switch (_that) {
case _MessageThread() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readId)  String id, @JsonKey(readValue: _readTitle)  String title, @JsonKey(readValue: _readPreview)  String preview, @JsonKey(readValue: _readUpdatedAt, fromJson: _dateTimeOrNow)  DateTime updatedAt, @JsonKey(readValue: _readUnreadCount)  int unreadCount, @JsonKey(readValue: _readAvatar)  String? avatarFallbackUrl, @JsonKey(readValue: _readIsOfficial)  bool isOfficial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageThread() when $default != null:
return $default(_that.id,_that.title,_that.preview,_that.updatedAt,_that.unreadCount,_that.avatarFallbackUrl,_that.isOfficial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readId)  String id, @JsonKey(readValue: _readTitle)  String title, @JsonKey(readValue: _readPreview)  String preview, @JsonKey(readValue: _readUpdatedAt, fromJson: _dateTimeOrNow)  DateTime updatedAt, @JsonKey(readValue: _readUnreadCount)  int unreadCount, @JsonKey(readValue: _readAvatar)  String? avatarFallbackUrl, @JsonKey(readValue: _readIsOfficial)  bool isOfficial)  $default,) {final _that = this;
switch (_that) {
case _MessageThread():
return $default(_that.id,_that.title,_that.preview,_that.updatedAt,_that.unreadCount,_that.avatarFallbackUrl,_that.isOfficial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readId)  String id, @JsonKey(readValue: _readTitle)  String title, @JsonKey(readValue: _readPreview)  String preview, @JsonKey(readValue: _readUpdatedAt, fromJson: _dateTimeOrNow)  DateTime updatedAt, @JsonKey(readValue: _readUnreadCount)  int unreadCount, @JsonKey(readValue: _readAvatar)  String? avatarFallbackUrl, @JsonKey(readValue: _readIsOfficial)  bool isOfficial)?  $default,) {final _that = this;
switch (_that) {
case _MessageThread() when $default != null:
return $default(_that.id,_that.title,_that.preview,_that.updatedAt,_that.unreadCount,_that.avatarFallbackUrl,_that.isOfficial);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageThread extends MessageThread {
  const _MessageThread({@JsonKey(readValue: _readId) required this.id, @JsonKey(readValue: _readTitle) required this.title, @JsonKey(readValue: _readPreview) required this.preview, @JsonKey(readValue: _readUpdatedAt, fromJson: _dateTimeOrNow) required this.updatedAt, @JsonKey(readValue: _readUnreadCount) this.unreadCount = 0, @JsonKey(readValue: _readAvatar) this.avatarFallbackUrl, @JsonKey(readValue: _readIsOfficial) this.isOfficial = false}): super._();
  factory _MessageThread.fromJson(Map<String, dynamic> json) => _$MessageThreadFromJson(json);

@override@JsonKey(readValue: _readId) final  String id;
@override@JsonKey(readValue: _readTitle) final  String title;
@override@JsonKey(readValue: _readPreview) final  String preview;
@override@JsonKey(readValue: _readUpdatedAt, fromJson: _dateTimeOrNow) final  DateTime updatedAt;
@override@JsonKey(readValue: _readUnreadCount) final  int unreadCount;
@override@JsonKey(readValue: _readAvatar) final  String? avatarFallbackUrl;
@override@JsonKey(readValue: _readIsOfficial) final  bool isOfficial;

/// Create a copy of MessageThread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageThreadCopyWith<_MessageThread> get copyWith => __$MessageThreadCopyWithImpl<_MessageThread>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageThreadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageThread&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.avatarFallbackUrl, avatarFallbackUrl) || other.avatarFallbackUrl == avatarFallbackUrl)&&(identical(other.isOfficial, isOfficial) || other.isOfficial == isOfficial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,preview,updatedAt,unreadCount,avatarFallbackUrl,isOfficial);

@override
String toString() {
  return 'MessageThread(id: $id, title: $title, preview: $preview, updatedAt: $updatedAt, unreadCount: $unreadCount, avatarFallbackUrl: $avatarFallbackUrl, isOfficial: $isOfficial)';
}


}

/// @nodoc
abstract mixin class _$MessageThreadCopyWith<$Res> implements $MessageThreadCopyWith<$Res> {
  factory _$MessageThreadCopyWith(_MessageThread value, $Res Function(_MessageThread) _then) = __$MessageThreadCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readId) String id,@JsonKey(readValue: _readTitle) String title,@JsonKey(readValue: _readPreview) String preview,@JsonKey(readValue: _readUpdatedAt, fromJson: _dateTimeOrNow) DateTime updatedAt,@JsonKey(readValue: _readUnreadCount) int unreadCount,@JsonKey(readValue: _readAvatar) String? avatarFallbackUrl,@JsonKey(readValue: _readIsOfficial) bool isOfficial
});




}
/// @nodoc
class __$MessageThreadCopyWithImpl<$Res>
    implements _$MessageThreadCopyWith<$Res> {
  __$MessageThreadCopyWithImpl(this._self, this._then);

  final _MessageThread _self;
  final $Res Function(_MessageThread) _then;

/// Create a copy of MessageThread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? preview = null,Object? updatedAt = null,Object? unreadCount = null,Object? avatarFallbackUrl = freezed,Object? isOfficial = null,}) {
  return _then(_MessageThread(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,avatarFallbackUrl: freezed == avatarFallbackUrl ? _self.avatarFallbackUrl : avatarFallbackUrl // ignore: cast_nullable_to_non_nullable
as String?,isOfficial: null == isOfficial ? _self.isOfficial : isOfficial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$SystemMessageEntry {

 String get id; String get title; String get icon; int get unreadCount;
/// Create a copy of SystemMessageEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SystemMessageEntryCopyWith<SystemMessageEntry> get copyWith => _$SystemMessageEntryCopyWithImpl<SystemMessageEntry>(this as SystemMessageEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SystemMessageEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,icon,unreadCount);

@override
String toString() {
  return 'SystemMessageEntry(id: $id, title: $title, icon: $icon, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class $SystemMessageEntryCopyWith<$Res>  {
  factory $SystemMessageEntryCopyWith(SystemMessageEntry value, $Res Function(SystemMessageEntry) _then) = _$SystemMessageEntryCopyWithImpl;
@useResult
$Res call({
 String id, String title, String icon, int unreadCount
});




}
/// @nodoc
class _$SystemMessageEntryCopyWithImpl<$Res>
    implements $SystemMessageEntryCopyWith<$Res> {
  _$SystemMessageEntryCopyWithImpl(this._self, this._then);

  final SystemMessageEntry _self;
  final $Res Function(SystemMessageEntry) _then;

/// Create a copy of SystemMessageEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? icon = null,Object? unreadCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SystemMessageEntry].
extension SystemMessageEntryPatterns on SystemMessageEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SystemMessageEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SystemMessageEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SystemMessageEntry value)  $default,){
final _that = this;
switch (_that) {
case _SystemMessageEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SystemMessageEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SystemMessageEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String icon,  int unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SystemMessageEntry() when $default != null:
return $default(_that.id,_that.title,_that.icon,_that.unreadCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String icon,  int unreadCount)  $default,) {final _that = this;
switch (_that) {
case _SystemMessageEntry():
return $default(_that.id,_that.title,_that.icon,_that.unreadCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String icon,  int unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _SystemMessageEntry() when $default != null:
return $default(_that.id,_that.title,_that.icon,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc


class _SystemMessageEntry implements SystemMessageEntry {
  const _SystemMessageEntry({required this.id, required this.title, required this.icon, required this.unreadCount});
  

@override final  String id;
@override final  String title;
@override final  String icon;
@override final  int unreadCount;

/// Create a copy of SystemMessageEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SystemMessageEntryCopyWith<_SystemMessageEntry> get copyWith => __$SystemMessageEntryCopyWithImpl<_SystemMessageEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SystemMessageEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,icon,unreadCount);

@override
String toString() {
  return 'SystemMessageEntry(id: $id, title: $title, icon: $icon, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$SystemMessageEntryCopyWith<$Res> implements $SystemMessageEntryCopyWith<$Res> {
  factory _$SystemMessageEntryCopyWith(_SystemMessageEntry value, $Res Function(_SystemMessageEntry) _then) = __$SystemMessageEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String icon, int unreadCount
});




}
/// @nodoc
class __$SystemMessageEntryCopyWithImpl<$Res>
    implements _$SystemMessageEntryCopyWith<$Res> {
  __$SystemMessageEntryCopyWithImpl(this._self, this._then);

  final _SystemMessageEntry _self;
  final $Res Function(_SystemMessageEntry) _then;

/// Create a copy of SystemMessageEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? icon = null,Object? unreadCount = null,}) {
  return _then(_SystemMessageEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
