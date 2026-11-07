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

  /// 来源：lib/features/discover/application/feed_providers.dart:18；原文：'我'
  ///
  /// In zh, this message translates to:
  /// **'我'**
  String get feedProviders_18;

  /// 来源：lib/features/discover/application/feed_providers.dart:25；原文：'刚刚发布'
  ///
  /// In zh, this message translates to:
  /// **'刚刚发布'**
  String get feedProviders_25;

  /// 来源：lib/features/discover/discover_page.dart:39；原文：'热门'
  ///
  /// In zh, this message translates to:
  /// **'热门'**
  String get discoverPage_39;

  /// 来源：lib/features/discover/discover_page.dart:39；原文：'关注'
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get discoverPage_39_2;

  /// 来源：lib/features/discover/discover_page.dart:72；原文：'关注的人还没有新动态'
  ///
  /// In zh, this message translates to:
  /// **'关注的人还没有新动态'**
  String get discoverPage_72;

  /// 来源：lib/features/discover/discover_page.dart:73；原文：'去热门看看大家在聊什么'
  ///
  /// In zh, this message translates to:
  /// **'去热门看看大家在聊什么'**
  String get discoverPage_73;

  /// 来源：lib/features/discover/discover_page.dart:75；原文：'查看热门'
  ///
  /// In zh, this message translates to:
  /// **'查看热门'**
  String get discoverPage_75;

  /// 来源：lib/features/discover/domain/feed_post.dart:65；原文：'${wan.toStringAsFixed(1)}万'
  ///
  /// In zh, this message translates to:
  /// **'{toStringAsFixed}万'**
  String feedPost_65(Object toStringAsFixed);

  /// 来源：lib/features/discover/domain/feed_post.dart:73；原文：'${(likeCount / 10000).toStringAsFixed(1)}万'
  ///
  /// In zh, this message translates to:
  /// **'{toStringAsFixed}万'**
  String feedPost_73(Object toStringAsFixed);

  /// 来源：lib/features/discover/domain/feed_post.dart:115；原文：'刚刚'
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get feedPost_115;

  /// 来源：lib/features/discover/domain/feed_post.dart:116；原文：'${delta.inMinutes}分钟前'
  ///
  /// In zh, this message translates to:
  /// **'{inMinutes}分钟前'**
  String feedPost_116(Object inMinutes);

  /// 来源：lib/features/discover/domain/feed_post.dart:117；原文：'${delta.inHours}小时前'
  ///
  /// In zh, this message translates to:
  /// **'{inHours}小时前'**
  String feedPost_117(Object inHours);

  /// 来源：lib/features/discover/domain/feed_post.dart:118；原文：'昨天'
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get feedPost_118;

  /// 来源：lib/features/discover/domain/feed_post.dart:119；原文：'${delta.inDays}天前'
  ///
  /// In zh, this message translates to:
  /// **'{inDays}天前'**
  String feedPost_119(Object inDays);

  /// 来源：lib/features/discover/domain/feed_post.dart:120；原文：'${publishedAt.month}月${publishedAt.day}日'
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日'**
  String feedPost_120(Object month, Object day);

  /// 来源：lib/features/discover/feed_detail_page.dart:45；原文：'动态详情'
  ///
  /// In zh, this message translates to:
  /// **'动态详情'**
  String get feedDetailPage_45;

  /// 来源：lib/features/discover/feed_detail_page.dart:48；原文：'动态不存在'
  ///
  /// In zh, this message translates to:
  /// **'动态不存在'**
  String get feedDetailPage_48;

  /// 来源：lib/features/discover/feed_detail_page.dart:49；原文：'它可能已被作者删除'
  ///
  /// In zh, this message translates to:
  /// **'它可能已被作者删除'**
  String get feedDetailPage_49;

  /// 来源：lib/features/discover/feed_detail_page.dart:51；原文：'返回发现'
  ///
  /// In zh, this message translates to:
  /// **'返回发现'**
  String get feedDetailPage_51;

  /// 来源：lib/features/discover/feed_detail_page.dart:125；原文：'相关演出'
  ///
  /// In zh, this message translates to:
  /// **'相关企划'**
  String get feedDetailPage_125;

  /// 来源：lib/features/discover/feed_detail_page.dart:151；原文：'评论 ${comments.length}'
  ///
  /// In zh, this message translates to:
  /// **'评论 {length}'**
  String feedDetailPage_151(Object length);

  /// 来源：lib/features/discover/feed_detail_page.dart:161；原文：'还没有评论'
  ///
  /// In zh, this message translates to:
  /// **'还没有评论'**
  String get feedDetailPage_161;

  /// 来源：lib/features/discover/feed_detail_page.dart:162；原文：'来说两句吧'
  ///
  /// In zh, this message translates to:
  /// **'来说两句吧'**
  String get feedDetailPage_162;

  /// 来源：lib/features/discover/feed_detail_page.dart:216；原文：'${formatRelativeTime(post.publishedAt)} · ${post.viewCountLabel} 阅读'
  ///
  /// In zh, this message translates to:
  /// **'{publishedAt} · {viewCountLabel} 阅读'**
  String feedDetailPage_216(Object publishedAt, Object viewCountLabel);

  /// 来源：lib/features/discover/feed_detail_page.dart:252；原文：'这条动态带视频，播放器尚未接入（需要 CDN 与 videoplayer 等价实现）'
  ///
  /// In zh, this message translates to:
  /// **'这条动态带视频，播放器尚未接入（需要 CDN 与 videoplayer 等价实现）'**
  String get feedDetailPage_252;

  /// 来源：lib/features/discover/feed_detail_page.dart:276；原文：'点赞接口待接入'
  ///
  /// In zh, this message translates to:
  /// **'点赞接口待接入'**
  String get feedDetailPage_276;

  /// 来源：lib/features/discover/feed_detail_page.dart:281；原文：'评论'
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get feedDetailPage_281;

  /// 来源：lib/features/discover/feed_detail_page.dart:282；原文：'评论发布待接入'
  ///
  /// In zh, this message translates to:
  /// **'评论发布待接入'**
  String get feedDetailPage_282;

  /// 来源：lib/features/discover/feed_detail_page.dart:287；原文：'分享'
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get feedDetailPage_287;

  /// 来源：lib/features/discover/feed_detail_page.dart:288；原文：'分享面板待接入 fluwx'
  ///
  /// In zh, this message translates to:
  /// **'分享面板待接入 fluwx'**
  String get feedDetailPage_288;

  /// 来源：lib/features/discover/widgets/publish_sheet.dart:69；原文：'发布动态'
  ///
  /// In zh, this message translates to:
  /// **'发布动态'**
  String get publishSheet_69;

  /// 来源：lib/features/discover/widgets/publish_sheet.dart:98；原文：'聊聊你看过的演出…'
  ///
  /// In zh, this message translates to:
  /// **'聊聊你支持过的企划…'**
  String get publishSheet_98;

  /// 来源：lib/features/discover/widgets/publish_sheet.dart:122；原文：'发布'
  ///
  /// In zh, this message translates to:
  /// **'发布'**
  String get publishSheet_122;

  /// 来源：lib/features/discover/widgets/bilibili_open_sheet.dart:37；原文：'播放视频'
  ///
  /// In zh, this message translates to:
  /// **'播放视频'**
  String get bilibiliOpenSheet_32;

  /// 来源：lib/features/discover/widgets/bilibili_open_sheet.dart:47；原文：'应用内播放'
  ///
  /// In zh, this message translates to:
  /// **'应用内播放'**
  String get bilibiliOpenSheet_41;

  /// 来源：lib/features/discover/widgets/bilibili_open_sheet.dart:53；原文：'打开哔哩哔哩'
  ///
  /// In zh, this message translates to:
  /// **'打开哔哩哔哩'**
  String get bilibiliOpenSheet_46;

  /// 来源：lib/features/discover/widgets/bilibili_open_sheet.dart:85；原文：'哔哩哔哩未安装，已用浏览器打开'
  ///
  /// In zh, this message translates to:
  /// **'哔哩哔哩未安装，已用浏览器打开'**
  String get bilibiliOpenSheet_72;

  /// 来源：lib/features/discover/widgets/bilibili_open_sheet.dart:94；原文：'无法打开视频，请稍后再试'
  ///
  /// In zh, this message translates to:
  /// **'无法打开视频，请稍后再试'**
  String get bilibiliOpenSheet_80;

  /// 来源：lib/features/discover/ui/bilibili_player_page.dart:78；原文：'无法打开浏览器，请稍后再试'
  ///
  /// In zh, this message translates to:
  /// **'无法打开浏览器，请稍后再试'**
  String get bilibiliPlayerPage_79;

  /// 来源：lib/features/discover/ui/bilibili_player_page.dart:89；原文：'哔哩哔哩'
  ///
  /// In zh, this message translates to:
  /// **'哔哩哔哩'**
  String get bilibiliPlayerPage_89;

  /// 来源：lib/features/discover/ui/bilibili_player_page.dart:93；原文：'刷新'
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get bilibiliPlayerPage_93;

  /// 来源：lib/features/discover/ui/bilibili_player_page.dart:98；原文：'在浏览器打开'
  ///
  /// In zh, this message translates to:
  /// **'在浏览器打开'**
  String get bilibiliPlayerPage_98;

  /// 来源：lib/features/discover/ui/bilibili_player_page.dart:111；原文：'视频加载失败'
  ///
  /// In zh, this message translates to:
  /// **'视频加载失败'**
  String get bilibiliPlayerPage_112;

  /// 来源：lib/features/discover/ui/bilibili_player_page.dart:112；原文：'请检查网络后重试'
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
