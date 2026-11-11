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

  /// No description provided for @coupon_115.
  ///
  /// In zh, this message translates to:
  /// **'{rate}折'**
  String coupon_115(Object rate);

  /// No description provided for @coupon_120.
  ///
  /// In zh, this message translates to:
  /// **'满{format}可用'**
  String coupon_120(Object format);

  /// No description provided for @coupon_120_2.
  ///
  /// In zh, this message translates to:
  /// **'无门槛'**
  String get coupon_120_2;

  /// No description provided for @coupon_125.
  ///
  /// In zh, this message translates to:
  /// **'{year}-{month}-{day}到期'**
  String coupon_125(Object year, Object month, Object day);

  /// No description provided for @couponPage_30.
  ///
  /// In zh, this message translates to:
  /// **'我的优惠券'**
  String get couponPage_30;

  /// No description provided for @couponPage_34.
  ///
  /// In zh, this message translates to:
  /// **'兑换'**
  String get couponPage_34;

  /// No description provided for @couponPage_97.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用优惠券'**
  String get couponPage_97;

  /// No description provided for @couponPage_98.
  ///
  /// In zh, this message translates to:
  /// **'暂无已使用记录'**
  String get couponPage_98;

  /// No description provided for @couponPage_99.
  ///
  /// In zh, this message translates to:
  /// **'暂无过期优惠券'**
  String get couponPage_99;

  /// No description provided for @couponPage_102.
  ///
  /// In zh, this message translates to:
  /// **'去首页领取更多优惠'**
  String get couponPage_102;

  /// No description provided for @couponPage_103.
  ///
  /// In zh, this message translates to:
  /// **'已使用的券会显示在这里'**
  String get couponPage_103;

  /// No description provided for @couponPage_104.
  ///
  /// In zh, this message translates to:
  /// **'过期的券会显示在这里'**
  String get couponPage_104;

  /// No description provided for @couponPage_107.
  ///
  /// In zh, this message translates to:
  /// **'去逛逛'**
  String get couponPage_107;

  /// No description provided for @couponPage_208.
  ///
  /// In zh, this message translates to:
  /// **'仅剩{daysUntilExpiry}天'**
  String couponPage_208(Object daysUntilExpiry);

  /// No description provided for @couponPage_290.
  ///
  /// In zh, this message translates to:
  /// **'折'**
  String get couponPage_290;

  /// No description provided for @couponPage_302.
  ///
  /// In zh, this message translates to:
  /// **'抵扣'**
  String get couponPage_302;

  /// No description provided for @couponProviders_10.
  ///
  /// In zh, this message translates to:
  /// **'可使用'**
  String get couponProviders_10;

  /// No description provided for @couponProviders_13.
  ///
  /// In zh, this message translates to:
  /// **'已使用'**
  String get couponProviders_13;

  /// No description provided for @couponProviders_16.
  ///
  /// In zh, this message translates to:
  /// **'已过期'**
  String get couponProviders_16;

  /// No description provided for @couponProviders_110.
  ///
  /// In zh, this message translates to:
  /// **'兑换码兑换券'**
  String get couponProviders_110;

  /// No description provided for @couponProviders_111.
  ///
  /// In zh, this message translates to:
  /// **'通过兑换码获得'**
  String get couponProviders_111;

  /// No description provided for @couponProviders_124.
  ///
  /// In zh, this message translates to:
  /// **'兑换码无效，请检查后重试'**
  String get couponProviders_124;

  /// No description provided for @exchangeCouponPage_32.
  ///
  /// In zh, this message translates to:
  /// **'兑换成功：{title}'**
  String exchangeCouponPage_32(Object title);

  /// No description provided for @exchangeCouponPage_47.
  ///
  /// In zh, this message translates to:
  /// **'兑换优惠券'**
  String get exchangeCouponPage_47;

  /// No description provided for @exchangeCouponPage_71.
  ///
  /// In zh, this message translates to:
  /// **'输入兑换码领取优惠券，兑换码由活动方发放'**
  String get exchangeCouponPage_71;

  /// No description provided for @exchangeCouponPage_84.
  ///
  /// In zh, this message translates to:
  /// **'兑换码'**
  String get exchangeCouponPage_84;

  /// No description provided for @exchangeCouponPage_95.
  ///
  /// In zh, this message translates to:
  /// **'请输入兑换码'**
  String get exchangeCouponPage_95;

  /// No description provided for @exchangeCouponPage_155.
  ///
  /// In zh, this message translates to:
  /// **'立即兑换'**
  String get exchangeCouponPage_155;

  /// No description provided for @addGiftCardPage_67.
  ///
  /// In zh, this message translates to:
  /// **'绑定礼品卡'**
  String get addGiftCardPage_67;

  /// No description provided for @addGiftCardPage_74.
  ///
  /// In zh, this message translates to:
  /// **'请输入礼品卡卡号'**
  String get addGiftCardPage_74;

  /// No description provided for @addGiftCardPage_91.
  ///
  /// In zh, this message translates to:
  /// **'输入礼品卡卡号 / 密码'**
  String get addGiftCardPage_91;

  /// No description provided for @addGiftCardPage_135.
  ///
  /// In zh, this message translates to:
  /// **'绑定'**
  String get addGiftCardPage_135;

  /// No description provided for @addGiftCardPage_155.
  ///
  /// In zh, this message translates to:
  /// **'使用说明'**
  String get addGiftCardPage_155;

  /// No description provided for @addGiftCardPage_164.
  ///
  /// In zh, this message translates to:
  /// **'1. 礼品卡卡号在实体卡背面刮开涂层后获取\n2. 绑定成功后余额可在下单时抵扣\n3. 礼品卡不可叠加使用，不记名不挂失\n4. 有效期以礼品卡标注为准'**
  String get addGiftCardPage_164;

  /// No description provided for @giftCard_96.
  ///
  /// In zh, this message translates to:
  /// **'{year}-{month}-{day}到期'**
  String giftCard_96(Object year, Object month, Object day);

  /// No description provided for @giftCard_100.
  ///
  /// In zh, this message translates to:
  /// **'面值 {format}'**
  String giftCard_100(Object format);

  /// No description provided for @giftCard_103.
  ///
  /// In zh, this message translates to:
  /// **'余额 {format}'**
  String giftCard_103(Object format);

  /// No description provided for @giftCardPage_30.
  ///
  /// In zh, this message translates to:
  /// **'礼品卡'**
  String get giftCardPage_30;

  /// No description provided for @giftCardPage_34.
  ///
  /// In zh, this message translates to:
  /// **'绑定'**
  String get giftCardPage_34;

  /// No description provided for @giftCardPage_41.
  ///
  /// In zh, this message translates to:
  /// **'暂无礼品卡'**
  String get giftCardPage_41;

  /// No description provided for @giftCardPage_42.
  ///
  /// In zh, this message translates to:
  /// **'绑定礼品卡后可在此查看和使用'**
  String get giftCardPage_42;

  /// No description provided for @giftCardPage_49.
  ///
  /// In zh, this message translates to:
  /// **'可用礼品卡'**
  String get giftCardPage_49;

  /// No description provided for @giftCardPage_57.
  ///
  /// In zh, this message translates to:
  /// **'不可用礼品卡'**
  String get giftCardPage_57;

  /// No description provided for @giftCardPage_158.
  ///
  /// In zh, this message translates to:
  /// **'面值'**
  String get giftCardPage_158;

  /// No description provided for @giftCardPage_196.
  ///
  /// In zh, this message translates to:
  /// **'余额 '**
  String get giftCardPage_196;

  /// No description provided for @giftCardPage_224.
  ///
  /// In zh, this message translates to:
  /// **'即将过期'**
  String get giftCardPage_224;

  /// No description provided for @giftCardProviders_54.
  ///
  /// In zh, this message translates to:
  /// **'请输入礼品卡卡号'**
  String get giftCardProviders_54;

  /// No description provided for @giftCardProviders_65.
  ///
  /// In zh, this message translates to:
  /// **'礼品卡绑定成功，已添加 200 星币余额'**
  String get giftCardProviders_65;

  /// No description provided for @wallet_56.
  ///
  /// In zh, this message translates to:
  /// **'余额 {format}'**
  String wallet_56(Object format);

  /// No description provided for @walletPage_31.
  ///
  /// In zh, this message translates to:
  /// **'我的钱包'**
  String get walletPage_31;

  /// No description provided for @walletPage_35.
  ///
  /// In zh, this message translates to:
  /// **'充值流程待接入支付 SDK'**
  String get walletPage_35;

  /// No description provided for @walletPage_35_2.
  ///
  /// In zh, this message translates to:
  /// **'提现需要先绑定银行卡'**
  String get walletPage_35_2;

  /// No description provided for @walletPage_39.
  ///
  /// In zh, this message translates to:
  /// **'暂无交易记录'**
  String get walletPage_39;

  /// No description provided for @walletPage_40.
  ///
  /// In zh, this message translates to:
  /// **'充值或消费后会有记录显示在这里'**
  String get walletPage_40;

  /// No description provided for @walletPage_94.
  ///
  /// In zh, this message translates to:
  /// **'当前余额（星币）'**
  String get walletPage_94;

  /// No description provided for @walletPage_143.
  ///
  /// In zh, this message translates to:
  /// **'充值'**
  String get walletPage_143;

  /// No description provided for @walletPage_152.
  ///
  /// In zh, this message translates to:
  /// **'提现'**
  String get walletPage_152;

  /// No description provided for @walletProviders_21.
  ///
  /// In zh, this message translates to:
  /// **'充值'**
  String get walletProviders_21;

  /// No description provided for @walletProviders_29.
  ///
  /// In zh, this message translates to:
  /// **'支持「五月天音乐影像企划」'**
  String get walletProviders_29;

  /// No description provided for @walletProviders_37.
  ///
  /// In zh, this message translates to:
  /// **'退款入账 - 订单 P20261101001'**
  String get walletProviders_37;

  /// No description provided for @walletProviders_45.
  ///
  /// In zh, this message translates to:
  /// **'新人注册赠送'**
  String get walletProviders_45;

  /// No description provided for @walletProviders_53.
  ///
  /// In zh, this message translates to:
  /// **'支持「脱口秀大会现场企划」'**
  String get walletProviders_53;

  /// No description provided for @mallPage_1.
  ///
  /// In zh, this message translates to:
  /// **'星币商城'**
  String get mallPage_1;

  /// No description provided for @mallPage_2.
  ///
  /// In zh, this message translates to:
  /// **'当前星币余额'**
  String get mallPage_2;

  /// No description provided for @mallPage_3.
  ///
  /// In zh, this message translates to:
  /// **'价格 {price}'**
  String mallPage_3(Object price);

  /// No description provided for @mallPage_4.
  ///
  /// In zh, this message translates to:
  /// **'限量 {count} 份'**
  String mallPage_4(Object count);

  /// No description provided for @mallPage_5.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {stock} 份'**
  String mallPage_5(Object stock);

  /// No description provided for @mallPage_6.
  ///
  /// In zh, this message translates to:
  /// **'兑换'**
  String get mallPage_6;

  /// No description provided for @mallPage_7.
  ///
  /// In zh, this message translates to:
  /// **'已售罄'**
  String get mallPage_7;

  /// No description provided for @mallPage_8.
  ///
  /// In zh, this message translates to:
  /// **'星币余额不足'**
  String get mallPage_8;

  /// No description provided for @mallPage_9.
  ///
  /// In zh, this message translates to:
  /// **'确认兑换'**
  String get mallPage_9;

  /// No description provided for @mallPage_10.
  ///
  /// In zh, this message translates to:
  /// **'兑换「{name}」将消耗 {price}'**
  String mallPage_10(Object name, Object price);

  /// No description provided for @mallPage_11.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get mallPage_11;

  /// No description provided for @mallPage_12.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get mallPage_12;

  /// No description provided for @mallPage_13.
  ///
  /// In zh, this message translates to:
  /// **'兑换成功'**
  String get mallPage_13;

  /// No description provided for @mallPage_14.
  ///
  /// In zh, this message translates to:
  /// **'暂无可兑换商品'**
  String get mallPage_14;

  /// No description provided for @mallPage_15.
  ///
  /// In zh, this message translates to:
  /// **'商品上架后会显示在这里'**
  String get mallPage_15;

  /// No description provided for @mallPage_16.
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
