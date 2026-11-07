// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'marketing_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MarketingLocalizationsEn extends MarketingLocalizations {
  MarketingLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String coupon_115(Object rate) {
    return '$rate折';
  }

  @override
  String coupon_120(Object format) {
    return '满$format可用';
  }

  @override
  String get coupon_120_2 => '无门槛';

  @override
  String coupon_125(Object year, Object month, Object day) {
    return '$year-$month-$day到期';
  }

  @override
  String get couponPage_30 => '我的优惠券';

  @override
  String get couponPage_34 => '兑换';

  @override
  String get couponPage_97 => '暂无可用优惠券';

  @override
  String get couponPage_98 => '暂无已使用记录';

  @override
  String get couponPage_99 => '暂无过期优惠券';

  @override
  String get couponPage_102 => '去首页领取更多优惠';

  @override
  String get couponPage_103 => '已使用的券会显示在这里';

  @override
  String get couponPage_104 => '过期的券会显示在这里';

  @override
  String get couponPage_107 => '去逛逛';

  @override
  String couponPage_208(Object daysUntilExpiry) {
    return '仅剩$daysUntilExpiry天';
  }

  @override
  String get couponPage_290 => '折';

  @override
  String get couponPage_302 => '抵扣';

  @override
  String get couponProviders_10 => '可使用';

  @override
  String get couponProviders_13 => '已使用';

  @override
  String get couponProviders_16 => '已过期';

  @override
  String get couponProviders_110 => '兑换码兑换券';

  @override
  String get couponProviders_111 => '通过兑换码获得';

  @override
  String get couponProviders_124 => '兑换码无效，请检查后重试';

  @override
  String exchangeCouponPage_32(Object title) {
    return '兑换成功：$title';
  }

  @override
  String get exchangeCouponPage_47 => '兑换优惠券';

  @override
  String get exchangeCouponPage_71 => '输入兑换码领取优惠券，兑换码由活动方发放';

  @override
  String get exchangeCouponPage_84 => '兑换码';

  @override
  String get exchangeCouponPage_95 => '请输入兑换码';

  @override
  String get exchangeCouponPage_155 => '立即兑换';

  @override
  String get addGiftCardPage_67 => '绑定礼品卡';

  @override
  String get addGiftCardPage_74 => '请输入礼品卡卡号';

  @override
  String get addGiftCardPage_91 => '输入礼品卡卡号 / 密码';

  @override
  String get addGiftCardPage_135 => '绑定';

  @override
  String get addGiftCardPage_155 => '使用说明';

  @override
  String get addGiftCardPage_164 => '1. 礼品卡卡号在实体卡背面刮开涂层后获取\n2. 绑定成功后余额可在下单时抵扣\n3. 礼品卡不可叠加使用，不记名不挂失\n4. 有效期以礼品卡标注为准';

  @override
  String giftCard_96(Object year, Object month, Object day) {
    return '$year-$month-$day到期';
  }

  @override
  String giftCard_100(Object format) {
    return '面值 $format';
  }

  @override
  String giftCard_103(Object format) {
    return '余额 $format';
  }

  @override
  String get giftCardPage_30 => '礼品卡';

  @override
  String get giftCardPage_34 => '绑定';

  @override
  String get giftCardPage_41 => '暂无礼品卡';

  @override
  String get giftCardPage_42 => '绑定礼品卡后可在此查看和使用';

  @override
  String get giftCardPage_49 => '可用礼品卡';

  @override
  String get giftCardPage_57 => '不可用礼品卡';

  @override
  String get giftCardPage_158 => '面值';

  @override
  String get giftCardPage_196 => '余额 ';

  @override
  String get giftCardPage_224 => '即将过期';

  @override
  String get giftCardProviders_54 => '请输入礼品卡卡号';

  @override
  String get giftCardProviders_65 => '礼品卡绑定成功，已添加 ¥200 余额';

  @override
  String wallet_56(Object format) {
    return '余额 $format';
  }

  @override
  String get walletPage_31 => '我的钱包';

  @override
  String get walletPage_35 => '充值流程待接入支付 SDK';

  @override
  String get walletPage_35_2 => '提现需要先绑定银行卡';

  @override
  String get walletPage_39 => '暂无交易记录';

  @override
  String get walletPage_40 => '充值或消费后会有记录显示在这里';

  @override
  String get walletPage_94 => '当前余额（元）';

  @override
  String get walletPage_143 => '充值';

  @override
  String get walletPage_152 => '提现';

  @override
  String get walletProviders_21 => '充值';

  @override
  String get walletProviders_29 => 'Support “Mayday Music Film Project”';

  @override
  String get walletProviders_37 => '退款入账 - 订单 P20261101001';

  @override
  String get walletProviders_45 => '新人注册赠送';

  @override
  String get walletProviders_53 => 'Support “Talk Show Live Project”';
}
