import 'package:core_domain/core_domain.dart';

/// 钱包交易记录类型。
///
/// 对齐 Android `item_wallet_balance.xml`：
/// 金额正数（`+`）为收入，负数为支出。Android 没有显式枚举，
/// 只用 `amount` 的正负号判断——这里用枚举让意图更清晰。
enum WalletTransactionType {
  /// 收入（充值 / 退款入账 / 活动赠送）。
  income,

  /// 支出（消费 / 提现）。
  expense,
}

/// 钱包交易记录。
///
/// 对齐 Android `v1/moneyaccount/sequences` 返回的单条记录：
/// - `title`：描述文案
/// - `amount`：金额（有符号）
/// - `balance`：交易后余额
/// - `happenTime`：时间戳
final class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.balanceAfter,
    required this.time,
    required this.type,
  });

  final int id;
  final String title;

  /// 交易金额（正数表示收入，负数表示支出）。
  final Money amount;

  /// 交易后余额。
  final Money balanceAfter;

  /// 交易时间。
  final DateTime time;

  final WalletTransactionType type;

  /// 金额展示文案（带正负号）。
  String get amountLabel {
    if (type == WalletTransactionType.income) {
      return '+${amount.format()}';
    }
    return '-${amount.abs().format()}';
  }

  /// 余额展示文案。
  String get balanceLabel => '余额 ${balanceAfter.format()}';

  /// 时间展示文案。
  String get timeLabel {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${time.year}-${two(time.month)}-${two(time.day)} '
        '${two(time.hour)}:${two(time.minute)}';
  }
}

/// 钱包账户信息。
final class WalletAccount {
  const WalletAccount({
    required this.balance,
    required this.transactions,
  });

  /// 当前余额。
  final Money balance;

  /// 交易记录列表。
  final List<WalletTransaction> transactions;
}
