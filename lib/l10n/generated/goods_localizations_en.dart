// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'goods_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class GoodsLocalizationsEn extends GoodsLocalizations {
  GoodsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String goodsShowTitle(String showId) {
    return 'Project $showId';
  }

  @override
  String get goodsGoToOrder => 'Support now';

  @override
  String get goodsSeatMapRefreshHint => 'Seat availability changes in real time; the price at checkout prevails';

  @override
  String get seatContinuityError => 'Please select adjacent seats in the same area and row';

  @override
  String seatSelectionCountdown(String time) {
    return 'Seats held for $time';
  }

  @override
  String get seatSelectionTimeout => 'Seat selection timed out. Please select again';

  @override
  String get chooseTicketPage_71 => '选择档位';

  @override
  String get chooseTicketPage_73 => '企划不存在或已下架';

  @override
  String chooseTicketPage_74(Object showId) {
    return '企划编号：$showId';
  }

  @override
  String get chooseTicketPage_76 => '返回';

  @override
  String get chooseTicketPage_100 => 'Select offline reward session';

  @override
  String get chooseTicketPage_109 => 'Select offline reward session';

  @override
  String get chooseTicketPage_122 => '选择回报档位';

  @override
  String get chooseTicketPage_127 => '暂无回报档位信息';

  @override
  String get chooseTicketPage_142 => '支持数量';

  @override
  String get chooseTicketPage_171 => '请先选择回报档位';

  @override
  String get chooseTicketPage_175 => '本企划暂时满额';

  @override
  String get chooseTicketPage_355 => '已满额';

  @override
  String chooseTicketPage_439(Object remaining) {
    return '仅剩 $remaining 份';
  }

  @override
  String get chooseTicketPage_451 => '已满额';

  @override
  String get chooseTicketPage_458 => ' · 已选';

  @override
  String chooseTicketPage_520(Object max) {
    return '最多支持 $max 份';
  }

  @override
  String get chooseTicketPage_569 => '支持一经确认，除企划取消外不支持退换。';

  @override
  String get chooseTicketPage_570 => '线下参与类回报需配合现场核销，请按创作者通知的时间到场。';

  @override
  String get chooseTicketPage_571 => '同一订单最多支持 6 份（部分档位可能更少）。';

  @override
  String get chooseTicketPage_588 => '支持须知';

  @override
  String get chooseTicketPage_669 => '选择座席';

  @override
  String get chooseTicketPage_697 => '请选择回报档位';

  @override
  String get chooseTicketPage_707 => '合计：';

  @override
  String get chooseTicketPage_731 => '确认支持';

  @override
  String seatMapView_212(Object name, Object availableCount) {
    return '$name ($availableCount席可选)';
  }

  @override
  String get seatSelectionPage_45 => '选座';

  @override
  String seatSelectionPage_91(Object count, Object format) {
    return '已选 $count 个座席，总价 $format';
  }

  @override
  String get seatSelectionPage_116 => '可选';

  @override
  String get seatSelectionPage_118 => '已选';

  @override
  String get seatSelectionPage_120 => '已售';

  @override
  String get seatSelectionPage_122 => '锁定';

  @override
  String seatSelectionPage_191(Object length, Object maxSeats) {
    return '已选 $length/$maxSeats 座';
  }

  @override
  String get seatSelectionPage_202 => '清空';

  @override
  String seatSelectionPage_226(Object areaName, Object row, Object col) {
    return '$areaName $row排$col座';
  }

  @override
  String seatSelectionPage_273(Object count) {
    return '已选 $count 座';
  }

  @override
  String get seatSelectionPage_280 => '合计 ';

  @override
  String get seatSelectionPage_288 => '请选择座席';

  @override
  String get seatSelectionPage_306 => '确认选座';

  @override
  String get seatSelectionPage_306_2 => '请先选座';

  @override
  String get showDetailPage_44 => '简介';

  @override
  String get showDetailPage_44_2 => 'Reward tiers';

  @override
  String get showDetailPage_44_3 => '须知';

  @override
  String get showDetailPage_84 => 'This project does not exist or has been removed';

  @override
  String showDetailPage_85(Object showId) {
    return 'Project ID: $showId';
  }

  @override
  String get showDetailPage_87 => '返回首页';

  @override
  String get showDetailPage_110 => '分享面板（演示）';

  @override
  String get showDetailPage_125 => '企划星支持保障（演示）';

  @override
  String get showDetailPage_143 => '客服会话（演示）';

  @override
  String get showDetailPage_144 => '已关注';

  @override
  String get showDetailPage_154 => '本场暂时售罄';

  @override
  String get showDetailPage_228 => '暂无评分';

  @override
  String showDetailPage_238(Object ratingCount) {
    return '$ratingCount 条评价';
  }

  @override
  String get showDetailPage_264 => '起';

  @override
  String get showDetailPage_473 => '企划星支持保障';

  @override
  String get showDetailPage_488 => 'Refund if the goal is missed, up to 2x';

  @override
  String get showDetailPage_519 => 'Select a reward tier';

  @override
  String get showDetailPage_560 => '售罄';

  @override
  String get showDetailPage_590 => 'Creator lineup';

  @override
  String get showDetailPage_685 => 'Once confirmed, support cannot be refunded or exchanged unless the project is cancelled.';

  @override
  String get showDetailPage_685_2 => 'Security checks apply at the venue. Please arrive 30 minutes early.';

  @override
  String get showDetailPage_693 => 'Support notes';

  @override
  String get showDetailPage_726 => 'Support first, receive later';

  @override
  String get showDetailPage_727 => 'Compensation if the goal is missed';

  @override
  String get showDetailPage_728 => 'Delivery guarantee';

  @override
  String get showDetailPage_729 => '配送保障';

  @override
  String get showDetailPage_748 => '企划星服务保障';

  @override
  String get showDetailPage_820 => '客服';

  @override
  String get showDetailPage_823 => '关注';

  @override
  String get showDetailPage_840 => '暂时售罄';

  @override
  String get showDetailPage_840_2 => 'Support now';

  @override
  String get venuePage_45 => 'Venue details';

  @override
  String get venuePage_48 => 'Venue not found';

  @override
  String get venuePage_49 => 'The venue may have been renamed, or it has no projects in this city';

  @override
  String get venuePage_51 => 'Back';

  @override
  String get venuePage_58 => 'Upcoming projects';

  @override
  String get venuePage_61 => 'No upcoming projects';

  @override
  String get venuePage_62 => 'Try another city or check back later';

  @override
  String get venuePage_124 => 'Address copied';

  @override
  String get venuePage_134 => 'Copy';

  @override
  String get venuePage_146 => 'projects';

  @override
  String get venuePage_148 => 'Open for support';

  @override
  String get projectDetailTitle => '企划详情';

  @override
  String get projectTabProgress => '目标进度';

  @override
  String get projectTabRewards => '回报档位';

  @override
  String get projectTabUpdates => '进度更新';

  @override
  String get projectTabRisk => '风险说明';

  @override
  String get projectGoalAmount => '目标金额';

  @override
  String get projectRaisedAmount => '已筹金额';

  @override
  String get projectAchievement => '达成率';

  @override
  String get projectSupporters => '支持人数';

  @override
  String get projectDeadline => '截止时间';

  @override
  String projectDaysLeft(int days) {
    return '剩 $days 天';
  }

  @override
  String get projectStatusPreheating => '预热中';

  @override
  String get projectStatusOngoing => '支持中';

  @override
  String get projectStatusAchieved => '已达成';

  @override
  String get projectStatusDelivered => '已交付';

  @override
  String get projectStatusFailed => '未达成';

  @override
  String get projectProgressTitle => '目标进度';

  @override
  String get projectRewardsTitle => '回报档位';

  @override
  String get projectRewardsEmpty => '暂未开放回报档位';

  @override
  String projectRewardDelivery(String time) {
    return '预计 $time 交付';
  }

  @override
  String get projectUpdatesTitle => '进度更新';

  @override
  String get projectUpdatesEmpty => '创作者还没有发布进度，支持后可第一时间收到更新。';

  @override
  String get projectRiskTitle => '风险说明';

  @override
  String get projectRiskNote => '风险说明';

  @override
  String get projectDeliveryPlan => '交付计划';

  @override
  String get projectFundUsage => '资金用途';

  @override
  String get projectRiskEmpty => '企划方暂未补充风险说明，请在支持前与创作者沟通确认。';

  @override
  String get projectCreatorTitle => '创作者信息';

  @override
  String get projectCreatorVerified => '已认证创作者';

  @override
  String get projectCreatorUnverified => '未认证创作者';

  @override
  String projectCreatorStats(int projects, int success, int rate) {
    return '$projects 个企划 · 成功 $success 个 · 履约率 $rate%';
  }

  @override
  String get projectCreatorBioEmpty => '这位创作者还没有填写简介。';

  @override
  String get projectSupportButton => '支持此企划';

  @override
  String get projectSupportClosed => '企划已结束';

  @override
  String get projectSupportFrom => '起支持';

  @override
  String get projectStoryTitle => '企划故事';

  @override
  String get projectNoticeTitle => '支持须知';

  @override
  String get projectGuaranteeTitle => '支持保障';

  @override
  String get projectGuaranteeFund => '资金托管';

  @override
  String get projectGuaranteeRefund => '未达成退款';

  @override
  String get projectGuaranteeProgress => '进度透明';

  @override
  String get projectGuaranteeDelivery => '按档交付';

  @override
  String get projectRefundRule => 'Refund policy';

  @override
  String projectRefundArrival(int days) {
    return 'Original payment refunded within $days days';
  }

  @override
  String get projectReviewsTitle => 'Reviews & Showcase';

  @override
  String get projectReviewsEmpty => 'No reviews yet. Supporters can share feedback after delivery.';

  @override
  String projectReviewsSummary(String rating, int count, int shows) {
    return '$rating / 10 · $count reviews · $shows showcases';
  }

  @override
  String get projectReviewShowBadge => 'Showcase';

  @override
  String get projectFaqTitle => 'FAQ';

  @override
  String get projectFaqEmpty => 'The creator has not added FAQs yet.';

  @override
  String get projectReportEntry => 'Report this project';

  @override
  String get projectReportTitle => 'Select a reason';

  @override
  String get projectReportFraud => 'Fraud or false claims';

  @override
  String get projectReportInfringe => 'Infringement or stolen assets';

  @override
  String get projectReportPorn => 'Sexual or vulgar content';

  @override
  String get projectReportOther => 'Other issues';

  @override
  String get projectReportSubmitted => 'Report submitted. We will review it within 24 hours.';
}
