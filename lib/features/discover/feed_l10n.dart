import 'package:flutter/widgets.dart';

import '../../l10n/l10n.dart';
import 'domain/feed_post.dart';

/// 发现页展示文案的本地化映射。
extension FeedPostL10n on FeedPost {
  /// 浏览量文案：`1.2万` / `3862`。
  String viewCountLabelOf(BuildContext context) =>
      _countLabel(context, viewCount, context.l10n.feedPost_65);

  /// 点赞数文案：`1.2万` / `208`。
  String likeCountLabelOf(BuildContext context) =>
      _countLabel(context, likeCount, context.l10n.feedPost_73);

  String _countLabel(
    BuildContext context,
    int value,
    String Function(Object) wan,
  ) {
    if (value >= 10000) {
      return wan((value / 10000).toStringAsFixed(1));
    }
    return '$value';
  }
}

extension FeedCommentL10n on FeedComment {
  /// 时间文案：`3分钟前` / `昨天` / `11月1日`。
  String timeLabelOf(BuildContext context, DateTime now) {
    final l10n = context.l10n;
    final delta = now.difference(publishedAt);
    if (delta.inMinutes < 1) return l10n.feedPost_115;
    if (delta.inMinutes < 60) return l10n.feedPost_116(delta.inMinutes);
    if (delta.inHours < 24) return l10n.feedPost_117(delta.inHours);
    if (delta.inDays == 1) return l10n.feedPost_118;
    if (delta.inDays < 7) return l10n.feedPost_119(delta.inDays);
    return l10n.feedPost_120(publishedAt.month, publishedAt.day);
  }
}

/// 相对时间：`刚刚` / `5分钟前` / `昨天` / `11月1日`。
String formatRelativeTimeL10n(
  BuildContext context,
  DateTime time, {
  DateTime? now,
}) {
  final l10n = context.l10n;
  final reference = now ?? DateTime.now();
  final delta = reference.difference(time);
  if (delta.inMinutes < 1) return l10n.feedPost_115;
  if (delta.inMinutes < 60) return l10n.feedPost_116(delta.inMinutes);
  if (delta.inHours < 24 && reference.day == time.day) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  if (delta.inDays == 1) return l10n.feedPost_118;
  if (delta.inDays < 7) return l10n.feedPost_119(delta.inDays);
  return l10n.feedPost_120(time.month, time.day);
}
