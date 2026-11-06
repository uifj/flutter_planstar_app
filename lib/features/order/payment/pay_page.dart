import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:core/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui/ps_price.dart';
import '../domain/domain.dart';
import '../order_l10n.dart';
import 'pay_info.dart';
import 'pay_providers.dart';
import '../../../l10n/l10n.dart';

/// 支付页（企划星 `PayActivity`）。
///
/// ## 结构
///
/// 顶部倒计时条 → 订单摘要卡 → 支付渠道列表 → 底部确认支付按钮。
/// 支付成功后跳 `/order/pay-success`，失败后留在本页可重试。
///
/// ## 与 Android 的差异
///
/// - **不做真实 SDK 调用**：企划星调微信 / 支付宝 / 银行 SDK，
///   这里只做状态机演示（idle → requesting → paying → success）。
///   理由：SDK 集成需要 fluwx / tobias + 平台配置，演示项目不引入。
///   状态机本身完整，接 SDK 时替换 `_invokeSdk` 即可。
/// - **倒计时**：企划星用服务端返回的 `leftTime` 做订单超时。
///   这里用 15 分钟固定值，超时后标记失败。
/// - **不做短信验证码**：企划星的 `needVerify` 分支在演示模式里不触发。
/// - **不做招行 H5**：`CmbPayWebActivity` 走 WebView，本项目无 WebView。
class PayPage extends ConsumerWidget {
  const PayPage({
    super.key,
    required this.orderNumber,
    required this.amount,
    required this.showTitle,
  });

  /// 订单号。
  final String orderNumber;

  /// 应付金额。
  final Money amount;

  /// 演出名。
  final String showTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arg = (
      orderNumber: orderNumber,
      amount: amount,
      showTitle: showTitle,
    );
    final state = ref.watch(payControllerProvider(arg));
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    // 支付成功后自动跳转。
    if (state.status == PayStatus.success) {
      // 在下一帧跳转，避免在 build 期间触发路由。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.go(
          '/order/pay-success'
          '?number=$orderNumber'
          '&amount=${amount.minorUnits}'
          '&title=${Uri.encodeComponent(showTitle)}',
        );
      });
    }

    return PopScope(
      // 支付进行中时不允许返回。
      canPop:
          state.status != PayStatus.requesting &&
          state.status != PayStatus.paying,
      child: AdaptiveScaffold(
        backgroundColor: colors.bgPage,
        appBar: AdaptiveAppBar(title: context.l10n.payPage_77),
        body: _PayBody(state: state, arg: arg),
      ),
    );
  }
}

class _PayBody extends ConsumerWidget {
  const _PayBody({required this.state, required this.arg});

  final PayState state;
  final ({String orderNumber, Money amount, String showTitle}) arg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final controller = ref.read(payControllerProvider(arg).notifier);

    return Column(
      children: <Widget>[
        // 倒计时条
        if (state.leftSeconds != null && state.leftSeconds! > 0)
          _CountdownBar(seconds: state.leftSeconds!, colors: colors),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
            children: <Widget>[
              // 订单摘要卡
              _OrderCard(info: state.info, colors: colors),
              const SizedBox(height: 12),
              // 支付渠道列表
              _ChannelSection(
                state: state,
                colors: colors,
                onSelect: controller.selectChannel,
              ),
              const SizedBox(height: 12),
              // 错误信息
              if (state.errorMessage != null)
                _ErrorBar(message: state.errorMessage!, colors: colors),
              // 说明
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  context.l10n.payPage_133,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: colors.textDisabled,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 底部确认支付按钮
        _PayButton(
          state: state,
          colors: colors,
          onTap: () => _handlePay(context, ref),
        ),
      ],
    );
  }

  Future<void> _handlePay(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(payControllerProvider(arg).notifier);
    final result = await controller.pay();

    if (!context.mounted) return;

    switch (result) {
      case PaySuccess():
        // 成功跳转由 build 里的 PostFrameCallback 处理。
        break;
      case PayFailure(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      case PayCancelled():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.payPage_166)));
    }
  }
}

