import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'proxy_buy_localizations_en.dart';
import 'proxy_buy_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ProxyBuyLocalizations
/// returned by `ProxyBuyLocalizations.of(context)`.
///
/// Applications need to include `ProxyBuyLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/proxy_buy_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ProxyBuyLocalizations.localizationsDelegates,
///   supportedLocales: ProxyBuyLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the ProxyBuyLocalizations.supportedLocales
/// property.
abstract class ProxyBuyLocalizations {
  ProxyBuyLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ProxyBuyLocalizations of(BuildContext context) {
    return Localizations.of<ProxyBuyLocalizations>(context, ProxyBuyLocalizations)!;
  }

  static const LocalizationsDelegate<ProxyBuyLocalizations> delegate = _ProxyBuyLocalizationsDelegate();

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

  /// 来源：lib/features/proxy_buy/proxy_buy.dart:142；原文：'待抢票'
  ///
  /// In zh, this message translates to:
  /// **'待抢票'**
  String get proxyBuy_142;

  /// 来源：lib/features/proxy_buy/proxy_buy.dart:144；原文：'抢票中'
  ///
  /// In zh, this message translates to:
  /// **'抢票中'**
  String get proxyBuy_144;

  /// 来源：lib/features/proxy_buy/proxy_buy.dart:146；原文：'抢票成功'
  ///
  /// In zh, this message translates to:
  /// **'抢票成功'**
  String get proxyBuy_146;

  /// 来源：lib/features/proxy_buy/proxy_buy.dart:148；原文：'抢票失败'
  ///
  /// In zh, this message translates to:
  /// **'抢票失败'**
  String get proxyBuy_148;

  /// 来源：lib/features/proxy_buy/proxy_buy.dart:150；原文：'已取消'
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get proxyBuy_150;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:30；原文：'代抢服务'
  ///
  /// In zh, this message translates to:
  /// **'代抢服务'**
  String get proxyBuyPage_30;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:36；原文：'我的代抢订单'
  ///
  /// In zh, this message translates to:
  /// **'我的代抢订单'**
  String get proxyBuyPage_36;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:39；原文：'暂无代抢订单'
  ///
  /// In zh, this message translates to:
  /// **'暂无代抢订单'**
  String get proxyBuyPage_39;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:40；原文：'参与代抢后订单会显示在这里'
  ///
  /// In zh, this message translates to:
  /// **'参与代抢后订单会显示在这里'**
  String get proxyBuyPage_40;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:81；原文：'代抢规则'
  ///
  /// In zh, this message translates to:
  /// **'代抢规则'**
  String get proxyBuyPage_81;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:98；原文：'含赔付'
  ///
  /// In zh, this message translates to:
  /// **'含赔付'**
  String get proxyBuyPage_98;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:118；原文：'代抢服务费：'
  ///
  /// In zh, this message translates to:
  /// **'代抢服务费：'**
  String get proxyBuyPage_118;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:122；原文：'${info.proxyBuyFee.format()}/张'
  ///
  /// In zh, this message translates to:
  /// **'{format}/张'**
  String proxyBuyPage_122(Object format);

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:165；原文：'选择截止时间'
  ///
  /// In zh, this message translates to:
  /// **'选择截止时间'**
  String get proxyBuyPage_165;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:303；原文：'场馆'
  ///
  /// In zh, this message translates to:
  /// **'场馆'**
  String get proxyBuyPage_303;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:305；原文：'场次'
  ///
  /// In zh, this message translates to:
  /// **'场次'**
  String get proxyBuyPage_305;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:307；原文：'截止'
  ///
  /// In zh, this message translates to:
  /// **'截止'**
  String get proxyBuyPage_307;

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:314；原文：'${order.quantity}张 × ${order.ticketPrice.format()}'
  ///
  /// In zh, this message translates to:
  /// **'{quantity}张 × {format}'**
  String proxyBuyPage_314(Object quantity, Object format);

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:322；原文：'代抢费 ${order.proxyBuyFee.format()}/张'
  ///
  /// In zh, this message translates to:
  /// **'代抢费 {format}/张'**
  String proxyBuyPage_322(Object format);

  /// 来源：lib/features/proxy_buy/proxy_buy_page.dart:334；原文：'合计 '
  ///
  /// In zh, this message translates to:
  /// **'合计 '**
  String get proxyBuyPage_334;
}

class _ProxyBuyLocalizationsDelegate extends LocalizationsDelegate<ProxyBuyLocalizations> {
  const _ProxyBuyLocalizationsDelegate();

  @override
  Future<ProxyBuyLocalizations> load(Locale locale) {
    return SynchronousFuture<ProxyBuyLocalizations>(lookupProxyBuyLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_ProxyBuyLocalizationsDelegate old) => false;
}

ProxyBuyLocalizations lookupProxyBuyLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return ProxyBuyLocalizationsEn();
    case 'zh': return ProxyBuyLocalizationsZh();
  }

  throw FlutterError(
    'ProxyBuyLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
