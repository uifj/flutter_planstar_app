// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'proxy_buy_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class ProxyBuyLocalizationsZh extends ProxyBuyLocalizations {
  ProxyBuyLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get proxyBuy_142 => '待代购';

  @override
  String get proxyBuy_144 => '代购中';

  @override
  String get proxyBuy_146 => '代购成功';

  @override
  String get proxyBuy_148 => '代购失败';

  @override
  String get proxyBuy_150 => '已取消';

  @override
  String get proxyBuyPage_30 => '代购服务';

  @override
  String get proxyBuyPage_36 => '我的代购订单';

  @override
  String get proxyBuyPage_39 => '暂无代购订单';

  @override
  String get proxyBuyPage_40 => '参与代购后订单会显示在这里';

  @override
  String get proxyBuyPage_81 => '代购规则';

  @override
  String get proxyBuyPage_98 => '含赔付';

  @override
  String get proxyBuyPage_118 => '代购服务费：';

  @override
  String proxyBuyPage_122(Object format) {
    return '$format/份';
  }

  @override
  String get proxyBuyPage_165 => '选择截止时间';

  @override
  String get proxyBuyPage_303 => '活动场地';

  @override
  String get proxyBuyPage_305 => '活动时间';

  @override
  String get proxyBuyPage_307 => '截止';

  @override
  String proxyBuyPage_314(Object quantity, Object format) {
    return '$quantity份 × $format';
  }

  @override
  String proxyBuyPage_322(Object format) {
    return '代购费 $format/份';
  }

  @override
  String get proxyBuyPage_334 => '合计 ';
}
