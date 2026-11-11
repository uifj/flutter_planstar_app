import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_post.freezed.dart';
part 'feed_post.g.dart';

/// 一条社区动态（发现页 feed 卡片）。
///
/// 字段：标题、作者、浏览量、角标文案，
/// 外加一个可选的关联企划 id（动态可以挂到某个企划上）。
@freezed
abstract class FeedPost with _$FeedPost {
  const factory FeedPost({
    @JsonKey(readValue: _readId) required String id,
    @JsonKey(readValue: _readTitle) required String title,
    @JsonKey(readValue: _readAuthor) required String author,
    @JsonKey(readValue: _readViewCount) required int viewCount,
    @JsonKey(readValue: _readPublishedAt, fromJson: _dateTimeOrNow)
    required DateTime publishedAt,
    @JsonKey(readValue: _readTag) String? tag,
    @JsonKey(readValue: _readShowId) String? showId,
    @JsonKey(readValue: _readLikeCount) @Default(0) int likeCount,
    @JsonKey(readValue: _readHasVideo) @Default(false) bool hasVideo,
    @JsonKey(readValue: _readBody) @Default('') String body,

    /// 视频地址（可选）。服务端可能直接给完整 URL，也可能只给 bvid。
    @JsonKey(readValue: _readVideoUrl) String? videoUrl,

    /// 哔哩哔哩视频号（可选）。裸号或 URL 都可由 `extractBvid` 归一。
    @JsonKey(readValue: _readBvid) String? bvid,
  }) = _FeedPost;

  factory FeedPost.fromJson(Map<String, dynamic> json) =>
      _$FeedPostFromJson(json);
}

/// 一条评论。
///
/// 评论是独立聚合（`v1/feed/comment/list`），支持二级回复。
/// 这里只做一级：二级回复需要展开状态与"回复谁"的上下文，
/// 没有真实接口时做出来只是一套点了没反应的空壳。
@freezed
abstract class FeedComment with _$FeedComment {
  const factory FeedComment({
    @JsonKey(readValue: _readCommentId) required String id,
    @JsonKey(readValue: _readCommentAuthor) required String author,
    @JsonKey(readValue: _readCommentText) required String text,
    @JsonKey(readValue: _readCommentPublishedAt, fromJson: _dateTimeOrNow)
    required DateTime publishedAt,
    @JsonKey(readValue: _readCommentLikeCount) @Default(0) int likeCount,
  }) = _FeedComment;

  factory FeedComment.fromJson(Map<String, dynamic> json) =>
      _$FeedCommentFromJson(json);
}

// ── JSON 兼容读取（字段名别名与请求头保持一致）────────────────────────────

Object? _readId(Map<dynamic, dynamic> json, String key) =>
    json['id']?.toString() ?? json['tweetId']?.toString() ?? '';

Object? _readTitle(Map<dynamic, dynamic> json, String key) =>
    json['title']?.toString() ?? json['content']?.toString() ?? '';

Object? _readAuthor(Map<dynamic, dynamic> json, String key) =>
    json['author']?.toString() ?? json['userName']?.toString() ?? '';

Object? _readViewCount(Map<dynamic, dynamic> json, String key) =>
    json['viewCount'] ?? json['readCount'] ?? 0;

Object? _readPublishedAt(Map<dynamic, dynamic> json, String key) =>
    json['publishedAt'] ?? json['createTime'];

Object? _readTag(Map<dynamic, dynamic> json, String key) =>
    json['tag']?.toString();

Object? _readShowId(Map<dynamic, dynamic> json, String key) =>
    json['showId']?.toString() ?? json['activityId']?.toString();

Object? _readLikeCount(Map<dynamic, dynamic> json, String key) =>
    json['likeCount'] ?? json['likeNum'] ?? 0;

Object? _readHasVideo(Map<dynamic, dynamic> json, String key) =>
    json['hasVideo'] == true || json['video'] != null;

Object? _readBody(Map<dynamic, dynamic> json, String key) =>
    json['body']?.toString() ?? json['content']?.toString() ?? '';

Object? _readVideoUrl(Map<dynamic, dynamic> json, String key) {
  for (final Object? candidate in <Object?>[
    json['videoUrl'],
    json['video_url'],
    json['url'],
  ]) {
    if (candidate is String && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }
  }
  return null;
}

Object? _readBvid(Map<dynamic, dynamic> json, String key) {
  final Object? raw = json['bvid'] ?? json['videoId'] ?? json['video_id'];
  if (raw == null) return null;
  final String value = raw.toString().trim();
  return value.isEmpty ? null : value;
}

Object? _readCommentId(Map<dynamic, dynamic> json, String key) =>
    json['id']?.toString() ?? '';

Object? _readCommentAuthor(Map<dynamic, dynamic> json, String key) =>
    json['author']?.toString() ?? json['userName']?.toString() ?? '';

Object? _readCommentText(Map<dynamic, dynamic> json, String key) =>
    json['text']?.toString() ?? json['content']?.toString() ?? '';

Object? _readCommentPublishedAt(Map<dynamic, dynamic> json, String key) =>
    json['publishedAt'] ?? json['createTime'];

Object? _readCommentLikeCount(Map<dynamic, dynamic> json, String key) =>
    json['likeCount'] ?? 0;

DateTime _dateTimeOrNow(Object? raw) {
  if (raw is String) {
    return DateTime.tryParse(raw) ?? DateTime.now();
  }
  return DateTime.now();
}
