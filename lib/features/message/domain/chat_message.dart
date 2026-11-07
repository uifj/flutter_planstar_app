/// 一条会话消息（`item_chat_message.xml` 的左右两种气泡）。
///
/// 企划星的 IM 走 pudding 的 mqtt 通道，消息体是 protobuf。这里只保留
/// 渲染需要的字段：谁发的、说了什么、什么时候。**不建模已读回执/撤回/图片**
/// ——这些没有真实通道时全是死字段。
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

/// 会话消息。
@freezed
abstract class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required String text,
    required DateTime sentAt,
    required bool fromMe,
    String? senderName,
  }) = _ChatMessage;

  /// 时间文案：`HH:mm`。
  String get timeLabel {
    final String hour = sentAt.hour.toString().padLeft(2, '0');
    final String minute = sentAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
