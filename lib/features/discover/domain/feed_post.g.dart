// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedPost _$FeedPostFromJson(Map<String, dynamic> json) => _FeedPost(
  id: _readId(json, 'id') as String,
  title: _readTitle(json, 'title') as String,
  author: _readAuthor(json, 'author') as String,
  viewCount: (_readViewCount(json, 'viewCount') as num).toInt(),
  publishedAt: _dateTimeOrNow(_readPublishedAt(json, 'publishedAt')),
  tag: _readTag(json, 'tag') as String?,
  showId: _readShowId(json, 'showId') as String?,
  likeCount: (_readLikeCount(json, 'likeCount') as num?)?.toInt() ?? 0,
  hasVideo: _readHasVideo(json, 'hasVideo') as bool? ?? false,
  body: _readBody(json, 'body') as String? ?? '',
  videoUrl: _readVideoUrl(json, 'videoUrl') as String?,
  bvid: _readBvid(json, 'bvid') as String?,
);

Map<String, dynamic> _$FeedPostToJson(_FeedPost instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'author': instance.author,
  'viewCount': instance.viewCount,
  'publishedAt': instance.publishedAt.toIso8601String(),
  'tag': instance.tag,
  'showId': instance.showId,
  'likeCount': instance.likeCount,
  'hasVideo': instance.hasVideo,
  'body': instance.body,
  'videoUrl': instance.videoUrl,
  'bvid': instance.bvid,
};

_FeedComment _$FeedCommentFromJson(Map<String, dynamic> json) => _FeedComment(
  id: _readCommentId(json, 'id') as String,
  author: _readCommentAuthor(json, 'author') as String,
  text: _readCommentText(json, 'text') as String,
  publishedAt: _dateTimeOrNow(_readCommentPublishedAt(json, 'publishedAt')),
  likeCount: (_readCommentLikeCount(json, 'likeCount') as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$FeedCommentToJson(_FeedComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'text': instance.text,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'likeCount': instance.likeCount,
    };
