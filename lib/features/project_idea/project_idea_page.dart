import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/session.dart';
import '../../l10n/l10n.dart';
import '../../shared/ui/ps_empty_state.dart';
import '../../shared/ui/ps_floating_tab_bar.dart';
import 'application/project_idea_analytics.dart';
import 'application/project_idea_providers.dart';
import 'model/project_idea.dart';
import 'oppose_sheet.dart';
import 'project_idea_feedback.dart';
import 'support_sheet.dart';

/// 「企划」叠卡流（Spec §4.4）。
///
/// 三层卡片同时渲染：当前卡 1.0，第二张 0.94 / Y+12 / 0.7，第三张
/// 0.88 / Y+24 / 0.4。左右滑或点按钮打开弹窗（**不直接落库**），上滑跳过，
/// 点击卡片进详情；提交成功才让卡片飞出并消费队列。
class ProjectIdeaPage extends ConsumerStatefulWidget {
  const ProjectIdeaPage({super.key});

  @override
  ConsumerState<ProjectIdeaPage> createState() => _ProjectIdeaPageState();
}

class _ProjectIdeaPageState extends ConsumerState<ProjectIdeaPage>
    with SingleTickerProviderStateMixin {
  /// 触发弹窗的横向位移阈值。
  static const double _horizontalThreshold = 80;

  /// 触发跳过（上滑）的纵向位移阈值。
  static const double _verticalThreshold = 70;

  /// 单张卡的飞出 / 回弹动画时长（Spec §4.4）。
  static const Duration _motionDuration = Duration(milliseconds: 300);

  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: _motionDuration,
  );

  Animation<Offset>? _motionTween;
  Offset _drag = Offset.zero;

  /// 今日已看张数（首屏不算，翻走一张 +1）。
  int _viewed = 0;

  /// 当前卡是否正在提交（防重复）。
  bool _submitting = false;

  int? _lastImpressionIdeaId;
  bool _emptyTracked = false;

  /// 登录态监听：登录页用 `context.go` 重建路由后，push 的 future 不会完成，
  /// 只能靠登录态变化续做登录前的表态动作。
  ProviderSubscription<Session>? _sessionSub;

  Offset get _offset => _motionTween?.value ?? _drag;

  @override
  void initState() {
    super.initState();
    _sessionSub = ref.listenManual<Session>(sessionProvider, (
      Session? prev,
      Session next,
    ) {
      if (next.isLoggedIn) _resumePendingAction();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final ProjectIdeaFeedState state = ref.read(projectIdeaFeedProvider);
      // 首屏无卡片时先等队列加载完成，否则续做动作会因取不到当前卡而丢失。
      if (state.ideas.isEmpty && !state.loading) {
        await ref.read(projectIdeaFeedProvider.notifier).loadInitial();
        if (!mounted) return;
      }
      final ProjectIdeaFeedState next = ref.read(projectIdeaFeedProvider);
      _maybeTrackImpression(next);
      _maybeTrackEmpty(next);
      _resumePendingAction();
    });
  }

  /// 登录页用 `context.go` 重建路由后，续做登录前的表态动作。
  ///
  /// 由登录态监听（或页面重建）触发，`take()` 保证只消费一次。
  void _resumePendingAction() {
    if (!ref.read(sessionProvider).isLoggedIn) return;
    // 队列未就绪时不消费，保留动作等下次页面 init，避免 take() 后无卡可弹。
    if (ref.read(projectIdeaFeedProvider).ideas.isEmpty) return;
    final IdeaPendingAction? action = ref
        .read(projectIdeaPendingActionProvider.notifier)
        .take();
    if (action == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (action) {
        case IdeaPendingAction.support:
          unawaited(_openSupport());
        case IdeaPendingAction.oppose:
          unawaited(_openOppose());
      }
    });
  }

  @override
  void dispose() {
    _sessionSub?.close();
    _motion.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _emptyTracked = false;
    await ref.read(projectIdeaFeedProvider.notifier).loadInitial();
  }

  void _maybeTrackImpression(ProjectIdeaFeedState state) {
    if (state.ideas.isEmpty) return;
    final int ideaId = state.ideas.first.ideaId;
    if (ideaId == _lastImpressionIdeaId) return;
    _lastImpressionIdeaId = ideaId;
    trackProjectIdeaEvent(
      ProjectIdeaEvents.ideaCardImpression,
      <String, Object?>{'ideaId': ideaId, 'position': 0, 'tab': 'projectIdea'},
    );
  }

  void _maybeTrackEmpty(ProjectIdeaFeedState state) {
    if (state.loading || state.error != null || state.ideas.isNotEmpty) return;
    if (_emptyTracked) return;
    _emptyTracked = true;
    trackProjectIdeaEvent(ProjectIdeaEvents.ideaFeedEmpty, <String, Object?>{
      'reason': 'empty',
    });
  }

  /// 冲突中的动画（例如连续滑动）直接忽略，避免两个 Tween 抢同一个控制器。
  bool get _busy => _submitting || _motion.isAnimating;

  void _animateTo(Offset target, {VoidCallback? onDone}) {
    _motionTween = Tween<Offset>(
      begin: _offset,
      end: target,
    ).animate(CurvedAnimation(parent: _motion, curve: Curves.easeOut));
    _motion.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      _motionTween = null;
      setState(() => _drag = target);
      onDone?.call();
    });
  }

  void _bounceBack() {
    if (!mounted) return;
    _animateTo(Offset.zero);
  }

  /// 提交成功后按方向飞出 → advance() → 下一张上浮。
  void _flyOut(int direction) {
    final double width = MediaQuery.sizeOf(context).width;
    _animateTo(
      Offset(direction * width * 1.4, 0),
      onDone: () {
        _drag = Offset.zero;
        _motionTween = null;
        setState(() => _viewed += 1);
        ref.read(projectIdeaFeedProvider.notifier).advance();
      },
    );
  }

  void _skipCurrent() {
    final ProjectIdea? idea = _currentIdea;
    if (idea == null) return;
    final double height = MediaQuery.sizeOf(context).height;
    _animateTo(
      Offset(0, -height),
      onDone: () {
        _drag = Offset.zero;
        _motionTween = null;
        setState(() => _viewed += 1);
        ref.read(projectIdeaFeedProvider.notifier).advance();
      },
    );
  }

  ProjectIdea? get _currentIdea {
    final List<ProjectIdea> ideas = ref.read(projectIdeaFeedProvider).ideas;
    return ideas.isEmpty ? null : ideas.first;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_busy) return;
    setState(() => _drag += Offset(details.delta.dx, 0));
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_busy) return;
    final double dx = _drag.dx;
    final double velocity = details.velocity.pixelsPerSecond.dx;
    if (dx > _horizontalThreshold || velocity > 700) {
      unawaited(_openSupport());
    } else if (dx < -_horizontalThreshold || velocity < -700) {
      unawaited(_openOppose());
    } else {
      _bounceBack();
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_busy) return;
    setState(() => _drag += Offset(0, details.delta.dy));
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_busy) return;
    final double dy = _drag.dy;
    final double velocity = details.velocity.pixelsPerSecond.dy;
    if (dy < -_verticalThreshold || velocity < -600) {
      _skipCurrent();
    } else {
      _bounceBack();
    }
  }

  /// 未登录不弹窗：先跳登录并带上来源。
  ///
  /// 登录页用 `context.go` 替换路由栈，`push` 的 future 不会完成，因此这里
  /// 一律返回 false；续做由 [initState] 里的登录态监听触发。
  Future<bool> _ensureLoggedIn() async {
    if (ref.read(sessionProvider).isLoggedIn) return true;
    await context.push('/login?from=${Uri.encodeComponent('/project-idea')}');
    if (!mounted) return false;
    if (!ref.read(sessionProvider).isLoggedIn) _bounceBack();
    return false;
  }

  /// 未登录时记住待续做的动作；已登录则清掉残留，避免下次重建误弹。
  void _rememberPendingAction(IdeaPendingAction action) {
    final ProjectIdeaPendingActionController controller = ref.read(
      projectIdeaPendingActionProvider.notifier,
    );
    if (ref.read(sessionProvider).isLoggedIn) {
      controller.take();
    } else {
      controller.set(action);
    }
  }

  Future<void> _openSupport() async {
    final ProjectIdea? idea = _currentIdea;
    if (idea == null || _busy) return;
    trackProjectIdeaEvent(ProjectIdeaEvents.ideaSupportClick, <String, Object?>{
      'ideaId': idea.ideaId,
    });
    _rememberPendingAction(IdeaPendingAction.support);
    if (!await _ensureLoggedIn()) {
      // 用户取消登录：清掉标记，避免之后进入页面误弹窗。
      if (mounted && !ref.read(sessionProvider).isLoggedIn) {
        ref.read(projectIdeaPendingActionProvider.notifier).take();
      }
      return;
    }
    if (!mounted) return;
    // 登录后当前页面已续做，消费掉标记防止路由重建时重复弹窗。
    ref.read(projectIdeaPendingActionProvider.notifier).take();

    setState(() => _submitting = true);
    final IdeaVoteResult? result = await SupportSheet.show(
      context,
      onSubmit: (SupportSelection selection) {
        trackProjectIdeaEvent(
          ProjectIdeaEvents.ideaSupportSubmit,
          <String, Object?>{'ideaId': idea.ideaId, 'tier': selection.tier},
        );
        return ref
            .read(projectIdeaFeedProvider.notifier)
            .support(
              idea,
              tier: selection.tier,
              reason: selection.reason.isEmpty ? null : selection.reason,
            );
      },
      onError: _bounceBack,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result == null) {
      _bounceBack();
      return;
    }
    showIdeaToast(
      context,
      result.alreadyVoted
          ? context.l10n.ideaAlreadyVoted
          : context.l10n.supportSuccess,
    );
    _flyOut(1);
  }

  Future<void> _openOppose() async {
    final ProjectIdea? idea = _currentIdea;
    if (idea == null || _busy) return;
    trackProjectIdeaEvent(ProjectIdeaEvents.ideaOpposeClick, <String, Object?>{
      'ideaId': idea.ideaId,
    });
    _rememberPendingAction(IdeaPendingAction.oppose);
    if (!await _ensureLoggedIn()) {
      // 用户取消登录：清掉标记，避免之后进入页面误弹窗。
      if (mounted && !ref.read(sessionProvider).isLoggedIn) {
        ref.read(projectIdeaPendingActionProvider.notifier).take();
      }
      return;
    }
    if (!mounted) return;
    // 登录后当前页面已续做，消费掉标记防止路由重建时重复弹窗。
    ref.read(projectIdeaPendingActionProvider.notifier).take();

    setState(() => _submitting = true);
    final IdeaVoteResult? result = await OpposeSheet.show(
      context,
      onSubmit: (OpposeSelection selection) {
        trackProjectIdeaEvent(
          ProjectIdeaEvents.ideaOpposeSubmit,
          <String, Object?>{
            'ideaId': idea.ideaId,
            'reasonCode': selection.reasonCode,
          },
        );
        return ref
            .read(projectIdeaFeedProvider.notifier)
            .oppose(
              idea,
              reasonCode: selection.reasonCode,
              reasonText: selection.reasonText.isEmpty
                  ? null
                  : selection.reasonText,
            );
      },
      onError: _bounceBack,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result == null) {
      _bounceBack();
      return;
    }
    showIdeaToast(
      context,
      result.alreadyVoted
          ? context.l10n.ideaAlreadyVoted
          : context.l10n.opposeSuccess,
    );
    _flyOut(-1);
  }

  void _openDetail(ProjectIdea idea) {
    if (_busy) return;
    context.push('/project-idea/${idea.ideaId}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final ProjectIdeaFeedState state = ref.watch(projectIdeaFeedProvider);

    // 当前卡变化（首屏 / 翻卡 / 刷新）时补曝光埋点；回调在 build 之外执行。
    ref.listen<ProjectIdeaFeedState>(projectIdeaFeedProvider, (_, next) {
      _maybeTrackImpression(next);
      _maybeTrackEmpty(next);
    });

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _Header(viewed: _viewed, onRefresh: _refresh),
            Expanded(child: _buildBody(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProjectIdeaFeedState state) {
    if (state.ideas.isEmpty && state.loading) {
      return const _SkeletonStack();
    }
    if (state.ideas.isEmpty && state.error != null) {
      return PsEmptyState(
        title: context.l10n.ideaLoadFailed,
        description: psErrorMessage(state.error!),
        icon: LucideIcons.circleAlert,
        actionLabel: context.l10n.actionRetry,
        onAction: () => unawaited(_refresh()),
      );
    }
    if (state.ideas.isEmpty) {
      return PsEmptyState(
        title: context.l10n.ideaEmptyTitle,
        description: context.l10n.ideaEmptyDescription,
        icon: LucideIcons.lightbulb,
        actionLabel: context.l10n.ideaRefresh,
        onAction: () => unawaited(_refresh()),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        PsFloatingTabBar.bottomClearance(context) + 8,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double height = constraints.maxHeight;
          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              for (var depth = 2; depth >= 0; depth--)
                if (depth < state.ideas.length)
                  _buildLayer(
                    context,
                    idea: state.ideas[depth],
                    depth: depth,
                    height: height,
                  ),
            ],
          );
        },
      ),
    );
  }

  /// [depth] 0 = 当前卡（可交互），1 / 2 = 背景卡。
  Widget _buildLayer(
    BuildContext context, {
    required ProjectIdea idea,
    required int depth,
    required double height,
  }) {
    final double scale = switch (depth) {
      0 => 1,
      1 => 0.94,
      _ => 0.88,
    };
    final double offsetY = switch (depth) {
      0 => 0,
      1 => 12,
      _ => 24,
    };
    final double opacity = switch (depth) {
      0 => 1,
      1 => 0.7,
      _ => 0.4,
    };
    final bool interactive = depth == 0;

    Widget card = _IdeaCard(
      idea: idea,
      busy: _submitting,
      onSupport: interactive ? () => unawaited(_openSupport()) : null,
      onOppose: interactive ? () => unawaited(_openOppose()) : null,
      onSkip: interactive ? _skipCurrent : null,
    );

    if (interactive) {
      card = GestureDetector(
        onTap: () => _openDetail(idea),
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: AnimatedBuilder(
          animation: _motion,
          child: card,
          builder: (BuildContext context, Widget? child) =>
              Transform.translate(offset: _offset, child: child),
        ),
      );
    } else {
      card = IgnorePointer(child: card);
    }

    return Positioned.fill(
      child: AnimatedSlide(
        duration: _motionDuration,
        curve: Curves.easeOut,
        offset: Offset(0, height <= 0 ? 0 : offsetY / height),
        child: AnimatedScale(
          duration: _motionDuration,
          curve: Curves.easeOut,
          scale: scale,
          alignment: Alignment.topCenter,
          child: AnimatedOpacity(
            duration: _motionDuration,
            curve: Curves.easeOut,
            opacity: opacity,
            child: card,
          ),
        ),
      ),
    );
  }
}

