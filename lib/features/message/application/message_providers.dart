import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_chat.dart';
import '../domain/chat_message.dart';
import '../domain/message_thread.dart';
import '../../../shared/ui/ps_network_images.dart';

/// 消息中心状态。
///
/// 企划星的消息走 IM 通道（pudding 的 mqtt），未读数由服务端推送。
/// 这里是一个内存实现：会话列表 + 三个系统入口，清空操作只改本地状态。
/// 接真实通道时把 `build()` 换成订阅 `imClientProvider` 的流即可，
/// 页面读的接口不变。
final class MessageCenterState {
  const MessageCenterState({required this.entries, required this.threads});

  final List<SystemMessageEntry> entries;
  final List<MessageThread> threads;

  /// 全部未读（用于底部 tab 角标）。
  int get totalUnread =>
      entries.fold<int>(0, (sum, entry) => sum + entry.unreadCount) +
      threads.fold<int>(0, (sum, thread) => sum + thread.unreadCount);

  bool get isEmpty => threads.isEmpty;

  MessageCenterState copyWith({
    List<SystemMessageEntry>? entries,
    List<MessageThread>? threads,
  }) {
    return MessageCenterState(
      entries: entries ?? this.entries,
      threads: threads ?? this.threads,
    );
  }
}

/// 消息中心控制器。
class MessageCenterController extends Notifier<MessageCenterState> {
  @override
  MessageCenterState build() {
    final now = DateTime.now();
    return MessageCenterState(
      entries: const <SystemMessageEntry>[
        SystemMessageEntry(
          id: 'activity',
          title: '活动通知',
          icon: 'campaign',
          unreadCount: 2,
        ),
        SystemMessageEntry(
          id: 'reply',
          title: '回复我的',
          icon: 'reply',
          unreadCount: 5,
        ),
        SystemMessageEntry(
          id: 'like',
          title: '赞和关注',
          icon: 'like',
          unreadCount: 0,
        ),
      ],
      threads: <MessageThread>[
        MessageThread(
          id: 't1',
          title: '企划星官方客服',
          preview: '您好，关于《剧院魅影》的退改签问题，我们已为您登记…',
          updatedAt: now.subtract(const Duration(minutes: 12)),
          unreadCount: 2,
          avatarFallbackUrl: PsImages.avatar('planstar-official'),
          isOfficial: true,
        ),
        MessageThread(
          id: 't2',
          title: '演出提醒',
          preview: '您关注的「周杰伦上海站」即将开票，别忘了设置提醒',
          updatedAt: now.subtract(const Duration(hours: 2)),
          unreadCount: 1,
        ),
        MessageThread(
          id: 't3',
          title: '订单助手',
          preview: '订单 PN20261108000001 已出票，可在「我的订单」查看电子票',
          updatedAt: now.subtract(const Duration(hours: 26)),
          unreadCount: 0,
          isOfficial: true,
        ),
        MessageThread(
          id: 't4',
          title: '剧院常驻民',
          preview: '你发的动态收到了 12 个赞',
          updatedAt: now.subtract(const Duration(days: 2)),
          unreadCount: 0,
        ),
        MessageThread(
          id: 't5',
          title: '抢票小分队',
          preview: '上海站加场了，明天十点开抢',
          updatedAt: now.subtract(const Duration(days: 4)),
          unreadCount: 0,
        ),
        MessageThread(
          id: 't6',
          title: '企划星福利官',
          preview: '您有一张 50 元无门槛券即将过期',
          updatedAt: now.subtract(const Duration(days: 9)),
          unreadCount: 0,
        ),
      ],
    );
  }

  /// 清空全部消息（企划星 `ib_message_clear`）。
  ///
  /// 只清会话与未读，**不清**三个系统入口——它们是固定入口，
  /// 清掉之后用户就再也进不去活动通知/回复/赞了。
  void clearThreads() {
    state = state.copyWith(
      threads: const <MessageThread>[],
      entries: <SystemMessageEntry>[
        for (final entry in state.entries)
          SystemMessageEntry(
            id: entry.id,
            title: entry.title,
            icon: entry.icon,
            unreadCount: 0,
          ),
      ],
    );
  }

  /// 读掉某个系统入口的未读。
  void markEntryRead(String id) {
    state = state.copyWith(
      entries: <SystemMessageEntry>[
        for (final entry in state.entries)
          if (entry.id == id)
            SystemMessageEntry(
              id: entry.id,
              title: entry.title,
              icon: entry.icon,
              unreadCount: 0,
            )
          else
            entry,
      ],
    );
  }

  /// 读掉某个会话的未读。
  void markThreadRead(String id) {
    state = state.copyWith(
      threads: <MessageThread>[
        for (final thread in state.threads)
          if (thread.id == id)
            MessageThread(
              id: thread.id,
              title: thread.title,
              preview: thread.preview,
              updatedAt: thread.updatedAt,
              avatarFallbackUrl: thread.avatarFallbackUrl,
              isOfficial: thread.isOfficial,
            )
          else
            thread,
      ],
    );
  }
}

/// 消息中心。
final messageCenterProvider =
    NotifierProvider<MessageCenterController, MessageCenterState>(
      MessageCenterController.new,
    );

/// 底部 tab 的未读角标数。
final messageUnreadProvider = Provider<int>(
  (ref) => ref.watch(messageCenterProvider).totalUnread,
);

/// 按 id 取会话。查不到返回 `null`（深链带脏 id 是正常情况）。
final messageThreadByIdProvider = Provider.family<MessageThread?, String>((
  ref,
  String id,
) {
  for (final MessageThread thread in ref.watch(messageCenterProvider).threads) {
    if (thread.id == id) return thread;
  }
  return null;
});

/// 某个会话的消息列表。
///
/// ## 为什么是 `StateProvider.family`
///
/// 发消息只是"往列表尾部追加"，没有别的状态要维护，不值得为它建一个
/// `Notifier` 子类。接真实通道时换成 `StreamProvider.family` 订阅 mqtt
/// 推送即可——页面读的仍然是 `List<ChatMessage>`，结构不变。
///
/// `family` 的键是会话 id：每个会话一份独立状态，切走再回来消息还在。
final chatMessagesProvider = StateProvider.family<List<ChatMessage>, String>((
  ref,
  String threadId,
) {
  return buildDemoChat(threadId);
});
