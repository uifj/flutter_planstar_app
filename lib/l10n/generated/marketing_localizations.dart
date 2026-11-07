import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'marketing_localizations_en.dart';
import 'marketing_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MarketingLocalizations
/// returned by `MarketingLocalizations.of(context)`.
///
/// Applications need to include `MarketingLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/marketing_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MarketingLocalizations.localizationsDelegates,
///   supportedLocales: MarketingLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the MarketingLocalizations.supportedLocales
/// property.
abstract class MarketingLocalizations {
  MarketingLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MarketingLocalizations of(BuildContext context) {
    return Localizations.of<MarketingLocalizations>(context, MarketingLocalizations)!;
  }

  static const LocalizationsDelegate<MarketingLocalizations> delegate = _MarketingLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// 来源：lib/features/marketing/coupon.dart:115；原文：'${rate.toStringAsFixed(rate * 10 % 10 == 0 ? 0 : 1)}折'
  ///
  /// In zh, this message translates to:
  /// **'{rate}折'**
  String coupon_115(Object rate);

  /// 来源：lib/features/marketing/coupon.dart:120；原文：'满${requireAmount.format()}可用'
  ///
  /// In zh, this message translates to:
  /// **'满{format}可用'**
  String coupon_120(Object format);

  /// 来源：lib/features/marketing/coupon.dart:120；原文：'无门槛'
  ///
  /// In zh, this message translates to:
  /// **'无门槛'**
  String get coupon_120_2;

  /// 来源：lib/features/marketing/coupon.dart:125；原文：'${validTo.year}-${two(validTo.month)}-${two(validTo.day)}到期'
  ///
  /// In zh, this message translates to:
  /// **'{year}-{month}-{day}到期'**
  String coupon_125(Object year, Object month, Object day);

  /// 来源：lib/features/marketing/coupon_page.dart:30；原文：'我的优惠券'
  ///
  /// In zh, this message translates to:
  /// **'我的优惠券'**
  String get couponPage_30;

  /// 来源：lib/features/marketing/coupon_page.dart:34；原文：'兑换'
  ///
  /// In zh, this message translates to:
  /// **'兑换'**
  String get couponPage_34;

  /// 来源：lib/features/marketing/coupon_page.dart:97；原文：'暂无可用优惠券'
  ///
  /// In zh, this message translates to:
  /// **'暂无可用优惠券'**
  String get couponPage_97;

  /// 来源：lib/features/marketing/coupon_page.dart:98；原文：'暂无已使用记录'
  ///
  /// In zh, this message translates to:
  /// **'暂无已使用记录'**
  String get couponPage_98;

  /// 来源：lib/features/marketing/coupon_page.dart:99；原文：'暂无过期优惠券'
  ///
  /// In zh, this message translates to:
  /// **'暂无过期优惠券'**
  String get couponPage_99;

  /// 来源：lib/features/marketing/coupon_page.dart:102；原文：'去首页领取更多优惠'
  ///
  /// In zh, this message translates to:
  /// **'去首页领取更多优惠'**
  String get couponPage_102;

  /// 来源：lib/features/marketing/coupon_page.dart:103；原文：'已使用的券会显示在这里'
  ///
  /// In zh, this message translates to:
  /// **'已使用的券会显示在这里'**
  String get couponPage_103;

  /// 来源：lib/features/marketing/coupon_page.dart:104；原文：'过期的券会显示在这里'
  ///
  /// In zh, this message translates to:
  /// **'过期的券会显示在这里'**
  String get couponPage_104;

  /// 来源：lib/features/marketing/coupon_page.dart:107；原文：'去逛逛'
  ///
  /// In zh, this message translates to:
  /// **'去逛逛'**
  String get couponPage_107;

  /// 来源：lib/features/marketing/coupon_page.dart:208；原文：'仅剩${coupon.daysUntilExpiry}天'
  ///
  /// In zh, this message translates to:
  /// **'仅剩{daysUntilExpiry}天'**
  String couponPage_208(Object daysUntilExpiry);

  /// 来源：lib/features/marketing/coupon_page.dart:290；原文：'折'
  ///
  /// In zh, this message translates to:
  /// **'折'**
  String get couponPage_290;

  /// 来源：lib/features/marketing/coupon_page.dart:302；原文：'抵扣'
  ///
  /// In zh, this message translates to:
  /// **'抵扣'**
  String get couponPage_302;

  /// 来源：lib/features/marketing/coupon_providers.dart:10；原文：'可使用'
  ///
  /// In zh, this message translates to:
  /// **'可使用'**
  String get couponProviders_10;

  /// 来源：lib/features/marketing/coupon_providers.dart:13；原文：'已使用'
  ///
  /// In zh, this message translates to:
  /// **'已使用'**
  String get couponProviders_13;

