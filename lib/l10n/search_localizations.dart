import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'search_localizations_en.dart';
import 'search_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SearchLocalizations
/// returned by `SearchLocalizations.of(context)`.
///
/// Applications need to include `SearchLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/search_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SearchLocalizations.localizationsDelegates,
///   supportedLocales: SearchLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the SearchLocalizations.supportedLocales
/// property.
abstract class SearchLocalizations {
  SearchLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SearchLocalizations of(BuildContext context) {
    return Localizations.of<SearchLocalizations>(context, SearchLocalizations)!;
  }

  static const LocalizationsDelegate<SearchLocalizations> delegate = _SearchLocalizationsDelegate();

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

  /// 来源：lib/features/search/application/search_providers.dart:22；原文：'剧院魅影'
  ///
  /// In zh, this message translates to:
  /// **'剧院魅影'**
  String get searchProviders_22;

  /// 来源：lib/features/search/application/search_providers.dart:22；原文：'周杰伦'
  ///
  /// In zh, this message translates to:
  /// **'周杰伦'**
  String get searchProviders_22_2;

  /// 来源：lib/features/search/application/search_providers.dart:22；原文：'上海大剧院'
  ///
  /// In zh, this message translates to:
  /// **'上海大剧院'**
  String get searchProviders_22_3;

  /// 来源：lib/features/search/application/search_providers.dart:55；原文：'剧院魅影'
  ///
  /// In zh, this message translates to:
  /// **'剧院魅影'**
  String get searchProviders_55;

  /// 来源：lib/features/search/application/search_providers.dart:56；原文：'周杰伦'
  ///
  /// In zh, this message translates to:
  /// **'周杰伦'**
  String get searchProviders_56;

  /// 来源：lib/features/search/application/search_providers.dart:57；原文：'演唱会'
  ///
  /// In zh, this message translates to:
  /// **'演唱会'**
  String get searchProviders_57;

  /// 来源：lib/features/search/application/search_providers.dart:58；原文：'上海大剧院'
  ///
  /// In zh, this message translates to:
  /// **'上海大剧院'**
  String get searchProviders_58;

  /// 来源：lib/features/search/application/search_providers.dart:59；原文：'话剧'
  ///
  /// In zh, this message translates to:
  /// **'话剧'**
  String get searchProviders_59;

  /// 来源：lib/features/search/application/search_providers.dart:60；原文：'音乐节'
  ///
  /// In zh, this message translates to:
  /// **'音乐节'**
  String get searchProviders_60;

  /// 来源：lib/features/search/application/search_providers.dart:61；原文：'亲子'
  ///
  /// In zh, this message translates to:
  /// **'亲子'**
  String get searchProviders_61;

  /// 来源：lib/features/search/application/search_providers.dart:62；原文：'交响'
  ///
  /// In zh, this message translates to:
  /// **'交响'**
  String get searchProviders_62;

  /// 来源：lib/features/search/domain/search_models.dart:14；原文：'全部'
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get searchModels_14;

  /// 来源：lib/features/search/domain/search_models.dart:15；原文：'演出'
  ///
  /// In zh, this message translates to:
  /// **'演出'**
  String get searchModels_15;

  /// 来源：lib/features/search/domain/search_models.dart:16；原文：'动态'
  ///
  /// In zh, this message translates to:
  /// **'动态'**
  String get searchModels_16;

  /// 来源：lib/features/search/domain/search_models.dart:43；原文：'${(hitCount / 10000).toStringAsFixed(1)}万'
  ///
  /// In zh, this message translates to:
  /// **'{toStringAsFixed}万'**
  String searchModels_43(Object toStringAsFixed);

  /// 来源：lib/features/search/search_page.dart:98；原文：'搜索明星、演出、场馆'
  ///
  /// In zh, this message translates to:
  /// **'搜索明星、演出、场馆'**
  String get searchPage_98;

  /// 来源：lib/features/search/search_page.dart:132；原文：'搜索历史'
  ///
  /// In zh, this message translates to:
  /// **'搜索历史'**
  String get searchPage_132;

  /// 来源：lib/features/search/search_page.dart:133；原文：'清空'
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get searchPage_133;

  /// 来源：lib/features/search/search_page.dart:150；原文：'已删除「$word」'
  ///
  /// In zh, this message translates to:
  /// **'已删除「{word}」'**
  String searchPage_150(Object word);

  /// 来源：lib/features/search/search_page.dart:171；原文：'长按可删除'
  ///
  /// In zh, this message translates to:
  /// **'长按可删除'**
  String get searchPage_171;

  /// 来源：lib/features/search/search_page.dart:187；原文：'热搜榜'
  ///
  /// In zh, this message translates to:
  /// **'热搜榜'**
  String get searchPage_187;

  /// 来源：lib/features/search/search_page.dart:219；原文：'热'
  ///
  /// In zh, this message translates to:
  /// **'热'**
  String get searchPage_219;

  /// 来源：lib/features/search/search_page.dart:262；原文：'搜索 '
  ///
  /// In zh, this message translates to:
  /// **'搜索 '**
  String get searchPage_262;

  /// 来源：lib/features/search/search_page.dart:325；原文：'没有匹配的演出，点上面「搜索」看全部结果'
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的演出，点上面「搜索」看全部结果'**
  String get searchPage_325;

  /// 来源：lib/features/search/search_result_page.dart:125；原文：'演出'
  ///
  /// In zh, this message translates to:
  /// **'演出'**
  String get searchResultPage_125;

  /// 来源：lib/features/search/search_result_page.dart:129；原文：'查看全部'
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get searchResultPage_129;

  /// 来源：lib/features/search/search_result_page.dart:142；原文：'动态'
  ///
  /// In zh, this message translates to:
  /// **'动态'**
  String get searchResultPage_142;

  /// 来源：lib/features/search/search_result_page.dart:146；原文：'查看全部'
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get searchResultPage_146;
}

class _SearchLocalizationsDelegate extends LocalizationsDelegate<SearchLocalizations> {
  const _SearchLocalizationsDelegate();

  @override
  Future<SearchLocalizations> load(Locale locale) {
    return SynchronousFuture<SearchLocalizations>(lookupSearchLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SearchLocalizationsDelegate old) => false;
}

SearchLocalizations lookupSearchLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return SearchLocalizationsEn();
    case 'zh': return SearchLocalizationsZh();
  }

  throw FlutterError(
    'SearchLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