/// 顶部「今日已看 N 张」+ 刷新。
class _Header extends StatelessWidget {
  const _Header({required this.viewed, required this.onRefresh});

  final int viewed;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
      child: Row(
        children: <Widget>[
          Text(
            context.l10n.ideaViewedToday(viewed),
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
          const Spacer(),
          IconButton(
            tooltip: context.l10n.ideaRefresh,
            onPressed: () => unawaited(onRefresh()),
            icon: Icon(
              LucideIcons.refreshCw,
              size: 18,
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 单张创意卡。背景卡传 `null` 回调即只读。
class _IdeaCard extends StatelessWidget {
  const _IdeaCard({
    required this.idea,
    this.busy = false,
    this.onSupport,
    this.onOppose,
    this.onSkip,
  });

  final ProjectIdea idea;
  final bool busy;
  final VoidCallback? onSupport;
  final VoidCallback? onOppose;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = context.l10n;
    final String category = idea.categoryName.isEmpty
        ? l10n.ideaCategoryFallback
        : idea.categoryName;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _Cover(idea: idea),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onBrand,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (onSkip != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: TextButton.icon(
                      onPressed: busy ? null : onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: colors.onBrand,
                        backgroundColor: Colors.black.withValues(alpha: 0.38),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: Icon(
                        LucideIcons.arrowUp,
                        size: 14,
                        color: colors.onBrand,
                      ),
                      label: Text(
                        l10n.ideaSkip,
                        style: TextStyle(fontSize: 12, color: colors.onBrand),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    idea.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 19,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      idea.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CreatorRow(idea: idea),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Icon(LucideIcons.thumbsUp, size: 14, color: colors.brand),
                      const SizedBox(width: 4),
                      Text(
                        l10n.ideaSupportCount(idea.supportCount),
                        style: TextStyle(fontSize: 12, color: colors.brand),
                      ),
                      const SizedBox(width: 14),
                      Icon(
                        LucideIcons.thumbsDown,
                        size: 14,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.ideaOpposeCount(idea.opposeCount),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: busy ? null : onOppose,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.textSecondary,
                            minimumSize: const Size(0, 44),
                            side: BorderSide(color: colors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.ideaOppose),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: busy ? null : onSupport,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.brand,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.ideaSupport),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.idea});

  final ProjectIdea idea;

  @override
  Widget build(BuildContext context) {
    if (idea.cover.isEmpty) return const _CoverPlaceholder();
    return Image.network(
      idea.cover,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _CoverPlaceholder(),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[colors.brand, colors.brandPressed],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        LucideIcons.lightbulb,
        size: 48,
        color: colors.onBrand.withValues(alpha: 0.75),
      ),
    );
  }
}

/// 发起人：头像 + 昵称。
class _CreatorRow extends StatelessWidget {
  const _CreatorRow({required this.idea});

  final ProjectIdea idea;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final String name = idea.creatorName.isEmpty
        ? context.l10n.ideaCreatorLabel
        : idea.creatorName;
    final Widget fallback = CircleAvatar(
      radius: 13,
      backgroundColor: colors.brandSubtle,
      child: Text(
        name.isEmpty ? '?' : name[0],
        style: TextStyle(fontSize: 12, color: colors.brand),
      ),
    );
    return Row(
      children: <Widget>[
        ClipOval(
          child: idea.creatorAvatar.isEmpty
              ? fallback
              : Image.network(
                  idea.creatorAvatar,
                  width: 26,
                  height: 26,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback,
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// 骨架卡（3 层占位）。
class _SkeletonStack extends StatelessWidget {
  const _SkeletonStack();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        PsFloatingTabBar.bottomClearance(context) + 8,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double height = constraints.maxHeight;
          return Stack(
            children: <Widget>[
              _skeletonLayer(context, colors, height, depth: 2),
              _skeletonLayer(context, colors, height, depth: 1),
              _skeletonLayer(context, colors, height, depth: 0),
            ],
          );
        },
      ),
    );
  }

  Widget _skeletonLayer(
    BuildContext context,
    AppColors colors,
    double height, {
    required int depth,
  }) {
    final double scale = switch (depth) {
      0 => 1,
      1 => 0.94,
      _ => 0.88,
    };
    final double offsetY = switch (depth) {
      0 => 0,
      1 => 12,
      _ => 24,
    };
    final double opacity = switch (depth) {
      0 => 1,
      1 => 0.7,
      _ => 0.4,
    };
    final Widget bar = Container(
      height: 14,
      decoration: BoxDecoration(
        color: colors.skeleton,
        borderRadius: BorderRadius.circular(7),
      ),
    );
    return Positioned.fill(
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        offset: Offset(0, height <= 0 ? 0 : offsetY / height),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          scale: scale,
          alignment: Alignment.topCenter,
          child: Opacity(
            opacity: opacity,
            child: Container(
              decoration: BoxDecoration(
                color: colors.bgCard,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(flex: 5, child: Container(color: colors.bgSubtle)),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          bar,
                          const SizedBox(height: 10),
                          bar,
                          const SizedBox(height: 10),
                          FractionallySizedBox(widthFactor: 0.6, child: bar),
                          const Spacer(),
                          Row(
                            children: <Widget>[
                              Expanded(child: bar),
                              const SizedBox(width: 12),
                              Expanded(child: bar),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
