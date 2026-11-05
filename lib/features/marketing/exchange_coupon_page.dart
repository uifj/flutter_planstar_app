import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'coupon_providers.dart';

/// 兑换码输入页。
///
/// ## 与 Android 的差异
///
/// - 企划星 `ExchangeCouponActivity` + `ExchangeCouponFragment` 是两件套
///   （Activity 是壳，Fragment 是内容）。这里合并为一个 Widget，
///   不需要 Fragment 层级——Flutter 的 Widget 组合就是 Fragment。
/// - 兑换成功后 Android 用 `setResult` + `finish` 回传券对象，
///   这里直接 `context.go('/coupons')` 返回券列表页（新券会在列表顶部）。
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
            content: Text('兑换成功：${next.result!.title}'),
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
      appBar: const AdaptiveAppBar(title: '兑换优惠券'),
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
                  Icon(
                    LucideIcons.info,
                    size: 18,
                    color: colors.brand,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '输入兑换码领取优惠券，兑换码由活动方发放',
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
              '兑换码',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: ref.read(exchangeControllerProvider.notifier).updateCode,
              decoration: InputDecoration(
                hintText: '请输入兑换码',
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
              style: TextStyle(
                fontSize: 16,
                color: colors.textPrimary,
              ),
            ),
            // 错误提示
            if (state.error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                state.error!,
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
                    ? () => ref.read(exchangeControllerProvider.notifier).submit()
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
                    : const Text(
                        '立即兑换',
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
