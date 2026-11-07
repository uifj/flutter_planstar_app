// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'home_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class HomeLocalizationsZh extends HomeLocalizations {
  HomeLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get homeTitle => '企划星 · 首页';

  @override
  String get homeEntryShowDetail => '企划详情';

  @override
  String get homeEntryShowDetailSubtitle => '深链 planstar://activity_detail?showId=888 → /show/888';

  @override
  String get homeEntryOrderConfirm => '确认订单（需登录）';

  @override
  String get homeEntryOrderConfirmSubtitle => 'planstar://order_confirm → /order/confirm，触发登录门禁';

  @override
  String cityListPage_46(Object city) {
    return '$city 暂无企划数据（演示数据仅覆盖部分城市）';
  }

  @override
  String get cityListPage_53 => '选择城市';

  @override
  String get cityListPage_57 => '上海';

  @override
  String get cityListPage_59 => '热门城市';

  @override
  String get cityListPage_65 => '全部城市';

  @override
  String get cityListPage_73 => '演示数据只覆盖上海、北京、杭州、广州、深圳；其余城市会显示空态。';

  @override
  String get cityListPage_115 => '当前定位：上海';

  @override
  String get cityListPage_120 => '演示环境没有接入定位，这里固定为上海';

  @override
  String get cityListPage_126 => '上海';

  @override
  String get cityListPage_140 => '使用';

  @override
  String get homePage_51 => '音乐企划 · 现场企划 · 巡演企划';

  @override
  String get homePage_52 => '话剧 · 音乐剧 · 沉浸式';

  @override
  String get homePage_53 => '交响 · 独奏 · 室内乐';

  @override
  String get homePage_54 => '儿童剧 · 亲子活动';

  @override
  String homePage_132(Object next) {
    return '$next 暂无企划数据（演示数据仅覆盖部分城市）';
  }

  @override
  String homePage_163(Object title) {
    return '$title · 运营活动页（演示）';
  }

  @override
  String homePage_175(Object city) {
    return '$city 暂无企划';
  }

  @override
  String get homePage_176 => '演示数据只覆盖上海、北京、杭州、广州、深圳';

  @override
  String get homePage_178 => '切换到上海';

  @override
  String get homePage_180 => '上海';

  @override
  String get homePage_193 => '热门企划';

  @override
  String get homePage_194 => '本周想看人数最多';

  @override
  String get homePage_241 => '企划星 · 让好企划被看见';

  @override
  String get homePage_251 => '让每一个企划都值得期待';

  @override
  String get homePage_270 => '音乐企划';

  @override
  String get homePage_271 => '话剧歌剧';

  @override
  String get homePage_272 => '音乐会';

  @override
  String get homePage_273 => '儿童亲子';

  @override
  String get homePage_274 => '企划';

  @override
  String homePage_323(Object city) {
    return '正在加载 $city 的企划…';
  }

  @override
  String get homePage_363 => '加载失败';

  @override
  String homePage_364(Object city, Object toString) {
    return '无法获取 $city 的企划数据\n$toString';
  }

  @override
  String get cityPickerSheet_70 => '选择城市';

  @override
  String get cityPickerSheet_90 => '当前定位：上海';

  @override
  String get cityPickerSheet_97 => '热门城市';

  @override
  String get cityPickerSheet_127 => '查看全部城市';

  @override
  String get homeBannerFloor_47 => '新企划首发：星海拾荒者';

  @override
  String get homeBannerFloor_48 => '上线 24 小时 · 支持者抢先看';

  @override
  String get homeBannerFloor_49 => '首发';

  @override
  String get homeBannerFloor_53 => '达成目标，解锁回报';

  @override
  String get homeBannerFloor_54 => '每一档回报都写明交付时间';

  @override
  String get homeBannerFloor_55 => '达成';

  @override
  String get homeBannerFloor_59 => '支持者可获进度更新';

  @override
  String get homeBannerFloor_60 => '创作者认证 · 每步进展都可查';

  @override
  String get homeBannerFloor_61 => '更新';

  @override
  String get homeBannerFloor_66 => '资金托管 · 未达成全额退';

  @override
  String get homeBannerFloor_67 => '支持款平台托管 · 原路退回';

  @override
  String get homeBannerFloor_68 => '保障';

  @override
  String get homeChoicenessFloor_83 => '精选推荐';

  @override
  String get homeGuaranteeFloor_13 => '100%履约';

  @override
  String get homeGuaranteeFloor_13_2 => '未达成退款';

  @override
  String get homeGuaranteeFloor_13_3 => '交付保障';

  @override
  String get homeGuaranteeFloor_13_4 => '配送保障';

  @override
  String get homeHeader_108 => '100%履约 · 未达成退款';

  @override
  String get homeVenuesFloor_48 => '热门活动场地';

  @override
  String get homeProjectPicked => '精选企划';

  @override
  String get homeProjectBannerSubtitle => '企划星 × 认真做内容的人';

  @override
  String get homeHotProjectTitle => '正在支持的企划';

  @override
  String get homeHotProjectDesc => '按支持人数与达成率排序';

  @override
  String get homeFloorGame => '游戏企划';

  @override
  String get homeFloorNovel => '小说企划';

  @override
  String get homeFloorDoujin => '同人企划';

  @override
  String get homeFloorInterview => '面经企划';

  @override
  String get homeFloorOther => '更多企划';

  @override
  String get homeFloorGameDesc => '把喜欢的游戏做出来';

  @override
  String get homeFloorNovelDesc => '让故事被印成书';

  @override
  String get homeFloorDoujinDesc => '同人创作，一起完成';

  @override
  String get homeFloorInterviewDesc => '把经验变成可交付的手册';

  @override
  String get homeRankingTitle => '企划榜单';

  @override
  String get homeRankingHot => '热度榜';

  @override
  String get homeRankingAchievement => '达成榜';

  @override
  String get homeRankingEnding => '冲刺榜';

  @override
  String homeRankingMetricSupporters(int count) {
    return '$count 人支持';
  }

  @override
  String homeRankingMetricAchievement(int percent) {
    return '达成 $percent%';
  }

  @override
  String homeRankingMetricRemaining(int days) {
    return '剩 $days 天';
  }
}