/// 倒计时条。
class _CountdownBar extends StatelessWidget {
  const _CountdownBar({required this.seconds, required this.colors});

  final int seconds;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final isUrgent = seconds < 60;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isUrgent
          ? colors.error.withValues(alpha: 0.08)
          : colors.brandSubtle,
      child: Row(
        children: <Widget>[
          Icon(
            LucideIcons.timer,
            size: 16,
            color: isUrgent ? colors.error : colors.brand,
          ),
          const SizedBox(width: 6),
          Text(
            context.l10n.payPage_195(PayController.formatCountdown(seconds)),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isUrgent ? colors.error : colors.brand,
            ),
          ),
        ],
      ),
    );
  }
}

/// 订单摘要卡。
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.info, required this.colors});

  final PayInfo info;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final line in info.detailLines)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 64,
                    child: Text(
                      line.labelOf(context),
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      line.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Divider(height: 1, color: colors.divider),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(
                context.l10n.payPage_259,
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
              const Spacer(),
              PsPrice(amount: info.payAmount, size: 22),
            ],
          ),
        ],
      ),
    );
  }
}

/// 支付渠道列表。
class _ChannelSection extends StatelessWidget {
  const _ChannelSection({
    required this.state,
    required this.colors,
    required this.onSelect,
  });

  final PayState state;
  final AppColors colors;
  final void Function(PaymentChannel) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              context.l10n.payPage_301,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
          for (final option in state.info.channels)
            _ChannelTile(
              option: option,
              selected: state.selectedChannel == option.channel,
              colors: colors,
              onTap: option.available ? () => onSelect(option.channel) : null,
            ),
        ],
      ),
    );
  }
}

/// 渠道选项行。
class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.option,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final PayChannelOption option;
  final bool selected;
  final AppColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (option.channel) {
      PaymentChannel.wechat => LucideIcons.messageCircle,
      PaymentChannel.alipay => LucideIcons.wallet,
      PaymentChannel.unionPay => LucideIcons.creditCard,
      PaymentChannel.creditPay => LucideIcons.creditCard,
      PaymentChannel.balance => LucideIcons.piggyBank,
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 24,
              color: option.available ? colors.brand : colors.textDisabled,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    option.channel.labelOf(context),
                    style: TextStyle(
                      fontSize: 15,
                      color: option.available
                          ? colors.textPrimary
                          : colors.textDisabled,
                    ),
                  ),
                  if (option.tipOf(context) != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        option.tipOf(context)!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 选中标记
            Icon(
              selected ? LucideIcons.circleDot : LucideIcons.circle,
              size: 20,
              color: selected ? colors.brand : colors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

/// 错误信息条。
class _ErrorBar extends StatelessWidget {
  const _ErrorBar({required this.message, required this.colors});

  final String message;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(LucideIcons.circleAlert, size: 16, color: colors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部确认支付按钮。
class _PayButton extends StatelessWidget {
  const _PayButton({
    required this.state,
    required this.colors,
    required this.onTap,
  });

  final PayState state;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isProcessing =
        state.status == PayStatus.requesting ||
        state.status == PayStatus.paying;

    String label;
    if (state.status == PayStatus.requesting) {
      label = context.l10n.payPage_436;
    } else if (state.status == PayStatus.paying) {
      label = context.l10n.payPage_438;
    } else {
      label = context.l10n.payPage_440(state.info.payAmount.format());
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border(top: BorderSide(color: colors.divider, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
        15,
        10,
        15,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          // 支付进行中不可点；其余状态可点（允许重试）。
          onPressed: isProcessing ? null : onTap,
          style: FilledButton.styleFrom(
            backgroundColor: colors.brand,
            disabledBackgroundColor: colors.brandDisabled,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
