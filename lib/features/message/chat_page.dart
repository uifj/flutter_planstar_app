import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import 'application/message_providers.dart';
import 'domain/chat_message.dart';
import 'domain/message_thread.dart';
import '../../shared/ui/ps_network_images.dart';
import '../../l10n/message_localizations.dart';

/// 会话详情页（企划星 `UserMsgDetailActivity` + `ChatListFragment` 的会话内页）。
///
/// ## 结构
///
/// 顶部是会话对象（`AdaptiveAppBar` 的标题），中间是消息气泡列表，
/// 底部是输入栏。气泡左右由 [ChatMessage.fromMe] 决定，
/// 时间只在"与上一条间隔超过 5 分钟"时插入，避免每条都顶一个时间。
///
/// ## 与 Android 的差异
///
/// - **没有真实通道**：发送只是把消息追加到本地状态（`chatMessagesProvider`），
///   退出再进会回到演示数据。企划星走 mqtt，这里没有等价物。
///   所以输入栏上方有一行明确的说明——**假装能发消息而不告诉用户是假的，
///   比不给输入栏更糟**。
/// - 不做图片/语音/表情/撤回：这些都需要通道协议支持。
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// 相邻两条消息超过这个间隔就插一个时间条。
  static const Duration _timeGap = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    // 打开会话即读掉未读。放在首帧之后：`markThreadRead` 会改 provider 状态，
    // 在 initState 里同步改会触发"build 期间修改状态"的断言。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(messageCenterProvider.notifier).markThreadRead(widget.threadId);
      _scrollToBottom(animated: false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final MessageThread? thread =
        ref.watch(messageThreadByIdProvider(widget.threadId));
    final List<ChatMessage> messages =
        ref.watch(chatMessagesProvider(widget.threadId));

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(
        title: thread?.title ?? MessageLocalizations.of(context).chatPage_75,
        subtitle: thread?.isOfficial ?? false ? MessageLocalizations.of(context).chatPage_76 : null,
      ),
      body: thread == null
          ? PsEmptyState(
              title: MessageLocalizations.of(context).chatPage_80,
              description: MessageLocalizations.of(context).chatPage_81,
              icon: LucideIcons.messagesSquare,
              actionLabel: MessageLocalizations.of(context).chatPage_83,
              onAction: () => context.go('/message'),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: messages.isEmpty
                      ? PsEmptyState(
                          title: MessageLocalizations.of(context).chatPage_91,
                          description: MessageLocalizations.of(context).chatPage_92,
                          icon: LucideIcons.messageCircle,
                          compact: true,
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          itemCount: messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ChatMessage message = messages[index];
                            final bool showTime = index == 0 ||
                                message.sentAt
                                        .difference(messages[index - 1].sentAt)
                                        .abs() >
                                    _timeGap;
                            return Column(
                              children: <Widget>[
                                if (showTime) _TimeDivider(label: message.timeLabel),
                                _Bubble(message: message),
                              ],
                            );
                          },
                        ),
                ),
                _Composer(
                  controller: _controller,
                  onSend: _send,
                ),
              ],
            ),
    );
  }

  void _send() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;

    final List<ChatMessage> current =
        ref.read(chatMessagesProvider(widget.threadId));
    ref.read(chatMessagesProvider(widget.threadId).notifier).state =
        <ChatMessage>[
      ...current,
      ChatMessage(
        id: 'm-${DateTime.now().microsecondsSinceEpoch}',
        text: text,
        sentAt: DateTime.now(),
        fromMe: true,
      ),
    ];

    _controller.clear();
    setState(() {});
    _scrollToBottom(animated: true);
  }

  void _scrollToBottom({required bool animated}) {
    if (!_scrollController.hasClients) return;
    final double target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }
}

/// 时间分隔条。
class _TimeDivider extends StatelessWidget {
  const _TimeDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.textDisabled),
        ),
      ),
    );
  }
}

/// 一条消息气泡。
class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final bool mine = message.fromMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!mine) ...<Widget>[
            ClipOval(
              child: Image.network(
                PsImages.defaultAvatar,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 32,
                  height: 32,
                  color: colors.brandSubtle,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                if (!mine && message.senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3, left: 2),
                    child: Text(
                      message.senderName!,
                      style: TextStyle(fontSize: 11, color: colors.textTertiary),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.68,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: mine ? colors.brand : colors.bgCard,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(mine ? 12 : 3),
                      bottomRight: Radius.circular(mine ? 3 : 12),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: mine ? colors.onBrand : colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 输入栏。
class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border(top: BorderSide(color: colors.divider, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 明确告知这是本地演示，避免用户以为消息真的发出去了。
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                MessageLocalizations.of(context).chatPage_288,
                style: TextStyle(fontSize: 10, color: colors.textDisabled),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: colors.bgSubtle,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: TextField(
                        controller: controller,
                        textInputAction: TextInputAction.send,
                        style: TextStyle(fontSize: 14, color: colors.textPrimary),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: MessageLocalizations.of(context).chatPage_310,
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: colors.textTertiary,
                          ),
                        ),
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSend,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.brand,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      MessageLocalizations.of(context).chatPage_334,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onBrand,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
