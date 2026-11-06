import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:core/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/ui/ps_empty_state.dart';
import 'wallet.dart';
import 'wallet_providers.dart';
import 'marketing_l10n.dart';
import '../../l10n/l10n.dart';

/// 钱包页面。
///
/// ## 与 Android 的差异
///
/// - 企划星 `MyWalletActivity` 的头部只有余额数字 + 一个「说明」按钮。
///   这里增加了「充值」「提现」两个入口按钮——企划星在 H5 里才有这两个流程，
///   原生页面没做。这里先给入口，点击 toast 说明"待接入"（遵循"假功能不做"约定）。
/// - 交易记录列表对齐 Android 的 `item_wallet_balance.xml`：
///   标题 + 余额 + 金额（带正负号 + 颜色区分）+ 时间。
class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(walletProvider);
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: context.l10n.walletPage_31),
      body: Column(
        children: <Widget>[
          _BalanceHeader(balance: account.balance),
          _ActionBar(
            onTapDeposit: () => _toast(context, context.l10n.walletPage_35),
            onTapWithdraw: () => _toast(context, context.l10n.walletPage_35_2),
          ),
          Expanded(
            child: account.transactions.isEmpty
                ? PsEmptyState(
                    title: context.l10n.walletPage_39,
                    description: context.l10n.walletPage_40,
                    icon: LucideIcons.receiptText,
                  )
                : ListView.separated(
                    itemCount: account.transactions.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, indent: 16, color: colors.divider),
                    itemBuilder: (_, int index) {
                      return _TransactionItem(
                        transaction: account.transactions[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 余额头部。
class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.balance});

  final Money balance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[colors.brand, colors.brand.withValues(alpha: 0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.walletPage_94,
            style: TextStyle(
              fontSize: 13,
              color: colors.onBrand.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                balance.format(withSymbol: false),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: colors.onBrand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 充值 / 提现按钮栏。
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onTapDeposit, required this.onTapWithdraw});

  final VoidCallback onTapDeposit;
  final VoidCallback onTapWithdraw;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      color: colors.bgCard,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ActionButton(
              icon: LucideIcons.circlePlus,
              label: context.l10n.walletPage_143,
              onTap: onTapDeposit,
              primary: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: LucideIcons.landmark,
              label: context.l10n.walletPage_152,
              onTap: onTapWithdraw,
              primary: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: primary ? colors.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: primary ? null : Border.all(color: colors.border, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 16,
              color: primary ? colors.onBrand : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primary ? colors.onBrand : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单条交易记录。
///
/// 对齐 Android `item_wallet_balance.xml`：
/// `tvTitle` / `tvBalance` / `tvAmount` / `tvTime`。
class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final isIncome = transaction.type == WalletTransactionType.income;
    final amountColor = isIncome ? colors.success : colors.textPrimary;

    return Container(
      color: colors.bgCard,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.balanceLabelOf(context),
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.timeLabel,
                  style: TextStyle(fontSize: 11, color: colors.textDisabled),
                ),
              ],
            ),
          ),
          Text(
            transaction.amountLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
