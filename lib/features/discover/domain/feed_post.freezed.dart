// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedPost {

@JsonKey(readValue: _readId) String get id;@JsonKey(readValue: _readTitle) String get title;@JsonKey(readValue: _readAuthor) String get author;@JsonKey(readValue: _readViewCount) int get viewCount;@JsonKey(readValue: _readPublishedAt, fromJson: _dateTimeOrNow) DateTime get publishedAt;@JsonKey(readValue: _readTag) String? get tag;@JsonKey(readValue: _readShowId) String? get showId;@JsonKey(readValue: _readLikeCount) int get likeCount;@JsonKey(readValue: _readHasVideo) bool get hasVideo;@JsonKey(readValue: _readBody) String get body;/// 视频地址（可选）。服务端可能直接给完整 URL，也可能只给 bvid。
@JsonKey(readValue: _readVideoUrl) String? get videoUrl;/// 哔哩哔哩视频号（可选）。裸号或 URL 都可由 `extractBvid` 归一。
@JsonKey(readValue: _readBvid) String? get bvid;
/// Create a copy of FeedPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedPostCopyWith<FeedPost> get copyWith => _$FeedPostCopyWithImpl<FeedPost>(this as FeedPost, _$identity);

  /// Serializes this FeedPost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedPost&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.showId, showId) || other.showId == showId)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.hasVideo, hasVideo) || other.hasVideo == hasVideo)&&(identical(other.body, body) || other.body == body)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.bvid, bvid) || other.bvid == bvid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,author,viewCount,publishedAt,tag,showId,likeCount,hasVideo,body,videoUrl,bvid);

@override
String toString() {
  return 'FeedPost(id: $id, title: $title, author: $author, viewCount: $viewCount, publishedAt: $publishedAt, tag: $tag, showId: $showId, likeCount: $likeCount, hasVideo: $hasVideo, body: $body, videoUrl: $videoUrl, bvid: $bvid)';
}


}

