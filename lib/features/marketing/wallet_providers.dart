import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wallet.dart';

/// 钱包演示数据。
///
/// 对齐 Android `GET v1/moneyaccount` + `GET v1/moneyaccount/sequences`。
/// 接口接上后把 [walletProvider] 改成 `FutureProvider` 即可。
final class DemoWallet {
  DemoWallet._();

  static WalletAccount generate() {
    final now = DateTime.now();

    return WalletAccount(
      balance: Money.fromMinorUnits(12850),
      transactions: <WalletTransaction>[
        WalletTransaction(
          id: 1,
          title: '充值',
          amount: Money.fromMinorUnits(10000),
          balanceAfter: Money.fromMinorUnits(12850),
          time: now.subtract(const Duration(days: 2)),
          type: WalletTransactionType.income,
        ),
        WalletTransaction(
          id: 2,
          title: '购买「五月天演唱会」门票',
          amount: Money.fromMinorUnits(38000),
          balanceAfter: Money.fromMinorUnits(2850),
          time: now.subtract(const Duration(days: 5)),
          type: WalletTransactionType.expense,
        ),
        WalletTransaction(
          id: 3,
          title: '退款入账 - 订单 P20261101001',
          amount: Money.fromMinorUnits(28000),
          balanceAfter: Money.fromMinorUnits(30850),
          time: now.subtract(const Duration(days: 10)),
          type: WalletTransactionType.income,
        ),
        WalletTransaction(
          id: 4,
          title: '新人注册赠送',
          amount: Money.fromMinorUnits(5000),
          balanceAfter: Money.fromMinorUnits(2850),
          time: now.subtract(const Duration(days: 30)),
          type: WalletTransactionType.income,
        ),
        WalletTransaction(
          id: 5,
          title: '购买「脱口秀大会」门票',
          amount: Money.fromMinorUnits(9800),
          balanceAfter: Money.fromMinorUnits(2850),
          time: now.subtract(const Duration(days: 15)),
          type: WalletTransactionType.expense,
        ),
      ],
    );
  }
}

/// 钱包账户 Provider。
///
/// 对齐 Android `MyWalletActivity` 的 `GET v1/moneyaccount`。
final walletProvider = Provider<WalletAccount>((ref) => DemoWallet.generate());

/// 钱包余额 Provider（「我的」页资产卡用）。
final walletBalanceProvider = Provider<Money>(
  (ref) => ref.watch(walletProvider).balance,
);
