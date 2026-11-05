// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'home_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class HomeLocalizationsEn extends HomeLocalizations {
  HomeLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'Planstar · Home';

  @override
  String get homeEntryShowDetail => 'Show detail';

  @override
  String get homeEntryShowDetailSubtitle => 'Deep link planstar://activity_detail?showId=888 → /show/888';

  @override
  String get homeEntryOrderConfirm => 'Confirm order (sign-in required)';

  @override
  String get homeEntryOrderConfirmSubtitle => 'planstar://order_confirm → /order/confirm, triggers the sign-in gate';
}
