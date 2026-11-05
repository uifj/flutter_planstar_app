// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'user_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class UserLocalizationsEn extends UserLocalizations {
  UserLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get userTitle => 'Me';

  @override
  String userLoggedIn(String nickname) {
    return 'Signed in as $nickname';
  }

  @override
  String get userNotLoggedIn => 'Not signed in';

  @override
  String get userLogout => 'Sign out';

  @override
  String get userMockLogin => 'Mock sign-in';

  @override
  String get userViewOrders => 'View orders (gated)';
}
