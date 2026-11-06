import '../domain/chat_message.dart';

/// 演示会话内容。
///
/// 企划星的会话消息来自 IM 通道，仓库里没有离线快照。这里按"客服 / 群聊 /
/// 官方通知"三种典型场景各造一段，**内容与该会话在消息中心的摘要对得上**
/// （例如「企划星官方客服」的摘要提到退改签，会话里就有退改签的往来），
/// 否则点进去会看到与摘要无关的对话。
///
/// 没有对应会话时返回空列表——空会话是真实存在的一屏。
List<ChatMessage> buildDemoChat(String threadId, {DateTime? now}) {
  final DateTime reference = now ?? DateTime.now();

  ChatMessage msg({
    required String id,
    required String text,
    required Duration ago,
    bool fromMe = false,
    String? senderName,
  }) {
    return ChatMessage(
      id: id,
      text: text,
      sentAt: reference.subtract(ago),
      fromMe: fromMe,
      senderName: senderName,
    );
  }

  return switch (threadId) {
    't1' => <ChatMessage>[
      msg(
        id: 't1-1',
        text: '您好，这里是企划星客服，请问有什么可以帮您？',
        ago: const Duration(minutes: 46),
        senderName: '企划星官方客服',
      ),
      msg(
        id: 't1-2',
        text: '我买的《剧院魅影》11 月 8 日那场，临时有事去不了，能退吗？',
        ago: const Duration(minutes: 38),
        fromMe: true,
      ),
      msg(
        id: 't1-3',
        text: '可以帮您看一下。请问订单号是多少？',
        ago: const Duration(minutes: 36),
        senderName: '企划星官方客服',
      ),
      msg(
        id: 't1-4',
        text: 'PN20261108000001',
        ago: const Duration(minutes: 34),
        fromMe: true,
      ),
      msg(
        id: 't1-5',
        text:
            '您好，关于《剧院魅影》的退改签问题，我们已为您登记，'
            '演出前 7 天可申请退票，扣除 10% 手续费，3 个工作日内原路退回。',
        ago: const Duration(minutes: 12),
        senderName: '企划星官方客服',
      ),
    ],
    't2' => <ChatMessage>[
      msg(
        id: 't2-1',
        text: '您关注的「周杰伦上海站」即将开票，别忘了设置提醒。',
        ago: const Duration(hours: 2),
        senderName: '演出提醒',
      ),
      msg(
        id: 't2-2',
        text: '提醒已经开了，谢谢',
        ago: const Duration(hours: 1, minutes: 50),
        fromMe: true,
      ),
    ],
    't3' => <ChatMessage>[
      msg(
        id: 't3-1',
        text: '订单 PN20261108000001 已出票，可在「我的订单」查看电子票。',
        ago: const Duration(hours: 26),
        senderName: '订单助手',
      ),
    ],
    't5' => <ChatMessage>[
      msg(
        id: 't5-1',
        text: '上海站加场了，明天十点开抢。',
        ago: const Duration(days: 4, minutes: 30),
        senderName: '抢票小分队',
      ),
      msg(
        id: 't5-2',
        text: '收到，明天守着',
        ago: const Duration(days: 4, minutes: 18),
        fromMe: true,
      ),
      msg(
        id: 't5-3',
        text: '加场是周五场，票档和原来一样。',
        ago: const Duration(days: 4, minutes: 5),
        senderName: '抢票小分队',
      ),
    ],
    _ => const <ChatMessage>[],
  };
}
