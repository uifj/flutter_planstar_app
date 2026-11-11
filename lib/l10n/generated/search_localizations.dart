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
/// import 'generated/search_localizations.dart';
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

  /// No description provided for @searchProviders_22.
  ///
  /// In zh, this message translates to:
  /// **'游戏企划'**
  String get searchProviders_22;

  /// No description provided for @searchProviders_22_2.
  ///
  /// In zh, this message translates to:
  /// **'同人画集'**
  String get searchProviders_22_2;

  /// No description provided for @searchProviders_22_3.
  ///
  /// In zh, this message translates to:
  /// **'面经企划'**
  String get searchProviders_22_3;

  /// No description provided for @searchProviders_55.
  ///
  /// In zh, this message translates to:
  /// **'游戏企划'**
  String get searchProviders_55;

  /// No description provided for @searchProviders_56.
  ///
  /// In zh, this message translates to:
  /// **'同人企划'**
  String get searchProviders_56;

  /// No description provided for @searchProviders_57.
  ///
  /// In zh, this message translates to:
  /// **'画集设定集'**
  String get searchProviders_57;

  /// No description provided for @searchProviders_58.
  ///
  /// In zh, this message translates to:
  /// **'面经企划'**
  String get searchProviders_58;

  /// No description provided for @searchProviders_59.
  ///
  /// In zh, this message translates to:
  /// **'桌游'**
  String get searchProviders_59;

  /// No description provided for @searchProviders_60.
  ///
  /// In zh, this message translates to:
  /// **'音乐影像'**
  String get searchProviders_60;

  /// No description provided for @searchProviders_61.
  ///
  /// In zh, this message translates to:
  /// **'小说企划'**
  String get searchProviders_61;

  /// No description provided for @searchProviders_62.
  ///
  /// In zh, this message translates to:
  /// **'秋招'**
  String get searchProviders_62;

  /// No description provided for @searchModels_14.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get searchModels_14;

  /// No description provided for @searchModels_15.
  ///
  /// In zh, this message translates to:
  /// **'企划'**
  String get searchModels_15;

  /// No description provided for @searchModels_16.
  ///
  /// In zh, this message translates to:
  /// **'动态'**
  String get searchModels_16;

  /// No description provided for @searchModels_43.
  ///
  /// In zh, this message translates to:
  /// **'{toStringAsFixed}万'**
  String searchModels_43(Object toStringAsFixed);

  /// No description provided for @searchPage_98.
  ///
  /// In zh, this message translates to:
  /// **'搜索企划、创作者、品类'**
  String get searchPage_98;

  /// No description provided for @searchPage_132.
  ///
  /// In zh, this message translates to:
  /// **'搜索历史'**
  String get searchPage_132;

  /// No description provided for @searchPage_133.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get searchPage_133;

  /// No description provided for @searchPage_150.
  ///
  /// In zh, this message translates to:
  /// **'已删除「{word}」'**
  String searchPage_150(Object word);

  /// No description provided for @searchPage_171.
  ///
  /// In zh, this message translates to:
  /// **'长按可删除'**
  String get searchPage_171;

  /// No description provided for @searchPage_187.
  ///
  /// In zh, this message translates to:
  /// **'热搜榜'**
  String get searchPage_187;

  /// No description provided for @searchPage_219.
  ///
  /// In zh, this message translates to:
  /// **'热'**
  String get searchPage_219;

  /// No description provided for @searchPage_262.
  ///
  /// In zh, this message translates to:
  /// **'搜索 '**
  String get searchPage_262;

  /// No description provided for @searchPage_325.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的企划，点上面「搜索」看全部结果'**
  String get searchPage_325;

  /// No description provided for @searchResultPage_125.
  ///
  /// In zh, this message translates to:
  /// **'企划'**
  String get searchResultPage_125;

  /// No description provided for @searchResultPage_129.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get searchResultPage_129;

  /// No description provided for @searchResultPage_142.
  ///
  /// In zh, this message translates to:
  /// **'动态'**
  String get searchResultPage_142;

  /// No description provided for @searchResultPage_146.
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
