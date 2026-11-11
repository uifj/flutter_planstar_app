import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui/ps_empty_state.dart';
import '../../../l10n/l10n.dart';
import '../application/proxy_buy_controller.dart';
import '../domain/proxy_buy.dart';
import 'proxy_buy_l10n.dart';

/// 代抢页面。
///
/// 遗留票务能力：与「企划支持平台」定位冲突，按 POSITIONING.md §10 待下线。
///
/// ## 页面结构
///
/// - 代抢流程合并为一个页面：顶部规则说明 + 截止选项 + 订单列表，
///   不再拆成选择与确认两步。
/// - 规则说明用原生展开文本，不加载 H5 规则页。
/// - 提交流程遵循"假功能不做"：表单是真实的，提交后 toast 说明"模拟提交"。
///
/// 页面只渲染 `ProxyBuyController` 暴露的视图状态，不取数、不算价。
class ProxyBuyPage extends ConsumerWidget {
  const ProxyBuyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ProxyBuyPageState> state = ref.watch(
      proxyBuyControllerProvider,
    );

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: context.l10n.proxyBuyPage_30),
      body: state.when(
        data: (ProxyBuyPageState page) => _content(context, page),
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

  Widget _content(BuildContext context, ProxyBuyPageState page) {
    return ListView(
      children: <Widget>[
        _RuleBanner(info: page.info),
        _DeadlineSelector(deadlines: page.info.deadlines),
        const SizedBox(height: 12),
        _SectionTitle(title: context.l10n.proxyBuyPage_36),
        if (page.orders.isEmpty)
          PsEmptyState(
            title: context.l10n.proxyBuyPage_39,
            description: context.l10n.proxyBuyPage_40,
            icon: LucideIcons.clipboardList,
          )
        else
          for (final order in page.orders) _OrderItem(order: order),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// 规则说明 Banner。
class _RuleBanner extends StatelessWidget {
  const _RuleBanner({required this.info});

  final ProxyBuyInfo info;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.warning.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(LucideIcons.info, size: 16, color: colors.warning),
              const SizedBox(width: 6),
              Text(
                context.l10n.proxyBuyPage_81,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.warning,
                ),
              ),
              if (info.compensationEnabled) ...<Widget>[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    context.l10n.proxyBuyPage_98,
                    style: TextStyle(fontSize: 10, color: colors.warning),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            info.ruleDesc,
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(
                context.l10n.proxyBuyPage_118,
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
              Text(
                context.l10n.proxyBuyPage_122(info.proxyBuyFee.format()),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.brand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 截止时间选择器。
class _DeadlineSelector extends StatefulWidget {
  const _DeadlineSelector({required this.deadlines});

  final List<ProxyBuyDeadline> deadlines;

  @override
  State<_DeadlineSelector> createState() => _DeadlineSelectorState();
}

class _DeadlineSelectorState extends State<_DeadlineSelector> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.proxyBuyPage_165,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (int i = 0; i < widget.deadlines.length; i++)
                _DeadlineChip(
                  label: widget.deadlines[i].desc,
                  selected: _selected == i,
                  onTap: () => setState(() => _selected = i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeadlineChip extends StatelessWidget {
  const _DeadlineChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? colors.brand : colors.border,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? colors.onBrand : colors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

/// 订单卡片。
class _OrderItem extends StatelessWidget {
  const _OrderItem({required this.order});

  final ProxyBuyOrder order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final statusColor = _statusColor(order.status, colors);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                order.showTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.statusLabelOf(context),
                  style: TextStyle(fontSize: 11, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(label: context.l10n.proxyBuyPage_303, value: order.venue),
          const SizedBox(height: 4),
          _InfoRow(
            label: context.l10n.proxyBuyPage_305,
            value: order.eventTime,
          ),
          const SizedBox(height: 4),
          _InfoRow(
            label: context.l10n.proxyBuyPage_307,
            value: order.deadline.desc,
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: colors.divider),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(
                context.l10n.proxyBuyPage_314(
                  order.quantity,
                  order.ticketPrice.format(),
                ),
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
              const Spacer(),
              Text(
                context.l10n.proxyBuyPage_322(order.proxyBuyFee.format()),
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Text(
                context.l10n.proxyBuyPage_334,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
              Text(
                order.totalAmount.format(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.brand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(ProxyBuyStatus status, AppColors colors) {
    switch (status) {
      case ProxyBuyStatus.success:
        return colors.success;
      case ProxyBuyStatus.inProgress:
        return colors.brand;
      case ProxyBuyStatus.pending:
        return colors.warning;
      case ProxyBuyStatus.failed:
        return colors.error;
      case ProxyBuyStatus.cancelled:
        return colors.textTertiary;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Row(
      children: <Widget>[
        SizedBox(
          width: 36,
          child: Text(
            '$label:',
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
