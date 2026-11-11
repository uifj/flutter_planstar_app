import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'goods_localizations_en.dart';
import 'goods_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of GoodsLocalizations
/// returned by `GoodsLocalizations.of(context)`.
///
/// Applications need to include `GoodsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/goods_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: GoodsLocalizations.localizationsDelegates,
///   supportedLocales: GoodsLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the GoodsLocalizations.supportedLocales
/// property.
abstract class GoodsLocalizations {
  GoodsLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static GoodsLocalizations of(BuildContext context) {
    return Localizations.of<GoodsLocalizations>(context, GoodsLocalizations)!;
  }

  static const LocalizationsDelegate<GoodsLocalizations> delegate = _GoodsLocalizationsDelegate();

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

  /// No description provided for @goodsShowTitle.
  ///
  /// In zh, this message translates to:
  /// **'企划 {showId}'**
  String goodsShowTitle(String showId);

  /// No description provided for @goodsGoToOrder.
  ///
  /// In zh, this message translates to:
  /// **'去下单'**
  String get goodsGoToOrder;

  /// No description provided for @goodsSeatMapRefreshHint.
  ///
  /// In zh, this message translates to:
  /// **'座席图实时变化，请以提交订单时的价格为准'**
  String get goodsSeatMapRefreshHint;

  /// No description provided for @seatContinuityError.
  ///
  /// In zh, this message translates to:
  /// **'请选择同一区域同一排的相邻座席'**
  String get seatContinuityError;

  /// No description provided for @seatSelectionCountdown.
  ///
  /// In zh, this message translates to:
  /// **'选座剩余 {time}'**
  String seatSelectionCountdown(String time);

  /// No description provided for @seatSelectionTimeout.
  ///
  /// In zh, this message translates to:
  /// **'选座已超时，请重新选择'**
  String get seatSelectionTimeout;

  /// No description provided for @chooseTicketPage_71.
  ///
  /// In zh, this message translates to:
  /// **'选择档位'**
  String get chooseTicketPage_71;

  /// No description provided for @chooseTicketPage_73.
  ///
  /// In zh, this message translates to:
  /// **'企划不存在或已下架'**
  String get chooseTicketPage_73;

  /// No description provided for @chooseTicketPage_74.
  ///
  /// In zh, this message translates to:
  /// **'企划编号：{showId}'**
  String chooseTicketPage_74(Object showId);

  /// No description provided for @chooseTicketPage_76.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get chooseTicketPage_76;

  /// No description provided for @chooseTicketPage_100.
  ///
  /// In zh, this message translates to:
  /// **'选择线下回报场次'**
  String get chooseTicketPage_100;

  /// No description provided for @chooseTicketPage_109.
  ///
  /// In zh, this message translates to:
  /// **'选择线下回报场次'**
  String get chooseTicketPage_109;

  /// No description provided for @chooseTicketPage_122.
  ///
  /// In zh, this message translates to:
  /// **'选择回报档位'**
  String get chooseTicketPage_122;

  /// No description provided for @chooseTicketPage_127.
  ///
  /// In zh, this message translates to:
  /// **'暂无回报档位信息'**
  String get chooseTicketPage_127;

  /// No description provided for @chooseTicketPage_142.
  ///
  /// In zh, this message translates to:
  /// **'支持数量'**
  String get chooseTicketPage_142;

  /// No description provided for @chooseTicketPage_171.
  ///
  /// In zh, this message translates to:
  /// **'请先选择回报档位'**
  String get chooseTicketPage_171;

  /// No description provided for @chooseTicketPage_175.
  ///
  /// In zh, this message translates to:
  /// **'本企划暂时满额'**
  String get chooseTicketPage_175;

  /// No description provided for @chooseTicketPage_355.
  ///
  /// In zh, this message translates to:
  /// **'已满额'**
  String get chooseTicketPage_355;

  /// No description provided for @chooseTicketPage_439.
  ///
  /// In zh, this message translates to:
  /// **'仅剩 {remaining} 份'**
  String chooseTicketPage_439(Object remaining);

