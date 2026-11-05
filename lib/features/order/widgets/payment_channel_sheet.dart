import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../domain/domain.dart';

/// 支付渠道选择面板（`dialog_pay_channel.xml`）。
///
/// ## 为什么从 `order_list_page.dart` 提出来
///
/// 订单列表和订单详情都有"点支付 → 选渠道"这一步。原来它是列表页里的私有
/// `_PaymentChannelSheet`，私有类没法跨文件用，于是详情页只有两个选择：
/// 复制一份，或者把用户弹回列表页。前者必然导致"两个页面的渠道列表不一致"
/// （加一个渠道漏改一处），所以提成公共组件。
class PaymentChannelSheet extends StatelessWidget {
  const PaymentChannelSheet({super.key});

  /// 弹出面板，返回用户选的渠道；取消返回 `null`。
  static Future<PaymentChannel?> show(BuildContext context) {
    return showModalBottomSheet<PaymentChannel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaymentChannelSheet(),
    );
  }

  /// 渠道与图标。企划星支持微信 / 支付宝 / 云闪付，招行一网通走独立 H5
  /// （`CmbPayWebActivity`），不在这个面板里。
  static const List<(PaymentChannel, IconData)> _channels =
      <(PaymentChannel, IconData)>[
    (PaymentChannel.wechat, LucideIcons.messageCircle),
    (PaymentChannel.alipay, LucideIcons.wallet),
    (PaymentChannel.unionPay, LucideIcons.creditCard),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '选择支付方式',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            for (final (PaymentChannel channel, IconData icon) in _channels)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon, color: colors.brand),
                title: Text(channel.label, style: const TextStyle(fontSize: 15)),
                trailing:
                    Icon(LucideIcons.chevronRight, size: 18, color: colors.textDisabled),
                onTap: () => Navigator.of(context).pop(channel),
              ),
          ],
        ),
      ),
    );
  }
}
