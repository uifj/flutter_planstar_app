import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'group_buy.dart';
import 'group_buy_providers.dart';
import '../../l10n/l10n.dart';

/// 拼团详情页。
///
/// ## 与 Android 的差异
///
/// - 企划星的拼团详情是 WebView（`groupBooking.html?pinTuanId={id}`），
///   这里做原生页面：顶部演出信息 + 成员头像列表 + 参团按钮。
/// - 参团遵循"假功能不做"：按钮是真实的，提交后 toast 说明"模拟参团"。
/// - 规则页面（Android WebView 加载 `pinTuanRule.html`）用展开文本替代。
class GroupBuyDetailPage extends ConsumerWidget {
  const GroupBuyDetailPage({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupBuyByIdProvider(groupId));
    final joinState = ref.watch(joinGroupControllerProvider);
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    // 监听参团结果
    ref.listen<JoinGroupState>(joinGroupControllerProvider, (prev, next) {
      if (next is JoinGroupSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.groupBuyProviders_59)),
        );
        ref.read(joinGroupControllerProvider.notifier).reset();
      } else if (next is JoinGroupError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
        ref.read(joinGroupControllerProvider.notifier).reset();
      }
    });

    if (group == null) {
      return AdaptiveScaffold(
        appBar: AdaptiveAppBar(title: context.l10n.groupBuyDetailPage_46),
        body: Center(
          child: Text(
            context.l10n.groupBuyDetailPage_49,
            style: TextStyle(fontSize: 14, color: colors.textTertiary),
          ),
        ),
      );
    }

    final isJoining = joinState is JoinGroupSubmitting;
    final canJoin = group.status == GroupBuyStatus.grouping && !group.isFull;

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: context.l10n.groupBuyDetailPage_60),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                _ShowInfoCard(group: group),
                _ProgressCard(group: group),
                _MembersCard(group: group),
                _RuleCard(),
                const SizedBox(height: 80),
              ],
            ),
          ),
          // 底部参团按钮
          if (canJoin)
            _BottomBar(
              group: group,
              isJoining: isJoining,
              onJoin: () =>
                  ref.read(joinGroupControllerProvider.notifier).join(groupId),
            ),
        ],
      ),
    );
  }
}

/// 演出信息卡。
class _ShowInfoCard extends StatelessWidget {
  const _ShowInfoCard({required this.group});

  final GroupBuyInfo group;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // 海报占位
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.bgPage,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  LucideIcons.image,
                  size: 24,
                  color: colors.textDisabled,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      group.showTitle,
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
                      group.venue,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.eventTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 价格
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBD9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  context.l10n.groupBuyDetailPage_172,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                Text(
                  group.lowPrice.format(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB44E02),
                  ),
                ),
                const SizedBox(width: 8),
                if (group.originalPrice.minorUnits >
                    group.lowPrice.minorUnits) ...<Widget>[
                  Text(
                    group.originalPrice.format(),
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textDisabled,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 6),
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
                      context.l10n.groupBuyDetailPage_208(
                        group.savedAmount.format(withSymbol: false),
                      ),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 进度卡。
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.group});

  final GroupBuyInfo group;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                context.l10n.groupBuyDetailPage_249(group.succeedNum),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              if (group.status == GroupBuyStatus.grouping)
                Text(
                  group.isFull
                      ? context.l10n.groupBuyDetailPage_259
                      : context.l10n.groupBuyDetailPage_259_2(group.remaining),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFD7700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: group.progress,
              backgroundColor: colors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFD7700),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          if (group.status == GroupBuyStatus.grouping && !group.isExpired)
            Text(
              context.l10n.groupBuyDetailPage_283(group.remainingHours),
              style: TextStyle(fontSize: 12, color: colors.textTertiary),
            ),
        ],
      ),
    );
  }
}

/// 成员列表卡。
class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.group});

  final GroupBuyInfo group;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.groupBuyDetailPage_316(
              group.currentMembers,
              group.succeedNum,
            ),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              for (final member in group.members) _MemberAvatar(member: member),
              // 空位占位
              for (int i = 0; i < group.remaining; i++) _EmptySlot(),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member});

  final GroupBuyMember member;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.brand.withValues(alpha: 0.15),
              ),
              child: member.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        member.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          LucideIcons.user,
                          size: 22,
                          color: colors.brand,
                        ),
                      ),
                    )
                  : Icon(LucideIcons.user, size: 22, color: colors.brand),
            ),
            if (member.isLeader)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFD7700),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    context.l10n.groupBuyDetailPage_394,
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          member.nickname,
          style: TextStyle(fontSize: 11, color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _EmptySlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Column(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.border,
              width: 1,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: Icon(LucideIcons.plus, size: 18, color: colors.textDisabled),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.groupBuyDetailPage_444,
          style: TextStyle(fontSize: 11, color: colors.textDisabled),
        ),
      ],
    );
  }
}

/// 规则说明卡。
class _RuleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.groupBuyDetailPage_472,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.groupBuyDetailPage_481,
            style: TextStyle(
              fontSize: 12,
              height: 1.7,
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部参团按钮。
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.group,
    required this.isJoining,
    required this.onJoin,
  });

  final GroupBuyInfo group;
  final bool isJoining;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: colors.bgCard,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.groupBuyDetailPage_533,
                  style: TextStyle(fontSize: 11, color: colors.textTertiary),
                ),
                Text(
                  group.lowPrice.format(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFD7700),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: isJoining ? null : onJoin,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFD7700),
                disabledBackgroundColor: const Color(
                  0xFFFD7700,
                ).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32),
              ),
              child: isJoining
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.l10n.groupBuyDetailPage_573,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
