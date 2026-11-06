// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'proxy_buy_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class ProxyBuyLocalizationsZh extends ProxyBuyLocalizations {
  ProxyBuyLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get proxyBuy_142 => '待抢票';

  @override
  String get proxyBuy_144 => '抢票中';

  @override
  String get proxyBuy_146 => '抢票成功';

  @override
  String get proxyBuy_148 => '抢票失败';

  @override
  String get proxyBuy_150 => '已取消';

  @override
  String get proxyBuyPage_30 => '代抢服务';

  @override
  String get proxyBuyPage_36 => '我的代抢订单';

  @override
  String get proxyBuyPage_39 => '暂无代抢订单';

  @override
  String get proxyBuyPage_40 => '参与代抢后订单会显示在这里';

  @override
  String get proxyBuyPage_81 => '代抢规则';

  @override
  String get proxyBuyPage_98 => '含赔付';

  @override
  String get proxyBuyPage_118 => '代抢服务费：';

  @override
  String proxyBuyPage_122(Object format) {
    return '$format/张';
  }

  @override
  String get proxyBuyPage_165 => '选择截止时间';

  @override
  String get proxyBuyPage_303 => '场馆';

  @override
  String get proxyBuyPage_305 => '场次';

  @override
  String get proxyBuyPage_307 => '截止';

  @override
  String proxyBuyPage_314(Object quantity, Object format) {
    return '$quantity张 × $format';
  }

  @override
  String proxyBuyPage_322(Object format) {
    return '代抢费 $format/张';
  }

  @override
  String get proxyBuyPage_334 => '合计 ';
}
