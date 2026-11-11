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
/// 只展示星币余额与流水；充值 / 提现 / 第三方支付已隐藏。
///
/// 交易记录列表每行展示：
/// 标题 + 余额 + 金额（带正负号 + 颜色区分）+ 时间。
class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(walletProvider);
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: context.l10n.walletPage_31),
      body: account.when(
        data: (WalletAccount value) => Column(
          children: <Widget>[
            _BalanceHeader(balance: value.balance),
            Expanded(
              child: value.transactions.isEmpty
                  ? PsEmptyState(
                      title: context.l10n.walletPage_39,
                      description: context.l10n.walletPage_40,
                      icon: LucideIcons.receiptText,
                    )
                  : ListView.separated(
                      itemCount: value.transactions.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, indent: 16, color: colors.divider),
                      itemBuilder: (_, int index) {
                        return _TransactionItem(
                          transaction: value.transactions[index],
                        );
                      },
                    ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => PsEmptyState(
          title: psErrorMessage(error),
          icon: LucideIcons.receiptText,
        ),
      ),
    );
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

/// 单条交易记录。
///
/// 左侧标题 + 交易后余额 + 时间，右侧金额（带正负号，收入用成功色）。
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
