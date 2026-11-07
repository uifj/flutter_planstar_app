// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'proxy_buy_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ProxyBuyLocalizationsEn extends ProxyBuyLocalizations {
  ProxyBuyLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get proxyBuy_142 => 'Awaiting purchase';

  @override
  String get proxyBuy_144 => 'Purchasing';

  @override
  String get proxyBuy_146 => 'Purchase succeeded';

  @override
  String get proxyBuy_148 => 'Purchase failed';

  @override
  String get proxyBuy_150 => 'Cancelled';

  @override
  String get proxyBuyPage_30 => 'Purchase service';

  @override
  String get proxyBuyPage_36 => 'My purchase orders';

  @override
  String get proxyBuyPage_39 => 'No purchase orders yet';

  @override
  String get proxyBuyPage_40 => 'Orders will appear here after you join a purchase service';

  @override
  String get proxyBuyPage_81 => 'Purchase service rules';

  @override
  String get proxyBuyPage_98 => 'Refund covered';

  @override
  String get proxyBuyPage_118 => 'Service fee: ';

  @override
  String proxyBuyPage_122(Object format) {
    return '$format/unit';
  }

  @override
  String get proxyBuyPage_165 => 'Select deadline';

  @override
  String get proxyBuyPage_303 => 'Venue';

  @override
  String get proxyBuyPage_305 => 'Event time';

  @override
  String get proxyBuyPage_307 => 'Deadline';

  @override
  String proxyBuyPage_314(Object quantity, Object format) {
    return '$quantity × $format';
  }

  @override
  String proxyBuyPage_322(Object format) {
    return 'Service fee $format/unit';
  }

  @override
  String get proxyBuyPage_334 => 'Total ';
}
