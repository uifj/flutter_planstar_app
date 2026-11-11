import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'catalog_localizations_en.dart';
import 'catalog_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CatalogLocalizations
/// returned by `CatalogLocalizations.of(context)`.
///
/// Applications need to include `CatalogLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/catalog_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CatalogLocalizations.localizationsDelegates,
///   supportedLocales: CatalogLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the CatalogLocalizations.supportedLocales
/// property.
abstract class CatalogLocalizations {
  CatalogLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CatalogLocalizations of(BuildContext context) {
    return Localizations.of<CatalogLocalizations>(context, CatalogLocalizations)!;
  }

  static const LocalizationsDelegate<CatalogLocalizations> delegate = _CatalogLocalizationsDelegate();

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

  /// No description provided for @catalogProviders_74.
  ///
  /// In zh, this message translates to:
  /// **'上海'**
  String get catalogProviders_74;

  /// No description provided for @showCategory_95.
  ///
  /// In zh, this message translates to:
  /// **'{address} · {showCount} 个企划'**
  String showCategory_95(Object address, Object showCount);

  /// No description provided for @showSummary_165.
  ///
  /// In zh, this message translates to:
  /// **'{text}折'**
  String showSummary_165(Object text);

  /// No description provided for @showSummary_178.
  ///
  /// In zh, this message translates to:
  /// **'暂时售罄'**
  String get showSummary_178;

  /// No description provided for @showSummary_178_2.
  ///
  /// In zh, this message translates to:
  /// **'支持中'**
  String get showSummary_178_2;

  /// No description provided for @showSummary_263.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get showSummary_263;

  /// No description provided for @showSummary_263_2.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get showSummary_263_2;

  /// No description provided for @showSummary_263_3.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get showSummary_263_3;

  /// No description provided for @showSummary_263_4.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get showSummary_263_4;

  /// No description provided for @showSummary_263_5.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get showSummary_263_5;

  /// No description provided for @showSummary_263_6.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get showSummary_263_6;

  /// No description provided for @showSummary_263_7.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get showSummary_263_7;

  /// No description provided for @showSummary_266.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日 {weekday} {hour}:{minute}'**
  String showSummary_266(Object month, Object day, Object weekday, Object hour, Object minute);

  /// No description provided for @showSummary_280.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get showSummary_280;

  /// No description provided for @showSummary_281.
  ///
  /// In zh, this message translates to:
  /// **'{inMinutes}分钟前'**
  String showSummary_281(Object inMinutes);

  /// No description provided for @showSummary_285.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get showSummary_285;

  /// No description provided for @showSummary_286.
  ///
  /// In zh, this message translates to:
  /// **'{inDays}天前'**
  String showSummary_286(Object inDays);

  /// No description provided for @showSummary_287.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日'**
  String showSummary_287(Object month, Object day);

  /// No description provided for @categoryHomePage_116.
  ///
  /// In zh, this message translates to:
  /// **'{city} 暂无{name}企划'**
  String categoryHomePage_116(Object city, Object name);

  /// No description provided for @categoryHomePage_unknownCategory.
  ///
  /// In zh, this message translates to:
  /// **'该分类'**
  String get categoryHomePage_unknownCategory;

  /// No description provided for @categoryHomePage_117.
  ///
  /// In zh, this message translates to:
  /// **'试试切换城市或查看其他分类'**
  String get categoryHomePage_117;

  /// No description provided for @categoryHomePage_119.
  ///
  /// In zh, this message translates to:
  /// **'去首页'**
  String get categoryHomePage_119;

  /// No description provided for @categoryHomePage_403.
  ///
  /// In zh, this message translates to:
  /// **'起'**
  String get categoryHomePage_403;

  /// No description provided for @categoryHomePage_406.
  ///
  /// In zh, this message translates to:
  /// **'{wishCount} 人想看'**
  String categoryHomePage_406(Object wishCount);

  /// No description provided for @showCards_72.
  ///
  /// In zh, this message translates to:
  /// **'暂时售罄'**
  String get showCards_72;

  /// No description provided for @showCards_75.
  ///
  /// In zh, this message translates to:
  /// **'起'**
  String get showCards_75;

  /// No description provided for @showCards_156.
  ///
  /// In zh, this message translates to:
  /// **'暂时售罄'**
  String get showCards_156;

  /// No description provided for @showCards_175.
  ///
  /// In zh, this message translates to:
  /// **'{discountLabel}起'**
  String showCards_175(Object discountLabel);

  /// No description provided for @showCards_270.
  ///
  /// In zh, this message translates to:
  /// **'暂时售罄'**
  String get showCards_270;

  /// No description provided for @showCards_277.
  ///
  /// In zh, this message translates to:
  /// **'起'**
  String get showCards_277;

  /// No description provided for @showListPage_78.
  ///
  /// In zh, this message translates to:
  /// **'该分类暂无企划'**
  String get showListPage_78;

  /// No description provided for @showListPage_79.
  ///
  /// In zh, this message translates to:
  /// **'换个分类或城市看看'**
  String get showListPage_79;

  /// No description provided for @showListPage_81.
  ///
  /// In zh, this message translates to:
  /// **'看全部企划'**
  String get showListPage_81;

  /// No description provided for @showListPage_112.
  ///
  /// In zh, this message translates to:
  /// **'全部企划'**
  String get showListPage_112;

  /// No description provided for @showListPage_140.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get showListPage_140;

  /// No description provided for @showListPage_141.
  ///
  /// In zh, this message translates to:
  /// **'最近开演'**
  String get showListPage_141;

  /// No description provided for @showListPage_142.
  ///
  /// In zh, this message translates to:
  /// **'价格最低'**
  String get showListPage_142;

  /// No description provided for @showListPage_172.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get showListPage_172;

  /// No description provided for @showListPage_249.
  ///
  /// In zh, this message translates to:
  /// **'共 {total} 场'**
  String showListPage_249(Object total);

  /// No description provided for @projectCardAchievement.
  ///
  /// In zh, this message translates to:
  /// **'{rate}%'**
  String projectCardAchievement(int rate);

  /// No description provided for @projectCardAchieved.
  ///
  /// In zh, this message translates to:
  /// **'已达成'**
  String get projectCardAchieved;

  /// No description provided for @projectCardGoal.
  ///
  /// In zh, this message translates to:
  /// **'目标 {amount}'**
  String projectCardGoal(String amount);

  /// No description provided for @projectCardSupporters.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人支持'**
  String projectCardSupporters(int count);

  /// No description provided for @projectCardDays.
  ///
  /// In zh, this message translates to:
  /// **'剩 {days} 天'**
  String projectCardDays(int days);

  /// No description provided for @projectCardEnded.
  ///
  /// In zh, this message translates to:
  /// **'已结束'**
  String get projectCardEnded;

  /// No description provided for @projectCardSupportFrom.
  ///
  /// In zh, this message translates to:
  /// **'起支持'**
  String get projectCardSupportFrom;
}

class _CatalogLocalizationsDelegate extends LocalizationsDelegate<CatalogLocalizations> {
  const _CatalogLocalizationsDelegate();

  @override
  Future<CatalogLocalizations> load(Locale locale) {
    return SynchronousFuture<CatalogLocalizations>(lookupCatalogLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_CatalogLocalizationsDelegate old) => false;
}

CatalogLocalizations lookupCatalogLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return CatalogLocalizationsEn();
    case 'zh': return CatalogLocalizationsZh();
  }

  throw FlutterError(
    'CatalogLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