  /// 来源：lib/features/marketing/coupon_providers.dart:16；原文：'已过期'
  ///
  /// In zh, this message translates to:
  /// **'已过期'**
  String get couponProviders_16;

  /// 来源：lib/features/marketing/coupon_providers.dart:110；原文：'兑换码兑换券'
  ///
  /// In zh, this message translates to:
  /// **'兑换码兑换券'**
  String get couponProviders_110;

  /// 来源：lib/features/marketing/coupon_providers.dart:111；原文：'通过兑换码获得'
  ///
  /// In zh, this message translates to:
  /// **'通过兑换码获得'**
  String get couponProviders_111;

  /// 来源：lib/features/marketing/coupon_providers.dart:124；原文：'兑换码无效，请检查后重试'
  ///
  /// In zh, this message translates to:
  /// **'兑换码无效，请检查后重试'**
  String get couponProviders_124;

  /// 来源：lib/features/marketing/exchange_coupon_page.dart:32；原文：'兑换成功：${next.result!.title}'
  ///
  /// In zh, this message translates to:
  /// **'兑换成功：{title}'**
  String exchangeCouponPage_32(Object title);

  /// 来源：lib/features/marketing/exchange_coupon_page.dart:47；原文：'兑换优惠券'
  ///
  /// In zh, this message translates to:
  /// **'兑换优惠券'**
  String get exchangeCouponPage_47;

  /// 来源：lib/features/marketing/exchange_coupon_page.dart:71；原文：'输入兑换码领取优惠券，兑换码由活动方发放'
  ///
  /// In zh, this message translates to:
  /// **'输入兑换码领取优惠券，兑换码由活动方发放'**
  String get exchangeCouponPage_71;

  /// 来源：lib/features/marketing/exchange_coupon_page.dart:84；原文：'兑换码'
  ///
  /// In zh, this message translates to:
  /// **'兑换码'**
  String get exchangeCouponPage_84;

  /// 来源：lib/features/marketing/exchange_coupon_page.dart:95；原文：'请输入兑换码'
  ///
  /// In zh, this message translates to:
  /// **'请输入兑换码'**
  String get exchangeCouponPage_95;

  /// 来源：lib/features/marketing/exchange_coupon_page.dart:155；原文：'立即兑换'
  ///
  /// In zh, this message translates to:
  /// **'立即兑换'**
  String get exchangeCouponPage_155;

  /// 来源：lib/features/marketing/giftcard/add_gift_card_page.dart:67；原文：'绑定礼品卡'
  ///
  /// In zh, this message translates to:
  /// **'绑定礼品卡'**
  String get addGiftCardPage_67;

  /// 来源：lib/features/marketing/giftcard/add_gift_card_page.dart:74；原文：'请输入礼品卡卡号'
  ///
  /// In zh, this message translates to:
  /// **'请输入礼品卡卡号'**
  String get addGiftCardPage_74;

  /// 来源：lib/features/marketing/giftcard/add_gift_card_page.dart:91；原文：'输入礼品卡卡号 / 密码'
  ///
  /// In zh, this message translates to:
  /// **'输入礼品卡卡号 / 密码'**
  String get addGiftCardPage_91;

  /// 来源：lib/features/marketing/giftcard/add_gift_card_page.dart:135；原文：'绑定'
  ///
  /// In zh, this message translates to:
  /// **'绑定'**
  String get addGiftCardPage_135;

  /// 来源：lib/features/marketing/giftcard/add_gift_card_page.dart:155；原文：'使用说明'
  ///
  /// In zh, this message translates to:
  /// **'使用说明'**
  String get addGiftCardPage_155;

  /// 来源：lib/features/marketing/giftcard/add_gift_card_page.dart:164；原文：'1. 礼品卡卡号在实体卡背面刮开涂层后获取\n'
  ///                     '2. 绑定成功后余额可在下单时抵扣\n'
  ///                     '3. 礼品卡不可叠加使用，不记名不挂失\n'
  ///                     '4. 有效期以礼品卡标注为准'
  ///
  /// In zh, this message translates to:
  /// **'1. 礼品卡卡号在实体卡背面刮开涂层后获取\n2. 绑定成功后余额可在下单时抵扣\n3. 礼品卡不可叠加使用，不记名不挂失\n4. 有效期以礼品卡标注为准'**
  String get addGiftCardPage_164;

  /// 来源：lib/features/marketing/giftcard/gift_card.dart:96；原文：'${effectiveTo.year}-${two(effectiveTo.month)}-${two(effectiveTo.day)}到期'
  ///
  /// In zh, this message translates to:
  /// **'{year}-{month}-{day}到期'**
  String giftCard_96(Object year, Object month, Object day);

