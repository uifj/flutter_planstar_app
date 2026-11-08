import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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

  /// 应用名称，显示在任务切换器与关于页
  ///
  /// In zh, this message translates to:
  /// **'企划星'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get tabHome;

  /// No description provided for @tabDiscover.
  ///
  /// In zh, this message translates to:
  /// **'发现'**
  String get tabDiscover;

  /// No description provided for @tabProject.
  ///
  /// In zh, this message translates to:
  /// **'企划'**
  String get tabProject;

  /// No description provided for @tabProfile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get tabProfile;

  /// No description provided for @actionRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get actionRetry;

  /// No description provided for @actionCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get actionConfirm;

  /// No description provided for @actionSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get actionSave;

  /// No description provided for @stateLoading.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get stateLoading;

  /// No description provided for @stateEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无内容'**
  String get stateEmpty;

  /// No description provided for @stateNetworkError.
  ///
  /// In zh, this message translates to:
  /// **'网络不给力，请稍后重试'**
  String get stateNetworkError;

  /// No description provided for @stateTimeout.
  ///
  /// In zh, this message translates to:
  /// **'请求超时，请重试'**
  String get stateTimeout;

  /// No description provided for @stateUnauthorized.
  ///
  /// In zh, this message translates to:
  /// **'登录已失效，请重新登录'**
  String get stateUnauthorized;

  /// No description provided for @stateOfflineCache.
  ///
  /// In zh, this message translates to:
  /// **'当前展示的是离线缓存内容'**
  String get stateOfflineCache;

  /// 来源：lib/features/app/splash_page.dart:129；原文：'让看演出更简单'
  ///
  /// In zh, this message translates to:
  /// **'让好企划被看见'**
  String get splashPage_129;

  /// 来源：lib/features/app/splash_page.dart:146；原文：'企划星科技 © 2026–2027'
  ///
  /// In zh, this message translates to:
  /// **'企划星科技 © 2026–2027'**
  String get splashPage_146;

  /// 来源：lib/features/app/splash_page.dart:180；原文：'隐私政策与用户协议'
  ///
  /// In zh, this message translates to:
  /// **'隐私政策与用户协议'**
  String get splashPage_180;

  /// 来源：lib/features/app/splash_page.dart:187；原文：'欢迎使用企划星。为了保障您的合法权益，请在使用前阅读并同意以下协议：'
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用企划星。为了保障您的合法权益，请在使用前阅读并同意以下协议：'**
  String get splashPage_187;

  /// 来源：lib/features/app/splash_page.dart:192；原文：'《用户协议》：规定了您与企划星之间的权利义务关系。'
  ///
  /// In zh, this message translates to:
  /// **'《用户协议》：规定了您与企划星之间的权利义务关系。'**
  String get splashPage_192;

  /// 来源：lib/features/app/splash_page.dart:195；原文：'《隐私政策》：说明了企划星如何收集、使用和保护您的个人信息。'
  ///
  /// In zh, this message translates to:
  /// **'《隐私政策》：说明了企划星如何收集、使用和保护您的个人信息。'**
  String get splashPage_195;

  /// 来源：lib/features/app/splash_page.dart:199；原文：'点击「同意并继续」表示您已阅读并同意以上协议。'
  ///
  /// In zh, this message translates to:
  /// **'点击「同意并继续」表示您已阅读并同意以上协议。'**
  String get splashPage_199;

  /// 来源：lib/features/app/splash_page.dart:208；原文：'不同意'
  ///
  /// In zh, this message translates to:
  /// **'不同意'**
  String get splashPage_208;

  /// 来源：lib/features/app/splash_page.dart:212；原文：'同意并继续'
  ///
  /// In zh, this message translates to:
  /// **'同意并继续'**
  String get splashPage_212;

  /// 来源：lib/shared/ui/ps_empty_state.dart:32；原文：'没有找到相关企划'
  ///
  /// In zh, this message translates to:
  /// **'没有找到相关企划'**
  String get psEmptyState_32;

  /// 来源：lib/shared/ui/ps_empty_state.dart:33；原文：'换个关键词或品类试试'
  ///
  /// In zh, this message translates to:
  /// **'换个关键词或品类试试'**
  String get psEmptyState_33;

  /// 来源：lib/shared/ui/ps_empty_state.dart:35；原文：'重新搜索'
  ///
  /// In zh, this message translates to:
  /// **'重新搜索'**
  String get psEmptyState_35;

  /// 来源：lib/shared/ui/ps_poster.dart:136；原文：'企'
  ///
  /// In zh, this message translates to:
  /// **'企'**
  String get psPoster_136;

  /// 来源：lib/shared/ui/ps_search_bar.dart:25；原文：'搜索企划、创作者、品类'
  ///
  /// In zh, this message translates to:
  /// **'搜索企划、创作者、品类'**
  String get psSearchBar_25;

  /// 来源：lib/shared/ui/ps_search_bar.dart:104；原文：'搜索'
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get psSearchBar_104;

  /// 来源：lib/shared/ui/ps_section_header.dart:16；原文：'全部'
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get psSectionHeader_16;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
