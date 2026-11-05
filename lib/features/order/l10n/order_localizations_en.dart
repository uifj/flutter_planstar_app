// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'order_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class OrderLocalizationsEn extends OrderLocalizations {
  OrderLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get orderListTitle => 'My orders';

  @override
  String get orderListPlaceholder => 'Order list (sign-in required)';

  @override
  String get orderGoConfirm => 'Go to confirm';

  @override
  String get orderStatusPending => 'Unpaid';

  @override
  String get orderStatusPaid => 'To ship';

  @override
  String get orderStatusShipped => 'To receive';

  @override
  String get orderStatusFinished => 'Completed';

  @override
  String get orderStatusRefund => 'Refunding';
}
