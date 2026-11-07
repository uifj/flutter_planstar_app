import 'dart:async';

import 'package:core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../../../shared/ui/ps_network_images.dart';
import '../../auth/application/auth_providers.dart';
import '../data/demo_chat.dart';
import '../data/planstar_chat_api.dart';
import '../data/planstar_message_api.dart';
import '../domain/chat_message.dart';
import '../domain/message_thread.dart';
import 'message_api_providers.dart';

/// 消息中心状态。
///
/// 真实模式下：`entries` 按 `v1/messages` 的 `msg_type` 聚合出三个系统入口的未读，
/// `threads` 来自 `GET /v1/chat/threads`。
/// `PS_USE_DEMO=true` 时仍是内存演示数据（会话 + 入口）。
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

/// 三个系统入口的固定顺序与文案（与 Android 头部三角色卡一致）。
const List<({String id, String title, String icon, String type})> _entrySpecs =
    <({String id, String title, String icon, String type})>[
      (id: 'activity', title: '活动通知', icon: 'campaign', type: '1'),
      (id: 'reply', title: '回复我的', icon: 'reply', type: '2'),
      (id: 'like', title: '赞和关注', icon: 'like', type: '3'),
    ];

/// 消息中心控制器。
class MessageCenterController extends AsyncNotifier<MessageCenterState> {
  @override
  Future<MessageCenterState> build() async {
    if (ref.watch(dataSourcePolicyProvider).isDemo) return _demoState();
    final PlanstarMessageApi api = ref.read(planstarMessageApiProvider);
    final ChatApi chatApi = ref.read(planstarChatApiProvider);

    // 三个系统入口的未读与客服会话并发加载。
    final List<Object?> loaded = await Future.wait<Object?>(<Future<Object?>>[
      _loadThreads(chatApi),
      for (final spec in _entrySpecs) _unreadOfType(api, spec.type),
    ]);
    final List<MessageThread> threads = loaded.first! as List<MessageThread>;
    final List<int> counts = <int>[
      for (final Object? value in loaded.skip(1)) value! as int,
    ];

    return MessageCenterState(
      entries: <SystemMessageEntry>[
        for (var i = 0; i < _entrySpecs.length; i++)
          SystemMessageEntry(
            id: _entrySpecs[i].id,
            title: _entrySpecs[i].title,
            icon: _entrySpecs[i].icon,
            unreadCount: counts[i],
          ),
      ],
      threads: threads,
    );
  }

  Future<List<MessageThread>> _loadThreads(ChatApi api) async {
    final result = await api.fetchThreads();
    return result.getOrElse((_) => const <MessageThread>[]);
  }

  /// 清空全部消息（企划星 `ib_message_clear`）。
  ///
  /// 演示模式清会话与未读，**不清**三个系统入口本身——它们是固定入口，
  /// 清掉之后用户就再也进不去活动通知/回复/赞了。
  /// 真实模式没有会话可清，入口未读以服务端为准，这里不动数据。
  void clearThreads() {
    final MessageCenterState? current = state.valueOrNull;
    if (current == null) return;
    if (ref.read(dataSourcePolicyProvider).isRemote) return;
    state = AsyncData(
      current.copyWith(
        threads: const <MessageThread>[],
        entries: <SystemMessageEntry>[
          for (final entry in current.entries)
            SystemMessageEntry(
              id: entry.id,
              title: entry.title,
              icon: entry.icon,
              unreadCount: 0,
            ),
        ],
      ),
    );
  }

  /// 读掉某个系统入口的未读。
  ///
  /// 本地先清零（乐观更新），真实模式再异步把该类型的通知逐条标已读；
  /// 失败不回滚——下次进入消息页重新拉取会以服务端为准。
  void markEntryRead(String id) {
    final MessageCenterState? current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        entries: <SystemMessageEntry>[
          for (final entry in current.entries)
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
      ),
    );
    if (ref.read(dataSourcePolicyProvider).isDemo) return;
    final spec = _entrySpecs.where((s) => s.id == id).firstOrNull;
    if (spec == null) return;
    unawaited(
      _markTypeReadOnServer(
        spec.type,
      ).whenComplete(() => ref.invalidate(messageUnreadProvider)),
    );
  }

  /// 读掉某个会话的未读：本地先清零，真实模式再调 `POST .../read`。
  void markThreadRead(String id) {
    final MessageCenterState? current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        threads: <MessageThread>[
          for (final thread in current.threads)
            if (thread.id == id) thread.copyWith(unreadCount: 0) else thread,
        ],
      ),
    );
    if (ref.read(dataSourcePolicyProvider).isDemo) return;
    unawaited(
      ref
          .read(planstarChatApiProvider)
          .markRead(id)
          .whenComplete(() => ref.invalidate(messageUnreadProvider)),
    );
  }

  Future<int> _unreadOfType(PlanstarMessageApi api, String type) async {
    final result = await api.fetchMessages(type: type, pageSize: 100);
    return result.fold(
      onSuccess: (List<MessageThread> rows) =>
          rows.fold<int>(0, (sum, row) => sum + row.unreadCount),
      onFailure: (_) => 0,
    );
  }

  Future<void> _markTypeReadOnServer(String type) async {
    final PlanstarMessageApi api = ref.read(planstarMessageApiProvider);
    final result = await api.fetchMessages(type: type, pageSize: 100);
    final List<MessageThread> rows = result.fold(
      onSuccess: (List<MessageThread> value) => value,
      onFailure: (_) => const <MessageThread>[],
    );
    for (final MessageThread row in rows) {
      if (row.unreadCount <= 0) continue;
      await api.markRead(row.id);
    }
  }

  MessageCenterState _demoState() {
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
          preview: '您好，关于《星海回声》企划的支持退款问题，我们已为您登记…',
          updatedAt: now.subtract(const Duration(minutes: 12)),
          unreadCount: 2,
          avatarFallbackUrl: PsImages.avatar('planstar-official'),
          isOfficial: true,
        ),
        MessageThread(
          id: 't2',
          title: '企划提醒',
          preview: '您关注的「夏日回声企划」即将开放支持，别忘了设置提醒',
          updatedAt: now.subtract(const Duration(hours: 2)),
          unreadCount: 1,
        ),
        MessageThread(
          id: 't3',
          title: '订单助手',
          preview: '订单 PN20261108000001 已生成支持凭证，可在「我的订单」查看',
          updatedAt: now.subtract(const Duration(hours: 26)),
          unreadCount: 0,
          isOfficial: true,
        ),
        MessageThread(
          id: 't4',
          title: '企划常驻民',
          preview: '你发的动态收到了 12 个赞',
          updatedAt: now.subtract(const Duration(days: 2)),
          unreadCount: 0,
        ),
        MessageThread(
          id: 't5',
          title: '支持小分队',
          preview: '新档位追加了，明天十点开放支持',
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
}

