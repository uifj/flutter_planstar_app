import 'package:flutter/widgets.dart';

import '../../l10n/l10n.dart';
import 'coupon.dart';
import 'coupon_providers.dart';
import 'giftcard/gift_card.dart';
import 'wallet.dart';

/// 营销模块展示文案的本地化映射。
extension CouponL10n on Coupon {
  /// 抵扣金额文案：固定金额 `¥30`；折扣率 `8.5折`。
  String discountLabelOf(BuildContext context) {
    if (discountType == CouponDiscountType.amount) {
      return discountAmount.format();
    }
    final rate = discountRate / 10;
    final text = rate.toStringAsFixed(rate * 10 % 10 == 0 ? 0 : 1);
    return context.l10n.coupon_115(text);
  }

  /// 门槛文案：`满¥100可用` 或 `无门槛`。
  String thresholdLabelOf(BuildContext context) => requireAmount.minorUnits > 0
      ? context.l10n.coupon_120(requireAmount.format())
      : context.l10n.coupon_120_2;

  /// 到期文案：`2026-12-31到期`。
  String expiryLabelOf(BuildContext context) {
    String two(int v) => v.toString().padLeft(2, '0');
    return context.l10n.coupon_125(
      '${validTo.year}',
      two(validTo.month),
      two(validTo.day),
    );
  }
}

extension CouponTabL10n on CouponTab {
  String labelOf(BuildContext context) => switch (this) {
    CouponTab.usable => context.l10n.couponProviders_10,
    CouponTab.used => context.l10n.couponProviders_13,
    CouponTab.expired => context.l10n.couponProviders_16,
  };
}

extension GiftCardL10n on GiftCard {
  /// 到期文案。
  String expiryLabelOf(BuildContext context) {
    String two(int v) => v.toString().padLeft(2, '0');
    return context.l10n.giftCard_96(
      '${effectiveTo.year}',
      two(effectiveTo.month),
      two(effectiveTo.day),
    );
  }

  /// 面值文案。
  String denominationLabelOf(BuildContext context) =>
      context.l10n.giftCard_100(denomination.format());

  /// 余额文案。
  String balanceLabelOf(BuildContext context) =>
      context.l10n.giftCard_103(balance.format());
}

extension WalletTransactionL10n on WalletTransaction {
  /// 余额展示文案。
  String balanceLabelOf(BuildContext context) =>
      context.l10n.wallet_56(balanceAfter.format());
}
