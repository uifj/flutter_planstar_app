import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:core/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'refund_providers.dart';
import 'refund_state.dart';
import '../../../l10n/order_localizations.dart';

/// 退款申请页。
///
/// ## 与 Android 的差异
///
/// - 企划星的退款是 WebView（`OrderRefundWebActivity` 加载 H5）。
///   这里做原生表单：原因选择 + 金额展示 + 提交。
/// - 遵循「假功能不做」约定：表单真实可用，提交调用模拟 API，
///   成功后 toast 提示并返回订单详情。等 `PUT v1/order/{orderId}/refund`
///   接上后替换 `RefundController.submit()` 内部即可。
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
            content: Text(OrderLocalizations.of(context).refundPage_43),
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

    final refundAmount = orderAmount; // 简化：全额退（实际按状态算）

    return PopScope(
      canPop: state.status != RefundStatus.submitting,
      child: AdaptiveScaffold(
        backgroundColor: colors.bgPage,
        appBar: AdaptiveAppBar(title: OrderLocalizations.of(context).refundPage_62),
        body: state.status == RefundStatus.submitted
            ? _SuccessView(amount: refundAmount)
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: <Widget>[
                  _RefundAmountCard(
                    orderAmount: orderAmount,
                    refundAmount: refundAmount,
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
                      RefundStatus.submitting => OrderLocalizations.of(context).refundPage_97,
                      RefundStatus.submitted => OrderLocalizations.of(context).refundPage_98,
                      _ => OrderLocalizations.of(context).refundPage_99,
                    },
                    enabled: state.canSubmit,
                    onTap: () =>
                        ref.read(refundControllerProvider(arg).notifier).submit(),
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
  final Money refundAmount;

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
            OrderLocalizations.of(context).refundPage_138,
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
                OrderLocalizations.of(context).refundPage_150,
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
                OrderLocalizations.of(context).refundPage_164,
                style: TextStyle(fontSize: 13, color: colors.textTertiary),
              ),
              Text(
                refundAmount.format(),
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
            OrderLocalizations.of(context).refundPage_207,
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
          hintText: OrderLocalizations.of(context).refundPage_244,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
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
                OrderLocalizations.of(context).refundPage_331,
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
            OrderLocalizations.of(context).refundPage_342,
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
  const _SuccessView({required this.amount});

  final Money amount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              LucideIcons.circleCheck,
              size: 64,
              color: colors.success,
            ),
            const SizedBox(height: 16),
            Text(
              OrderLocalizations.of(context).refundPage_382,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              OrderLocalizations.of(context).refundPage_391(amount.format()),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/order'),
              style: FilledButton.styleFrom(
                backgroundColor: colors.brand,
              ),
              child: Text(OrderLocalizations.of(context).refundPage_404),
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
              isSelected
                  ? LucideIcons.circleDot
                  : LucideIcons.circle,
              size: 18,
              color: isSelected ? colors.brand : colors.textDisabled,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    reason.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reason.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textTertiary,
                    ),
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
