import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/demo_feed.dart';
import '../data/planstar_feed_api.dart';
import '../domain/feed_post.dart';
import 'feed_api_providers.dart';

/// 发现页动态流。
///
/// 真实模式走 `GET v4/feed/hot`，`PS_USE_DEMO=true` 时读 `buildDemoFeed()`。
/// 用 `Notifier` 而不是 `Provider`：发布动态要**就地插入**到列表头部，
/// 不能靠重建整个列表（那会把用户滚动位置和已加载状态一起丢掉）。
class FeedController extends AsyncNotifier<List<FeedPost>> {
  @override
  Future<List<FeedPost>> build() async {
    if (ref.watch(useDemoProvider)) return buildDemoFeed();
    final PlanstarFeedApi api = ref.read(planstarFeedApiProvider);
    final result = await api.fetchHotFeeds(page: 1, pageSize: 20);
    return result.fold(
      onSuccess: (List<FeedPost> feeds) => feeds,
      onFailure: (failure) => throw failure,
    );
  }

  /// 发布一条动态（本地插入，不落库）。
  ///
  /// 服务端暂无发布接口，这里插入一条 `p-<timestamp>` 的临时项；
  /// 刷新后消失，所以 UI 上仍按"本地演示"的语义处理。
  FeedPost publish(
    String title, {
    required String author,
    required String tag,
  }) {
    final post = FeedPost(
      id: 'p-${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      author: author,
      viewCount: 0,
      publishedAt: DateTime.now(),
      tag: tag,
    );
    state = AsyncData(<FeedPost>[
      post,
      ...state.valueOrNull ?? const <FeedPost>[],
    ]);
    return post;
  }
}

/// 动态流。
final feedControllerProvider =
    AsyncNotifierProvider<FeedController, List<FeedPost>>(FeedController.new);

/// 按 id 取动态（详情页用）。
///
/// 先查已加载的热门流；真实模式下查不到再打 `GET v1/tweets/{id}`，
/// 这样深链进来不必等首页翻到那一条。查不到返回 `null`——
/// 深链带脏 id 是正常情况。
final feedPostByIdProvider = FutureProvider.family<FeedPost?, String>((
  ref,
  id,
) async {
  final List<FeedPost> loaded =
      ref.watch(feedControllerProvider).valueOrNull ?? const <FeedPost>[];
  for (final FeedPost post in loaded) {
    if (post.id == id) return post;
  }
  if (ref.watch(useDemoProvider)) return null;

  final result = await ref.read(planstarFeedApiProvider).fetchFeedDetail(id);
  return result.fold(
    onSuccess: (FeedPost? post) => post,
    onFailure: (_) => null,
  );
});

/// 某条动态的评论。
///
/// 真实模式走 `GET v1/userReply?tweetId=`；评论失败不阻断详情正文，
/// 静默按"暂无评论"展示，避免整页挂在一段辅助内容上。
final feedCommentsProvider = FutureProvider.family<List<FeedComment>, String>((
  ref,
  postId,
) async {
  if (ref.watch(useDemoProvider)) return buildDemoComments(postId);
  final result = await ref.read(planstarFeedApiProvider).fetchComments(postId);
  return result.fold(
    onSuccess: (List<FeedComment> comments) => comments,
    onFailure: (_) => const <FeedComment>[],
  );
});

/// 「关注」流。
///
/// 真实模式走 `GET v1/feed`；演示模式**诚实地返回空**——没有社交关系数据，
/// 拿热门流冒充关注流会让用户以为关注了别人。页面会渲染空态并引导去看热门。
final followingFeedProvider = FutureProvider<List<FeedPost>>((ref) async {
  if (ref.watch(useDemoProvider)) return const <FeedPost>[];
  final result = await ref
      .read(planstarFeedApiProvider)
      .fetchFollowingFeeds(page: 1, pageSize: 20);
  return result.fold(
    onSuccess: (List<FeedPost> feeds) => feeds,
    onFailure: (_) => const <FeedPost>[],
  );
});
