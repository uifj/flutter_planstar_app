import 'package:core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planstar/app/network/data_source_policy.dart';
import 'package:planstar/app/network/network_providers.dart';
import 'package:planstar/features/message/application/message_api_providers.dart';
import 'package:planstar/features/message/application/message_providers.dart';
import 'package:planstar/features/message/data/planstar_chat_api.dart';
import 'package:planstar/features/message/domain/chat_message.dart';
import 'package:planstar/features/message/domain/message_thread.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingChatApi implements ChatApi {
  int sendCalls = 0;

  @override
  Future<Result<List<MessageThread>>> fetchThreads() async =>
      const Success<List<MessageThread>>(<MessageThread>[]);

  @override
  Future<Result<List<ChatMessage>>> fetchMessages(
    String threadId, {
    int limit = 20,
    int? before,
  }) async {
    return Success<List<ChatMessage>>(<ChatMessage>[
      ChatMessage(
        id: 'm1',
        text: '历史消息',
        sentAt: DateTime(2026, 11, 7, 9),
        fromMe: false,
      ),
    ]);
  }

  @override
  Future<Result<ChatMessage>> sendMessage(
    String threadId,
    String text,
  ) async {
    sendCalls++;
    return const Fail<ChatMessage>(
      Failure(
        code: 'CHAT_SEND_FAILED',
        message: '消息发送失败',
        type: FailureType.network,
      ),
    );
  }

  @override
  Future<Result<void>> markRead(String threadId) async =>
      const Success<void>(null);
}

void main() {
  test('聊天发送失败后乐观消息回滚', () async {
    final api = _FailingChatApi();
    final container = ProviderContainer(
      overrides: <Override>[
        dataSourcePolicyProvider.overrideWithValue(
          const DataSourcePolicy(isDemo: false),
        ),
        planstarChatApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    final provider = chatMessagesProvider('thread-1');
    final List<ChatMessage> initial = await container.read(provider.future);
    expect(initial, hasLength(1));

    final error = await container.read(provider.notifier).send('新消息');
    expect(error, '消息发送失败');
    expect(api.sendCalls, 1);

    final List<ChatMessage> after = container.read(provider).requireValue;
    expect(after, hasLength(1));
    expect(after.single.text, '历史消息');
    expect(after.any((message) => message.text == '新消息'), isFalse);
  });
}
