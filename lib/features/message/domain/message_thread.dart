import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_thread.freezed.dart';
part 'message_thread.g.dart';

/// 消息中心的一条会话。
///
/// 渲染尺寸：48dp 方头像、16dp 标题、11dp 时间、
/// 14dp `text_3` 单行摘要、底部 1dp `#ffeeeeee` 分隔线。
@freezed
abstract class MessageThread with _$MessageThread {
  const MessageThread._();

  const factory MessageThread({
    @JsonKey(readValue: _readId) required String id,
    @JsonKey(readValue: _readTitle) required String title,
    @JsonKey(readValue: _readPreview) required String preview,
    @JsonKey(readValue: _readUpdatedAt, fromJson: _dateTimeOrNow)
    required DateTime updatedAt,
    @JsonKey(readValue: _readUnreadCount) @Default(0) int unreadCount,
    @JsonKey(readValue: _readAvatar) String? avatarFallbackUrl,
    @JsonKey(readValue: _readIsOfficial) @Default(false) bool isOfficial,
  }) = _MessageThread;

  factory MessageThread.fromJson(Map<String, dynamic> json) =>
      _$MessageThreadFromJson(json);

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

/// 系统消息入口（头部三列）。
@freezed
abstract class SystemMessageEntry with _$SystemMessageEntry {
  const factory SystemMessageEntry({
    required String id,
    required String title,
    required String icon,
    required int unreadCount,
  }) = _SystemMessageEntry;
}

// ── JSON 兼容读取 ───────────────────────────────────────────────────────

Object? _readId(Map<dynamic, dynamic> json, String key) =>
    json['id']?.toString() ??
    json['threadId']?.toString() ??
    json['messageId']?.toString() ??
    '';

Object? _readTitle(Map<dynamic, dynamic> json, String key) =>
    json['title']?.toString() ?? json['subject']?.toString() ?? '';

Object? _readPreview(Map<dynamic, dynamic> json, String key) =>
    json['preview']?.toString() ?? json['content']?.toString() ?? '';

Object? _readUpdatedAt(Map<dynamic, dynamic> json, String key) =>
    json['updatedAt'] ?? json['updateTime'] ?? json['createTime'];

Object? _readUnreadCount(Map<dynamic, dynamic> json, String key) =>
    json['unreadCount'] ?? json['unread'] ?? 0;

Object? _readAvatar(Map<dynamic, dynamic> json, String key) =>
    json['avatar']?.toString() ?? json['avatarUrl']?.toString();

Object? _readIsOfficial(Map<dynamic, dynamic> json, String key) =>
    json['isOfficial'] == true || json['official'] == true;

DateTime _dateTimeOrNow(Object? raw) {
  if (raw is String) {
    return DateTime.tryParse(raw) ?? DateTime.now();
  }
  return DateTime.now();
}