  /// 来源：lib/features/marketing/giftcard/gift_card.dart:100；原文：'面值 ${denomination.format()}'
  ///
  /// In zh, this message translates to:
  /// **'面值 {format}'**
  String giftCard_100(Object format);

  /// 来源：lib/features/marketing/giftcard/gift_card.dart:103；原文：'余额 ${balance.format()}'
  ///
  /// In zh, this message translates to:
  /// **'余额 {format}'**
  String giftCard_103(Object format);

  /// 来源：lib/features/marketing/giftcard/gift_card_page.dart:30；原文：'礼品卡'
  ///
  /// In zh, this message translates to:
  /// **'礼品卡'**
  String get giftCardPage_30;

  /// 来源：lib/features/marketing/giftcard/gift_card_page.dart:34；原文：'绑定'
  ///
  /// In zh, this message translates to:
  /// **'绑定'**
  String get giftCardPage_34;

  /// 来源：lib/features/marketing/giftcard/gift_card_page.dart:41；原文：'暂无礼品卡'
  ///
  /// In zh, this message translates to:
  /// **'暂无礼品卡'**
  String get giftCardPage_41;

  /// 来源：lib/features/marketing/giftcard/gift_card_page.dart:42；原文：'绑定礼品卡后可在此查看和使用'
  ///
  /// In zh, this message translates to:
  /// **'绑定礼品卡后可在此查看和使用'**
  String get giftCardPage_42;

  /// 来源：lib/features/marketing/giftcard/gift_card_page.dart:49；原文：'可用礼品卡'
  ///
  /// In zh, this message translates to:
  /// **'可用礼品卡'**
  String get giftCardPage_49;

  /// 来源：lib/features/marketing/giftcard/gift_card_page.dart:57；原文：'不可用礼品卡'
  ///
  /// In zh, this message translates to:
  /// **'不可用礼品卡'**
  String get giftCardPage_57;

  /// 来源：lib/features/marketing/giftcard/gift_card_page.dart:158；原文：'面值'
  ///
  /// In zh, this message translates to:
  /// **'面值'**
  String get giftCardPage_158;

  /// 来源：lib/features/marketing/giftcard/gift_card_page.dart:196；原文：'余额 '
  ///
  /// In zh, this message translates to:
  /// **'余额 '**
  String get giftCardPage_196;

  /// 来源：lib/features/marketing/giftcard/gift_card_page.dart:224；原文：'即将过期'
  ///
  /// In zh, this message translates to:
  /// **'即将过期'**
  String get giftCardPage_224;

  /// 来源：lib/features/marketing/giftcard/gift_card_providers.dart:54；原文：'请输入礼品卡卡号'
  ///
  /// In zh, this message translates to:
  /// **'请输入礼品卡卡号'**
  String get giftCardProviders_54;

  /// 来源：lib/features/marketing/giftcard/gift_card_providers.dart:65；原文：'礼品卡绑定成功，已添加 200 星币余额'
  ///
  /// In zh, this message translates to:
  /// **'礼品卡绑定成功，已添加 200 星币余额'**
  String get giftCardProviders_65;

  /// 来源：lib/features/marketing/wallet.dart:56；原文：'余额 ${balanceAfter.format()}'
  ///
  /// In zh, this message translates to:
  /// **'余额 {format}'**
  String wallet_56(Object format);

  /// 来源：lib/features/marketing/wallet_page.dart:31；原文：'我的钱包'
  ///
  /// In zh, this message translates to:
  /// **'我的钱包'**
  String get walletPage_31;

  /// 来源：lib/features/marketing/wallet_page.dart:35；原文：'充值流程待接入支付 SDK'
  ///
  /// In zh, this message translates to:
  /// **'充值流程待接入支付 SDK'**
  String get walletPage_35;

  /// 来源：lib/features/marketing/wallet_page.dart:35；原文：'提现需要先绑定银行卡'
  ///
  /// In zh, this message translates to:
  /// **'提现需要先绑定银行卡'**
  String get walletPage_35_2;

  /// 来源：lib/features/marketing/wallet_page.dart:39；原文：'暂无交易记录'
  ///
  /// In zh, this message translates to:
  /// **'暂无交易记录'**
  String get walletPage_39;

  /// 来源：lib/features/marketing/wallet_page.dart:40；原文：'充值或消费后会有记录显示在这里'
  ///
  /// In zh, this message translates to:
  /// **'充值或消费后会有记录显示在这里'**
  String get walletPage_40;

  /// 来源：lib/features/marketing/wallet_page.dart:94；原文：'当前余额（星币）'
  ///
  /// In zh, this message translates to:
  /// **'当前余额（星币）'**
  String get walletPage_94;

  /// 来源：lib/features/marketing/wallet_page.dart:143；原文：'充值'
  ///
  /// In zh, this message translates to:
  /// **'充值'**
  String get walletPage_143;