  /// No description provided for @chooseTicketPage_451.
  ///
  /// In zh, this message translates to:
  /// **'已满额'**
  String get chooseTicketPage_451;

  /// No description provided for @chooseTicketPage_458.
  ///
  /// In zh, this message translates to:
  /// **' · 已选'**
  String get chooseTicketPage_458;

  /// No description provided for @chooseTicketPage_520.
  ///
  /// In zh, this message translates to:
  /// **'最多支持 {max} 份'**
  String chooseTicketPage_520(Object max);

  /// No description provided for @chooseTicketPage_569.
  ///
  /// In zh, this message translates to:
  /// **'支持一经确认，除企划取消外不支持退换。'**
  String get chooseTicketPage_569;

  /// No description provided for @chooseTicketPage_570.
  ///
  /// In zh, this message translates to:
  /// **'线下参与类回报需配合现场核销，请按创作者通知的时间到场。'**
  String get chooseTicketPage_570;

  /// No description provided for @chooseTicketPage_571.
  ///
  /// In zh, this message translates to:
  /// **'同一订单最多支持 6 份（部分档位可能更少）。'**
  String get chooseTicketPage_571;

  /// No description provided for @chooseTicketPage_588.
  ///
  /// In zh, this message translates to:
  /// **'支持须知'**
  String get chooseTicketPage_588;

  /// No description provided for @chooseTicketPage_669.
  ///
  /// In zh, this message translates to:
  /// **'选择座席'**
  String get chooseTicketPage_669;

  /// No description provided for @chooseTicketPage_697.
  ///
  /// In zh, this message translates to:
  /// **'请选择回报档位'**
  String get chooseTicketPage_697;

  /// No description provided for @chooseTicketPage_707.
  ///
  /// In zh, this message translates to:
  /// **'合计：'**
  String get chooseTicketPage_707;

  /// No description provided for @chooseTicketPage_731.
  ///
  /// In zh, this message translates to:
  /// **'确认支持'**
  String get chooseTicketPage_731;

  /// No description provided for @seatMapView_212.
  ///
  /// In zh, this message translates to:
  /// **'{name} ({availableCount}席可选)'**
  String seatMapView_212(Object name, Object availableCount);

  /// No description provided for @seatSelectionPage_45.
  ///
  /// In zh, this message translates to:
  /// **'选座'**
  String get seatSelectionPage_45;

  /// No description provided for @seatSelectionPage_91.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count} 个座席，总价 {format}'**
  String seatSelectionPage_91(Object count, Object format);

  /// No description provided for @seatSelectionPage_116.
  ///
  /// In zh, this message translates to:
  /// **'可选'**
  String get seatSelectionPage_116;

  /// No description provided for @seatSelectionPage_118.
  ///
  /// In zh, this message translates to:
  /// **'已选'**
  String get seatSelectionPage_118;

  /// No description provided for @seatSelectionPage_120.
  ///
  /// In zh, this message translates to:
  /// **'已售'**
  String get seatSelectionPage_120;

  /// No description provided for @seatSelectionPage_122.
  ///
  /// In zh, this message translates to:
  /// **'锁定'**
  String get seatSelectionPage_122;

  /// No description provided for @seatSelectionPage_191.
  ///
  /// In zh, this message translates to:
  /// **'已选 {length}/{maxSeats} 座'**
  String seatSelectionPage_191(Object length, Object maxSeats);

  /// No description provided for @seatSelectionPage_202.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get seatSelectionPage_202;

  /// No description provided for @seatSelectionPage_226.
  ///
  /// In zh, this message translates to:
  /// **'{areaName} {row}排{col}座'**
  String seatSelectionPage_226(Object areaName, Object row, Object col);

  /// No description provided for @seatSelectionPage_273.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count} 座'**
  String seatSelectionPage_273(Object count);

  /// No description provided for @seatSelectionPage_280.
  ///
  /// In zh, this message translates to:
  /// **'合计 '**
  String get seatSelectionPage_280;

  /// No description provided for @seatSelectionPage_288.
  ///
  /// In zh, this message translates to:
  /// **'请选择座席'**
  String get seatSelectionPage_288;

