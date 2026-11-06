import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'message_localizations_en.dart';
import 'message_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MessageLocalizations
/// returned by `MessageLocalizations.of(context)`.
///
/// Applications need to include `MessageLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/message_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MessageLocalizations.localizationsDelegates,
///   supportedLocales: MessageLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the MessageLocalizations.supportedLocales
/// property.
abstract class MessageLocalizations {
  MessageLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MessageLocalizations of(BuildContext context) {
    return Localizations.of<MessageLocalizations>(context, MessageLocalizations)!;
  }

  static const LocalizationsDelegate<MessageLocalizations> delegate = _MessageLocalizationsDelegate();

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

  /// No description provided for @messageTitle.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get messageTitle;

  /// 来源：lib/features/message/application/message_providers.dart:48；原文：'活动通知'
  ///
  /// In zh, this message translates to:
  /// **'活动通知'**
  String get messageProviders_48;

  /// 来源：lib/features/message/application/message_providers.dart:49；原文：'回复我的'
  ///
  /// In zh, this message translates to:
  /// **'回复我的'**
  String get messageProviders_49;

  /// 来源：lib/features/message/application/message_providers.dart:50；原文：'赞和关注'
  ///
  /// In zh, this message translates to:
  /// **'赞和关注'**
  String get messageProviders_50;

  /// 来源：lib/features/message/application/message_providers.dart:55；原文：'企划星官方客服'
  ///
  /// In zh, this message translates to:
  /// **'企划星官方客服'**
  String get messageProviders_55;

  /// 来源：lib/features/message/application/message_providers.dart:56；原文：'您好，关于《剧院魅影》的退改签问题，我们已为您登记…'
  ///
  /// In zh, this message translates to:
  /// **'您好，关于《剧院魅影》的退改签问题，我们已为您登记…'**
  String get messageProviders_56;

  /// 来源：lib/features/message/application/message_providers.dart:64；原文：'演出提醒'
  ///
  /// In zh, this message translates to:
  /// **'演出提醒'**
  String get messageProviders_64;

  /// 来源：lib/features/message/application/message_providers.dart:65；原文：'您关注的「周杰伦上海站」即将开票，别忘了设置提醒'
  ///
  /// In zh, this message translates to:
  /// **'您关注的「周杰伦上海站」即将开票，别忘了设置提醒'**
  String get messageProviders_65;

  /// 来源：lib/features/message/application/message_providers.dart:71；原文：'订单助手'
  ///
  /// In zh, this message translates to:
  /// **'订单助手'**
  String get messageProviders_71;

  /// 来源：lib/features/message/application/message_providers.dart:72；原文：'订单 PN20261108000001 已出票，可在「我的订单」查看电子票'
  ///
  /// In zh, this message translates to:
  /// **'订单 PN20261108000001 已出票，可在「我的订单」查看电子票'**
  String get messageProviders_72;

  /// 来源：lib/features/message/application/message_providers.dart:79；原文：'剧院常驻民'
  ///
  /// In zh, this message translates to:
  /// **'剧院常驻民'**
  String get messageProviders_79;

  /// 来源：lib/features/message/application/message_providers.dart:80；原文：'你发的动态收到了 12 个赞'
  ///
  /// In zh, this message translates to:
  /// **'你发的动态收到了 12 个赞'**
  String get messageProviders_80;

  /// 来源：lib/features/message/application/message_providers.dart:86；原文：'抢票小分队'
  ///
  /// In zh, this message translates to:
  /// **'抢票小分队'**
  String get messageProviders_86;

  /// 来源：lib/features/message/application/message_providers.dart:87；原文：'上海站加场了，明天十点开抢'
  ///
  /// In zh, this message translates to:
  /// **'上海站加场了，明天十点开抢'**
  String get messageProviders_87;

  /// 来源：lib/features/message/application/message_providers.dart:93；原文：'企划星福利官'
  ///
  /// In zh, this message translates to:
  /// **'企划星福利官'**
  String get messageProviders_93;

  /// 来源：lib/features/message/application/message_providers.dart:94；原文：'您有一张 50 元无门槛券即将过期'
  ///
  /// In zh, this message translates to:
  /// **'您有一张 50 元无门槛券即将过期'**
  String get messageProviders_94;

