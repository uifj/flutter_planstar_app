// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'catalog_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class CatalogLocalizationsZh extends CatalogLocalizations {
  CatalogLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get catalogProviders_74 => '上海';

  @override
  String showCategory_95(Object address, Object showCount) {
    return '$address · $showCount 场演出';
  }

  @override
  String showSummary_165(Object text) {
    return '$text折';
  }

  @override
  String get showSummary_178 => '暂时售罄';

  @override
  String get showSummary_178_2 => '售票中';

  @override
  String get showSummary_263 => '周一';

  @override
  String get showSummary_263_2 => '周二';

  @override
  String get showSummary_263_3 => '周三';

  @override
  String get showSummary_263_4 => '周四';

  @override
  String get showSummary_263_5 => '周五';

  @override
  String get showSummary_263_6 => '周六';

  @override
  String get showSummary_263_7 => '周日';

  @override
  String showSummary_266(Object month, Object day, Object weekday, Object hour, Object minute) {
    return '$month月$day日 $weekday $hour:$minute';
  }

  @override
  String get showSummary_280 => '刚刚';

  @override
  String showSummary_281(Object inMinutes) {
    return '$inMinutes分钟前';
  }

  @override
  String get showSummary_285 => '昨天';

  @override
  String showSummary_286(Object inDays) {
    return '$inDays天前';
  }

  @override
  String showSummary_287(Object month, Object day) {
    return '$month月$day日';
  }

  @override
  String categoryHomePage_116(Object city, Object name) {
    return '$city 暂无$name演出';
  }

  @override
  String get categoryHomePage_unknownCategory => '该分类';

  @override
  String get categoryHomePage_117 => '试试切换城市或查看其他分类';

  @override
  String get categoryHomePage_119 => '去首页';

  @override
  String get categoryHomePage_403 => '起';

  @override
  String categoryHomePage_406(Object wishCount) {
    return '$wishCount 人想看';
  }

  @override
  String get showCards_72 => '暂时售罄';

  @override
  String get showCards_75 => '起';

  @override
  String get showCards_156 => '暂时售罄';

  @override
  String showCards_175(Object discountLabel) {
    return '$discountLabel起';
  }

  @override
  String get showCards_270 => '暂时售罄';

  @override
  String get showCards_277 => '起';

  @override
  String get showListPage_78 => '该分类暂无演出';

  @override
  String get showListPage_79 => '换个分类或城市看看';

  @override
  String get showListPage_81 => '看全部演出';

  @override
  String get showListPage_112 => '全部演出';

  @override
  String get showListPage_140 => '推荐';

  @override
  String get showListPage_141 => '最近开演';

  @override
  String get showListPage_142 => '价格最低';

  @override
  String get showListPage_172 => '全部';

  @override
  String showListPage_249(Object total) {
    return '共 $total 场';
  }
}
