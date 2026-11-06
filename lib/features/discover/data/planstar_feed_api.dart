import 'package:core/network.dart';
import 'package:core/result.dart';

import '../domain/feed_post.dart';

/// 动态/发现 API。
///
/// ## 端点
///
/// | 用途 | 方法 | 路径 |
/// |---|---|---|
/// | 动态列表（热门） | GET | `v4/feed/hot` |
/// | 动态列表（关注） | GET | `v1/feed` |
/// | 动态详情 | GET | `v1/tweets/{id}` |
/// | 点赞 | POST | `v1/userLike` |
/// | 取消赞 | DELETE | `v1/userLike` |
/// | 评论列表 | GET | `v1/userReply` |
/// | 发评论 | POST | `v1/userReply` |
final class PlanstarFeedApi {
  PlanstarFeedApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  /// 热门动态。
  Future<Result<List<FeedPost>>> fetchHotFeeds({
    int page = 1,
    int pageSize = 20,
    String? nextPageKey,
  }) {
    return _client.get<List<FeedPost>>(
      'v4/feed/hot',
      queryParameters: <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'nextPageKey': ?nextPageKey,
      },
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => _parseFeedList(data),
    );
  }

  /// 关注动态。
  Future<Result<List<FeedPost>>> fetchFollowingFeeds({
    int page = 1,
    int pageSize = 20,
    String? nextPageKey,
  }) {
    return _client.get<List<FeedPost>>(
      'v1/feed',
      queryParameters: <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'nextPageKey': ?nextPageKey,
      },
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => _parseFeedList(data),
    );
  }

  /// 动态详情。
  Future<Result<FeedPost?>> fetchFeedDetail(String id) {
    return _client.get<FeedPost?>(
      'v1/tweets/$id',
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is! Map<String, dynamic>) return null;
        return FeedPost.fromJson(data);
      },
    );
  }

  /// 评论列表。
  Future<Result<List<FeedComment>>> fetchComments(String postId) {
    return _client.get<List<FeedComment>>(
      'v1/userReply',
      queryParameters: <String, dynamic>{'tweetId': postId},
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final list = data as List<dynamic>? ?? <dynamic>[];
        return list
            .whereType<Map<String, dynamic>>()
            .map(FeedComment.fromJson)
            .toList(growable: false);
      },
    );
  }

  static List<FeedPost> _parseFeedList(Object? data) {
    // 企划星 feed 接口有两种包装：
    // 1. 直接返回 List<FeedBean>
    // 2. 包在 FeedPagination 里 {data, hasMore, nextPageKey}
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) {
        return inner
            .whereType<Map<String, dynamic>>()
            .map(FeedPost.fromJson)
            .toList(growable: false);
      }
    }
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(FeedPost.fromJson)
          .toList(growable: false);
    }
    return const <FeedPost>[];
  }
}
