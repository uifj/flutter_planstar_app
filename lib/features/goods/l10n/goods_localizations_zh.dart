// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'goods_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class GoodsLocalizationsZh extends GoodsLocalizations {
  GoodsLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String goodsShowTitle(String showId) {
    return '演出 $showId';
  }

  @override
  String get goodsGoToOrder => '去下单';

  @override
  String get goodsSeatMapRefreshHint => '座位图实时变化，请以提交订单时的价格为准';
}