  /// No description provided for @seatSelectionPage_306.
  ///
  /// In zh, this message translates to:
  /// **'确认选座'**
  String get seatSelectionPage_306;

  /// No description provided for @seatSelectionPage_306_2.
  ///
  /// In zh, this message translates to:
  /// **'请先选座'**
  String get seatSelectionPage_306_2;

  /// No description provided for @showDetailPage_44.
  ///
  /// In zh, this message translates to:
  /// **'简介'**
  String get showDetailPage_44;

  /// No description provided for @showDetailPage_44_2.
  ///
  /// In zh, this message translates to:
  /// **'回报档位'**
  String get showDetailPage_44_2;

  /// No description provided for @showDetailPage_44_3.
  ///
  /// In zh, this message translates to:
  /// **'须知'**
  String get showDetailPage_44_3;

  /// No description provided for @showDetailPage_84.
  ///
  /// In zh, this message translates to:
  /// **'企划不存在或已下架'**
  String get showDetailPage_84;

  /// No description provided for @showDetailPage_85.
  ///
  /// In zh, this message translates to:
  /// **'企划编号：{showId}'**
  String showDetailPage_85(Object showId);

  /// No description provided for @showDetailPage_87.
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get showDetailPage_87;

  /// No description provided for @showDetailPage_110.
  ///
  /// In zh, this message translates to:
  /// **'分享面板（演示）'**
  String get showDetailPage_110;

  /// No description provided for @showDetailPage_125.
  ///
  /// In zh, this message translates to:
  /// **'企划星支持保障（演示）'**
  String get showDetailPage_125;

  /// No description provided for @showDetailPage_143.
  ///
  /// In zh, this message translates to:
  /// **'客服会话（演示）'**
  String get showDetailPage_143;

  /// No description provided for @showDetailPage_144.
  ///
  /// In zh, this message translates to:
  /// **'已关注'**
  String get showDetailPage_144;

  /// No description provided for @showDetailPage_154.
  ///
  /// In zh, this message translates to:
  /// **'本场暂时售罄'**
  String get showDetailPage_154;

  /// No description provided for @showDetailPage_228.
  ///
  /// In zh, this message translates to:
  /// **'暂无评分'**
  String get showDetailPage_228;

  /// No description provided for @showDetailPage_238.
  ///
  /// In zh, this message translates to:
  /// **'{ratingCount} 条评价'**
  String showDetailPage_238(Object ratingCount);

  /// No description provided for @showDetailPage_264.
  ///
  /// In zh, this message translates to:
  /// **'起'**
  String get showDetailPage_264;

  /// No description provided for @showDetailPage_473.
  ///
  /// In zh, this message translates to:
  /// **'企划星支持保障'**
  String get showDetailPage_473;

  /// No description provided for @showDetailPage_488.
  ///
  /// In zh, this message translates to:
  /// **'未达成必退 最高退一赔一'**
  String get showDetailPage_488;

  /// No description provided for @showDetailPage_519.
  ///
  /// In zh, this message translates to:
  /// **'选择回报档位'**
  String get showDetailPage_519;

  /// No description provided for @showDetailPage_560.
  ///
  /// In zh, this message translates to:
  /// **'售罄'**
  String get showDetailPage_560;

  /// No description provided for @showDetailPage_590.
  ///
  /// In zh, this message translates to:
  /// **'创作者阵容'**
  String get showDetailPage_590;

  /// No description provided for @showDetailPage_685.
  ///
  /// In zh, this message translates to:
  /// **'支持一经确认，除企划取消外不支持退换。'**
  String get showDetailPage_685;

  /// No description provided for @showDetailPage_685_2.
  ///
  /// In zh, this message translates to:
  /// **'入场需配合活动场地安检，请提前 30 分钟到场。'**
  String get showDetailPage_685_2;

  /// No description provided for @showDetailPage_693.
  ///
  /// In zh, this message translates to:
  /// **'支持须知'**
  String get showDetailPage_693;

  /// No description provided for @showDetailPage_726.
  ///
  /// In zh, this message translates to:
  /// **'先支持后交付'**
  String get showDetailPage_726;

