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

  /// No description provided for @cityListPage_46.
  ///
  /// In zh, this message translates to:
  /// **'{city} 暂无企划数据（演示数据仅覆盖部分城市）'**
  String cityListPage_46(Object city);

  /// No description provided for @cityListPage_53.
  ///
  /// In zh, this message translates to:
  /// **'选择城市'**
  String get cityListPage_53;

  /// No description provided for @cityListPage_57.
  ///
  /// In zh, this message translates to:
  /// **'上海'**
  String get cityListPage_57;

  /// No description provided for @cityListPage_59.
  ///
  /// In zh, this message translates to:
  /// **'热门城市'**
  String get cityListPage_59;

  /// No description provided for @cityListPage_65.
  ///
  /// In zh, this message translates to:
  /// **'全部城市'**
  String get cityListPage_65;

  /// No description provided for @cityListPage_73.
  ///
  /// In zh, this message translates to:
  /// **'演示数据只覆盖上海、北京、杭州、广州、深圳；其余城市会显示空态。'**
  String get cityListPage_73;

  /// No description provided for @cityListPage_115.
  ///
  /// In zh, this message translates to:
  /// **'当前定位：上海'**
  String get cityListPage_115;

  /// No description provided for @cityListPage_120.
  ///
  /// In zh, this message translates to:
  /// **'演示环境没有接入定位，这里固定为上海'**
  String get cityListPage_120;

  /// No description provided for @cityListPage_126.
  ///
  /// In zh, this message translates to:
  /// **'上海'**
  String get cityListPage_126;

  /// No description provided for @cityListPage_140.
  ///
  /// In zh, this message translates to:
  /// **'使用'**
  String get cityListPage_140;

  /// No description provided for @homePage_51.
  ///
  /// In zh, this message translates to:
  /// **'音乐企划 · 现场企划 · 巡演企划'**
  String get homePage_51;

  /// No description provided for @homePage_52.
  ///
  /// In zh, this message translates to:
  /// **'话剧 · 音乐剧 · 沉浸式'**
  String get homePage_52;

  /// No description provided for @homePage_53.
  ///
  /// In zh, this message translates to:
  /// **'交响 · 独奏 · 室内乐'**
  String get homePage_53;

  /// No description provided for @homePage_54.
  ///
  /// In zh, this message translates to:
  /// **'儿童剧 · 亲子活动'**
  String get homePage_54;

  /// No description provided for @homePage_132.
  ///
  /// In zh, this message translates to:
  /// **'{next} 暂无企划数据（演示数据仅覆盖部分城市）'**
  String homePage_132(Object next);

  /// No description provided for @homePage_163.
  ///
  /// In zh, this message translates to:
  /// **'{title} · 运营活动页（演示）'**
  String homePage_163(Object title);

  /// No description provided for @homePage_175.
  ///
  /// In zh, this message translates to:
  /// **'{city} 暂无企划'**
  String homePage_175(Object city);

  /// No description provided for @homePage_176.
  ///
  /// In zh, this message translates to:
  /// **'演示数据只覆盖上海、北京、杭州、广州、深圳'**
  String get homePage_176;

  /// No description provided for @homePage_178.
  ///
  /// In zh, this message translates to:
  /// **'切换到上海'**
  String get homePage_178;

  /// No description provided for @homePage_180.
  ///
  /// In zh, this message translates to:
  /// **'上海'**
  String get homePage_180;

  /// No description provided for @homePage_193.
  ///
  /// In zh, this message translates to:
  /// **'热门企划'**
  String get homePage_193;

  /// No description provided for @homePage_194.
  ///
  /// In zh, this message translates to:
  /// **'本周想看人数最多'**
  String get homePage_194;

  /// No description provided for @homePage_241.
  ///
  /// In zh, this message translates to:
  /// **'企划星 · 让好企划被看见'**
  String get homePage_241;

  /// No description provided for @homePage_251.
  ///
  /// In zh, this message translates to:
  /// **'让每一个企划都值得期待'**
  String get homePage_251;

  /// No description provided for @homePage_270.
  ///
  /// In zh, this message translates to:
  /// **'音乐企划'**
  String get homePage_270;

  /// No description provided for @homePage_271.
  ///
  /// In zh, this message translates to:
  /// **'话剧歌剧'**
  String get homePage_271;

  /// No description provided for @homePage_272.
  ///
  /// In zh, this message translates to:
  /// **'音乐会'**
  String get homePage_272;

  /// No description provided for @homePage_273.
  ///
  /// In zh, this message translates to:
  /// **'儿童亲子'**
  String get homePage_273;

  /// No description provided for @homePage_274.
  ///
  /// In zh, this message translates to:
  /// **'企划'**
  String get homePage_274;

  /// No description provided for @homePage_323.
  ///
  /// In zh, this message translates to:
  /// **'正在加载 {city} 的企划…'**
  String homePage_323(Object city);

  /// No description provided for @homePage_363.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get homePage_363;

  /// No description provided for @homePage_364.
  ///
  /// In zh, this message translates to:
  /// **'无法获取 {city} 的企划数据\n{toString}'**
  String homePage_364(Object city, Object toString);

  /// No description provided for @cityPickerSheet_70.
  ///
  /// In zh, this message translates to:
  /// **'选择城市'**
  String get cityPickerSheet_70;

  /// No description provided for @cityPickerSheet_90.
  ///
  /// In zh, this message translates to:
  /// **'当前定位：上海'**
  String get cityPickerSheet_90;

  /// No description provided for @cityPickerSheet_97.
  ///
  /// In zh, this message translates to:
  /// **'热门城市'**
  String get cityPickerSheet_97;

  /// No description provided for @cityPickerSheet_127.
  ///
  /// In zh, this message translates to:
  /// **'查看全部城市'**
  String get cityPickerSheet_127;

  /// No description provided for @homeBannerFloor_47.
  ///
  /// In zh, this message translates to:
  /// **'新企划首发：星海拾荒者'**
  String get homeBannerFloor_47;

  /// No description provided for @homeBannerFloor_48.
  ///
  /// In zh, this message translates to:
  /// **'上线 24 小时 · 支持者抢先看'**
  String get homeBannerFloor_48;

  /// No description provided for @homeBannerFloor_49.
  ///
  /// In zh, this message translates to:
  /// **'首发'**
  String get homeBannerFloor_49;

  /// No description provided for @homeBannerFloor_53.
  ///
  /// In zh, this message translates to:
  /// **'达成目标，解锁回报'**
  String get homeBannerFloor_53;

  /// No description provided for @homeBannerFloor_54.
  ///
  /// In zh, this message translates to:
  /// **'每一档回报都写明交付时间'**
  String get homeBannerFloor_54;

  /// No description provided for @homeBannerFloor_55.
  ///
  /// In zh, this message translates to:
  /// **'达成'**
  String get homeBannerFloor_55;

  /// No description provided for @homeBannerFloor_59.
  ///
  /// In zh, this message translates to:
  /// **'支持者可获进度更新'**
  String get homeBannerFloor_59;

  /// No description provided for @homeBannerFloor_60.
  ///
  /// In zh, this message translates to:
  /// **'创作者认证 · 每步进展都可查'**
  String get homeBannerFloor_60;

  /// No description provided for @homeBannerFloor_61.
  ///
  /// In zh, this message translates to:
  /// **'更新'**
  String get homeBannerFloor_61;

  /// No description provided for @homeBannerFloor_66.
  ///
  /// In zh, this message translates to:
  /// **'资金托管 · 未达成全额退'**
  String get homeBannerFloor_66;

  /// No description provided for @homeBannerFloor_67.
  ///
  /// In zh, this message translates to:
  /// **'支持款平台托管 · 原路退回'**
  String get homeBannerFloor_67;

  /// No description provided for @homeBannerFloor_68.
  ///
  /// In zh, this message translates to:
  /// **'保障'**
  String get homeBannerFloor_68;

  /// No description provided for @homeChoicenessFloor_83.
  ///
  /// In zh, this message translates to:
  /// **'精选推荐'**
  String get homeChoicenessFloor_83;

  /// No description provided for @homeGuaranteeFloor_13.
  ///
  /// In zh, this message translates to:
  /// **'100%履约'**
  String get homeGuaranteeFloor_13;

  /// No description provided for @homeGuaranteeFloor_13_2.
  ///
  /// In zh, this message translates to:
  /// **'未达成退款'**
  String get homeGuaranteeFloor_13_2;

  /// No description provided for @homeGuaranteeFloor_13_3.
  ///
  /// In zh, this message translates to:
  /// **'交付保障'**
  String get homeGuaranteeFloor_13_3;

  /// No description provided for @homeGuaranteeFloor_13_4.
  ///
  /// In zh, this message translates to:
  /// **'配送保障'**
  String get homeGuaranteeFloor_13_4;

  /// No description provided for @homeHeader_108.
  ///
  /// In zh, this message translates to:
  /// **'100%履约 · 未达成退款'**
  String get homeHeader_108;

  /// No description provided for @homeVenuesFloor_48.
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
