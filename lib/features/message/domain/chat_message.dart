/// 一条会话消息（`item_chat_message.xml` 的左右两种气泡）。
///
/// 企划星的 IM 走 pudding 的 mqtt 通道，消息体是 protobuf。这里只保留
/// 渲染需要的字段：谁发的、说了什么、什么时候。**不建模已读回执/撤回/图片**
/// ——这些没有真实通道时全是死字段。
library;

/// 会话消息。
final class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.fromMe,
    this.senderName,
  });

  final String id;
  final String text;
  final DateTime sentAt;

  /// 是否自己发的（决定气泡左右与配色）。
  final bool fromMe;

  /// 对方昵称（群聊用；一对一为 `null`）。
  final String? senderName;

  /// 时间文案：`HH:mm`。
  String get timeLabel {
    final String hour = sentAt.hour.toString().padLeft(2, '0');
    final String minute = sentAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
