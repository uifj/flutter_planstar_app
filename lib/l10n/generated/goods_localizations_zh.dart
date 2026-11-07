// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'goods_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class GoodsLocalizationsZh extends GoodsLocalizations {
  GoodsLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String goodsShowTitle(String showId) {
    return '企划 $showId';
  }

  @override
  String get goodsGoToOrder => '去下单';

  @override
  String get goodsSeatMapRefreshHint => '座席图实时变化，请以提交订单时的价格为准';

  @override
  String get seatContinuityError => '请选择同一区域同一排的相邻座席';

  @override
  String seatSelectionCountdown(String time) {
    return '选座剩余 $time';
  }

  @override
  String get seatSelectionTimeout => '选座已超时，请重新选择';

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
  String get chooseTicketPage_100 => '选择线下回报场次';

  @override
  String get chooseTicketPage_109 => '选择线下回报场次';

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
  String get showDetailPage_44_2 => '回报档位';

  @override
  String get showDetailPage_44_3 => '须知';

  @override
  String get showDetailPage_84 => '企划不存在或已下架';

  @override
  String showDetailPage_85(Object showId) {
    return '企划编号：$showId';
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
  String get showDetailPage_488 => '未达成必退 最高退一赔一';

  @override
  String get showDetailPage_519 => '选择回报档位';

  @override
  String get showDetailPage_560 => '售罄';

  @override
  String get showDetailPage_590 => '创作者阵容';

  @override
  String get showDetailPage_685 => '支持一经确认，除企划取消外不支持退换。';

  @override
  String get showDetailPage_685_2 => '入场需配合活动场地安检，请提前 30 分钟到场。';

  @override
  String get showDetailPage_693 => '支持须知';

  @override
  String get showDetailPage_726 => '先支持后交付';

  @override
  String get showDetailPage_727 => '未达成赔付';

  @override
  String get showDetailPage_728 => '交付保障';

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
  String get showDetailPage_840_2 => '立即支持';

  @override
  String get venuePage_45 => '活动场地详情';

  @override
  String get venuePage_48 => '没有找到这个活动场地';

  @override
  String get venuePage_49 => '活动场地可能已更名，或当前城市没有它的企划';

  @override
  String get venuePage_51 => '返回';

  @override
  String get venuePage_58 => '近期企划';

  @override
  String get venuePage_61 => '暂无近期企划';

  @override
  String get venuePage_62 => '换个城市或过几天再来看看';

  @override
  String get venuePage_124 => '地址已复制';

  @override
  String get venuePage_134 => '复制';

  @override
  String get venuePage_146 => '个企划';

  @override
  String get venuePage_148 => '近期可支持';

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
  String get projectRefundRule => '退款规则';

  @override
  String projectRefundArrival(int days) {
    return '预计 $days 天内原路到账';
  }

  @override
  String get projectReviewsTitle => '评价晒单';

  @override
  String get projectReviewsEmpty => '还没有评价，已支持的用户可在交付后分享体验。';

  @override
  String projectReviewsSummary(String rating, int count, int shows) {
    return '$rating 分 · $count 条评价 · $shows 条晒单';
  }

  @override
  String get projectReviewShowBadge => '晒单';

  @override
  String get projectFaqTitle => '常见问题';

  @override
  String get projectFaqEmpty => '创作者还没有补充常见问题。';

  @override
  String get projectReportEntry => '举报该企划';

  @override
  String get projectReportTitle => '选择举报原因';

  @override
  String get projectReportFraud => '欺诈或虚假宣传';

  @override
  String get projectReportInfringe => '侵权或盗用素材';

  @override
  String get projectReportPorn => '色情低俗内容';

  @override
  String get projectReportOther => '其他问题';

  @override
  String get projectReportSubmitted => '举报已提交，我们会在 24 小时内处理。';
}
