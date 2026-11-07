import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'group_buy_localizations_en.dart';
import 'group_buy_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of GroupBuyLocalizations
/// returned by `GroupBuyLocalizations.of(context)`.
///
/// Applications need to include `GroupBuyLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/group_buy_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: GroupBuyLocalizations.localizationsDelegates,
///   supportedLocales: GroupBuyLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the GroupBuyLocalizations.supportedLocales
/// property.
abstract class GroupBuyLocalizations {
  GroupBuyLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static GroupBuyLocalizations of(BuildContext context) {
    return Localizations.of<GroupBuyLocalizations>(context, GroupBuyLocalizations)!;
  }

  static const LocalizationsDelegate<GroupBuyLocalizations> delegate = _GroupBuyLocalizationsDelegate();

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

  /// 来源：lib/features/group_buy/group_buy.dart:72；原文：'超低价拼团'
  ///
  /// In zh, this message translates to:
  /// **'超低价拼团'**
  String get groupBuy_72;

  /// 来源：lib/features/group_buy/group_buy.dart:144；原文：'${rate ~/ 10}折'
  ///
  /// In zh, this message translates to:
  /// **'{rate}折'**
  String groupBuy_144(Object rate);

  /// 来源：lib/features/group_buy/group_buy.dart:145；原文：'${rate / 10}折'
  ///
  /// In zh, this message translates to:
  /// **'{rate}折'**
  String groupBuy_145(Object rate);

  /// 来源：lib/features/group_buy/group_buy.dart:155；原文：'拼团中'
  ///
  /// In zh, this message translates to:
  /// **'拼团中'**
  String get groupBuy_155;

  /// 来源：lib/features/group_buy/group_buy.dart:157；原文：'拼团成功'
  ///
  /// In zh, this message translates to:
  /// **'拼团成功'**
  String get groupBuy_157;

  /// 来源：lib/features/group_buy/group_buy.dart:159；原文：'拼团失败'
  ///
  /// In zh, this message translates to:
  /// **'拼团失败'**
  String get groupBuy_159;

  /// 来源：lib/features/group_buy/group_buy.dart:161；原文：'已取消'
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get groupBuy_161;

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:46；原文：'拼团详情'
  ///
  /// In zh, this message translates to:
  /// **'拼团详情'**
  String get groupBuyDetailPage_46;

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:49；原文：'拼团活动不存在'
  ///
  /// In zh, this message translates to:
  /// **'拼团活动不存在'**
  String get groupBuyDetailPage_49;

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:60；原文：'拼团详情'
  ///
  /// In zh, this message translates to:
  /// **'拼团详情'**
  String get groupBuyDetailPage_60;

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:172；原文：'拼团价 '
  ///
  /// In zh, this message translates to:
  /// **'拼团价 '**
  String get groupBuyDetailPage_172;

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:208；原文：'省${group.savedAmount.format(withSymbol: false)}'
  ///
  /// In zh, this message translates to:
  /// **'省{savedAmount}'**
  String groupBuyDetailPage_208(Object savedAmount);

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:249；原文：'${group.succeedNum}人成团'
  ///
  /// In zh, this message translates to:
  /// **'{succeedNum}人成团'**
  String groupBuyDetailPage_249(Object succeedNum);

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:259；原文：'已满团'
  ///
  /// In zh, this message translates to:
  /// **'已满团'**
  String get groupBuyDetailPage_259;

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:259；原文：'还差${group.remaining}人'
  ///
  /// In zh, this message translates to:
  /// **'还差{remaining}人'**
  String groupBuyDetailPage_259_2(Object remaining);

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:283；原文：'剩余 ${group.remainingHours} 小时'
  ///
  /// In zh, this message translates to:
  /// **'剩余 {remainingHours} 小时'**
  String groupBuyDetailPage_283(Object remainingHours);

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:316；原文：'参团成员 (${group.currentMembers}/${group.succeedNum})'
  ///
  /// In zh, this message translates to:
  /// **'参团成员 ({currentMembers}/{succeedNum})'**
  String groupBuyDetailPage_316(Object currentMembers, Object succeedNum);

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:394；原文：'团长'
  ///
  /// In zh, this message translates to:
  /// **'团长'**
  String get groupBuyDetailPage_394;

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:444；原文：'待邀请'
  ///
  /// In zh, this message translates to:
  /// **'待邀请'**
  String get groupBuyDetailPage_444;

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:472；原文：'拼团规则'
  ///
  /// In zh, this message translates to:
  /// **'拼团规则'**
  String get groupBuyDetailPage_472;

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:481；原文：'1. 在有效期内邀请好友参团，满人数即成团\n'
  ///             '2. 拼团成功后系统自动出票\n'
  ///             '3. 未在有效期内满团则自动退款\n'
  ///             '4. 每人限参 1 个拼团\n'
  ///             '5. 拼团价不与其他优惠叠加'
  ///
  /// In zh, this message translates to:
  /// **'1. 在有效期内邀请好友参团，满人数即成团\n2. 拼团成功后系统自动生成支持凭证\n3. 未在有效期内满团则自动退款\n4. 每人限参 1 个拼团\n5. 拼团价不与其他优惠叠加'**
  String get groupBuyDetailPage_481;

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:533；原文：'拼团价'
  ///
  /// In zh, this message translates to:
  /// **'拼团价'**
  String get groupBuyDetailPage_533;

  /// 来源：lib/features/group_buy/group_buy_detail_page.dart:573；原文：'立即参团'
  ///
  /// In zh, this message translates to:
  /// **'立即参团'**
  String get groupBuyDetailPage_573;

  /// 来源：lib/features/group_buy/group_buy_page.dart:28；原文：'超低价拼团'
  ///
  /// In zh, this message translates to:
  /// **'超低价拼团'**
  String get groupBuyPage_28;

  /// 来源：lib/features/group_buy/group_buy_page.dart:31；原文：'暂无拼团活动'
  ///
  /// In zh, this message translates to:
  /// **'暂无拼团活动'**
  String get groupBuyPage_31;

  /// 来源：lib/features/group_buy/group_buy_page.dart:32；原文：'拼团活动上线后会显示在这里'
  ///
  /// In zh, this message translates to:
  /// **'拼团活动上线后会显示在这里'**
  String get groupBuyPage_32;

  /// 来源：lib/features/group_buy/group_buy_page.dart:150；原文：'拼团价 '
  ///
  /// In zh, this message translates to:
  /// **'拼团价 '**
  String get groupBuyPage_150;

  /// 来源：lib/features/group_buy/group_buy_page.dart:210；原文：'${group.currentMembers}/${group.succeedNum}人'
  ///
  /// In zh, this message translates to:
  /// **'{currentMembers}/{succeedNum}人'**
  String groupBuyPage_210(Object currentMembers, Object succeedNum);

  /// 来源：lib/features/group_buy/group_buy_providers.dart:59；原文：'参团成功！等待拼团完成'
  ///
  /// In zh, this message translates to:
  /// **'参团成功！等待拼团完成'**
  String get groupBuyProviders_59;
}

class _GroupBuyLocalizationsDelegate extends LocalizationsDelegate<GroupBuyLocalizations> {
  const _GroupBuyLocalizationsDelegate();

  @override
  Future<GroupBuyLocalizations> load(Locale locale) {
    return SynchronousFuture<GroupBuyLocalizations>(lookupGroupBuyLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_GroupBuyLocalizationsDelegate old) => false;
}

GroupBuyLocalizations lookupGroupBuyLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return GroupBuyLocalizationsEn();
    case 'zh': return GroupBuyLocalizationsZh();
  }

  throw FlutterError(
    'GroupBuyLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
