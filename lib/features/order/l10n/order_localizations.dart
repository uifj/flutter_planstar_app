import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'order_localizations_en.dart';
import 'order_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of OrderLocalizations
/// returned by `OrderLocalizations.of(context)`.
///
/// Applications need to include `OrderLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/order_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: OrderLocalizations.localizationsDelegates,
///   supportedLocales: OrderLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the OrderLocalizations.supportedLocales
/// property.
abstract class OrderLocalizations {
  OrderLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static OrderLocalizations of(BuildContext context) {
    return Localizations.of<OrderLocalizations>(context, OrderLocalizations)!;
  }

  static const LocalizationsDelegate<OrderLocalizations> delegate = _OrderLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @orderListTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的订单'**
  String get orderListTitle;

  /// No description provided for @orderListPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'订单列表（需登录）'**
  String get orderListPlaceholder;

  /// No description provided for @orderGoConfirm.
  ///
  /// In zh, this message translates to:
  /// **'去确认订单'**
  String get orderGoConfirm;

  /// No description provided for @orderStatusPending.
  ///
  /// In zh, this message translates to:
  /// **'待付款'**
  String get orderStatusPending;

  /// No description provided for @orderStatusPaid.
  ///
  /// In zh, this message translates to:
  /// **'待发货'**
  String get orderStatusPaid;

  /// No description provided for @orderStatusShipped.
  ///
  /// In zh, this message translates to:
  /// **'待收货'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusFinished.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get orderStatusFinished;

  /// No description provided for @orderStatusRefund.
  ///
  /// In zh, this message translates to:
  /// **'退款中'**
  String get orderStatusRefund;
}

class _OrderLocalizationsDelegate extends LocalizationsDelegate<OrderLocalizations> {
  const _OrderLocalizationsDelegate();

  @override
  Future<OrderLocalizations> load(Locale locale) {
    return SynchronousFuture<OrderLocalizations>(lookupOrderLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_OrderLocalizationsDelegate old) => false;
}

OrderLocalizations lookupOrderLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return OrderLocalizationsEn();
    case 'zh': return OrderLocalizationsZh();
  }

  throw FlutterError(
    'OrderLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
