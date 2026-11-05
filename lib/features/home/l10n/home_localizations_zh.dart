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
  String get homeEntryShowDetail => '演出详情';

  @override
  String get homeEntryShowDetailSubtitle => '深链 planstar://activity_detail?showId=888 → /show/888';

  @override
  String get homeEntryOrderConfirm => '确认订单（需登录）';

  @override
  String get homeEntryOrderConfirmSubtitle => 'planstar://order_confirm → /order/confirm，触发登录门禁';
}
