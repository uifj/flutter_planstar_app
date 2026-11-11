import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'discover_localizations_en.dart';
import 'discover_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of DiscoverLocalizations
/// returned by `DiscoverLocalizations.of(context)`.
///
/// Applications need to include `DiscoverLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/discover_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: DiscoverLocalizations.localizationsDelegates,
///   supportedLocales: DiscoverLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the DiscoverLocalizations.supportedLocales
/// property.
abstract class DiscoverLocalizations {
  DiscoverLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static DiscoverLocalizations of(BuildContext context) {
    return Localizations.of<DiscoverLocalizations>(context, DiscoverLocalizations)!;
  }

  static const LocalizationsDelegate<DiscoverLocalizations> delegate = _DiscoverLocalizationsDelegate();

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

  /// No description provided for @discoverTitle.
  ///
  /// In zh, this message translates to:
  /// **'发现'**
  String get discoverTitle;

  /// No description provided for @feedProviders_18.
  ///
  /// In zh, this message translates to:
  /// **'我'**
  String get feedProviders_18;

  /// No description provided for @feedProviders_25.
  ///
  /// In zh, this message translates to:
  /// **'刚刚发布'**
  String get feedProviders_25;

  /// No description provided for @discoverPage_39.
  ///
  /// In zh, this message translates to:
  /// **'热门'**
  String get discoverPage_39;

  /// No description provided for @discoverPage_39_2.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get discoverPage_39_2;

  /// No description provided for @discoverPage_72.
  ///
  /// In zh, this message translates to:
  /// **'关注的人还没有新动态'**
  String get discoverPage_72;

  /// No description provided for @discoverPage_73.
  ///
  /// In zh, this message translates to:
  /// **'去热门看看大家在聊什么'**
  String get discoverPage_73;

  /// No description provided for @discoverPage_75.
  ///
  /// In zh, this message translates to:
  /// **'查看热门'**
  String get discoverPage_75;

  /// No description provided for @feedPost_65.
  ///
  /// In zh, this message translates to:
  /// **'{toStringAsFixed}万'**
  String feedPost_65(Object toStringAsFixed);

  /// No description provided for @feedPost_73.
  ///
  /// In zh, this message translates to:
  /// **'{toStringAsFixed}万'**
  String feedPost_73(Object toStringAsFixed);

  /// No description provided for @feedPost_115.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get feedPost_115;

  /// No description provided for @feedPost_116.
  ///
  /// In zh, this message translates to:
  /// **'{inMinutes}分钟前'**
  String feedPost_116(Object inMinutes);

  /// No description provided for @feedPost_117.
  ///
  /// In zh, this message translates to:
  /// **'{inHours}小时前'**
  String feedPost_117(Object inHours);

  /// No description provided for @feedPost_118.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get feedPost_118;

  /// No description provided for @feedPost_119.
  ///
  /// In zh, this message translates to:
  /// **'{inDays}天前'**
  String feedPost_119(Object inDays);

  /// No description provided for @feedPost_120.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日'**
  String feedPost_120(Object month, Object day);

  /// No description provided for @feedDetailPage_45.
  ///
  /// In zh, this message translates to:
  /// **'动态详情'**
  String get feedDetailPage_45;

  /// No description provided for @feedDetailPage_48.
  ///
  /// In zh, this message translates to:
  /// **'动态不存在'**
  String get feedDetailPage_48;

  /// No description provided for @feedDetailPage_49.
  ///
  /// In zh, this message translates to:
  /// **'它可能已被作者删除'**
  String get feedDetailPage_49;

  /// No description provided for @feedDetailPage_51.
  ///
  /// In zh, this message translates to:
  /// **'返回发现'**
  String get feedDetailPage_51;

  /// No description provided for @feedDetailPage_125.
  ///
  /// In zh, this message translates to:
  /// **'相关企划'**
  String get feedDetailPage_125;

  /// No description provided for @feedDetailPage_151.
  ///
  /// In zh, this message translates to:
  /// **'评论 {length}'**
  String feedDetailPage_151(Object length);

  /// No description provided for @feedDetailPage_161.
  ///
  /// In zh, this message translates to:
  /// **'还没有评论'**
  String get feedDetailPage_161;

  /// No description provided for @feedDetailPage_162.
  ///
  /// In zh, this message translates to:
  /// **'来说两句吧'**
  String get feedDetailPage_162;

