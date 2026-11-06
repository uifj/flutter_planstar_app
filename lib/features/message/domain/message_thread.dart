/// 消息中心的一条会话。
///
/// 对应 `item_user_message.xml`：48dp 方头像、16dp 标题、11dp 时间、
/// 14dp `text_3` 单行摘要、底部 1dp `#ffeeeeee` 分隔线。
final class MessageThread {
  const MessageThread({
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    this.unreadCount = 0,
    this.avatarFallbackUrl,
    this.isOfficial = false,
  });

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    final String? atRaw =
        json['updatedAt'] ?? json['updateTime'] ?? json['createTime'];
    return MessageThread(
      id: json['id']?.toString() ?? json['messageId']?.toString() ?? '',
      title: json['title']?.toString() ?? json['subject']?.toString() ?? '',
      preview: json['preview']?.toString() ?? json['content']?.toString() ?? '',
      updatedAt: atRaw != null
          ? DateTime.tryParse(atRaw) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: json['unreadCount'] ?? json['unread'] ?? 0,
      avatarFallbackUrl: json['avatar']?.toString(),
      isOfficial: json['isOfficial'] == true || json['official'] == true,
    );
  }

  final String id;
  final String title;

  /// 最后一条消息摘要。
  final String preview;

  final DateTime updatedAt;
  final int unreadCount;

  /// 头像图（`null` 时用首字 + 品牌色块占位）。
  final String? avatarFallbackUrl;

  /// 官方账号（标题后带「官方」标）。
  final bool isOfficial;

  /// 时间文案：今天显示 `HH:mm`，否则 `MM-dd`。
  String timeLabel(DateTime now) {
    final sameDay =
        now.year == updatedAt.year &&
        now.month == updatedAt.month &&
        now.day == updatedAt.day;
    if (sameDay) {
      final hour = updatedAt.hour.toString().padLeft(2, '0');
      final minute = updatedAt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    final month = updatedAt.month.toString().padLeft(2, '0');
    final day = updatedAt.day.toString().padLeft(2, '0');
    return '$month-$day';
  }
}

/// 系统消息入口（`layout_user_message_header.xml` 的三列）。
final class SystemMessageEntry {
  const SystemMessageEntry({
    required this.id,
    required this.title,
    required this.icon,
    required this.unreadCount,
  });

  final String id;
  final String title;

  /// 图标标识（表现层映射成具体 `IconData`，领域层不依赖 Flutter）。
  final String icon;

  final int unreadCount;
}