/// 消息中心。
final messageCenterProvider =
    AsyncNotifierProvider<MessageCenterController, MessageCenterState>(
      MessageCenterController.new,
    );

/// 底部 tab / 「我的」页的消息角标。
///
/// 真实模式走 `GET v1/messages/unreadCount`：只取一个整数，比为了角标去拉
/// 三页消息列表便宜，且角标与服务端未读总数严格一致。demo 模式沿用
/// [messageCenterProvider] 里演示会话的未读合计。
final messageUnreadProvider = FutureProvider<int>((ref) async {
  if (ref.watch(dataSourcePolicyProvider).isDemo) {
    return ref.watch(messageCenterProvider).valueOrNull?.totalUnread ?? 0;
  }
  // 未登录时该端点必返 401，游客页不必发这次请求。
  if (!ref.watch(authControllerProvider).isLoggedIn) return 0;
  final result = await ref.watch(planstarMessageApiProvider).fetchUnreadCount();
  return result.fold(
    onSuccess: (count) => count,
    onFailure: (_) => 0, // 角标失败不打扰用户
  );
});

/// 按 id 取会话。查不到返回 `null`（深链带脏 id 是正常情况）。
final messageThreadByIdProvider = Provider.family<MessageThread?, String>((
  ref,
  String id,
) {
  final List<MessageThread> threads =
      ref.watch(messageCenterProvider).valueOrNull?.threads ??
      const <MessageThread>[];
  for (final MessageThread thread in threads) {
    if (thread.id == id) return thread;
  }
  return null;
});

/// 某个会话的消息列表控制器。
///
/// 真实模式从 `GET /v1/chat/threads/{id}/messages` 加载；发送走
/// `POST .../messages`，采用乐观上屏 + 失败回滚。
/// 演示模式保留 [buildDemoChat] 的本地数据。
class ChatMessagesController
    extends FamilyAsyncNotifier<List<ChatMessage>, String> {
  @override
  Future<List<ChatMessage>> build(String threadId) async {
    if (ref.watch(dataSourcePolicyProvider).isDemo) {
      return buildDemoChat(threadId);
    }
    final Result<List<ChatMessage>> result = await ref
        .read(planstarChatApiProvider)
        .fetchMessages(threadId);
    return result.fold(
      onSuccess: (messages) => messages,
      onFailure: (failure) => throw failure,
    );
  }

  /// 发送消息。返回 `null` 表示成功，否则为错误文案（页面弹提示）。
  Future<String?> send(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final List<ChatMessage> snapshot =
        state.valueOrNull ?? const <ChatMessage>[];
    final ChatMessage optimistic = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      text: trimmed,
      sentAt: DateTime.now(),
      fromMe: true,
    );
    state = AsyncData(<ChatMessage>[...snapshot, optimistic]);

    if (ref.read(dataSourcePolicyProvider).isDemo) {
      // 演示分支：只做本地追加，不请求接口。
      return null;
    }

    final Result<ChatMessage> result = await ref
        .read(planstarChatApiProvider)
        .sendMessage(arg, trimmed);
    return result.fold(
      onSuccess: (ChatMessage saved) {
        final List<ChatMessage> current =
            state.valueOrNull ?? const <ChatMessage>[];
        state = AsyncData(<ChatMessage>[
          ...current.where((message) => message.id != optimistic.id),
          saved,
        ]);
        return null;
      },
      onFailure: (failure) {
        // 失败回滚到发送前的快照。
        state = AsyncData(snapshot);
        return failure.message.isEmpty ? '发送失败，请重试' : failure.message;
      },
    );
  }
}

/// 某个会话的消息列表。
final chatMessagesProvider =
    AsyncNotifierProvider.family<
      ChatMessagesController,
      List<ChatMessage>,
      String
    >(ChatMessagesController.new);
