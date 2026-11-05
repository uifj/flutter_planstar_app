import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_price.dart';

/// 支付成功页（企划星 `PaySuccessActivity` + `PaySuccessFragment`）。
///
/// ## 结构
///
/// - 顶部成功图标 + 「支付成功」标题；
/// - 订单摘要卡（演出名 + 订单号 + 金额）；
/// - 底部两个按钮：「查看订单」和「继续逛逛」。
///
/// ## 与 Android 的差异
///
/// - 原页是一个 `PNSlideActivity`（可侧滑返回），这里用 `PopScope(canPop: false)`
///   阻止返回：支付成功后不应该让用户回到支付页。
/// - 原页的 Fragment 负责拉取订单详情。这里只展示路由参数传入的信息
///   （订单号 + 金额 + 演出名），因为支付完成时这些信息已经确定，
///   不需要再请求一次——如果请求失败，"支付成功了但详情拉不到"
///   反而让用户焦虑。
/// - 不做 Lottie 成功动画：本地动画资源已移除，
///   用 Material 的 `check_circle` 图标 + 品牌色足够。
class PaySuccessPage extends ConsumerWidget {
  const PaySuccessPage({
    super.key,
    required this.orderNumber,
    required this.amount,
    this.showTitle,
  });

  /// 订单号。
  final String orderNumber;

  /// 支付金额。
  final Money amount;

  /// 演出名（可选）。
  final String? showTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final topPadding = MediaQuery.paddingOf(context).top;

    return PopScope(
      // 阻止返回：支付成功后不应该回到支付页或确认订单页。
      canPop: false,
      child: AdaptiveScaffold(
        backgroundColor: colors.bgPage,
        body: Column(
          children: <Widget>[
            SizedBox(height: topPadding + 60),
            // 成功图标
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.brandSubtle,
              ),
              child: Icon(
                LucideIcons.circleCheck,
                size: 48,
                color: colors.brand,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '支付成功',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '企划星正在为您出票，请耐心等待',
              style: TextStyle(fontSize: 14, color: colors.textTertiary),
            ),
            const SizedBox(height: 32),
            // 订单摘要卡
            _OrderSummaryCard(
              orderNumber: orderNumber,
              amount: amount,
              showTitle: showTitle,
            ),
            const Spacer(),
            // 底部按钮
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, topPadding + 24),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: () {
                        // 查看订单详情。
                        context.go('/order/detail?number=$orderNumber');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.brand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                      child: const Text(
                        '查看订单',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: TextButton(
                      onPressed: () {
                        // 回到首页。
                        context.go('/');
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                      child: Text(
                        '继续逛逛',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.textSecondary,
                        ),
                      ),
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

/// 订单摘要卡。
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.orderNumber,
    required this.amount,
    this.showTitle,
  });

  final String orderNumber;
  final Money amount;
  final String? showTitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          if (showTitle != null) ...<Widget>[
            _SummaryRow(
              label: '演出',
              value: showTitle!,
              valueMaxLines: 2,
            ),
            const SizedBox(height: 12),
          ],
          _SummaryRow(
            label: '订单号',
            value: orderNumber,
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colors.divider),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(
                '支付金额',
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
              const Spacer(),
              PsPrice(
                amount: amount,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 摘要行（label + value）。
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueMaxLines = 1,
  });

  final String label;
  final String value;
  final int valueMaxLines;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: colors.textTertiary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: valueMaxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
