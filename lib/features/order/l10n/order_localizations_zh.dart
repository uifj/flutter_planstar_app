// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'order_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class OrderLocalizationsZh extends OrderLocalizations {
  OrderLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get orderListTitle => '我的订单';

  @override
  String get orderListPlaceholder => '订单列表（需登录）';

  @override
  String get orderGoConfirm => '去确认订单';

  @override
  String get orderStatusPending => '待付款';

  @override
  String get orderStatusPaid => '待发货';

  @override
  String get orderStatusShipped => '待收货';

  @override
  String get orderStatusFinished => '已完成';

  @override
  String get orderStatusRefund => '退款中';
}
