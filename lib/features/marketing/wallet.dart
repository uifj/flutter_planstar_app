import 'package:core/domain.dart';

/// 钱包交易记录类型。
///
/// 金额正数（`+`）为收入，负数为支出。用显式枚举表达方向，
/// 而不是只靠 `amount` 的正负号判断，让意图更清晰。
enum WalletTransactionType {
  /// 收入（充值 / 退款入账 / 活动赠送）。
  income,

  /// 支出（消费 / 提现）。
  expense,
}

/// 钱包交易记录。
///
/// 对应 `v1/moneyaccount/sequences` 返回的单条记录：
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

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final int amount = _asInt(json['amount']) ?? 0;
    return WalletTransaction(
      id: _asInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      amount: Money.fromMinorUnits(amount.abs()),
      balanceAfter: Money.fromMinorUnits(_asInt(json['balanceAfter']) ?? 0),
      time:
          DateTime.tryParse(json['happenTime']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: json['type']?.toString() == 'expense'
          ? WalletTransactionType.expense
          : WalletTransactionType.income,
    );
  }

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

  /// 时间展示文案。
  String get timeLabel {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${time.year}-${two(time.month)}-${two(time.day)} '
        '${two(time.hour)}:${two(time.minute)}';
  }
}

/// 钱包账户信息。
final class WalletAccount {
  const WalletAccount({required this.balance, required this.transactions});

  /// 当前余额。
  final Money balance;

  /// 交易记录列表。
  final List<WalletTransaction> transactions;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
