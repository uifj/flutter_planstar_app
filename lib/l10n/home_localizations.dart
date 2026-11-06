import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'home_localizations_en.dart';
import 'home_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of HomeLocalizations
/// returned by `HomeLocalizations.of(context)`.
///
/// Applications need to include `HomeLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/home_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: HomeLocalizations.localizationsDelegates,
///   supportedLocales: HomeLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the HomeLocalizations.supportedLocales
/// property.
abstract class HomeLocalizations {
  HomeLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static HomeLocalizations of(BuildContext context) {
    return Localizations.of<HomeLocalizations>(context, HomeLocalizations)!;
  }

  static const LocalizationsDelegate<HomeLocalizations> delegate = _HomeLocalizationsDelegate();

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

  /// No description provided for @homeTitle.
  ///
  /// In zh, this message translates to:
  /// **'企划星 · 首页'**
  String get homeTitle;

  /// No description provided for @homeEntryShowDetail.
  ///
  /// In zh, this message translates to:
  /// **'演出详情'**
  String get homeEntryShowDetail;

  /// No description provided for @homeEntryShowDetailSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'深链 planstar://activity_detail?showId=888 → /show/888'**
  String get homeEntryShowDetailSubtitle;

  /// No description provided for @homeEntryOrderConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认订单（需登录）'**
  String get homeEntryOrderConfirm;

  /// No description provided for @homeEntryOrderConfirmSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'planstar://order_confirm → /order/confirm，触发登录门禁'**
  String get homeEntryOrderConfirmSubtitle;

  /// 来源：lib/features/home/city_list_page.dart:46；原文：'$city 暂无演出数据（演示数据仅覆盖部分城市）'
  ///
  /// In zh, this message translates to:
  /// **'{city} 暂无演出数据（演示数据仅覆盖部分城市）'**
  String cityListPage_46(Object city);

  /// 来源：lib/features/home/city_list_page.dart:53；原文：'选择城市'
  ///
  /// In zh, this message translates to:
  /// **'选择城市'**
  String get cityListPage_53;

  /// 来源：lib/features/home/city_list_page.dart:57；原文：'上海'
  ///
  /// In zh, this message translates to:
  /// **'上海'**
  String get cityListPage_57;

  /// 来源：lib/features/home/city_list_page.dart:59；原文：'热门城市'
  ///
  /// In zh, this message translates to:
  /// **'热门城市'**
  String get cityListPage_59;

  /// 来源：lib/features/home/city_list_page.dart:65；原文：'全部城市'
  ///
  /// In zh, this message translates to:
  /// **'全部城市'**
  String get cityListPage_65;

  /// 来源：lib/features/home/city_list_page.dart:73；原文：'演示数据只覆盖上海、北京、杭州、广州、深圳；其余城市会显示空态。'
  ///
  /// In zh, this message translates to:
  /// **'演示数据只覆盖上海、北京、杭州、广州、深圳；其余城市会显示空态。'**
  String get cityListPage_73;

  /// 来源：lib/features/home/city_list_page.dart:115；原文：'当前定位：上海'
  ///
  /// In zh, this message translates to:
  /// **'当前定位：上海'**
  String get cityListPage_115;

  /// 来源：lib/features/home/city_list_page.dart:120；原文：'演示环境没有接入定位，这里固定为上海'
  ///
  /// In zh, this message translates to:
  /// **'演示环境没有接入定位，这里固定为上海'**
  String get cityListPage_120;

  /// 来源：lib/features/home/city_list_page.dart:126；原文：'上海'
  ///
  /// In zh, this message translates to:
  /// **'上海'**
  String get cityListPage_126;

  /// 来源：lib/features/home/city_list_page.dart:140；原文：'使用'
  ///
  /// In zh, this message translates to:
  /// **'使用'**
  String get cityListPage_140;

  /// 来源：lib/features/home/home_page.dart:51；原文：'演唱会 · 音乐节 · 巡演'
  ///
  /// In zh, this message translates to:
  /// **'演唱会 · 音乐节 · 巡演'**
  String get homePage_51;

  /// 来源：lib/features/home/home_page.dart:52；原文：'话剧 · 音乐剧 · 沉浸式'
  ///
  /// In zh, this message translates to:
  /// **'话剧 · 音乐剧 · 沉浸式'**
  String get homePage_52;

  /// 来源：lib/features/home/home_page.dart:53；原文：'交响 · 独奏 · 室内乐'
  ///
  /// In zh, this message translates to:
  /// **'交响 · 独奏 · 室内乐'**
  String get homePage_53;

