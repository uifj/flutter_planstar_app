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
/// import 'generated/message_localizations.dart';
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

  /// No description provided for @messageProviders_48.
  ///
  /// In zh, this message translates to:
  /// **'活动通知'**
  String get messageProviders_48;

  /// No description provided for @messageProviders_49.
  ///
  /// In zh, this message translates to:
  /// **'回复我的'**
  String get messageProviders_49;

  /// No description provided for @messageProviders_50.
  ///
  /// In zh, this message translates to:
  /// **'赞和关注'**
  String get messageProviders_50;

  /// No description provided for @messageProviders_55.
  ///
  /// In zh, this message translates to:
  /// **'企划星官方客服'**
  String get messageProviders_55;

  /// No description provided for @messageProviders_56.
  ///
  /// In zh, this message translates to:
  /// **'您好，关于《星海回声》企划的支持退款问题，我们已为您登记…'**
  String get messageProviders_56;

  /// No description provided for @messageProviders_64.
  ///
  /// In zh, this message translates to:
  /// **'企划提醒'**
  String get messageProviders_64;

  /// No description provided for @messageProviders_65.
  ///
  /// In zh, this message translates to:
  /// **'您关注的「夏日回声企划」即将开放支持，别忘了设置提醒'**
  String get messageProviders_65;

  /// No description provided for @messageProviders_71.
  ///
  /// In zh, this message translates to:
  /// **'订单助手'**
  String get messageProviders_71;

  /// No description provided for @messageProviders_72.
  ///
  /// In zh, this message translates to:
  /// **'订单 PN20261108000001 已生成支持凭证，可在「我的订单」查看'**
  String get messageProviders_72;

  /// No description provided for @messageProviders_79.
  ///
  /// In zh, this message translates to:
  /// **'企划常驻民'**
  String get messageProviders_79;

  /// No description provided for @messageProviders_80.
  ///
  /// In zh, this message translates to:
  /// **'你发的动态收到了 12 个赞'**
  String get messageProviders_80;

  /// No description provided for @messageProviders_86.
  ///
  /// In zh, this message translates to:
  /// **'支持小分队'**
  String get messageProviders_86;

  /// No description provided for @messageProviders_87.
  ///
  /// In zh, this message translates to:
  /// **'新档位追加了，明天十点开放支持'**
  String get messageProviders_87;

  /// No description provided for @messageProviders_93.
  ///
  /// In zh, this message translates to:
  /// **'企划星福利官'**
  String get messageProviders_93;

  /// No description provided for @messageProviders_94.
  ///
  /// In zh, this message translates to:
  /// **'您有一张 50 星币无门槛券即将过期'**
  String get messageProviders_94;

  /// No description provided for @chatPage_75.
  ///
  /// In zh, this message translates to:
  /// **'会话'**
  String get chatPage_75;

  /// No description provided for @chatPage_76.
  ///
  /// In zh, this message translates to:
  /// **'官方账号'**
  String get chatPage_76;

  /// No description provided for @chatPage_80.
  ///
  /// In zh, this message translates to:
  /// **'会话不存在'**
  String get chatPage_80;

  /// No description provided for @chatPage_81.
  ///
  /// In zh, this message translates to:
  /// **'它可能已被清空'**
  String get chatPage_81;

  /// No description provided for @chatPage_83.
  ///
  /// In zh, this message translates to:
  /// **'返回消息'**
  String get chatPage_83;

  /// No description provided for @chatPage_91.
  ///
  /// In zh, this message translates to:
  /// **'还没有消息'**
  String get chatPage_91;

  /// No description provided for @chatPage_92.
  ///
  /// In zh, this message translates to:
  /// **'打个招呼吧'**
  String get chatPage_92;

  /// No description provided for @chatPage_288.
  ///
  /// In zh, this message translates to:
  /// **'演示环境：消息只保存在本地，不会真的发送'**
  String get chatPage_288;

  /// No description provided for @chatPage_310.
  ///
  /// In zh, this message translates to:
  /// **'输入消息…'**
  String get chatPage_310;

  /// No description provided for @chatPage_334.
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get chatPage_334;

  /// No description provided for @messagePage_62.
  ///
  /// In zh, this message translates to:
  /// **'{title}列表（演示）'**
  String messagePage_62(Object title);

  /// No description provided for @messagePage_72.
  ///
  /// In zh, this message translates to:
  /// **'暂无消息'**
  String get messagePage_72;

  /// No description provided for @messagePage_73.
  ///
  /// In zh, this message translates to:
  /// **'订单进度、支持提醒都会出现在这里'**
  String get messagePage_73;

  /// No description provided for @messagePage_122.
  ///
  /// In zh, this message translates to:
  /// **'清空消息'**
  String get messagePage_122;

  /// No description provided for @messagePage_123.
  ///
  /// In zh, this message translates to:
  /// **'清空后会话记录将不再显示，确定继续吗？'**
  String get messagePage_123;

  /// No description provided for @messagePage_131.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get messagePage_131;

  /// No description provided for @messagePage_160.
  ///
  /// In zh, this message translates to:
  /// **'消息中心'**
  String get messagePage_160;

  /// No description provided for @messagePage_358.
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
