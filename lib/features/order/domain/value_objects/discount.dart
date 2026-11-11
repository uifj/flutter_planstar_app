import 'package:core/domain.dart';

import 'ids.dart';

/// 折扣的两种形态：**减固定金额** 或 **按比例减（可封顶）**。
///
/// 只有"减固定金额"一种形态不够用（营销/券优惠按 `double` 元下发），
/// 但服务端下发的券里已经出现"满 1000 减 15%"，所以这里把两种都建模，
/// 由 [Money.percentage] 统一处理舍入。
sealed class Discount extends ValueObject {
  const Discount();

  /// 在 [base] 上算出**抵扣金额**（永远非负、且不超过 [base]）。
  ///
  /// 刻意不让抵扣额超过总额再靠事后 `if (paymentAmount < 0) = 0` 兜底。
  /// 这里在源头钳住，`paymentAmount` 就不会出现负数中间态。
  Money discountOn(Money base);
}

/// 减固定金额。
final class AmountDiscount extends Discount {
  AmountDiscount(this.amount) {
    if (amount.isNegative) {
      throw ArgumentError.value(amount, 'amount', '抵扣金额不能为负');
    }
  }

  /// 抵扣金额。
  final Money amount;

  @override
  Money discountOn(Money base) => amount.min(base);

  @override
  List<Object?> get props => <Object?>[amount];
}

/// 按万分比减，可封顶。
///
/// [basisPoints] 用整数万分比（`8500` = 85 折），避免调用方传 `0.85` 这种 `double`。
final class RateDiscount extends Discount {
  RateDiscount(this.basisPoints, {this.cap}) {
    if (basisPoints < 0 || basisPoints > 10000) {
      throw ArgumentError.value(
        basisPoints,
        'basisPoints',
        '比例必须在 0..10000 之间',
      );
    }
  }

  /// 折扣比例（万分比，即"减掉的比例"）。
  final int basisPoints;

  /// 封顶金额。
  final Money? cap;

  @override
  Money discountOn(Money base) {
    final raw = base.percentage(basisPoints);
    final ceiling = cap;
    return ceiling == null ? raw : raw.min(ceiling);
  }

  @override
  List<Object?> get props => <Object?>[basisPoints, cap];
}

/// 用户本单选择的优惠：**营销活动 / 优惠券 / 都不用，三选一**。
///
/// ## 为什么不用 `int selectStatus`
///
/// 用 `int selectStatus`（`0` 营销、`1` 券、`2` 都不用）时，互斥关系靠
/// `if/else if/else` 在重算金额时维持，下单时又要在建单逻辑里
/// 用另一段 `if (i2 != 0) ... else if` 再维持一次。
/// 两处逻辑必须同步，否则"页面显示用了券、请求里带的是活动"。
///
/// 用 `sealed` 之后，**互斥由类型保证**：一个 `DiscountSelection` 只能是一种，
/// 想要"同时用券和活动"根本构造不出来。
sealed class DiscountSelection {
  const DiscountSelection();

  /// 都不用（默认）。
  static const DiscountSelection none = NoDiscount();

  /// 选营销活动。
  factory DiscountSelection.campaign(CampaignId id, Discount discount) =
      CampaignSelection;

  /// 选优惠券。
  factory DiscountSelection.coupon(CouponId id, Discount discount) =
      CouponSelection;

  /// 在 [base] 上算抵扣额。
  Money discountOn(Money base);

  /// 参与下单的促销 id（`campaignIds` 或 `couponIds`，**不会同时有值**）。
  String? get promotionId;
}

/// 不用任何优惠。
final class NoDiscount extends DiscountSelection {
  const NoDiscount();

  @override
  Money discountOn(Money base) => Money.zero(base.currency);

  @override
  String? get promotionId => null;
}

/// 营销活动。
final class CampaignSelection extends DiscountSelection {
  const CampaignSelection(this.campaignId, this.discount);

  final CampaignId campaignId;
  final Discount discount;

  @override
  Money discountOn(Money base) => discount.discountOn(base);

  @override
  String? get promotionId => campaignId.value;
}

/// 优惠券。
final class CouponSelection extends DiscountSelection {
  const CouponSelection(this.couponId, this.discount);

  final CouponId couponId;
  final Discount discount;

  @override
  Money discountOn(Money base) => discount.discountOn(base);

  @override
  String? get promotionId => couponId.value;
}
