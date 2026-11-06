// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'home_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class HomeLocalizationsEn extends HomeLocalizations {
  HomeLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'Planstar · Home';

  @override
  String get homeEntryShowDetail => 'Show detail';

  @override
  String get homeEntryShowDetailSubtitle => 'Deep link planstar://activity_detail?showId=888 → /show/888';

  @override
  String get homeEntryOrderConfirm => 'Confirm order (sign-in required)';

  @override
  String get homeEntryOrderConfirmSubtitle => 'planstar://order_confirm → /order/confirm, triggers the sign-in gate';

  @override
  String cityListPage_46(Object city) {
    return '$city 暂无演出数据（演示数据仅覆盖部分城市）';
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
  String get homePage_51 => '演唱会 · 音乐节 · 巡演';

  @override
  String get homePage_52 => '话剧 · 音乐剧 · 沉浸式';

  @override
  String get homePage_53 => '交响 · 独奏 · 室内乐';

  @override
  String get homePage_54 => '儿童剧 · 亲子活动';

  @override
  String homePage_132(Object next) {
    return '$next 暂无演出数据（演示数据仅覆盖部分城市）';
  }

  @override
  String homePage_163(Object title) {
    return '$title · 运营活动页（演示）';
  }

  @override
  String homePage_175(Object city) {
    return '$city 暂无演出';
  }

  @override
  String get homePage_176 => '演示数据只覆盖上海、北京、杭州、广州、深圳';

  @override
  String get homePage_178 => '切换到上海';

  @override
  String get homePage_180 => '上海';

  @override
  String get homePage_193 => '热门演出';

  @override
  String get homePage_194 => '本周想看人数最多';

  @override
  String get homePage_241 => '企划星 · 让看演出更简单';

  @override
  String get homePage_251 => '让每一场演出都值得期待';

  @override
  String get homePage_270 => '演唱会';

  @override
  String get homePage_271 => '话剧歌剧';

  @override
  String get homePage_272 => '音乐会';

  @override
  String get homePage_273 => '儿童亲子';

  @override
  String get homePage_274 => '演出';

  @override
  String homePage_323(Object city) {
    return '正在加载 $city 的演出…';
  }

  @override
  String get homePage_363 => '加载失败';

  @override
  String homePage_364(Object city, Object toString) {
    return '无法获取 $city 的演出数据\n$toString';
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
  String get homeBannerFloor_47 => '双 11 演出狂欢';

  @override
  String get homeBannerFloor_48 => '满 500 减 100 · 全场通用';

  @override
  String get homeBannerFloor_49 => '限时';

  @override
  String get homeBannerFloor_53 => '新人首单立减 50';

  @override
  String get homeBannerFloor_54 => '注册即领 · 无门槛使用';

  @override
  String get homeBannerFloor_55 => '新人';

  @override
  String get homeBannerFloor_59 => '《剧院魅影》中文版';

  @override
  String get homeBannerFloor_60 => '限时 9 折 · 上海文化广场';

  @override
  String get homeBannerFloor_61 => '热卖';

  @override
  String get homeBannerFloor_66 => '企划星安心入场保障';

  @override
  String get homeBannerFloor_67 => '无票必赔 · 最高退一赔一';

  @override
  String get homeBannerFloor_68 => '保障';

  @override
  String get homeChoicenessFloor_83 => '精选推荐';

  @override
  String get homeGuaranteeFloor_13 => '100%真票';

  @override
  String get homeGuaranteeFloor_13_2 => '无票赔付';

  @override
  String get homeGuaranteeFloor_13_3 => '出票保真';

  @override
  String get homeGuaranteeFloor_13_4 => '配送保障';

  @override
  String get homeHeader_108 => '100%真票 · 无票赔付';

  @override
  String get homeVenuesFloor_48 => '热门场馆';
}
