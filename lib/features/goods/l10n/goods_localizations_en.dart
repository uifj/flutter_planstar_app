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
}