  /// 来源：lib/features/home/home_page.dart:54；原文：'儿童剧 · 亲子活动'
  ///
  /// In zh, this message translates to:
  /// **'儿童剧 · 亲子活动'**
  String get homePage_54;

  /// 来源：lib/features/home/home_page.dart:132；原文：'$next 暂无演出数据（演示数据仅覆盖部分城市）'
  ///
  /// In zh, this message translates to:
  /// **'{next} 暂无演出数据（演示数据仅覆盖部分城市）'**
  String homePage_132(Object next);

  /// 来源：lib/features/home/home_page.dart:163；原文：'${slide.title} · 运营活动页（演示）'
  ///
  /// In zh, this message translates to:
  /// **'{title} · 运营活动页（演示）'**
  String homePage_163(Object title);

  /// 来源：lib/features/home/home_page.dart:175；原文：'$city 暂无演出'
  ///
  /// In zh, this message translates to:
  /// **'{city} 暂无演出'**
  String homePage_175(Object city);

  /// 来源：lib/features/home/home_page.dart:176；原文：'演示数据只覆盖上海、北京、杭州、广州、深圳'
  ///
  /// In zh, this message translates to:
  /// **'演示数据只覆盖上海、北京、杭州、广州、深圳'**
  String get homePage_176;

  /// 来源：lib/features/home/home_page.dart:178；原文：'切换到上海'
  ///
  /// In zh, this message translates to:
  /// **'切换到上海'**
  String get homePage_178;

  /// 来源：lib/features/home/home_page.dart:180；原文：'上海'
  ///
  /// In zh, this message translates to:
  /// **'上海'**
  String get homePage_180;

  /// 来源：lib/features/home/home_page.dart:193；原文：'热门演出'
  ///
  /// In zh, this message translates to:
  /// **'热门演出'**
  String get homePage_193;

  /// 来源：lib/features/home/home_page.dart:194；原文：'本周想看人数最多'
  ///
  /// In zh, this message translates to:
  /// **'本周想看人数最多'**
  String get homePage_194;

  /// 来源：lib/features/home/home_page.dart:241；原文：'企划星 · 让看演出更简单'
  ///
  /// In zh, this message translates to:
  /// **'企划星 · 让看演出更简单'**
  String get homePage_241;

  /// 来源：lib/features/home/home_page.dart:251；原文：'让每一场演出都值得期待'
  ///
  /// In zh, this message translates to:
  /// **'让每一场演出都值得期待'**
  String get homePage_251;

  /// 来源：lib/features/home/home_page.dart:270；原文：'演唱会'
  ///
  /// In zh, this message translates to:
  /// **'演唱会'**
  String get homePage_270;

  /// 来源：lib/features/home/home_page.dart:271；原文：'话剧歌剧'
  ///
  /// In zh, this message translates to:
  /// **'话剧歌剧'**
  String get homePage_271;

  /// 来源：lib/features/home/home_page.dart:272；原文：'音乐会'
  ///
  /// In zh, this message translates to:
  /// **'音乐会'**
  String get homePage_272;

  /// 来源：lib/features/home/home_page.dart:273；原文：'儿童亲子'
  ///
  /// In zh, this message translates to:
  /// **'儿童亲子'**
  String get homePage_273;

  /// 来源：lib/features/home/home_page.dart:274；原文：'演出'
  ///
  /// In zh, this message translates to:
  /// **'演出'**
  String get homePage_274;

  /// 来源：lib/features/home/home_page.dart:323；原文：'正在加载 $city 的演出…'
  ///
  /// In zh, this message translates to:
  /// **'正在加载 {city} 的演出…'**
  String homePage_323(Object city);

  /// 来源：lib/features/home/home_page.dart:363；原文：'加载失败'
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get homePage_363;

  /// 来源：lib/features/home/home_page.dart:364；原文：'无法获取 $city 的演出数据\n${error.toString()}'
  ///
  /// In zh, this message translates to:
  /// **'无法获取 {city} 的演出数据\n{toString}'**
  String homePage_364(Object city, Object toString);

  /// 来源：lib/features/home/widgets/city_picker_sheet.dart:70；原文：'选择城市'
  ///
  /// In zh, this message translates to:
  /// **'选择城市'**
  String get cityPickerSheet_70;

  /// 来源：lib/features/home/widgets/city_picker_sheet.dart:90；原文：'当前定位：上海'
  ///
  /// In zh, this message translates to:
  /// **'当前定位：上海'**
  String get cityPickerSheet_90;