  /// No description provided for @showDetailPage_727.
  ///
  /// In zh, this message translates to:
  /// **'未达成赔付'**
  String get showDetailPage_727;

  /// No description provided for @showDetailPage_728.
  ///
  /// In zh, this message translates to:
  /// **'交付保障'**
  String get showDetailPage_728;

  /// No description provided for @showDetailPage_729.
  ///
  /// In zh, this message translates to:
  /// **'配送保障'**
  String get showDetailPage_729;

  /// No description provided for @showDetailPage_748.
  ///
  /// In zh, this message translates to:
  /// **'企划星服务保障'**
  String get showDetailPage_748;

  /// No description provided for @showDetailPage_820.
  ///
  /// In zh, this message translates to:
  /// **'客服'**
  String get showDetailPage_820;

  /// No description provided for @showDetailPage_823.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get showDetailPage_823;

  /// No description provided for @showDetailPage_840.
  ///
  /// In zh, this message translates to:
  /// **'暂时售罄'**
  String get showDetailPage_840;

  /// No description provided for @showDetailPage_840_2.
  ///
  /// In zh, this message translates to:
  /// **'立即支持'**
  String get showDetailPage_840_2;

  /// No description provided for @venuePage_45.
  ///
  /// In zh, this message translates to:
  /// **'活动场地详情'**
  String get venuePage_45;

  /// No description provided for @venuePage_48.
  ///
  /// In zh, this message translates to:
  /// **'没有找到这个活动场地'**
  String get venuePage_48;

  /// No description provided for @venuePage_49.
  ///
  /// In zh, this message translates to:
  /// **'活动场地可能已更名，或当前城市没有它的企划'**
  String get venuePage_49;

  /// No description provided for @venuePage_51.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get venuePage_51;

  /// No description provided for @venuePage_58.
  ///
  /// In zh, this message translates to:
  /// **'近期企划'**
  String get venuePage_58;

  /// No description provided for @venuePage_61.
  ///
  /// In zh, this message translates to:
  /// **'暂无近期企划'**
  String get venuePage_61;

  /// No description provided for @venuePage_62.
  ///
  /// In zh, this message translates to:
  /// **'换个城市或过几天再来看看'**
  String get venuePage_62;

  /// No description provided for @venuePage_124.
  ///
  /// In zh, this message translates to:
  /// **'地址已复制'**
  String get venuePage_124;

  /// No description provided for @venuePage_134.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get venuePage_134;

  /// No description provided for @venuePage_146.
  ///
  /// In zh, this message translates to:
  /// **'个企划'**
  String get venuePage_146;

  /// No description provided for @venuePage_148.
  ///
  /// In zh, this message translates to:
  /// **'近期可支持'**
  String get venuePage_148;

  /// No description provided for @projectDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'企划详情'**
  String get projectDetailTitle;

  /// No description provided for @projectTabProgress.
  ///
  /// In zh, this message translates to:
  /// **'目标进度'**
  String get projectTabProgress;

  /// No description provided for @projectTabRewards.
  ///
  /// In zh, this message translates to:
  /// **'回报档位'**
  String get projectTabRewards;

  /// No description provided for @projectTabUpdates.
  ///
  /// In zh, this message translates to:
  /// **'进度更新'**
  String get projectTabUpdates;

  /// No description provided for @projectTabRisk.
  ///
  /// In zh, this message translates to:
  /// **'风险说明'**
  String get projectTabRisk;

  /// No description provided for @projectGoalAmount.
  ///
  /// In zh, this message translates to:
  /// **'目标金额'**
  String get projectGoalAmount;

  /// No description provided for @projectRaisedAmount.
  ///
  /// In zh, this message translates to:
  /// **'已筹金额'**
  String get projectRaisedAmount;

  /// No description provided for @projectAchievement.
  ///
  /// In zh, this message translates to:
  /// **'达成率'**
  String get projectAchievement;

  /// No description provided for @projectSupporters.
  ///
  /// In zh, this message translates to:
  /// **'支持人数'**
  String get projectSupporters;

  /// No description provided for @projectDeadline.
  ///
  /// In zh, this message translates to:
  /// **'截止时间'**
  String get projectDeadline;

