import 'package:core/network.dart';
import 'package:core/result.dart';

import '../../../app/network/api_paths.dart';
import '../domain/message_thread.dart';

/// 消息中心 API。
///
/// ## 端点
///
/// | 用途 | 方法 | 路径 |
/// |---|---|---|
/// | 消息列表 | GET | `v1/messages` |
/// | 标记已读 | POST | `v1/messages/read` |
/// | 未读计数 | GET | `v1/messages/unreadCount` |
///
/// 删除消息（`DELETE v1/messages/{id}`）后端未实现，不封装。
///
/// `MessagesService` 原方法签名是 `fetchMessages(type, pageIndex, pageSize)`，
/// 对应 `GET v1/messages?type=&pageIndex=&pageSize=`。
final class PlanstarMessageApi {
  PlanstarMessageApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  /// 消息列表。
  ///
  /// [type] 是消息类型过滤：'1'=系统通知, '2'=回复我的, '3'=赞和关注。
  Future<Result<List<MessageThread>>> fetchMessages({
    String? type,
    int pageIndex = 1,
    int pageSize = 20,
  }) {
    return _client.get<List<MessageThread>>(
      ApiPaths.messages,
      queryParameters: <String, dynamic>{
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        'type': ?type,
      },
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is Map<String, dynamic>) {
          final inner = data['data'];
          if (inner is List) {
            return inner
                .whereType<Map<String, dynamic>>()
                .map(MessageThread.fromJson)
                .toList(growable: false);
          }
        }
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(MessageThread.fromJson)
              .toList(growable: false);
        }
        return const <MessageThread>[];
      },
    );
  }

  /// 未读消息计数。
  Future<Result<int>> fetchUnreadCount() {
    return _client.get<int>(
      ApiPaths.messagesUnreadCount,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is int) return data;
        if (data is Map<String, dynamic>) {
          return data['count'] as int? ?? data['unreadCount'] as int? ?? 0;
        }
        return 0;
      },
    );
  }

  /// 标记消息已读。
  Future<Result<void>> markRead(String messageId) {
    return _client.post<void>(
      ApiPaths.messagesRead,
      data: <String, dynamic>{'messageId': messageId},
      envelope: const PassthroughEnvelope(),
      parser: (_) {},
    );
  }
}
