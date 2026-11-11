import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/network/network_providers.dart';
import '../user/application/user_api_providers.dart';
import '../user/data/planstar_user_api.dart';
import 'demo_wallet_state.dart';
import 'wallet.dart';

/// 钱包演示数据。
///
/// 对应真实接口 `GET v1/moneyaccount` + `GET v1/moneyaccount/sequences`。
final class DemoWallet {
  DemoWallet._();

  /// 生成与当前星币余额自洽的签到流水（星币唯一来源为每日签到）。
  static WalletAccount generate({
    required Money balance,
    required bool signedToday,
  }) {
    final now = DateTime.now();
    const int reward = DemoWalletController.signInRewardMinorUnits;
    const int count = 3;
    final int start = balance.minorUnits - reward * count;
    final DateTime anchor = signedToday
        ? now.subtract(const Duration(days: 2))
        : now.subtract(const Duration(days: 3));

    final List<WalletTransaction> items = <WalletTransaction>[];
    for (var i = 0; i < count; i++) {
      items.add(
        WalletTransaction(
          id: i + 1,
          title: '每日签到',
          amount: Money.fromMinorUnits(reward),
          balanceAfter: Money.fromMinorUnits(start + reward * (i + 1)),
          time: anchor.add(Duration(days: i)),
          type: WalletTransactionType.income,
        ),
      );
    }

    return WalletAccount(
      balance: balance,
      // 最新的在最前，与接口倒序一致。
      transactions: items.reversed.toList(growable: false),
    );
  }
}

/// 钱包账户 Provider。
///
/// 真实模式请求 `GET v1/moneyaccount` + `GET v1/moneyaccount/sequences`；
/// demo 模式保留本地演示数据。
final walletProvider = FutureProvider<WalletAccount>((ref) async {
  if (ref.watch(dataSourcePolicyProvider).isDemo) {
    final DemoWalletState demo = ref.watch(demoWalletStateProvider);
    return DemoWallet.generate(
      balance: Money.fromMinorUnits(demo.balanceMinorUnits),
      signedToday: demo.signedToday,
    );
  }

  final api = ref.watch(planstarUserApiProvider);
  final accountResult = await api.fetchWallet();
  final WalletAccountInfo account = accountResult.fold(
    onSuccess: (WalletAccountInfo info) => info,
    onFailure: (failure) => throw failure,
  );

  final sequencesResult = await api.fetchWalletSequences();
  final List<WalletTransaction> transactions = sequencesResult.fold(
    onSuccess: (List<WalletTransaction> items) => items,
    onFailure: (failure) => throw failure,
  );

  return WalletAccount(balance: account.balance, transactions: transactions);
});

/// 钱包余额 Provider（「我的」页资产卡用）。
final walletBalanceProvider = Provider<Money>(
  (ref) => ref.watch(walletProvider).valueOrNull?.balance ?? Money.zero(),
);