  /// No description provided for @projectDaysLeft.
  ///
  /// In zh, this message translates to:
  /// **'剩 {days} 天'**
  String projectDaysLeft(int days);

  /// No description provided for @projectStatusPreheating.
  ///
  /// In zh, this message translates to:
  /// **'预热中'**
  String get projectStatusPreheating;

  /// No description provided for @projectStatusOngoing.
  ///
  /// In zh, this message translates to:
  /// **'支持中'**
  String get projectStatusOngoing;

  /// No description provided for @projectStatusAchieved.
  ///
  /// In zh, this message translates to:
  /// **'已达成'**
  String get projectStatusAchieved;

  /// No description provided for @projectStatusDelivered.
  ///
  /// In zh, this message translates to:
  /// **'已交付'**
  String get projectStatusDelivered;

  /// No description provided for @projectStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'未达成'**
  String get projectStatusFailed;

  /// No description provided for @projectProgressTitle.
  ///
  /// In zh, this message translates to:
  /// **'目标进度'**
  String get projectProgressTitle;

  /// No description provided for @projectRewardsTitle.
  ///
  /// In zh, this message translates to:
  /// **'回报档位'**
  String get projectRewardsTitle;

  /// No description provided for @projectRewardsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂未开放回报档位'**
  String get projectRewardsEmpty;

  /// No description provided for @projectRewardDelivery.
  ///
  /// In zh, this message translates to:
  /// **'预计 {time} 交付'**
  String projectRewardDelivery(String time);

  /// No description provided for @projectUpdatesTitle.
  ///
  /// In zh, this message translates to:
  /// **'进度更新'**
  String get projectUpdatesTitle;

  /// No description provided for @projectUpdatesEmpty.
  ///
  /// In zh, this message translates to:
  /// **'创作者还没有发布进度，支持后可第一时间收到更新。'**
  String get projectUpdatesEmpty;

  /// No description provided for @projectRiskTitle.
  ///
  /// In zh, this message translates to:
  /// **'风险说明'**
  String get projectRiskTitle;

  /// No description provided for @projectRiskNote.
  ///
  /// In zh, this message translates to:
  /// **'风险说明'**
  String get projectRiskNote;

  /// No description provided for @projectDeliveryPlan.
  ///
  /// In zh, this message translates to:
  /// **'交付计划'**
  String get projectDeliveryPlan;

  /// No description provided for @projectFundUsage.
  ///
  /// In zh, this message translates to:
  /// **'资金用途'**
  String get projectFundUsage;

  /// No description provided for @projectRiskEmpty.
  ///
  /// In zh, this message translates to:
  /// **'企划方暂未补充风险说明，请在支持前与创作者沟通确认。'**
  String get projectRiskEmpty;

  /// No description provided for @projectCreatorTitle.
  ///
  /// In zh, this message translates to:
  /// **'创作者信息'**
  String get projectCreatorTitle;

  /// No description provided for @projectCreatorVerified.
  ///
  /// In zh, this message translates to:
  /// **'已认证创作者'**
  String get projectCreatorVerified;

  /// No description provided for @projectCreatorUnverified.
  ///
  /// In zh, this message translates to:
  /// **'未认证创作者'**
  String get projectCreatorUnverified;

  /// No description provided for @projectCreatorStats.
  ///
  /// In zh, this message translates to:
  /// **'{projects} 个企划 · 成功 {success} 个 · 履约率 {rate}%'**
  String projectCreatorStats(int projects, int success, int rate);

  /// No description provided for @projectCreatorBioEmpty.
  ///
  /// In zh, this message translates to:
  /// **'这位创作者还没有填写简介。'**
  String get projectCreatorBioEmpty;

  /// No description provided for @projectSupportButton.
  ///
  /// In zh, this message translates to:
  /// **'支持此企划'**
  String get projectSupportButton;

  /// No description provided for @projectSupportClosed.
  ///
  /// In zh, this message translates to:
  /// **'企划已结束'**
  String get projectSupportClosed;

  /// No description provided for @projectSupportFrom.
  ///
  /// In zh, this message translates to:
  /// **'起支持'**
  String get projectSupportFrom;

