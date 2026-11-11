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
/// import 'generated/proxy_buy_localizations.dart';
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

  /// No description provided for @proxyBuy_142.
  ///
  /// In zh, this message translates to:
  /// **'待代购'**
  String get proxyBuy_142;

  /// No description provided for @proxyBuy_144.
  ///
  /// In zh, this message translates to:
  /// **'代购中'**
  String get proxyBuy_144;

  /// No description provided for @proxyBuy_146.
  ///
  /// In zh, this message translates to:
  /// **'代购成功'**
  String get proxyBuy_146;

  /// No description provided for @proxyBuy_148.
  ///
  /// In zh, this message translates to:
  /// **'代购失败'**
  String get proxyBuy_148;

  /// No description provided for @proxyBuy_150.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get proxyBuy_150;

  /// No description provided for @proxyBuyPage_30.
  ///
  /// In zh, this message translates to:
  /// **'代购服务'**
  String get proxyBuyPage_30;

  /// No description provided for @proxyBuyPage_36.
  ///
  /// In zh, this message translates to:
  /// **'我的代购订单'**
  String get proxyBuyPage_36;

  /// No description provided for @proxyBuyPage_39.
  ///
  /// In zh, this message translates to:
  /// **'暂无代购订单'**
  String get proxyBuyPage_39;

  /// No description provided for @proxyBuyPage_40.
  ///
  /// In zh, this message translates to:
  /// **'参与代购后订单会显示在这里'**
  String get proxyBuyPage_40;

  /// No description provided for @proxyBuyPage_81.
  ///
  /// In zh, this message translates to:
  /// **'代购规则'**
  String get proxyBuyPage_81;

  /// No description provided for @proxyBuyPage_98.
  ///
  /// In zh, this message translates to:
  /// **'含赔付'**
  String get proxyBuyPage_98;

  /// No description provided for @proxyBuyPage_118.
  ///
  /// In zh, this message translates to:
  /// **'代购服务费：'**
  String get proxyBuyPage_118;

  /// No description provided for @proxyBuyPage_122.
  ///
  /// In zh, this message translates to:
  /// **'{format}/份'**
  String proxyBuyPage_122(Object format);

  /// No description provided for @proxyBuyPage_165.
  ///
  /// In zh, this message translates to:
  /// **'选择截止时间'**
  String get proxyBuyPage_165;

  /// No description provided for @proxyBuyPage_303.
  ///
  /// In zh, this message translates to:
  /// **'活动场地'**
  String get proxyBuyPage_303;

  /// No description provided for @proxyBuyPage_305.
  ///
  /// In zh, this message translates to:
  /// **'活动时间'**
  String get proxyBuyPage_305;

  /// No description provided for @proxyBuyPage_307.
  ///
  /// In zh, this message translates to:
  /// **'截止'**
  String get proxyBuyPage_307;

  /// No description provided for @proxyBuyPage_314.
  ///
  /// In zh, this message translates to:
  /// **'{quantity}份 × {format}'**
  String proxyBuyPage_314(Object quantity, Object format);

  /// No description provided for @proxyBuyPage_322.
  ///
  /// In zh, this message translates to:
  /// **'代购费 {format}/份'**
  String proxyBuyPage_322(Object format);

  /// No description provided for @proxyBuyPage_334.
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
