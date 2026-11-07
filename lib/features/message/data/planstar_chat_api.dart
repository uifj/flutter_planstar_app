import 'package:core/network.dart';
import 'package:core/result.dart';

import '../../../app/network/api_paths.dart';
import '../domain/chat_message.dart';
import '../domain/message_thread.dart';

/// 客服会话接口。
///
/// 抽成接口是为了让测试可以注入假实现，页面/控制器只依赖这个端口。
abstract interface class ChatApi {
  Future<Result<List<MessageThread>>> fetchThreads();

  Future<Result<List<ChatMessage>>> fetchMessages(
    String threadId, {
    int limit = 20,
    int? before,
  });

  Future<Result<ChatMessage>> sendMessage(String threadId, String text);

  Future<Result<void>> markRead(String threadId);
}

/// 真实客服会话接口（契约 7.4 / 8.11）。
final class PlanstarChatApi implements ChatApi {
  const PlanstarChatApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<Result<List<MessageThread>>> fetchThreads() {
    return _client.get<List<MessageThread>>(
      ApiPaths.chatThreads,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        return <MessageThread>[
          for (final Object? item in _asList(data))
            if (item is Map<Object?, Object?>)
              MessageThread.fromJson(
                item.map(
                  (Object? key, Object? value) =>
                      MapEntry<String, dynamic>('$key', value),
                ),
              ),
        ];
      },
    );
  }

  @override
  Future<Result<List<ChatMessage>>> fetchMessages(
    String threadId, {
    int limit = 20,
    int? before,
  }) {
    return _client.get<List<ChatMessage>>(
      ApiPaths.chatMessages(threadId),
      queryParameters: <String, dynamic>{
        'limit': limit,
        if (before != null && before > 0) 'before': before,
      },
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        return <ChatMessage>[
          for (final Object? item in _asList(data))
            if (item is Map<Object?, Object?>) _parseMessage(_asMap(item)),
        ];
      },
    );
  }

  @override
  Future<Result<ChatMessage>> sendMessage(String threadId, String text) {
    return _client.post<ChatMessage>(
      ApiPaths.chatMessages(threadId),
      data: <String, dynamic>{'text': text},
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => _parseMessage(_asMap(data)),
    );
  }

  @override
  Future<Result<void>> markRead(String threadId) {
    return _client.post<void>(
      ApiPaths.chatRead(threadId),
      envelope: const PassthroughEnvelope(),
      parser: (Object? _) {},
    );
  }

  static ChatMessage _parseMessage(Map<String, dynamic> json) {
    return ChatMessage(
      id: '${json['id'] ?? json['messageId'] ?? ''}',
      text: '${json['text'] ?? json['content'] ?? json['message'] ?? ''}',
      sentAt: _parseTime(
        json['sentAt'] ?? json['sentTime'] ?? json['createTime'],
      ),
      fromMe: json['fromMe'] == true || json['from_me'] == true,
      senderName: _asString(json['senderName'] ?? json['sender_name']),
    );
  }

  static DateTime _parseTime(Object? raw) {
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    if (raw is num) {
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    }
    return DateTime.now();
  }

  static String? _asString(Object? value) {
    if (value == null) return null;
    final String text = value.toString();
    return text.isEmpty ? null : text;
  }

  static List<Object?> _asList(Object? value) {
    if (value is List<Object?>) return value;
    if (value is Map<Object?, Object?>) {
      final Object? rows = value['list'] ?? value['items'] ?? value['data'];
      if (rows is List<Object?>) return rows;
    }
    return const <Object?>[];
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map<Object?, Object?>) {
      return value.map(
        (Object? key, Object? value) => MapEntry<String, dynamic>('$key', value),
      );
    }
    return const <String, dynamic>{};
  }
}
