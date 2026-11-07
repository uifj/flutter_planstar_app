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
/// import 'generated/home_localizations.dart';
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
  /// **'企划详情'**
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
  /// **'{city} 暂无企划数据（演示数据仅覆盖部分城市）'**
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
  /// **'音乐企划 · 现场企划 · 巡演企划'**
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
  /// **'{next} 暂无企划数据（演示数据仅覆盖部分城市）'**
  String homePage_132(Object next);

  /// 来源：lib/features/home/home_page.dart:163；原文：'${slide.title} · 运营活动页（演示）'
  ///
  /// In zh, this message translates to:
  /// **'{title} · 运营活动页（演示）'**
  String homePage_163(Object title);

  /// 来源：lib/features/home/home_page.dart:175；原文：'$city 暂无演出'
  ///
  /// In zh, this message translates to:
  /// **'{city} 暂无企划'**
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
  /// **'热门企划'**
  String get homePage_193;

  /// 来源：lib/features/home/home_page.dart:194；原文：'本周想看人数最多'
  ///
  /// In zh, this message translates to:
  /// **'本周想看人数最多'**
  String get homePage_194;

  /// 来源：lib/features/home/home_page.dart:241；原文：'企划星 · 让看演出更简单'
  ///
  /// In zh, this message translates to:
  /// **'企划星 · 让好企划被看见'**
  String get homePage_241;

  /// 来源：lib/features/home/home_page.dart:251；原文：'让每一场演出都值得期待'
  ///
  /// In zh, this message translates to:
  /// **'让每一个企划都值得期待'**
  String get homePage_251;

  /// 来源：lib/features/home/home_page.dart:270；原文：'演唱会'
  ///
  /// In zh, this message translates to:
  /// **'音乐企划'**
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
  /// **'企划'**
  String get homePage_274;

  /// 来源：lib/features/home/home_page.dart:323；原文：'正在加载 $city 的演出…'
  ///
  /// In zh, this message translates to:
  /// **'正在加载 {city} 的企划…'**
  String homePage_323(Object city);

  /// 来源：lib/features/home/home_page.dart:363；原文：'加载失败'
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get homePage_363;

  /// 来源：lib/features/home/home_page.dart:364；原文：'无法获取 $city 的演出数据\n${error.toString()}'
  ///
  /// In zh, this message translates to:
  /// **'无法获取 {city} 的企划数据\n{toString}'**
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

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:47；原文：'新企划首发：星海拾荒者'
  ///
  /// In zh, this message translates to:
  /// **'新企划首发：星海拾荒者'**
  String get homeBannerFloor_47;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:48；原文：'上线 24 小时 · 支持者抢先看'
  ///
  /// In zh, this message translates to:
  /// **'上线 24 小时 · 支持者抢先看'**
  String get homeBannerFloor_48;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:49；原文：'首发'
  ///
  /// In zh, this message translates to:
  /// **'首发'**
  String get homeBannerFloor_49;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:53；原文：'达成目标，解锁回报'
  ///
  /// In zh, this message translates to:
  /// **'达成目标，解锁回报'**
  String get homeBannerFloor_53;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:54；原文：'每一档回报都写明交付时间'
  ///
  /// In zh, this message translates to:
  /// **'每一档回报都写明交付时间'**
  String get homeBannerFloor_54;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:55；原文：'达成'
  ///
  /// In zh, this message translates to:
  /// **'达成'**
  String get homeBannerFloor_55;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:59；原文：'支持者可获进度更新'
  ///
  /// In zh, this message translates to:
  /// **'支持者可获进度更新'**
  String get homeBannerFloor_59;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:60；原文：'创作者认证 · 每步进展都可查'
  ///
  /// In zh, this message translates to:
  /// **'创作者认证 · 每步进展都可查'**
  String get homeBannerFloor_60;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:61；原文：'更新'
  ///
  /// In zh, this message translates to:
  /// **'更新'**
  String get homeBannerFloor_61;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:66；原文：'资金托管 · 未达成全额退'
  ///
  /// In zh, this message translates to:
  /// **'资金托管 · 未达成全额退'**
  String get homeBannerFloor_66;

  /// 来源：lib/features/home/widgets/home_banner_floor.dart:67；原文：'支持款平台托管 · 原路退回'
  ///
  /// In zh, this message translates to:
  /// **'支持款平台托管 · 原路退回'**
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
  /// **'100%履约'**
  String get homeGuaranteeFloor_13;

  /// 来源：lib/features/home/widgets/home_guarantee_floor.dart:13；原文：'无票赔付'
  ///
  /// In zh, this message translates to:
  /// **'未达成退款'**
  String get homeGuaranteeFloor_13_2;

  /// 来源：lib/features/home/widgets/home_guarantee_floor.dart:13；原文：'出票保真'
  ///
  /// In zh, this message translates to:
  /// **'交付保障'**
  String get homeGuaranteeFloor_13_3;

  /// 来源：lib/features/home/widgets/home_guarantee_floor.dart:13；原文：'配送保障'
  ///
  /// In zh, this message translates to:
  /// **'配送保障'**
  String get homeGuaranteeFloor_13_4;

  /// 来源：lib/features/home/widgets/home_header.dart:108；原文：'100%真票 · 无票赔付'
  ///
  /// In zh, this message translates to:
  /// **'100%履约 · 未达成退款'**
  String get homeHeader_108;

  /// 来源：lib/features/home/widgets/home_venues_floor.dart:48；原文：'热门场馆'
  ///
  /// In zh, this message translates to:
  /// **'热门活动场地'**
  String get homeVenuesFloor_48;

  /// No description provided for @homeProjectPicked.
  ///
  /// In zh, this message translates to:
  /// **'精选企划'**
  String get homeProjectPicked;

  /// No description provided for @homeProjectBannerSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'企划星 × 认真做内容的人'**
  String get homeProjectBannerSubtitle;

  /// No description provided for @homeHotProjectTitle.
  ///
  /// In zh, this message translates to:
  /// **'正在支持的企划'**
  String get homeHotProjectTitle;

  /// No description provided for @homeHotProjectDesc.
  ///
  /// In zh, this message translates to:
  /// **'按支持人数与达成率排序'**
  String get homeHotProjectDesc;

  /// No description provided for @homeFloorGame.
  ///
  /// In zh, this message translates to:
  /// **'游戏企划'**
  String get homeFloorGame;

  /// No description provided for @homeFloorNovel.
  ///
  /// In zh, this message translates to:
  /// **'小说企划'**
  String get homeFloorNovel;

  /// No description provided for @homeFloorDoujin.
  ///
  /// In zh, this message translates to:
  /// **'同人企划'**
  String get homeFloorDoujin;

  /// No description provided for @homeFloorInterview.
  ///
  /// In zh, this message translates to:
  /// **'面经企划'**
  String get homeFloorInterview;

  /// No description provided for @homeFloorOther.
  ///
  /// In zh, this message translates to:
  /// **'更多企划'**
  String get homeFloorOther;

  /// No description provided for @homeFloorGameDesc.
  ///
  /// In zh, this message translates to:
  /// **'把喜欢的游戏做出来'**
  String get homeFloorGameDesc;

  /// No description provided for @homeFloorNovelDesc.
  ///
  /// In zh, this message translates to:
  /// **'让故事被印成书'**
  String get homeFloorNovelDesc;

  /// No description provided for @homeFloorDoujinDesc.
  ///
  /// In zh, this message translates to:
  /// **'同人创作，一起完成'**
  String get homeFloorDoujinDesc;

  /// No description provided for @homeFloorInterviewDesc.
  ///
  /// In zh, this message translates to:
  /// **'把经验变成可交付的手册'**
  String get homeFloorInterviewDesc;

  /// No description provided for @homeRankingTitle.
  ///
  /// In zh, this message translates to:
  /// **'企划榜单'**
  String get homeRankingTitle;

  /// No description provided for @homeRankingHot.
  ///
  /// In zh, this message translates to:
  /// **'热度榜'**
  String get homeRankingHot;

  /// No description provided for @homeRankingAchievement.
  ///
  /// In zh, this message translates to:
  /// **'达成榜'**
  String get homeRankingAchievement;

  /// No description provided for @homeRankingEnding.
  ///
  /// In zh, this message translates to:
  /// **'冲刺榜'**
  String get homeRankingEnding;

  /// No description provided for @homeRankingMetricSupporters.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人支持'**
  String homeRankingMetricSupporters(int count);

  /// No description provided for @homeRankingMetricAchievement.
  ///
  /// In zh, this message translates to:
  /// **'达成 {percent}%'**
  String homeRankingMetricAchievement(int percent);

  /// No description provided for @homeRankingMetricRemaining.
  ///
  /// In zh, this message translates to:
  /// **'剩 {days} 天'**
  String homeRankingMetricRemaining(int days);
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
