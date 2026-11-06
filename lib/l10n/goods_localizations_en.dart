// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'goods_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class GoodsLocalizationsEn extends GoodsLocalizations {
  GoodsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String goodsShowTitle(String showId) {
    return 'Show $showId';
  }

  @override
  String get goodsGoToOrder => 'Buy tickets';

  @override
  String get goodsSeatMapRefreshHint => 'Seat availability changes in real time; the price at checkout prevails';

  @override
  String get chooseTicketPage_71 => '选票';

  @override
  String get chooseTicketPage_73 => '演出不存在或已下架';

  @override
  String chooseTicketPage_74(Object showId) {
    return '演出编号：$showId';
  }

  @override
  String get chooseTicketPage_76 => '返回';

  @override
  String get chooseTicketPage_100 => '选择场次';

  @override
  String get chooseTicketPage_109 => '选择场次';

  @override
  String get chooseTicketPage_122 => '选择票档';

  @override
  String get chooseTicketPage_127 => '暂无票档信息';

  @override
  String get chooseTicketPage_142 => '购买数量';

  @override
  String get chooseTicketPage_171 => '请先选择票档';

  @override
  String get chooseTicketPage_175 => '本场暂时售罄';

  @override
  String get chooseTicketPage_355 => '售罄';

  @override
  String chooseTicketPage_439(Object remaining) {
    return '仅剩 $remaining 张';
  }

  @override
  String get chooseTicketPage_451 => '售罄';

  @override
  String get chooseTicketPage_458 => ' · 已选';

  @override
  String chooseTicketPage_520(Object max) {
    return '最多购买 $max 张';
  }

  @override
  String get chooseTicketPage_569 => '演出票一经售出，除演出取消外不支持退换。';

  @override
  String get chooseTicketPage_570 => '入场需配合场馆安检，请提前 30 分钟到场。';

  @override
  String get chooseTicketPage_571 => '同一订单最多购买 6 张票（部分票档可能更少）。';

  @override
  String get chooseTicketPage_588 => '购票须知';

  @override
  String get chooseTicketPage_669 => '选座购票';

  @override
  String get chooseTicketPage_697 => '请选择票档';

  @override
  String get chooseTicketPage_707 => '合计：';

  @override
  String get chooseTicketPage_731 => '确认选票';

  @override
  String seatMapView_212(Object name, Object availableCount) {
    return '$name ($availableCount席可选)';
  }

  @override
  String get seatSelectionPage_45 => '选座';

  @override
  String seatSelectionPage_91(Object count, Object format) {
    return '已选 $count 个座位，总价 $format';
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
  String get seatSelectionPage_288 => '请选择座位';

  @override
  String get seatSelectionPage_306 => '确认选座';

  @override
  String get seatSelectionPage_306_2 => '请先选座';

  @override
  String get showDetailPage_44 => '简介';

  @override
  String get showDetailPage_44_2 => '票档';

  @override
  String get showDetailPage_44_3 => '须知';

  @override
  String get showDetailPage_84 => '演出不存在或已下架';

  @override
  String showDetailPage_85(Object showId) {
    return '演出编号：$showId';
  }

  @override
  String get showDetailPage_87 => '返回首页';

  @override
  String get showDetailPage_110 => '分享面板（演示）';

  @override
  String get showDetailPage_125 => '企划星安心入场保障（演示）';

  @override
  String get showDetailPage_143 => '客服会话（演示）';

  @override
  String get showDetailPage_144 => '已加入想看';

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
  String get showDetailPage_473 => '企划星安心入场保障';

  @override
  String get showDetailPage_488 => '无票必赔 最高退一赔一';

  @override
  String get showDetailPage_519 => '选择票档';

  @override
  String get showDetailPage_560 => '售罄';

  @override
  String get showDetailPage_590 => '艺人阵容';

  @override
  String get showDetailPage_685 => '演出票一经售出，除演出取消外不支持退换。';

  @override
  String get showDetailPage_685_2 => '入场需配合场馆安检，请提前 30 分钟到场。';

  @override
  String get showDetailPage_693 => '购买须知';

  @override
  String get showDetailPage_726 => '先看后付';

  @override
  String get showDetailPage_727 => '无票赔付';

  @override
  String get showDetailPage_728 => '出票保真';

  @override
  String get showDetailPage_729 => '配送保障';

  @override
  String get showDetailPage_748 => '企划星服务保障';

  @override
  String get showDetailPage_820 => '客服';

  @override
  String get showDetailPage_823 => '想看';

  @override
  String get showDetailPage_840 => '暂时售罄';

  @override
  String get showDetailPage_840_2 => '立即购买';

  @override
  String get venuePage_45 => '场馆详情';

  @override
  String get venuePage_48 => '没有找到这个场馆';

  @override
  String get venuePage_49 => '场馆可能已更名，或当前城市没有它的演出';

  @override
  String get venuePage_51 => '返回';

  @override
  String get venuePage_58 => '近期演出';

  @override
  String get venuePage_61 => '暂无近期演出';

  @override
  String get venuePage_62 => '换个城市或过几天再来看看';

  @override
  String get venuePage_124 => '地址已复制';

  @override
  String get venuePage_134 => '复制';

  @override
  String get venuePage_146 => '场演出';

  @override
  String get venuePage_148 => '近期可购';
}
