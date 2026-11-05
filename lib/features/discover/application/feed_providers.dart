import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_feed.dart';
import '../domain/feed_post.dart';

/// 发现页动态流。
///
/// 用 `Notifier` 而不是 `Provider`：发布动态要**就地插入**到列表头部，
/// 不能靠重建整个列表（那会把用户滚动位置和已加载状态一起丢掉）。
class FeedController extends Notifier<List<FeedPost>> {
  @override
  List<FeedPost> build() => buildDemoFeed();

  /// 发布一条动态（本地插入，不落库）。
  ///
  /// 真实实现应该是 `POST v1/feed/publish` → 用返回的实体替换临时项；
  /// 这里插入一条 `p-<timestamp>` 的临时项，行为上等价于"发布成功"。
  FeedPost publish(String title, {String author = '我'}) {
    final post = FeedPost(
      id: 'p-${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      author: author,
      viewCount: 0,
      publishedAt: DateTime.now(),
      tag: '刚刚发布',
    );
    state = <FeedPost>[post, ...state];
    return post;
  }
}

/// 动态流。
final feedControllerProvider = NotifierProvider<FeedController, List<FeedPost>>(
  FeedController.new,
);

/// 按 id 取动态（详情页用）。查不到返回 `null`——深链带脏 id 是正常情况。
final feedPostByIdProvider = Provider.family<FeedPost?, String>((ref, id) {
  for (final FeedPost post in ref.watch(feedControllerProvider)) {
    if (post.id == id) return post;
  }
  return null;
});

/// 某条动态的评论。
///
/// 演示数据只给前几条动态造了评论，其余返回空（见 `buildDemoComments`）。
/// 接真实接口时换成 `AsyncValue` + 分页即可，页面结构不用动。
final feedCommentsProvider =
    Provider.family<List<FeedComment>, String>((ref, postId) {
  return buildDemoComments(postId);
});

/// 「关注」流。
///
/// 企划星的关注流是"我关注的人发的动态"。本项目没有社交关系数据
/// （没有登录用户、没有关注列表、没有 authorId 关联），所以这里**诚实地返回空**，
/// 由页面渲染空态并引导用户去看热门——而不是拿热门流冒充关注流。
final followingFeedProvider = Provider<List<FeedPost>>(
  (ref) => const <FeedPost>[],
);
