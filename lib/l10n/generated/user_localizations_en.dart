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

  @override
  String get addressPage_49 => 'Shipping address';

  @override
  String get addressPage_55 => 'No shipping address yet';

  @override
  String get addressPage_56 => 'Offline rewards need a shipping address — add one to get started';

  @override
  String get addressPage_58 => 'Add address';

  @override
  String get addressPage_131 => 'Delete address';

  @override
  String addressPage_132(Object name, Object maskedMobile) {
    return 'Delete this address ($name $maskedMobile)?';
  }

  @override
  String get addressPage_140 => 'Delete';

  @override
  String get addressPage_150 => 'Deleted';

  @override
  String get addressPage_211 => 'Default';

  @override
  String get addressPage_263 => 'Default address';

  @override
  String get addressPage_263_2 => 'Set as default';

  @override
  String get addressPage_276 => 'Edit';

  @override
  String get addressPage_278 => 'Delete';

  @override
  String get addressPage_349 => 'Add address';

  @override
  String get addressPage_472 => 'Edit address';

  @override
  String get addressPage_472_2 => 'Add address';

  @override
  String get addressPage_493 => 'Recipient';

  @override
  String get addressPage_494 => 'Full name';

  @override
  String get addressPage_500 => 'Mobile number';

  @override
  String get addressPage_501 => '11-digit mobile number';

  @override
  String get addressPage_511 => 'Region';

  @override
  String get addressPage_512 => 'Province / city / district (e.g. Pudong New Area, Shanghai)';

  @override
  String get addressPage_517 => 'Street address';

  @override
  String get addressPage_518 => 'Street, house number, reward pickup point';

  @override
  String get profileProviders_58 => 'Sign in for a richer experience';

  @override
  String profileProviders_86(Object level) {
    return 'V$level Senior Supporter';
  }

  @override
  String get editProfilePage_65 => 'Edit profile';

  @override
  String get editProfilePage_75 => 'Avatar upload not integrated yet';

  @override
  String get editProfilePage_107 => 'Tap to change avatar';

  @override
  String get editProfilePage_116 => 'Nickname';

  @override
  String get editProfilePage_140 => 'Gender';

  @override
  String get editProfilePage_145 => 'Prefer not to say';

  @override
  String get editProfilePage_151 => 'Male';

  @override
  String get editProfilePage_157 => 'Female';

  @override
  String get editProfilePage_165 => 'Bio';

  @override
  String get editProfilePage_180 => 'Write something about yourself…';

  @override
  String get editProfilePage_229 => 'Profile saved (demo mode — not actually submitted to the server)';

  @override
  String get feedbackPage_32 => 'Feature request';

  @override
  String get feedbackPage_33 => 'Project issue';

  @override
  String get feedbackPage_34 => 'Payment issue';

  @override
  String get feedbackPage_35 => 'Support experience';

  @override
  String get feedbackPage_36 => 'Other';

  @override
  String get feedbackPage_58 => 'Feedback';

  @override
  String get feedbackPage_66 => 'Feedback type';

  @override
  String get feedbackPage_114 => 'Feedback content';

  @override
  String get feedbackPage_123 => 'Please enter at least 10 characters so we can better understand your issue';

  @override
  String get feedbackPage_140 => 'Describe the issue you ran into or your suggestion…';

  @override
  String get feedbackPage_160 => 'Contact info (optional)';

  @override
  String get feedbackPage_169 => 'Leave your mobile number or email so we can reach you';

  @override
  String get feedbackPage_184 => 'Mobile number / email';

  @override
  String get feedbackPage_211 => 'Submit feedback';

  @override
  String get feedbackPage_230 => 'Feedback recorded (demo mode — not actually submitted to the server)';

  @override
  String get settingsPage_53 => 'Settings';

  @override
  String get settingsPage_60 => 'Nickname';

  @override
  String get settingsPage_64 => 'Please sign in first';

  @override
  String get settingsPage_67 => 'Mobile number';

  @override
  String get settingsPage_68 => 'Not linked';

  @override
  String get settingsPage_69 => 'Verify your current mobile number before changing it';

  @override
  String get settingsPage_72 => 'Feedback';

  @override
  String get settingsPage_76 => 'Real-name verification';

  @override
  String get settingsPage_77 => 'Not verified';

  @override
  String get settingsPage_79 => 'Real-name verification is a separate ID service, not implemented in this demo';

  @override
  String get settingsPage_86 => 'Notifications';

  @override
  String get settingsPage_95 => 'Dark mode';

  @override
  String get settingsPage_107 => 'Clear cache';

  @override
  String get settingsPage_108 => 'Image and API cache';

  @override
  String get settingsPage_110 => 'Cache clearing not integrated yet — HttpCacheStore from package:core/cache.dart';

  @override
  String get settingsPage_117 => 'Version';

  @override
  String get settingsPage_119 => 'Up to date';

  @override
  String get settingsPage_122 => 'User agreement';

  @override
  String get settingsPage_123 => 'Agreement page not integrated yet — WebView (the 64-class `web` package equivalent)';

  @override
  String get settingsPage_126 => 'Privacy policy';

  @override
  String get settingsPage_128 => 'Privacy policy page not integrated yet — WebView';

  @override
  String get settingsPage_162 => 'Follow system';

  @override
  String get settingsPage_164 => 'On';

  @override
  String get settingsPageDarkModeOff => 'Off';

  @override
  String get settingsPage_172 => 'You\'ll need to sign in again to view your orders after signing out. Continue?';

  @override
  String get settingsPage_180 => 'Sign out';

  @override
  String get settingsPage_188 => 'Signed out';

  @override
  String get settingsPageGroupAccount => 'Account';

  @override
  String get settingsPageGroupGeneral => 'General';

  @override
  String get settingsPageGroupAbout => 'About';

  @override
  String get userPage_81 => 'Supporter management coming soon';

  @override
  String get userPage_82 => 'Customer service chat (demo)';

  @override
  String get userPage_83 => 'Seller recruitment is out of scope this time';

  @override
  String get userPage_98 => 'Signed out';

  @override
  String get userPage_254 => 'Sign in to view your orders and more';

  @override
  String get userPage_333 => 'Supported';

  @override
  String get userPage_340 => 'Following';

  @override
  String get userPage_483 => 'All pledges';

  @override
  String get userPage_569 => 'Coupons';

  @override
  String get userPage_580 => 'My wallet';

  @override
  String get userPage_650 => 'Gift cards';

  @override
  String get userPage_653 => 'Address management';

  @override
  String get userPage_654 => 'Supporters';

  @override
  String get userPage_655 => 'Contact customer service';

  @override
  String get userPage_656 => 'Seller recruitment';

  @override
  String get userMenuMall => 'Star Coin Mall';

  @override
  String get userMenuMessage => 'Messages';

  @override
  String get userMenuOrder => 'Orders';

  @override
  String get userMenuGroupMore => 'More Services';

  @override
  String signInReward(Object amount) {
    return 'Daily check-in · +$amount star coins';
  }

  @override
  String get signInDone => 'Checked in today';

  @override
  String signInSuccess(Object amount) {
    return 'Check-in successful, +$amount star coins';
  }

  @override
  String get signInFailed => 'Check-in failed, please try again later';
}
