// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Planstar';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Discover';

  @override
  String get tabMessage => 'Messages';

  @override
  String get tabOrder => 'Orders';

  @override
  String get tabProfile => 'Me';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'OK';

  @override
  String get actionSave => 'Save';

  @override
  String get stateLoading => 'Loading…';

  @override
  String get stateEmpty => 'Nothing here yet';

  @override
  String get stateNetworkError => 'Network unavailable, please try again later';

  @override
  String get stateTimeout => 'Request timed out, please retry';

  @override
  String get stateUnauthorized => 'Session expired, please sign in again';

  @override
  String get stateOfflineCache => 'Showing cached content while offline';
}
