import 'package:core/domain.dart';

import 'ids.dart';

/// 加速包（抢票加速）。
///
/// 企划星的算法（`wiki_zh/modules/order-and-payment` §3.5）：
/// ```
/// 总加速包 = 单张加速包价 × 票数
/// 现金部分 = max(0, 总加速包 − 账户加速包余额)   ← 计入应付
/// 余额部分 = 总加速包 − 现金部分                 ← 走余额抵扣，不动现金
/// ```
/// 关键语义：**加速包不能用礼品卡付**——它是在礼品卡抵扣之后的 `paymentAmount`
/// 上"加回去"的（原实现顺序：先礼品卡后加速包）。这个顺序被固化在
/// [OrderQuote] 的计算里，不再依赖调用方记得。
final class SpeedPack extends ValueObject {
  SpeedPack({
    required this.units,
    required this.unitPrice,
    required this.balanceAvailable,
  }) {
    if (units < 0) throw ArgumentError.value(units, 'units', '加速包数量不能为负');
    if (unitPrice.isNegative) {
      throw ArgumentError.value(unitPrice, 'unitPrice', '加速包单价不能为负');
    }
    if (balanceAvailable.isNegative) {
      throw ArgumentError.value(
        balanceAvailable,
        'balanceAvailable',
        '加速包余额不能为负',
      );
    }
  }

  /// 按票数生成：每张票一份加速包（原实现 `speedPackage * mCounts`）。
  factory SpeedPack.forTickets({
    required int tickets,
    required Money unitPrice,
    required Money balanceAvailable,
  }) => SpeedPack(
    units: tickets,
    unitPrice: unitPrice,
    balanceAvailable: balanceAvailable,
  );

  /// 份数（= 票数）。
  final int units;

  /// 单份价格。
  final Money unitPrice;

  /// 账户可用加速包余额。
  final Money balanceAvailable;

  /// 总价。
  Money get total => unitPrice * units;

  /// 余额抵扣部分。
  Money get balancePortion => total.min(balanceAvailable);

  /// 需要现金支付的部分。
  Money get cashPortion => total - balancePortion;

  @override
  List<Object?> get props => <Object?>[units, unitPrice, balanceAvailable];

  @override
  String toString() =>
      '加速包 $units 份（现金 ${cashPortion.format()} / 余额 ${balancePortion.format()}）';
}

/// 礼品卡（本单用于抵扣的一张卡）。
///
/// 只带 id 与余额：**实际抵扣额由金额计算决定**（`min(余额, 应付)`），
/// 不存在"卡上写死抵扣多少"的状态。企划星把 `useAmount` 写回卡对象
/// （`giftCard.setUseAmount(...)`），导致同一个卡对象在不同页面带着不同的抵扣额。
final class GiftCardTender extends ValueObject {
  GiftCardTender({required this.id, required this.balance}) {
    if (balance.isNegative) {
      throw ArgumentError.value(balance, 'balance', '礼品卡余额不能为负');
    }
  }

  final GiftCardId id;

  /// 卡内余额。
  final Money balance;

  @override
  List<Object?> get props => <Object?>[id, balance];

  @override
  String toString() => '礼品卡 ${id.value}（余额 ${balance.format()}）';
}
