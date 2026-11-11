import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gift_card_providers.dart';
import '../../../l10n/l10n.dart';

/// 绑定礼品卡页。
///
/// 页面结构：
/// - 单输入框输入卡号 + 提交按钮。
/// - 提交时调 `POST v1/giftCards`（这里模拟）。
class AddGiftCardPage extends ConsumerStatefulWidget {
  const AddGiftCardPage({super.key});

  @override
  ConsumerState<AddGiftCardPage> createState() => _AddGiftCardPageState();
}

class _AddGiftCardPageState extends ConsumerState<AddGiftCardPage> {
  final _controller = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final newVal = _controller.text.trim().isNotEmpty;
      if (newVal != _canSubmit) {
        setState(() => _canSubmit = newVal);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final state = ref.watch(addGiftCardControllerProvider);

    // 监听状态变化，成功后自动返回
    ref.listen<AddGiftCardState>(addGiftCardControllerProvider, (prev, next) {
      if (next is AddGiftCardSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.giftCardProviders_65)),
        );
        // 延迟返回让用户看到提示
        final navigator = Navigator.of(context);
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          if (mounted) navigator.pop();
        });
      } else if (next is AddGiftCardError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.giftCardProviders_54)),
        );
      }
    });

    final isSubmitting = state is AddGiftCardSubmitting;

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: context.l10n.addGiftCardPage_67),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.l10n.addGiftCardPage_74,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: colors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: TextField(
                controller: _controller,
                enabled: !isSubmitting,
                decoration: InputDecoration(
                  hintText: context.l10n.addGiftCardPage_91,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: colors.textDisabled,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(fontSize: 15, color: colors.textPrimary),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: (_canSubmit && !isSubmitting)
                    ? () => ref
                          .read(addGiftCardControllerProvider.notifier)
                          .bind(_controller.text)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                  disabledBackgroundColor: colors.brand.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onBrand,
                        ),
                      )
                    : Text(
                        context.l10n.addGiftCardPage_135,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            // 说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.bgPage,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.addGiftCardPage_155,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.addGiftCardPage_164,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.8,
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
