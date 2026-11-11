import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui/ps_empty_state.dart';
import '../../../l10n/l10n.dart';
import '../application/group_buy_controller.dart';
import '../domain/group_buy.dart';
import 'group_buy_l10n.dart';

/// 组队支持列表页。
///
/// ## 为什么单独做一页
///
/// - 企划详情页没有组队支持入口，所以这里用独立列表页承载"我的组队"，
///   方便用户查看所有进行中的组队。
/// - 组队详情通过点击列表项进入 `/group-buy/:id`。
///
/// 页面只渲染 `GroupBuyListController` 暴露的 `GroupBuyView`。
class GroupBuyPage extends ConsumerWidget {
  const GroupBuyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<GroupBuyView>> listState = ref.watch(
      groupBuyListProvider,
    );

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: context.l10n.groupBuyPage_28),
      body: listState.when(
        data: (List<GroupBuyView> list) => list.isEmpty
            ? PsEmptyState(
                title: context.l10n.groupBuyPage_31,
                description: context.l10n.groupBuyPage_32,
                icon: LucideIcons.users,
              )
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: <Widget>[
                  for (final group in list)
                    _GroupBuyCard(
                      group: group,
                      onTap: () => context.push('/group-buy/${group.info.id}'),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}

/// 组队支持卡片。
class _GroupBuyCard extends StatelessWidget {
  const _GroupBuyCard({required this.group, required this.onTap});

  final GroupBuyView group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final statusColor = _statusColor(group.info.status, colors);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 顶部：标签 + 状态
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFD7700),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      group.tagLabelOf(context),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    group.statusLabelOf(context),
                    style: TextStyle(fontSize: 12, color: statusColor),
                  ),
                ],
              ),
            ),
            // 中部：标题 + 活动场地
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    group.info.showTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.info.venue} · ${group.info.eventTime}',
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                  const SizedBox(height: 10),
                  // 价格行
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        context.l10n.groupBuyPage_150,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textTertiary,
                        ),
                      ),
                      Text(
                        group.info.lowPrice.format(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFD7700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (group.hasDiscount) ...<Widget>[
                        Text(
                          group.info.originalPrice.format(),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textDisabled,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (group.discountLabelOf(context).isNotEmpty)
                          Text(
                            group.discountLabelOf(context),
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFFFD7700),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 进度条
                  if (group.info.status == GroupBuyStatus.grouping) ...<Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: group.progress.progress,
                              backgroundColor: colors.divider,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFD7700),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.groupBuyPage_210(
                            group.info.currentMembers,
                            group.info.succeedNum,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFD7700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      group.info.slogan,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ] else ...<Widget>[
                    Text(
                      group.info.slogan,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(GroupBuyStatus status, AppColors colors) {
    switch (status) {
      case GroupBuyStatus.grouping:
        return const Color(0xFFFD7700);
      case GroupBuyStatus.success:
        return colors.success;
      case GroupBuyStatus.failed:
        return colors.error;
      case GroupBuyStatus.cancelled:
        return colors.textTertiary;
    }
  }
}
