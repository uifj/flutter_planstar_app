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

  /// 来源：lib/features/catalog/application/catalog_providers.dart:74；原文：'上海'
  ///
  /// In zh, this message translates to:
  /// **'上海'**
  String get catalogProviders_74;

  /// 来源：lib/features/catalog/domain/show_category.dart:95；原文：'$address · $showCount 场演出'
  ///
  /// In zh, this message translates to:
  /// **'{address} · {showCount} 个企划'**
  String showCategory_95(Object address, Object showCount);

  /// 来源：lib/features/catalog/domain/show_summary.dart:165；原文：'$text折'
  ///
  /// In zh, this message translates to:
  /// **'{text}折'**
  String showSummary_165(Object text);

  /// 来源：lib/features/catalog/domain/show_summary.dart:178；原文：'暂时售罄'
  ///
  /// In zh, this message translates to:
  /// **'暂时售罄'**
  String get showSummary_178;

  /// 来源：lib/features/catalog/domain/show_summary.dart:178；原文：'售票中'
  ///
  /// In zh, this message translates to:
  /// **'支持中'**
  String get showSummary_178_2;

  /// 来源：lib/features/catalog/domain/show_summary.dart:263；原文：'周一'
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get showSummary_263;

  /// 来源：lib/features/catalog/domain/show_summary.dart:263；原文：'周二'
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get showSummary_263_2;

  /// 来源：lib/features/catalog/domain/show_summary.dart:263；原文：'周三'
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get showSummary_263_3;

  /// 来源：lib/features/catalog/domain/show_summary.dart:263；原文：'周四'
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get showSummary_263_4;

  /// 来源：lib/features/catalog/domain/show_summary.dart:263；原文：'周五'
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get showSummary_263_5;

  /// 来源：lib/features/catalog/domain/show_summary.dart:263；原文：'周六'
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get showSummary_263_6;

  /// 来源：lib/features/catalog/domain/show_summary.dart:263；原文：'周日'
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get showSummary_263_7;

  /// 来源：lib/features/catalog/domain/show_summary.dart:266；原文：'${time.month}月${time.day}日 ${weekdays[time.weekday - 1]} $hour:$minute'
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日 {weekday} {hour}:{minute}'**
  String showSummary_266(Object month, Object day, Object weekday, Object hour, Object minute);

  /// 来源：lib/features/catalog/domain/show_summary.dart:280；原文：'刚刚'
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get showSummary_280;

  /// 来源：lib/features/catalog/domain/show_summary.dart:281；原文：'${delta.inMinutes}分钟前'
  ///
  /// In zh, this message translates to:
  /// **'{inMinutes}分钟前'**
  String showSummary_281(Object inMinutes);

  /// 来源：lib/features/catalog/domain/show_summary.dart:285；原文：'昨天'
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get showSummary_285;

  /// 来源：lib/features/catalog/domain/show_summary.dart:286；原文：'${delta.inDays}天前'
  ///
  /// In zh, this message translates to:
  /// **'{inDays}天前'**
  String showSummary_286(Object inDays);

  /// 来源：lib/features/catalog/domain/show_summary.dart:287；原文：'${time.month}月${time.day}日'
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日'**
  String showSummary_287(Object month, Object day);

  /// 来源：lib/features/catalog/ui/category_home_page.dart:116；原文：'$city 暂无${selectedCategory?.name ?? '该分类'}演出'
  ///
  /// In zh, this message translates to:
  /// **'{city} 暂无{name}企划'**
  String categoryHomePage_116(Object city, Object name);

  /// 来源：lib/features/catalog/ui/category_home_page.dart:116；原文：'该分类'
  ///
  /// In zh, this message translates to:
  /// **'该分类'**
  String get categoryHomePage_unknownCategory;

  /// 来源：lib/features/catalog/ui/category_home_page.dart:117；原文：'试试切换城市或查看其他分类'
  ///
  /// In zh, this message translates to:
  /// **'试试切换城市或查看其他分类'**
  String get categoryHomePage_117;

  /// 来源：lib/features/catalog/ui/category_home_page.dart:119；原文：'去首页'
  ///
  /// In zh, this message translates to:
  /// **'去首页'**
  String get categoryHomePage_119;

  /// 来源：lib/features/catalog/ui/category_home_page.dart:403；原文：'起'
  ///
  /// In zh, this message translates to:
  /// **'起'**
  String get categoryHomePage_403;

  /// 来源：lib/features/catalog/ui/category_home_page.dart:406；原文：'${show.wishCount} 人想看'
  ///
  /// In zh, this message translates to:
  /// **'{wishCount} 人想看'**
  String categoryHomePage_406(Object wishCount);

  /// 来源：lib/features/catalog/ui/show_cards.dart:72；原文：'暂时售罄'
  ///
  /// In zh, this message translates to:
  /// **'暂时售罄'**
  String get showCards_72;

  /// 来源：lib/features/catalog/ui/show_cards.dart:75；原文：'起'
  ///
  /// In zh, this message translates to:
  /// **'起'**
  String get showCards_75;

  /// 来源：lib/features/catalog/ui/show_cards.dart:156；原文：'暂时售罄'
  ///
  /// In zh, this message translates to:
  /// **'暂时售罄'**
  String get showCards_156;

  /// 来源：lib/features/catalog/ui/show_cards.dart:175；原文：'${show.discountLabel!}起'
  ///
  /// In zh, this message translates to:
  /// **'{discountLabel}起'**
  String showCards_175(Object discountLabel);

  /// 来源：lib/features/catalog/ui/show_cards.dart:270；原文：'暂时售罄'
  ///
  /// In zh, this message translates to:
  /// **'暂时售罄'**
  String get showCards_270;

  /// 来源：lib/features/catalog/ui/show_cards.dart:277；原文：'起'
  ///
  /// In zh, this message translates to:
  /// **'起'**
  String get showCards_277;

  /// 来源：lib/features/catalog/ui/show_list_page.dart:78；原文：'该分类暂无演出'
  ///
  /// In zh, this message translates to:
  /// **'该分类暂无企划'**
  String get showListPage_78;

  /// 来源：lib/features/catalog/ui/show_list_page.dart:79；原文：'换个分类或城市看看'
  ///
  /// In zh, this message translates to:
  /// **'换个分类或城市看看'**
  String get showListPage_79;

  /// 来源：lib/features/catalog/ui/show_list_page.dart:81；原文：'看全部演出'
  ///
  /// In zh, this message translates to:
  /// **'看全部企划'**
  String get showListPage_81;

  /// 来源：lib/features/catalog/ui/show_list_page.dart:112；原文：'全部演出'
  ///
  /// In zh, this message translates to:
  /// **'全部企划'**
  String get showListPage_112;

  /// 来源：lib/features/catalog/ui/show_list_page.dart:140；原文：'推荐'
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get showListPage_140;

  /// 来源：lib/features/catalog/ui/show_list_page.dart:141；原文：'最近开演'
  ///
  /// In zh, this message translates to:
  /// **'最近开演'**
  String get showListPage_141;

  /// 来源：lib/features/catalog/ui/show_list_page.dart:142；原文：'价格最低'
  ///
  /// In zh, this message translates to:
  /// **'价格最低'**
  String get showListPage_142;

  /// 来源：lib/features/catalog/ui/show_list_page.dart:172；原文：'全部'
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get showListPage_172;

  /// 来源：lib/features/catalog/ui/show_list_page.dart:249；原文：'共 $total 场'
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