  /// 来源：lib/features/marketing/wallet_page.dart:152；原文：'提现'
  ///
  /// In zh, this message translates to:
  /// **'提现'**
  String get walletPage_152;

  /// 来源：lib/features/marketing/wallet_providers.dart:21；原文：'充值'
  ///
  /// In zh, this message translates to:
  /// **'充值'**
  String get walletProviders_21;

  /// 来源：lib/features/marketing/wallet_providers.dart:29；原文：'购买「五月天演唱会」门票'
  ///
  /// In zh, this message translates to:
  /// **'支持「五月天音乐影像企划」'**
  String get walletProviders_29;

  /// 来源：lib/features/marketing/wallet_providers.dart:37；原文：'退款入账 - 订单 P20261101001'
  ///
  /// In zh, this message translates to:
  /// **'退款入账 - 订单 P20261101001'**
  String get walletProviders_37;

  /// 来源：lib/features/marketing/wallet_providers.dart:45；原文：'新人注册赠送'
  ///
  /// In zh, this message translates to:
  /// **'新人注册赠送'**
  String get walletProviders_45;

  /// 来源：lib/features/marketing/wallet_providers.dart:53；原文：'购买「脱口秀大会」门票'
  ///
  /// In zh, this message translates to:
  /// **'支持「脱口秀大会现场企划」'**
  String get walletProviders_53;

  /// 来源：lib/features/mall/mall_page.dart；星币商城页标题
  ///
  /// In zh, this message translates to:
  /// **'星币商城'**
  String get mallPage_1;

  /// 来源：lib/features/mall/mall_page.dart；余额区标题
  ///
  /// In zh, this message translates to:
  /// **'当前星币余额'**
  String get mallPage_2;

  /// 来源：lib/features/mall/mall_page.dart；规格价格
  ///
  /// In zh, this message translates to:
  /// **'价格 {price}'**
  String mallPage_3(Object price);

  /// 来源：lib/features/mall/mall_page.dart；规格限量
  ///
  /// In zh, this message translates to:
  /// **'限量 {count} 份'**
  String mallPage_4(Object count);

  /// 来源：lib/features/mall/mall_page.dart；规格剩余库存
  ///
  /// In zh, this message translates to:
  /// **'剩余 {stock} 份'**
  String mallPage_5(Object stock);

  /// 来源：lib/features/mall/mall_page.dart；兑换按钮
  ///
  /// In zh, this message translates to:
  /// **'兑换'**
  String get mallPage_6;

  /// 来源：lib/features/mall/mall_page.dart；售罄按钮
  ///
  /// In zh, this message translates to:
  /// **'已售罄'**
  String get mallPage_7;

  /// 来源：lib/features/mall/mall_page.dart；余额不足提示
  ///
  /// In zh, this message translates to:
  /// **'星币余额不足'**
  String get mallPage_8;

  /// 来源：lib/features/mall/mall_page.dart；二次确认标题
  ///
  /// In zh, this message translates to:
  /// **'确认兑换'**
  String get mallPage_9;

  /// 来源：lib/features/mall/mall_page.dart；二次确认内容
  ///
  /// In zh, this message translates to:
  /// **'兑换「{name}」将消耗 {price}'**
  String mallPage_10(Object name, Object price);

  /// 来源：lib/features/mall/mall_page.dart；取消按钮
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get mallPage_11;

  /// 来源：lib/features/mall/mall_page.dart；确认按钮
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get mallPage_12;

  /// 来源：lib/features/mall/mall_page.dart；兑换成功提示
  ///
  /// In zh, this message translates to:
  /// **'兑换成功'**
  String get mallPage_13;

  /// 来源：lib/features/mall/mall_page.dart；空态标题
  ///
  /// In zh, this message translates to:
  /// **'暂无可兑换商品'**
  String get mallPage_14;

  /// 来源：lib/features/mall/mall_page.dart；空态说明
  ///
  /// In zh, this message translates to:
  /// **'商品上架后会显示在这里'**
  String get mallPage_15;

  /// 来源：lib/features/mall/mall_page.dart；错误态重试
  ///
  /// In zh, this message translates to:
  /// **'重新加载'**
  String get mallPage_16;
}

class _MarketingLocalizationsDelegate extends LocalizationsDelegate<MarketingLocalizations> {
  const _MarketingLocalizationsDelegate();

  @override
  Future<MarketingLocalizations> load(Locale locale) {
    return SynchronousFuture<MarketingLocalizations>(lookupMarketingLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_MarketingLocalizationsDelegate old) => false;
}

MarketingLocalizations lookupMarketingLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return MarketingLocalizationsEn();
    case 'zh': return MarketingLocalizationsZh();
  }

  throw FlutterError(
    'MarketingLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