  /// No description provided for @feedDetailPage_216.
  ///
  /// In zh, this message translates to:
  /// **'{publishedAt} · {viewCountLabel} 阅读'**
  String feedDetailPage_216(Object publishedAt, Object viewCountLabel);

  /// No description provided for @feedDetailPage_252.
  ///
  /// In zh, this message translates to:
  /// **'这条动态带视频，播放器尚未接入（需要 CDN 与 videoplayer 等价实现）'**
  String get feedDetailPage_252;

  /// No description provided for @feedDetailPage_276.
  ///
  /// In zh, this message translates to:
  /// **'点赞接口待接入'**
  String get feedDetailPage_276;

  /// No description provided for @feedDetailPage_281.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get feedDetailPage_281;

  /// No description provided for @feedDetailPage_282.
  ///
  /// In zh, this message translates to:
  /// **'评论发布待接入'**
  String get feedDetailPage_282;

  /// No description provided for @feedDetailPage_287.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get feedDetailPage_287;

  /// No description provided for @feedDetailPage_288.
  ///
  /// In zh, this message translates to:
  /// **'分享面板待接入 fluwx'**
  String get feedDetailPage_288;

  /// No description provided for @publishSheet_69.
  ///
  /// In zh, this message translates to:
  /// **'发布动态'**
  String get publishSheet_69;

  /// No description provided for @publishSheet_98.
  ///
  /// In zh, this message translates to:
  /// **'聊聊你支持过的企划…'**
  String get publishSheet_98;

  /// No description provided for @publishSheet_122.
  ///
  /// In zh, this message translates to:
  /// **'发布'**
  String get publishSheet_122;

  /// No description provided for @bilibiliOpenSheet_32.
  ///
  /// In zh, this message translates to:
  /// **'播放视频'**
  String get bilibiliOpenSheet_32;

  /// No description provided for @bilibiliOpenSheet_41.
  ///
  /// In zh, this message translates to:
  /// **'应用内播放'**
  String get bilibiliOpenSheet_41;

  /// No description provided for @bilibiliOpenSheet_46.
  ///
  /// In zh, this message translates to:
  /// **'打开哔哩哔哩'**
  String get bilibiliOpenSheet_46;

  /// No description provided for @bilibiliOpenSheet_72.
  ///
  /// In zh, this message translates to:
  /// **'哔哩哔哩未安装，已用浏览器打开'**
  String get bilibiliOpenSheet_72;

  /// No description provided for @bilibiliOpenSheet_80.
  ///
  /// In zh, this message translates to:
  /// **'无法打开视频，请稍后再试'**
  String get bilibiliOpenSheet_80;

  /// No description provided for @bilibiliPlayerPage_79.
  ///
  /// In zh, this message translates to:
  /// **'无法打开浏览器，请稍后再试'**
  String get bilibiliPlayerPage_79;

  /// No description provided for @bilibiliPlayerPage_89.
  ///
  /// In zh, this message translates to:
  /// **'哔哩哔哩'**
  String get bilibiliPlayerPage_89;

  /// No description provided for @bilibiliPlayerPage_93.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get bilibiliPlayerPage_93;

  /// No description provided for @bilibiliPlayerPage_98.
  ///
  /// In zh, this message translates to:
  /// **'在浏览器打开'**
  String get bilibiliPlayerPage_98;

  /// No description provided for @bilibiliPlayerPage_112.
  ///
  /// In zh, this message translates to:
  /// **'视频加载失败'**
  String get bilibiliPlayerPage_112;

  /// No description provided for @bilibiliPlayerPage_113.
  ///
  /// In zh, this message translates to:
  /// **'请检查网络后重试'**
  String get bilibiliPlayerPage_113;
}

class _DiscoverLocalizationsDelegate extends LocalizationsDelegate<DiscoverLocalizations> {
  const _DiscoverLocalizationsDelegate();

  @override
  Future<DiscoverLocalizations> load(Locale locale) {
    return SynchronousFuture<DiscoverLocalizations>(lookupDiscoverLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_DiscoverLocalizationsDelegate old) => false;
}

DiscoverLocalizations lookupDiscoverLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return DiscoverLocalizationsEn();
    case 'zh': return DiscoverLocalizationsZh();
  }

  throw FlutterError(
    'DiscoverLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
