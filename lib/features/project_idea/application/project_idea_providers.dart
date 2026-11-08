import 'dart:async';

import 'package:core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/project_idea_api.dart';
import '../model/project_idea.dart';

/// 企划创意接口客户端。
final projectIdeaApiProvider = Provider<ProjectIdeaApi>(
  (ref) => ProjectIdeaApi(client: ref.watch(apiClientProvider)),
);

/// 表态服务：叠卡流与详情页共用同一套投票参数拼装。
final class ProjectIdeaVoteService {
  const ProjectIdeaVoteService(this._api);

  final ProjectIdeaApi _api;

  /// 支持（仅表达意愿，不扣星币）。
  Future<IdeaVoteResult> support(int ideaId, {int tier = 5, String? reason}) {
    return _api.vote(ideaId, voteType: 1, coinTier: tier, reasonText: reason);
  }

  /// 不支持（标准理由必填）。
  Future<IdeaVoteResult> oppose(
    int ideaId, {
    required String reasonCode,
    String? reasonText,
  }) {
    return _api.vote(
      ideaId,
      voteType: 2,
      reasonCode: reasonCode,
      reasonText: reasonText,
    );
  }
}

/// 表态服务（详情页复用时只依赖它，不直接依赖 API）。
final projectIdeaVoteServiceProvider = Provider<ProjectIdeaVoteService>(
  (ref) => ProjectIdeaVoteService(ref.watch(projectIdeaApiProvider)),
);

const Object _unset = Object();

/// 叠卡流状态。[ideas] 是**尚未消费**的卡片队列，当前卡恒为第一条。
final class ProjectIdeaFeedState {
  const ProjectIdeaFeedState({
    this.ideas = const <ProjectIdea>[],
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.cursor,
    this.error,
  });

  final List<ProjectIdea> ideas;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? cursor;

  /// 最近一次加载失败；成功后清空。
  final Failure? error;

  /// 是否已无可消费的卡片。
  bool get isEmpty => ideas.isEmpty;

  /// 可直接展示的错误文案。
  String? get errorMessage => error?.message;

  ProjectIdeaFeedState copyWith({
    List<ProjectIdea>? ideas,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    Object? cursor = _unset,
    Object? error = _unset,
  }) {
    return ProjectIdeaFeedState(
      ideas: ideas ?? this.ideas,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      error: identical(error, _unset) ? this.error : error as Failure?,
    );
  }
}

/// 叠卡流控制器。
///
/// 失败时保留已加载队列（只记录 [ProjectIdeaFeedState.error]），避免用户翻到
/// 第 5 张时因为一次网络抖动被清空进度。
final class ProjectIdeaFeedController extends Notifier<ProjectIdeaFeedState> {
  /// 每页条数（Spec §4.4）。
  static const int pageSize = 10;

  /// 剩余卡片 ≤ 该值时预取下一页。
  static const int prefetchThreshold = 3;

  @override
  ProjectIdeaFeedState build() => const ProjectIdeaFeedState();

  /// 首次加载 / 刷新（替换整个队列）。
  Future<void> loadInitial() async {
    if (state.loading) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final ProjectIdeaFeedPage page = await ref
          .read(projectIdeaApiProvider)
          .feed(size: pageSize);
      state = ProjectIdeaFeedState(
        ideas: page.items,
        hasMore: page.hasMore,
        cursor: page.nextCursor,
      );
      _maybePrefetch();
    } catch (error) {
      state = state.copyWith(loading: false, error: _asFailure(error));
    }
  }

  /// 追加下一页（游标来自上一次响应）。
  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    state = state.copyWith(loadingMore: true, error: null);
    try {
      final ProjectIdeaFeedPage page = await ref
          .read(projectIdeaApiProvider)
          .feed(cursor: state.cursor, size: pageSize);
      state = state.copyWith(
        ideas: <ProjectIdea>[...state.ideas, ...page.items],
        loadingMore: false,
        // 空页强制结束，避免游标不变时预取死循环。
        hasMore: page.hasMore && page.items.isNotEmpty,
        cursor: page.nextCursor,
      );
      _maybePrefetch();
    } catch (error) {
      state = state.copyWith(loadingMore: false, error: _asFailure(error));
    }
  }

  /// 支持当前创意；失败时记录状态并原样抛出，供页面提示。
  Future<IdeaVoteResult> support(
    ProjectIdea idea, {
    int tier = 5,
    String? reason,
  }) {
    return _vote(
      () => ref
          .read(projectIdeaVoteServiceProvider)
          .support(idea.ideaId, tier: tier, reason: reason),
    );
  }

  /// 不支持当前创意；失败时记录状态并原样抛出，供页面提示。
  Future<IdeaVoteResult> oppose(
    ProjectIdea idea, {
    required String reasonCode,
    String? reasonText,
  }) {
    return _vote(
      () => ref
          .read(projectIdeaVoteServiceProvider)
          .oppose(idea.ideaId, reasonCode: reasonCode, reasonText: reasonText),
    );
  }

  /// 消费当前卡（投票成功、卡片飞出的动画结束后调用）。
  void advance() {
    if (state.ideas.isEmpty) return;
    state = state.copyWith(
      ideas: state.ideas.sublist(1).toList(growable: false),
    );
    _maybePrefetch();
  }

  Future<IdeaVoteResult> _vote(Future<IdeaVoteResult> Function() action) async {
    try {
      return await action();
    } catch (error) {
      state = state.copyWith(error: _asFailure(error));
      rethrow;
    }
  }

  /// 剩余卡片不多时静默预取，不打断当前手势。
  void _maybePrefetch() {
    if (state.ideas.isEmpty) return;
    if (state.ideas.length > prefetchThreshold) return;
    if (!state.hasMore || state.loading || state.loadingMore) return;
    unawaited(loadMore());
  }

  static Failure _asFailure(Object error) {
    if (error is Failure) return error;
    return Failure.server(
      code: 'UNEXPECTED',
      message: '加载失败：$error',
      cause: error,
    );
  }
}

/// 叠卡流。
final projectIdeaFeedProvider =
    NotifierProvider<ProjectIdeaFeedController, ProjectIdeaFeedState>(
      ProjectIdeaFeedController.new,
    );

/// 登录门禁拦下后待续做的表态动作。
enum IdeaPendingAction { support, oppose }

/// 跨页面保留的待续做动作：登录页 `context.go` 重建路由后，新页面据此重开弹窗。
final projectIdeaPendingActionProvider =
    NotifierProvider<ProjectIdeaPendingActionController, IdeaPendingAction?>(
      ProjectIdeaPendingActionController.new,
    );

final class ProjectIdeaPendingActionController
    extends Notifier<IdeaPendingAction?> {
  @override
  IdeaPendingAction? build() => null;

  void set(IdeaPendingAction action) => state = action;

  /// 取出并清空，保证只消费一次。
  IdeaPendingAction? take() {
    final IdeaPendingAction? action = state;
    state = null;
    return action;
  }
}

/// 创意详情（按 ideaId 缓存，页面销毁即释放）。
final projectIdeaDetailProvider = FutureProvider.autoDispose
    .family<ProjectIdeaDetail, int>((ref, ideaId) {
      return ref.watch(projectIdeaApiProvider).detail(ideaId);
    });
