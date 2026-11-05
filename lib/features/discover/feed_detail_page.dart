import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import '../../shared/ui/ps_tag.dart';
import '../catalog/application/catalog_providers.dart';
import '../catalog/domain/show_summary.dart';
import '../catalog/ui/show_cards.dart';
import 'application/feed_providers.dart';
import 'domain/feed_post.dart';
import '../../shared/ui/ps_network_images.dart';

/// 动态详情页（企划星 `FeedDetailActivity` + `FeedDetailTweetFragment`）。
///
/// ## 结构
///
/// 作者行 → 标题 → 正文 → 相关演出 → 互动条 → 评论区。
/// 企划星的详情页是"一个 Activity + 5 个 Fragment"（图文/文章/视频/转发/收藏），
/// 本项目只有图文一种，所以不拆 Fragment——**类型分叉靠 `hasVideo` 之类的
/// 字段驱动，而不是靠 5 个子类**。
///
/// ## 与 Android 的差异
///
/// - 不做视频播放：`hasVideo` 为真时只在头部显示一个播放角标并说明原因，
///   不假装能播（播放器需要 CDN 与 `videoplayer` 那 16 个类的等价物）。
/// - 不做点赞/评论的写入：企划星走 `v1/feed/like` 与评论接口。这里点赞与
///   写评论都是 toast 占位，**不本地改数字**——本地 +1 而服务端没加，
///   退出再进就回退，比不给按钮更困惑。
class FeedDetailPage extends ConsumerWidget {
  const FeedDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final FeedPost? post = ref.watch(feedPostByIdProvider(postId));

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: const AdaptiveAppBar(title: '动态详情'),
      body: post == null
          ? PsEmptyState(
              title: '动态不存在',
              description: '它可能已被作者删除',
              icon: LucideIcons.fileText,
              actionLabel: '返回发现',
              onAction: () => context.go('/discover'),
            )
          : _FeedDetailBody(post: post),
    );
  }
}

class _FeedDetailBody extends ConsumerWidget {
  const _FeedDetailBody({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final List<FeedComment> comments = ref.watch(feedCommentsProvider(post.id));
    final ShowSummary? show =
        post.showId == null ? null : ref.watch(showByIdProvider(post.showId!));

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        Container(
          color: colors.bgCard,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _AuthorRow(post: post),
              const SizedBox(height: 14),
              Text(
                post.title,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              if (post.body.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                for (final String paragraph in post.body.split('\n\n'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      paragraph,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.65,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
              ],
              if (post.hasVideo) ...<Widget>[
                const SizedBox(height: 4),
                _VideoNotice(),
              ],
              const SizedBox(height: 8),
              _InteractionBar(post: post),
            ],
          ),
        ),
        if (show != null) ...<Widget>[
          const SizedBox(height: 8),
          Container(
            color: colors.bgCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Text(
                    '相关演出',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                ShowCardRow(
                  show: show,
                  onTap: () => context.push('/show/${show.id}'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          color: colors.bgCard,
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(
                  '评论 ${comments.length}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (comments.isEmpty)
                const PsEmptyState(
                  title: '还没有评论',
                  description: '来说两句吧',
                  icon: LucideIcons.messageSquare,
                  compact: true,
                )
              else
                for (final FeedComment comment in comments)
                  _CommentTile(comment: comment),
            ],
          ),
        ),
      ],
    );
  }
}

/// 作者行（头像 + 名字 + 时间 + 角标）。
class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Row(
      children: <Widget>[
        ClipOval(
          child: Image.network(
            PsImages.defaultAvatar,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 36,
              height: 36,
              color: colors.brandSubtle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                post.author,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${formatRelativeTime(post.publishedAt)} · ${post.viewCountLabel} 阅读',
                style: TextStyle(fontSize: 11, color: colors.textTertiary),
              ),
            ],
          ),
        ),
        if (post.tag != null)
          PsTag(
            label: post.tag!,
            tone: PsTagTone.soft,
            fontSize: 10,
            radius: 3,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          ),
      ],
    );
  }
}

/// 视频占位说明。
class _VideoNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.bgSubtle,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: <Widget>[
          Icon(LucideIcons.circlePlay, size: 20, color: colors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '这条动态带视频，播放器尚未接入（需要 CDN 与 videoplayer 等价实现）',
              style: TextStyle(fontSize: 12, height: 1.4, color: colors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

/// 互动条（点赞 / 评论 / 分享）。
class _InteractionBar extends StatelessWidget {
  const _InteractionBar({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Row(
      children: <Widget>[
        _Action(
          icon: LucideIcons.heart,
          label: post.likeCountLabel,
          onTap: () => _toast(context, '点赞接口待接入'),
        ),
        const SizedBox(width: 24),
        _Action(
          icon: LucideIcons.messageSquare,
          label: '评论',
          onTap: () => _toast(context, '评论发布待接入'),
        ),
        const SizedBox(width: 24),
        _Action(
          icon: LucideIcons.share,
          label: '分享',
          onTap: () => _toast(context, '分享面板待接入 fluwx'),
        ),
        const Spacer(),
        Text(
          post.viewCountLabel,
          style: TextStyle(fontSize: 11, color: colors.textDisabled),
        ),
        const SizedBox(width: 3),
        Icon(LucideIcons.eye, size: 12, color: colors.textDisabled),
      ],
    );
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: colors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        ],
      ),
    );
  }
}

/// 一条评论。
class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final FeedComment comment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipOval(
            child: Image.network(
              PsImages.defaultAvatar,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 28,
                height: 28,
                color: colors.brandSubtle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      comment.author,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeLabel(DateTime.now()),
                      style: TextStyle(fontSize: 10, color: colors.textDisabled),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (comment.likeCount > 0)
            Row(
              children: <Widget>[
                Icon(LucideIcons.heart, size: 12, color: colors.textDisabled),
                const SizedBox(width: 2),
                Text(
                  '${comment.likeCount}',
                  style: TextStyle(fontSize: 10, color: colors.textDisabled),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
