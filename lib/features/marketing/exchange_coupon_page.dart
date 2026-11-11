import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'coupon_providers.dart';
import '../../l10n/l10n.dart';

/// 兑换码输入页。
///
/// ## 设计取舍
///
/// - 页面壳与内容合并为一个 Widget，不再拆分层级。
/// - 兑换成功后先提示，再 `context.go('/coupons')` 返回券列表页，
///   不走"回传券对象给上一页"的路子。
class ExchangeCouponPage extends ConsumerWidget {
  const ExchangeCouponPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exchangeControllerProvider);
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    // 兑换成功 → 提示并返回券列表。
    ref.listen<ExchangeState>(exchangeControllerProvider, (previous, next) {
      if (next.result != null && (previous?.result == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.exchangeCouponPage_32(next.result!.title),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        // 延迟返回，让用户看到提示。
        Future<void>.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            ref.read(exchangeControllerProvider.notifier).reset();
            context.go('/coupons');
          }
        });
      }
    });

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: context.l10n.exchangeCouponPage_47),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 说明区
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.brandSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <Widget>[
                  Icon(LucideIcons.info, size: 18, color: colors.brand),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.exchangeCouponPage_71,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // 输入框
            Text(
              context.l10n.exchangeCouponPage_84,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: ref
                  .read(exchangeControllerProvider.notifier)
                  .updateCode,
              decoration: InputDecoration(
                hintText: context.l10n.exchangeCouponPage_95,
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
                  vertical: 14,
                ),
              ),
              style: TextStyle(fontSize: 16, color: colors.textPrimary),
            ),
            // 错误提示
            if (state.error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                context.l10n.couponProviders_124,
                style: TextStyle(fontSize: 12, color: colors.error),
              ),
            ],
            const SizedBox(height: 28),
            // 兑换按钮
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: state.canSubmit
                    ? () =>
                          ref.read(exchangeControllerProvider.notifier).submit()
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                  disabledBackgroundColor: colors.brand.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: state.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        context.l10n.exchangeCouponPage_155,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