  /// 来源：lib/features/message/chat_page.dart:75；原文：'会话'
  ///
  /// In zh, this message translates to:
  /// **'会话'**
  String get chatPage_75;

  /// 来源：lib/features/message/chat_page.dart:76；原文：'官方账号'
  ///
  /// In zh, this message translates to:
  /// **'官方账号'**
  String get chatPage_76;

  /// 来源：lib/features/message/chat_page.dart:80；原文：'会话不存在'
  ///
  /// In zh, this message translates to:
  /// **'会话不存在'**
  String get chatPage_80;

  /// 来源：lib/features/message/chat_page.dart:81；原文：'它可能已被清空'
  ///
  /// In zh, this message translates to:
  /// **'它可能已被清空'**
  String get chatPage_81;

  /// 来源：lib/features/message/chat_page.dart:83；原文：'返回消息'
  ///
  /// In zh, this message translates to:
  /// **'返回消息'**
  String get chatPage_83;

  /// 来源：lib/features/message/chat_page.dart:91；原文：'还没有消息'
  ///
  /// In zh, this message translates to:
  /// **'还没有消息'**
  String get chatPage_91;

  /// 来源：lib/features/message/chat_page.dart:92；原文：'打个招呼吧'
  ///
  /// In zh, this message translates to:
  /// **'打个招呼吧'**
  String get chatPage_92;

  /// 来源：lib/features/message/chat_page.dart:288；原文：'演示环境：消息只保存在本地，不会真的发送'
  ///
  /// In zh, this message translates to:
  /// **'演示环境：消息只保存在本地，不会真的发送'**
  String get chatPage_288;

  /// 来源：lib/features/message/chat_page.dart:310；原文：'输入消息…'
  ///
  /// In zh, this message translates to:
  /// **'输入消息…'**
  String get chatPage_310;

  /// 来源：lib/features/message/chat_page.dart:334；原文：'发送'
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get chatPage_334;

  /// 来源：lib/features/message/message_page.dart:62；原文：'${entry.title}列表（演示）'
  ///
  /// In zh, this message translates to:
  /// **'{title}列表（演示）'**
  String messagePage_62(Object title);

  /// 来源：lib/features/message/message_page.dart:72；原文：'暂无消息'
  ///
  /// In zh, this message translates to:
  /// **'暂无消息'**
  String get messagePage_72;

  /// 来源：lib/features/message/message_page.dart:73；原文：'订单进度、开票提醒都会出现在这里'
  ///
  /// In zh, this message translates to:
  /// **'订单进度、开票提醒都会出现在这里'**
  String get messagePage_73;

  /// 来源：lib/features/message/message_page.dart:122；原文：'清空消息'
  ///
  /// In zh, this message translates to:
  /// **'清空消息'**
  String get messagePage_122;

  /// 来源：lib/features/message/message_page.dart:123；原文：'清空后会话记录将不再显示，确定继续吗？'
  ///
  /// In zh, this message translates to:
  /// **'清空后会话记录将不再显示，确定继续吗？'**
  String get messagePage_123;

  /// 来源：lib/features/message/message_page.dart:131；原文：'清空'
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get messagePage_131;

  /// 来源：lib/features/message/message_page.dart:160；原文：'消息中心'
  ///
  /// In zh, this message translates to:
  /// **'消息中心'**
  String get messagePage_160;

  /// 来源：lib/features/message/message_page.dart:358；原文：'官方'
  ///
  /// In zh, this message translates to:
  /// **'官方'**
  String get messagePage_358;
}

class _MessageLocalizationsDelegate extends LocalizationsDelegate<MessageLocalizations> {
  const _MessageLocalizationsDelegate();

  @override
  Future<MessageLocalizations> load(Locale locale) {
    return SynchronousFuture<MessageLocalizations>(lookupMessageLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_MessageLocalizationsDelegate old) => false;
}

MessageLocalizations lookupMessageLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return MessageLocalizationsEn();
    case 'zh': return MessageLocalizationsZh();
  }

  throw FlutterError(
    'MessageLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