  /// 来源：lib/features/home/widgets/city_picker_sheet.dart:97；原文：'热门城市'
  ///
  /// In zh, this message translates to:
  /// **'热门城市'**
  String get cityPickerSheet_97;

  /// 来源：lib/features/home/widgets/city_picker_sheet.dart:127；原文：'查看全部城市'
  ///
  /// In zh, this message translates to:
  /// **'查看全部城市'**
  String get cityPickerSheet_127;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:47；原文：'双 11 演出狂欢'
  ///
  /// In zh, this message translates to:
  /// **'双 11 演出狂欢'**
  String get homeBannerFloor_47;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:48；原文：'满 500 减 100 · 全场通用'
  ///
  /// In zh, this message translates to:
  /// **'满 500 减 100 · 全场通用'**
  String get homeBannerFloor_48;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:49；原文：'限时'
  ///
  /// In zh, this message translates to:
  /// **'限时'**
  String get homeBannerFloor_49;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:53；原文：'新人首单立减 50'
  ///
  /// In zh, this message translates to:
  /// **'新人首单立减 50'**
  String get homeBannerFloor_53;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:54；原文：'注册即领 · 无门槛使用'
  ///
  /// In zh, this message translates to:
  /// **'注册即领 · 无门槛使用'**
  String get homeBannerFloor_54;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:55；原文：'新人'
  ///
  /// In zh, this message translates to:
  /// **'新人'**
  String get homeBannerFloor_55;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:59；原文：'《剧院魅影》中文版'
  ///
  /// In zh, this message translates to:
  /// **'《剧院魅影》中文版'**
  String get homeBannerFloor_59;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:60；原文：'限时 9 折 · 上海文化广场'
  ///
  /// In zh, this message translates to:
  /// **'限时 9 折 · 上海文化广场'**
  String get homeBannerFloor_60;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:61；原文：'热卖'
  ///
  /// In zh, this message translates to:
  /// **'热卖'**
  String get homeBannerFloor_61;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:66；原文：'企划星安心入场保障'
  ///
  /// In zh, this message translates to:
  /// **'企划星安心入场保障'**
  String get homeBannerFloor_66;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:67；原文：'无票必赔 · 最高退一赔一'
  ///
  /// In zh, this message translates to:
  /// **'无票必赔 · 最高退一赔一'**
  String get homeBannerFloor_67;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:68；原文：'保障'
  ///
  /// In zh, this message translates to:
  /// **'保障'**
  String get homeBannerFloor_68;

  /// 来源：lib/features/home/widgets/home_choiceness_floor.dart:83；原文：'精选推荐'
  ///
  /// In zh, this message translates to:
  /// **'精选推荐'**
  String get homeChoicenessFloor_83;

  /// 来源：lib/features/home/widgets/home_guarantee_floor.dart:13；原文：'100%真票'
  ///
  /// In zh, this message translates to:
  /// **'100%真票'**
  String get homeGuaranteeFloor_13;

  /// 来源：lib/features/home/widgets/home_guarantee_floor.dart:13；原文：'无票赔付'
  ///
  /// In zh, this message translates to:
  /// **'无票赔付'**
  String get homeGuaranteeFloor_13_2;

  /// 来源：lib/features/home/widgets/home_guarantee_floor.dart:13；原文：'出票保真'
  ///
  /// In zh, this message translates to:
  /// **'出票保真'**
  String get homeGuaranteeFloor_13_3;

  /// 来源：lib/features/home/widgets/home_guarantee_floor.dart:13；原文：'配送保障'
  ///
  /// In zh, this message translates to:
  /// **'配送保障'**
  String get homeGuaranteeFloor_13_4;

  /// 来源：lib/features/home/widgets/home_header.dart:108；原文：'100%真票 · 无票赔付'
  ///
  /// In zh, this message translates to:
  /// **'100%真票 · 无票赔付'**
  String get homeHeader_108;

  /// 来源：lib/features/home/widgets/home_venues_floor.dart:48；原文：'热门场馆'
  ///
  /// In zh, this message translates to:
  /// **'热门场馆'**
  String get homeVenuesFloor_48;
}

class _HomeLocalizationsDelegate extends LocalizationsDelegate<HomeLocalizations> {
  const _HomeLocalizationsDelegate();

  @override
  Future<HomeLocalizations> load(Locale locale) {
    return SynchronousFuture<HomeLocalizations>(lookupHomeLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_HomeLocalizationsDelegate old) => false;
}

HomeLocalizations lookupHomeLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return HomeLocalizationsEn();
    case 'zh': return HomeLocalizationsZh();
  }

  throw FlutterError(
    'HomeLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
