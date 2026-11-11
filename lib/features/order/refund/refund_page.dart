import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:core/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'refund_providers.dart';
import 'refund_state.dart';
import '../order_l10n.dart';
import '../../../l10n/l10n.dart';

/// 退款申请页。
///
/// ## 刻意的设计选择
///
/// - 退款不用 WebView 加载 H5，
///   而是原生表单：原因选择 + 金额展示 + 提交。
/// - 退款金额与规则来自订单详情下发的字段；缺失时不自行计算。
/// - 提交走 `POST /v1/order/{id}/refund`，成功后展示服务端返回的可退金额。
class RefundPage extends ConsumerWidget {
  const RefundPage({
    super.key,
    required this.orderNumber,
    required this.orderAmount,
  });

  final String orderNumber;
  final Money orderAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arg = (orderNumber: orderNumber, orderAmount: orderAmount);
    final state = ref.watch(refundControllerProvider(arg));
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    // 提交成功 → toast + 返回。
    ref.listen<RefundState>(refundControllerProvider(arg), (previous, next) {
      if (next.status == RefundStatus.submitted &&
          previous?.status != RefundStatus.submitted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.refundPage_43),
            duration: Duration(seconds: 2),
          ),
        );
        Future<void>.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            ref.read(refundControllerProvider(arg).notifier).reset();
            context.go('/order/detail?number=$orderNumber');
          }
        });
      }
    });

    final refundAmount = state.refundableAmount;

    return PopScope(
      canPop: state.status != RefundStatus.submitting,
      child: AdaptiveScaffold(
        backgroundColor: colors.bgPage,
        appBar: AdaptiveAppBar(title: context.l10n.refundPage_62),
        body: state.status == RefundStatus.submitted
            ? _SuccessView(
                amount: refundAmount ?? orderAmount,
                expectedArrivalDays: state.expectedArrivalDays,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: <Widget>[
                  _RefundAmountCard(
                    orderAmount: orderAmount,
                    refundAmount: refundAmount,
                  ),
                  if (state.ruleMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        state.ruleMessage!,
                        style: TextStyle(fontSize: 12, color: colors.warning),
                      ),
                    ),
                  const SizedBox(height: 12),
                  _ReasonSection(
                    selectedReason: state.reason,
                    onSelected: ref
                        .read(refundControllerProvider(arg).notifier)
                        .selectReason,
                  ),
                  if (state.reason == RefundReason.other)
                    _CustomReasonInput(
                      value: state.customReason,
                      onChanged: ref
                          .read(refundControllerProvider(arg).notifier)
                          .updateCustomReason,
                    ),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(fontSize: 12, color: colors.error),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _SubmitButton(
                    label: switch (state.status) {
                      RefundStatus.submitting => context.l10n.refundPage_97,
                      RefundStatus.submitted => context.l10n.refundPage_98,
                      _ => context.l10n.refundPage_99,
                    },
                    enabled: state.canSubmit,
                    onTap: () => ref
                        .read(refundControllerProvider(arg).notifier)
                        .submit(),
                  ),
                  const SizedBox(height: 16),
                  _RefundPolicy(),
                ],
              ),
      ),
    );
  }
}

/// 退款金额卡片。
class _RefundAmountCard extends StatelessWidget {
  const _RefundAmountCard({
    required this.orderAmount,
    required this.refundAmount,
  });

  final Money orderAmount;
  final Money? refundAmount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.refundPage_138,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                context.l10n.refundPage_150,
                style: TextStyle(fontSize: 13, color: colors.textTertiary),
              ),
              Text(
                orderAmount.format(),
                style: TextStyle(fontSize: 13, color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                context.l10n.refundPage_164,
                style: TextStyle(fontSize: 13, color: colors.textTertiary),
              ),
              Text(
                refundAmount?.format() ?? '--',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.price,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 退款原因选择。
class _ReasonSection extends StatelessWidget {
  const _ReasonSection({
    required this.selectedReason,
    required this.onSelected,
  });

  final RefundReason selectedReason;
  final void Function(RefundReason) onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.refundPage_207,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (final reason in RefundReason.values)
            _ReasonRadioRow(
              reason: reason,
              isSelected: reason == selectedReason,
              onTap: () => onSelected(reason),
            ),
        ],
      ),
    );
  }
}

/// 自定义原因输入框。
class _CustomReasonInput extends StatelessWidget {
  const _CustomReasonInput({required this.value, required this.onChanged});

  final String value;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        onChanged: onChanged,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: context.l10n.refundPage_244,
          hintStyle: TextStyle(color: colors.textDisabled),
          filled: true,
          fillColor: colors.bgCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.brand, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        style: TextStyle(fontSize: 14, color: colors.textPrimary),
      ),
    );
  }
}

/// 提交按钮。
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        style: FilledButton.styleFrom(
          backgroundColor: colors.price,
          disabledBackgroundColor: colors.price.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// 退款说明。
class _RefundPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(LucideIcons.info, size: 14, color: colors.warning),
              const SizedBox(width: 4),
              Text(
                context.l10n.refundPage_331,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.refundPage_342,
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 提交成功视图。
class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.amount, this.expectedArrivalDays});

  final Money amount;
  final int? expectedArrivalDays;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(LucideIcons.circleCheck, size: 64, color: colors.success),
            const SizedBox(height: 16),
            Text(
              context.l10n.refundPage_382,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.refundPage_391(amount.format()),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textTertiary),
            ),
            if (expectedArrivalDays != null && expectedArrivalDays! > 0) ...[
              const SizedBox(height: 6),
              Text(
                '预计 $expectedArrivalDays 天内到账',
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/order'),
              style: FilledButton.styleFrom(backgroundColor: colors.brand),
              child: Text(context.l10n.refundPage_404),
            ),
          ],
        ),
      ),
    );
  }
}

/// 退款原因单选行。
///
/// 不用 `RadioListTile`：Flutter 3.41 起 `groupValue`/`onChanged` 被废弃，
/// 改用 `RadioGroup` 祖先组件。这里用简单的自定义行避免引入新 API，
/// 保持与项目其他页面（`PsCell` 风格）一致。
class _ReasonRadioRow extends StatelessWidget {
  const _ReasonRadioRow({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  final RefundReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            Icon(
              isSelected ? LucideIcons.circleDot : LucideIcons.circle,
              size: 18,
              color: isSelected ? colors.brand : colors.textDisabled,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    reason.labelOf(context),
                    style: TextStyle(fontSize: 14, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reason.descriptionOf(context),
                    style: TextStyle(fontSize: 11, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
