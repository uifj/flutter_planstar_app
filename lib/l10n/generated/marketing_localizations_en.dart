// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'marketing_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MarketingLocalizationsEn extends MarketingLocalizations {
  MarketingLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String coupon_115(Object rate) {
    return '$rate% off';
  }

  @override
  String coupon_120(Object format) {
    return 'Usable on orders over $format';
  }

  @override
  String get coupon_120_2 => 'No minimum spend';

  @override
  String coupon_125(Object year, Object month, Object day) {
    return 'Expires $year-$month-$day';
  }

  @override
  String get couponPage_30 => 'My Coupons';

  @override
  String get couponPage_34 => 'Redeem';

  @override
  String get couponPage_97 => 'No available coupons';

  @override
  String get couponPage_98 => 'No used coupons';

  @override
  String get couponPage_99 => 'No expired coupons';

  @override
  String get couponPage_102 => 'Go to Home to get more coupons';

  @override
  String get couponPage_103 => 'Used coupons will appear here';

  @override
  String get couponPage_104 => 'Expired coupons will appear here';

  @override
  String get couponPage_107 => 'Browse';

  @override
  String couponPage_208(Object daysUntilExpiry) {
    return 'Only $daysUntilExpiry days left';
  }

  @override
  String get couponPage_290 => '% off';

  @override
  String get couponPage_302 => 'Deduction';

  @override
  String get couponProviders_10 => 'Available';

  @override
  String get couponProviders_13 => 'Used';

  @override
  String get couponProviders_16 => 'Expired';

  @override
  String get couponProviders_110 => 'Redemption code coupon';

  @override
  String get couponProviders_111 => 'Obtained via a redemption code';

  @override
  String get couponProviders_124 => 'Invalid redemption code. Please check and try again';

  @override
  String exchangeCouponPage_32(Object title) {
    return 'Redemption successful: $title';
  }

  @override
  String get exchangeCouponPage_47 => 'Redeem Coupon';

  @override
  String get exchangeCouponPage_71 => 'Enter the redemption code to claim your coupon. Codes are issued by the event organizer';

  @override
  String get exchangeCouponPage_84 => 'Redemption Code';

  @override
  String get exchangeCouponPage_95 => 'Please enter the redemption code';

  @override
  String get exchangeCouponPage_155 => 'Redeem Now';

  @override
  String get addGiftCardPage_67 => 'Bind Gift Card';

  @override
  String get addGiftCardPage_74 => 'Please enter the gift card number';

  @override
  String get addGiftCardPage_91 => 'Enter gift card number / PIN';

  @override
  String get addGiftCardPage_135 => 'Bind';

  @override
  String get addGiftCardPage_155 => 'Instructions';

  @override
  String get addGiftCardPage_164 => '1. Scratch off the coating on the back of the physical card to find the gift card number\n2. After binding, the balance can be used at checkout\n3. Gift cards cannot be combined; they are not registered and cannot be reissued\n4. Validity is subject to the date printed on the gift card';

  @override
  String giftCard_96(Object year, Object month, Object day) {
    return 'Expires $year-$month-$day';
  }

  @override
  String giftCard_100(Object format) {
    return 'Face value $format';
  }

  @override
  String giftCard_103(Object format) {
    return 'Balance $format';
  }

  @override
  String get giftCardPage_30 => 'Gift Card';

  @override
  String get giftCardPage_34 => 'Bind';

  @override
  String get giftCardPage_41 => 'No gift cards';

  @override
  String get giftCardPage_42 => 'Gift cards you bind will appear here';

  @override
  String get giftCardPage_49 => 'Available Gift Cards';

  @override
  String get giftCardPage_57 => 'Unavailable Gift Cards';

  @override
  String get giftCardPage_158 => 'Face Value';

  @override
  String get giftCardPage_196 => 'Balance ';

  @override
  String get giftCardPage_224 => 'Expiring Soon';

  @override
  String get giftCardProviders_54 => 'Please enter the gift card number';

  @override
  String get giftCardProviders_65 => 'Gift card bound successfully. 200 star coins added to your balance';

  @override
  String wallet_56(Object format) {
    return 'Balance $format';
  }

  @override
  String get walletPage_31 => 'My Wallet';

  @override
  String get walletPage_35 => 'Top-up requires the payment SDK to be integrated';

  @override
  String get walletPage_35_2 => 'Please bind a bank card before withdrawing';

  @override
  String get walletPage_39 => 'No transactions yet';

  @override
  String get walletPage_40 => 'Transactions will appear here after you top up or spend';

  @override
  String get walletPage_94 => 'Current Balance (star coins)';

  @override
  String get walletPage_143 => 'Top Up';

  @override
  String get walletPage_152 => 'Withdraw';

  @override
  String get walletProviders_21 => 'Top-up';

  @override
  String get walletProviders_29 => 'Support “Mayday Music Film Project”';

  @override
  String get walletProviders_37 => 'Refund received - Order P20261101001';

  @override
  String get walletProviders_45 => 'New user registration gift';

  @override
  String get walletProviders_53 => 'Support “Talk Show Live Project”';

  @override
  String get mallPage_1 => 'Star Coin Mall';

  @override
  String get mallPage_2 => 'Star Coin Balance';

  @override
  String mallPage_3(Object price) {
    return 'Price $price';
  }

  @override
  String mallPage_4(Object count) {
    return 'Limited to $count';
  }

  @override
  String mallPage_5(Object stock) {
    return '$stock left';
  }

  @override
  String get mallPage_6 => 'Redeem';

  @override
  String get mallPage_7 => 'Sold out';

  @override
  String get mallPage_8 => 'Not enough star coins';

  @override
  String get mallPage_9 => 'Confirm redemption';

  @override
  String mallPage_10(Object name, Object price) {
    return 'Redeem “$name” for $price';
  }

  @override
  String get mallPage_11 => 'Cancel';

  @override
  String get mallPage_12 => 'Confirm';

  @override
  String get mallPage_13 => 'Redeemed successfully';

  @override
  String get mallPage_14 => 'No items available';

  @override
  String get mallPage_15 => 'Items will appear here once listed';

  @override
  String get mallPage_16 => 'Reload';
}