/// @nodoc
abstract mixin class $FeedPostCopyWith<$Res>  {
  factory $FeedPostCopyWith(FeedPost value, $Res Function(FeedPost) _then) = _$FeedPostCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readId) String id,@JsonKey(readValue: _readTitle) String title,@JsonKey(readValue: _readAuthor) String author,@JsonKey(readValue: _readViewCount) int viewCount,@JsonKey(readValue: _readPublishedAt, fromJson: _dateTimeOrNow) DateTime publishedAt,@JsonKey(readValue: _readTag) String? tag,@JsonKey(readValue: _readShowId) String? showId,@JsonKey(readValue: _readLikeCount) int likeCount,@JsonKey(readValue: _readHasVideo) bool hasVideo,@JsonKey(readValue: _readBody) String body,@JsonKey(readValue: _readVideoUrl) String? videoUrl,@JsonKey(readValue: _readBvid) String? bvid
});




}
/// @nodoc
class _$FeedPostCopyWithImpl<$Res>
    implements $FeedPostCopyWith<$Res> {
  _$FeedPostCopyWithImpl(this._self, this._then);

  final FeedPost _self;
  final $Res Function(FeedPost) _then;

/// Create a copy of FeedPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? author = null,Object? viewCount = null,Object? publishedAt = null,Object? tag = freezed,Object? showId = freezed,Object? likeCount = null,Object? hasVideo = null,Object? body = null,Object? videoUrl = freezed,Object? bvid = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tag: freezed == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String?,showId: freezed == showId ? _self.showId : showId // ignore: cast_nullable_to_non_nullable
as String?,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,hasVideo: null == hasVideo ? _self.hasVideo : hasVideo // ignore: cast_nullable_to_non_nullable
as bool,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,bvid: freezed == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedPost].
extension FeedPostPatterns on FeedPost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedPost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedPost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedPost value)  $default,){
final _that = this;
switch (_that) {
case _FeedPost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedPost value)?  $default,){
final _that = this;
switch (_that) {
case _FeedPost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readId)  String id, @JsonKey(readValue: _readTitle)  String title, @JsonKey(readValue: _readAuthor)  String author, @JsonKey(readValue: _readViewCount)  int viewCount, @JsonKey(readValue: _readPublishedAt, fromJson: _dateTimeOrNow)  DateTime publishedAt, @JsonKey(readValue: _readTag)  String? tag, @JsonKey(readValue: _readShowId)  String? showId, @JsonKey(readValue: _readLikeCount)  int likeCount, @JsonKey(readValue: _readHasVideo)  bool hasVideo, @JsonKey(readValue: _readBody)  String body, @JsonKey(readValue: _readVideoUrl)  String? videoUrl, @JsonKey(readValue: _readBvid)  String? bvid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedPost() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.viewCount,_that.publishedAt,_that.tag,_that.showId,_that.likeCount,_that.hasVideo,_that.body,_that.videoUrl,_that.bvid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readId)  String id, @JsonKey(readValue: _readTitle)  String title, @JsonKey(readValue: _readAuthor)  String author, @JsonKey(readValue: _readViewCount)  int viewCount, @JsonKey(readValue: _readPublishedAt, fromJson: _dateTimeOrNow)  DateTime publishedAt, @JsonKey(readValue: _readTag)  String? tag, @JsonKey(readValue: _readShowId)  String? showId, @JsonKey(readValue: _readLikeCount)  int likeCount, @JsonKey(readValue: _readHasVideo)  bool hasVideo, @JsonKey(readValue: _readBody)  String body, @JsonKey(readValue: _readVideoUrl)  String? videoUrl, @JsonKey(readValue: _readBvid)  String? bvid)  $default,) {final _that = this;
switch (_that) {
case _FeedPost():
return $default(_that.id,_that.title,_that.author,_that.viewCount,_that.publishedAt,_that.tag,_that.showId,_that.likeCount,_that.hasVideo,_that.body,_that.videoUrl,_that.bvid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readId)  String id, @JsonKey(readValue: _readTitle)  String title, @JsonKey(readValue: _readAuthor)  String author, @JsonKey(readValue: _readViewCount)  int viewCount, @JsonKey(readValue: _readPublishedAt, fromJson: _dateTimeOrNow)  DateTime publishedAt, @JsonKey(readValue: _readTag)  String? tag, @JsonKey(readValue: _readShowId)  String? showId, @JsonKey(readValue: _readLikeCount)  int likeCount, @JsonKey(readValue: _readHasVideo)  bool hasVideo, @JsonKey(readValue: _readBody)  String body, @JsonKey(readValue: _readVideoUrl)  String? videoUrl, @JsonKey(readValue: _readBvid)  String? bvid)?  $default,) {final _that = this;
switch (_that) {
case _FeedPost() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.viewCount,_that.publishedAt,_that.tag,_that.showId,_that.likeCount,_that.hasVideo,_that.body,_that.videoUrl,_that.bvid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedPost implements FeedPost {
  const _FeedPost({@JsonKey(readValue: _readId) required this.id, @JsonKey(readValue: _readTitle) required this.title, @JsonKey(readValue: _readAuthor) required this.author, @JsonKey(readValue: _readViewCount) required this.viewCount, @JsonKey(readValue: _readPublishedAt, fromJson: _dateTimeOrNow) required this.publishedAt, @JsonKey(readValue: _readTag) this.tag, @JsonKey(readValue: _readShowId) this.showId, @JsonKey(readValue: _readLikeCount) this.likeCount = 0, @JsonKey(readValue: _readHasVideo) this.hasVideo = false, @JsonKey(readValue: _readBody) this.body = '', @JsonKey(readValue: _readVideoUrl) this.videoUrl, @JsonKey(readValue: _readBvid) this.bvid});
  factory _FeedPost.fromJson(Map<String, dynamic> json) => _$FeedPostFromJson(json);

@override@JsonKey(readValue: _readId) final  String id;
@override@JsonKey(readValue: _readTitle) final  String title;
@override@JsonKey(readValue: _readAuthor) final  String author;
@override@JsonKey(readValue: _readViewCount) final  int viewCount;
@override@JsonKey(readValue: _readPublishedAt, fromJson: _dateTimeOrNow) final  DateTime publishedAt;
@override@JsonKey(readValue: _readTag) final  String? tag;
@override@JsonKey(readValue: _readShowId) final  String? showId;
@override@JsonKey(readValue: _readLikeCount) final  int likeCount;
@override@JsonKey(readValue: _readHasVideo) final  bool hasVideo;
@override@JsonKey(readValue: _readBody) final  String body;
/// 视频地址（可选）。服务端可能直接给完整 URL，也可能只给 bvid。
@override@JsonKey(readValue: _readVideoUrl) final  String? videoUrl;
/// 哔哩哔哩视频号（可选）。裸号或 URL 都可由 `extractBvid` 归一。
@override@JsonKey(readValue: _readBvid) final  String? bvid;

/// Create a copy of FeedPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedPostCopyWith<_FeedPost> get copyWith => __$FeedPostCopyWithImpl<_FeedPost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedPostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedPost&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.showId, showId) || other.showId == showId)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.hasVideo, hasVideo) || other.hasVideo == hasVideo)&&(identical(other.body, body) || other.body == body)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.bvid, bvid) || other.bvid == bvid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,author,viewCount,publishedAt,tag,showId,likeCount,hasVideo,body,videoUrl,bvid);

@override
String toString() {
  return 'FeedPost(id: $id, title: $title, author: $author, viewCount: $viewCount, publishedAt: $publishedAt, tag: $tag, showId: $showId, likeCount: $likeCount, hasVideo: $hasVideo, body: $body, videoUrl: $videoUrl, bvid: $bvid)';
}


}

/// @nodoc
abstract mixin class _$FeedPostCopyWith<$Res> implements $FeedPostCopyWith<$Res> {
  factory _$FeedPostCopyWith(_FeedPost value, $Res Function(_FeedPost) _then) = __$FeedPostCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readId) String id,@JsonKey(readValue: _readTitle) String title,@JsonKey(readValue: _readAuthor) String author,@JsonKey(readValue: _readViewCount) int viewCount,@JsonKey(readValue: _readPublishedAt, fromJson: _dateTimeOrNow) DateTime publishedAt,@JsonKey(readValue: _readTag) String? tag,@JsonKey(readValue: _readShowId) String? showId,@JsonKey(readValue: _readLikeCount) int likeCount,@JsonKey(readValue: _readHasVideo) bool hasVideo,@JsonKey(readValue: _readBody) String body,@JsonKey(readValue: _readVideoUrl) String? videoUrl,@JsonKey(readValue: _readBvid) String? bvid
});




}
/// @nodoc
class __$FeedPostCopyWithImpl<$Res>
    implements _$FeedPostCopyWith<$Res> {
  __$FeedPostCopyWithImpl(this._self, this._then);

  final _FeedPost _self;
  final $Res Function(_FeedPost) _then;

/// Create a copy of FeedPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? author = null,Object? viewCount = null,Object? publishedAt = null,Object? tag = freezed,Object? showId = freezed,Object? likeCount = null,Object? hasVideo = null,Object? body = null,Object? videoUrl = freezed,Object? bvid = freezed,}) {
  return _then(_FeedPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tag: freezed == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String?,showId: freezed == showId ? _self.showId : showId // ignore: cast_nullable_to_non_nullable
as String?,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,hasVideo: null == hasVideo ? _self.hasVideo : hasVideo // ignore: cast_nullable_to_non_nullable
as bool,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,bvid: freezed == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FeedComment {

@JsonKey(readValue: _readCommentId) String get id;@JsonKey(readValue: _readCommentAuthor) String get author;@JsonKey(readValue: _readCommentText) String get text;@JsonKey(readValue: _readCommentPublishedAt, fromJson: _dateTimeOrNow) DateTime get publishedAt;@JsonKey(readValue: _readCommentLikeCount) int get likeCount;
/// Create a copy of FeedComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedCommentCopyWith<FeedComment> get copyWith => _$FeedCommentCopyWithImpl<FeedComment>(this as FeedComment, _$identity);

  /// Serializes this FeedComment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedComment&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.text, text) || other.text == text)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,text,publishedAt,likeCount);

@override
String toString() {
  return 'FeedComment(id: $id, author: $author, text: $text, publishedAt: $publishedAt, likeCount: $likeCount)';
}


}

/// @nodoc
abstract mixin class $FeedCommentCopyWith<$Res>  {
  factory $FeedCommentCopyWith(FeedComment value, $Res Function(FeedComment) _then) = _$FeedCommentCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readCommentId) String id,@JsonKey(readValue: _readCommentAuthor) String author,@JsonKey(readValue: _readCommentText) String text,@JsonKey(readValue: _readCommentPublishedAt, fromJson: _dateTimeOrNow) DateTime publishedAt,@JsonKey(readValue: _readCommentLikeCount) int likeCount
});




}
/// @nodoc
class _$FeedCommentCopyWithImpl<$Res>
    implements $FeedCommentCopyWith<$Res> {
  _$FeedCommentCopyWithImpl(this._self, this._then);

  final FeedComment _self;
  final $Res Function(FeedComment) _then;

/// Create a copy of FeedComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? author = null,Object? text = null,Object? publishedAt = null,Object? likeCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedComment].
extension FeedCommentPatterns on FeedComment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedComment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedComment value)  $default,){
final _that = this;
switch (_that) {
case _FeedComment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedComment value)?  $default,){
final _that = this;
switch (_that) {
case _FeedComment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readCommentId)  String id, @JsonKey(readValue: _readCommentAuthor)  String author, @JsonKey(readValue: _readCommentText)  String text, @JsonKey(readValue: _readCommentPublishedAt, fromJson: _dateTimeOrNow)  DateTime publishedAt, @JsonKey(readValue: _readCommentLikeCount)  int likeCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedComment() when $default != null:
return $default(_that.id,_that.author,_that.text,_that.publishedAt,_that.likeCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readCommentId)  String id, @JsonKey(readValue: _readCommentAuthor)  String author, @JsonKey(readValue: _readCommentText)  String text, @JsonKey(readValue: _readCommentPublishedAt, fromJson: _dateTimeOrNow)  DateTime publishedAt, @JsonKey(readValue: _readCommentLikeCount)  int likeCount)  $default,) {final _that = this;
switch (_that) {
case _FeedComment():
return $default(_that.id,_that.author,_that.text,_that.publishedAt,_that.likeCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readCommentId)  String id, @JsonKey(readValue: _readCommentAuthor)  String author, @JsonKey(readValue: _readCommentText)  String text, @JsonKey(readValue: _readCommentPublishedAt, fromJson: _dateTimeOrNow)  DateTime publishedAt, @JsonKey(readValue: _readCommentLikeCount)  int likeCount)?  $default,) {final _that = this;
switch (_that) {
case _FeedComment() when $default != null:
return $default(_that.id,_that.author,_that.text,_that.publishedAt,_that.likeCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedComment implements FeedComment {
  const _FeedComment({@JsonKey(readValue: _readCommentId) required this.id, @JsonKey(readValue: _readCommentAuthor) required this.author, @JsonKey(readValue: _readCommentText) required this.text, @JsonKey(readValue: _readCommentPublishedAt, fromJson: _dateTimeOrNow) required this.publishedAt, @JsonKey(readValue: _readCommentLikeCount) this.likeCount = 0});
  factory _FeedComment.fromJson(Map<String, dynamic> json) => _$FeedCommentFromJson(json);

@override@JsonKey(readValue: _readCommentId) final  String id;
@override@JsonKey(readValue: _readCommentAuthor) final  String author;
@override@JsonKey(readValue: _readCommentText) final  String text;
@override@JsonKey(readValue: _readCommentPublishedAt, fromJson: _dateTimeOrNow) final  DateTime publishedAt;
@override@JsonKey(readValue: _readCommentLikeCount) final  int likeCount;

/// Create a copy of FeedComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedCommentCopyWith<_FeedComment> get copyWith => __$FeedCommentCopyWithImpl<_FeedComment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedCommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedComment&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.text, text) || other.text == text)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,text,publishedAt,likeCount);

@override
String toString() {
  return 'FeedComment(id: $id, author: $author, text: $text, publishedAt: $publishedAt, likeCount: $likeCount)';
}


}

/// @nodoc
abstract mixin class _$FeedCommentCopyWith<$Res> implements $FeedCommentCopyWith<$Res> {
  factory _$FeedCommentCopyWith(_FeedComment value, $Res Function(_FeedComment) _then) = __$FeedCommentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readCommentId) String id,@JsonKey(readValue: _readCommentAuthor) String author,@JsonKey(readValue: _readCommentText) String text,@JsonKey(readValue: _readCommentPublishedAt, fromJson: _dateTimeOrNow) DateTime publishedAt,@JsonKey(readValue: _readCommentLikeCount) int likeCount
});




}
/// @nodoc
class __$FeedCommentCopyWithImpl<$Res>
    implements _$FeedCommentCopyWith<$Res> {
  __$FeedCommentCopyWithImpl(this._self, this._then);

  final _FeedComment _self;
  final $Res Function(_FeedComment) _then;

/// Create a copy of FeedComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? author = null,Object? text = null,Object? publishedAt = null,Object? likeCount = null,}) {
  return _then(_FeedComment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
