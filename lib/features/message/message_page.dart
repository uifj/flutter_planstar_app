import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_badge.dart';
import '../../shared/ui/ps_empty_state.dart';
import '../../shared/ui/ps_floating_tab_bar.dart';
import 'application/message_providers.dart';
import 'domain/message_thread.dart';
import '../../l10n/message_localizations.dart';
import '../../l10n/app_localizations.dart';

/// 消息 Tab（`layout_user_message.xml`）。
///
/// ## 结构
///
/// - 50dp 顶栏：标题 16dp 居中、右侧「清空」按钮 50×50；
/// - 1dp 分隔线；
/// - 灰色背景上依次是：113dp 的三角色卡（活动通知 / 回复我的 / 赞和关注，
///   56dp 图标 + 13dp 文案 + 右上 18dp 未读角标）→ 15dp 间隔 →
///   白色圆角 20dp（仅上圆角）的会话列表（80dp 行、48dp 方头像、
///   16dp 标题、11dp 右侧时间、14dp `text_3` 单行摘要、1dp 分隔线）。
///
/// ## 与 Android 的差异
///
/// 原页是独立 Activity，顶栏有返回箭头。这里是底部 tab 的一级页面，
/// 返回箭头没有去处，所以去掉了——保留它会是"点了没反应"的死按钮。
class MessagePage extends ConsumerWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final state = ref.watch(messageCenterProvider);
    final controller = ref.read(messageCenterProvider.notifier);
    final now = DateTime.now();

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      body: Column(
        children: <Widget>[
          _MessageTopBar(
            onClear: state.isEmpty
                ? null
                : () => _confirmClear(context, controller.clearThreads),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                top: 15,
                bottom: PsFloatingTabBar.bottomClearance(context),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: _SystemEntryCard(
                    entries: state.entries,
                    onTap: (entry) {
                      controller.markEntryRead(entry.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(MessageLocalizations.of(context).messagePage_62(entry.title))),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                if (state.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: PsEmptyState(
                      title: MessageLocalizations.of(context).messagePage_72,
                      description: MessageLocalizations.of(context).messagePage_73,
                      icon: LucideIcons.messagesSquare,
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: colors.bgCard,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: <Widget>[
                        for (var i = 0; i < state.threads.length; i++)
                          _ThreadRow(
                            thread: state.threads[i],
                            now: now,
                            showDivider: i != state.threads.length - 1,
                            onTap: () {
                              // 先在列表侧把未读清掉，再进会话页：会话页
                              // 也会调一次 `markThreadRead`（它可能被深链
                              // 直接打开，没经过列表），两次都幂等。
                              controller.markThreadRead(state.threads[i].id);
                              context.push(
                                '/message/thread/${state.threads[i].id}',
                              );
                            },
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    VoidCallback onConfirm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(MessageLocalizations.of(context).messagePage_122),
        content: Text(MessageLocalizations.of(context).messagePage_123),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(MessageLocalizations.of(context).messagePage_131),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onConfirm();
  }
}

/// 顶栏（50dp）。
class _MessageTopBar extends StatelessWidget {
  const _MessageTopBar({this.onClear});

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Text(
                    MessageLocalizations.of(context).messagePage_160,
                    style: TextStyle(fontSize: 16, color: colors.textPrimary),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClear,
                    child: SizedBox(
                      width: 50,
                      child: Center(
                        child: Icon(
                          LucideIcons.trash2,
                          size: 20,
                          color: onClear == null
                              ? colors.textDisabled
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: colors.divider),
        ],
      ),
    );
  }
}

/// 三角色卡（`layout_user_message_header.xml`，113dp）。
class _SystemEntryCard extends StatelessWidget {
  const _SystemEntryCard({required this.entries, required this.onTap});

  final List<SystemMessageEntry> entries;
  final void Function(SystemMessageEntry entry) onTap;

  /// 领域层的图标标识 → Material 图标。
  ///
  /// 企划星用的是 `vector_notice_campaign` / `vector_notice_reply` /
  /// `vector_notice_like` 三个 vector drawable，未随资源迁移，这里按语义替换。
  static const Map<String, IconData> _icons = <String, IconData>{
    'campaign': LucideIcons.megaphone,
    'reply': LucideIcons.messageCircle,
    'like': LucideIcons.heart,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      height: 113,
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14F2F4FA),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          for (final entry in entries)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(entry),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    PsBadgeAnchor(
                      count: entry.unreadCount,
                      offset: const Offset(14, -4),
                      child: Icon(
                        _icons[entry.icon] ?? LucideIcons.bell,
                        size: 56,
                        color: colors.brand,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.title,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.1,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 会话行（`item_user_message.xml`，80dp）。
class _ThreadRow extends StatelessWidget {
  const _ThreadRow({
    required this.thread,
    required this.now,
    required this.showDivider,
    required this.onTap,
  });

  final MessageThread thread;
  final DateTime now;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 80,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: <Widget>[
                  PsBadgeAnchor(
                    count: thread.unreadCount,
                    offset: const Offset(9, -9),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: thread.avatarFallbackUrl == null
                          ? Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              color: colors.brandSubtle,
                              child: Text(
                                thread.title.characters.first,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: colors.brand,
                                ),
                              ),
                            )
                          : Image.network(
                              thread.avatarFallbackUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 48,
                                height: 48,
                                color: colors.brandSubtle,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                thread.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            if (thread.isOfficial) ...<Widget>[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.brandSubtle,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  MessageLocalizations.of(context).messagePage_358,
                                  style: TextStyle(
                                    fontSize: 9,
                                    height: 1.1,
                                    color: colors.brand,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          thread.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              top: 18,
              child: Text(
                thread.timeLabel(now),
                style: TextStyle(fontSize: 11, color: colors.textTertiary),
              ),
            ),
            if (showDivider)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(height: 1, color: colors.divider),
              ),
          ],
        ),
      ),
    );
  }
}