  /// No description provided for @projectStoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'企划故事'**
  String get projectStoryTitle;

  /// No description provided for @projectNoticeTitle.
  ///
  /// In zh, this message translates to:
  /// **'支持须知'**
  String get projectNoticeTitle;

  /// No description provided for @projectGuaranteeTitle.
  ///
  /// In zh, this message translates to:
  /// **'支持保障'**
  String get projectGuaranteeTitle;

  /// No description provided for @projectGuaranteeFund.
  ///
  /// In zh, this message translates to:
  /// **'资金托管'**
  String get projectGuaranteeFund;

  /// No description provided for @projectGuaranteeRefund.
  ///
  /// In zh, this message translates to:
  /// **'未达成退款'**
  String get projectGuaranteeRefund;

  /// No description provided for @projectGuaranteeProgress.
  ///
  /// In zh, this message translates to:
  /// **'进度透明'**
  String get projectGuaranteeProgress;

  /// No description provided for @projectGuaranteeDelivery.
  ///
  /// In zh, this message translates to:
  /// **'按档交付'**
  String get projectGuaranteeDelivery;

  /// No description provided for @projectRefundRule.
  ///
  /// In zh, this message translates to:
  /// **'退款规则'**
  String get projectRefundRule;

  /// No description provided for @projectRefundArrival.
  ///
  /// In zh, this message translates to:
  /// **'预计 {days} 天内原路到账'**
  String projectRefundArrival(int days);

  /// No description provided for @projectReviewsTitle.
  ///
  /// In zh, this message translates to:
  /// **'评价晒单'**
  String get projectReviewsTitle;

  /// No description provided for @projectReviewsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有评价，已支持的用户可在交付后分享体验。'**
  String get projectReviewsEmpty;

  /// No description provided for @projectReviewsSummary.
  ///
  /// In zh, this message translates to:
  /// **'{rating} 分 · {count} 条评价 · {shows} 条晒单'**
  String projectReviewsSummary(String rating, int count, int shows);

  /// No description provided for @projectReviewShowBadge.
  ///
  /// In zh, this message translates to:
  /// **'晒单'**
  String get projectReviewShowBadge;

  /// No description provided for @projectFaqTitle.
  ///
  /// In zh, this message translates to:
  /// **'常见问题'**
  String get projectFaqTitle;

  /// No description provided for @projectFaqEmpty.
  ///
  /// In zh, this message translates to:
  /// **'创作者还没有补充常见问题。'**
  String get projectFaqEmpty;

  /// No description provided for @projectReportEntry.
  ///
  /// In zh, this message translates to:
  /// **'举报该企划'**
  String get projectReportEntry;

  /// No description provided for @projectReportTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择举报原因'**
  String get projectReportTitle;

  /// No description provided for @projectReportFraud.
  ///
  /// In zh, this message translates to:
  /// **'欺诈或虚假宣传'**
  String get projectReportFraud;

  /// No description provided for @projectReportInfringe.
  ///
  /// In zh, this message translates to:
  /// **'侵权或盗用素材'**
  String get projectReportInfringe;

  /// No description provided for @projectReportPorn.
  ///
  /// In zh, this message translates to:
  /// **'色情低俗内容'**
  String get projectReportPorn;

  /// No description provided for @projectReportOther.
  ///
  /// In zh, this message translates to:
  /// **'其他问题'**
  String get projectReportOther;

  /// No description provided for @projectReportSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'举报已提交，我们会在 24 小时内处理。'**
  String get projectReportSubmitted;
}

class _GoodsLocalizationsDelegate extends LocalizationsDelegate<GoodsLocalizations> {
  const _GoodsLocalizationsDelegate();

  @override
  Future<GoodsLocalizations> load(Locale locale) {
    return SynchronousFuture<GoodsLocalizations>(lookupGoodsLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_GoodsLocalizationsDelegate old) => false;
}

GoodsLocalizations lookupGoodsLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return GoodsLocalizationsEn();
    case 'zh': return GoodsLocalizationsZh();
  }

  throw FlutterError(
    'GoodsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
