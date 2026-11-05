/// 一条社区动态（发现页 feed 卡片）。
///
/// 字段对齐 `home_item_waterfall_feed.xml`：标题、作者、浏览量、角标文案，
/// 外加一个可选的关联演出 id（企划星的动态可以挂到某场演出上）。
final class FeedPost {
  const FeedPost({
    required this.id,
    required this.title,
    required this.author,
    required this.viewCount,
    required this.publishedAt,
    this.tag,
    this.showId,
    this.likeCount = 0,
    this.hasVideo = false,
    this.body = '',
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    final String? atRaw = json['publishedAt'] ?? json['createTime'];
    return FeedPost(
      id: json['id']?.toString() ?? json['tweetId']?.toString() ?? '',
      title: json['title']?.toString() ?? json['content']?.toString() ?? '',
      author: json['author']?.toString() ?? json['userName']?.toString() ?? '',
      viewCount: json['viewCount'] ?? json['readCount'] ?? 0,
      publishedAt: atRaw != null
          ? DateTime.tryParse(atRaw) ?? DateTime.now()
          : DateTime.now(),
      tag: json['tag']?.toString(),
      showId: json['showId']?.toString() ?? json['activityId']?.toString(),
      likeCount: json['likeCount'] ?? json['likeNum'] ?? 0,
      hasVideo: json['hasVideo'] == true || json['video'] != null,
      body: json['body']?.toString() ?? json['content']?.toString() ?? '',
    );
  }

  final String id;
  final String title;
  final String author;
  final int viewCount;
  final DateTime publishedAt;

  /// 角标（`网友热议` / `观演repo` / `攻略`）。
  final String? tag;

  /// 关联演出 id（点卡片优先跳详情）。
  final String? showId;

  final int likeCount;

  /// 视频动态（卡片右上角显示播放图标）。
  final bool hasVideo;

  /// 正文（详情页用）。空字符串 = 只有标题的短动态。
  ///
  /// 卡片不需要正文，所以放在同一个类里而不是另建 `FeedPostDetail`：
  /// 企划星的列表与详情返回的是同一个 `FeedBean`，只是详情多了 `content` 字段，
  /// 为它复制一个 20 字段的类不值当。
  final String body;

  /// 浏览量文案：`1.2万` / `3862`。
  String get viewCountLabel {
    if (viewCount >= 10000) {
      final wan = viewCount / 10000;
      return '${wan.toStringAsFixed(1)}万';
    }
    return '$viewCount';
  }

  /// 点赞数文案：`1.2万` / `208`。
  String get likeCountLabel {
    if (likeCount >= 10000) {
      return '${(likeCount / 10000).toStringAsFixed(1)}万';
    }
    return '$likeCount';
  }
}

/// 一条评论（`item_feed_comment.xml`）。
///
/// 企划星的评论是独立聚合（`v1/feed/comment/list`），支持二级回复。
/// 这里只做一级：二级回复需要展开状态与"回复谁"的上下文，
/// 没有真实接口时做出来只是一套点了没反应的空壳。
final class FeedComment {
  const FeedComment({
    required this.id,
    required this.author,
    required this.text,
    required this.publishedAt,
    this.likeCount = 0,
  });

  factory FeedComment.fromJson(Map<String, dynamic> json) {
    final String? atRaw = json['publishedAt'] ?? json['createTime'];
    return FeedComment(
      id: json['id']?.toString() ?? '',
      author: json['author']?.toString() ?? json['userName']?.toString() ?? '',
      text: json['text']?.toString() ?? json['content']?.toString() ?? '',
      publishedAt: atRaw != null
          ? DateTime.tryParse(atRaw) ?? DateTime.now()
          : DateTime.now(),
      likeCount: json['likeCount'] ?? 0,
    );
  }

  final String id;
  final String author;
  final String text;
  final DateTime publishedAt;
  final int likeCount;

  /// 时间文案：`3分钟前` / `昨天` / `11月1日`。
  String timeLabel(DateTime now) {
    final Duration delta = now.difference(publishedAt);
    if (delta.inMinutes < 1) return '刚刚';
    if (delta.inMinutes < 60) return '${delta.inMinutes}分钟前';
    if (delta.inHours < 24) return '${delta.inHours}小时前';
    if (delta.inDays == 1) return '昨天';
    if (delta.inDays < 7) return '${delta.inDays}天前';
    return '${publishedAt.month}月${publishedAt.day}日';
  }
}
