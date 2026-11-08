// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'catalog_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CatalogLocalizationsEn extends CatalogLocalizations {
  CatalogLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get catalogProviders_74 => 'Shanghai';

  @override
  String showCategory_95(Object address, Object showCount) {
    return '$address · $showCount projects';
  }

  @override
  String showSummary_165(Object text) {
    return '$text% off';
  }

  @override
  String get showSummary_178 => 'Sold out';

  @override
  String get showSummary_178_2 => 'Supporting';

  @override
  String get showSummary_263 => 'Mon';

  @override
  String get showSummary_263_2 => 'Tue';

  @override
  String get showSummary_263_3 => 'Wed';

  @override
  String get showSummary_263_4 => 'Thu';

  @override
  String get showSummary_263_5 => 'Fri';

  @override
  String get showSummary_263_6 => 'Sat';

  @override
  String get showSummary_263_7 => 'Sun';

  @override
  String showSummary_266(Object month, Object day, Object weekday, Object hour, Object minute) {
    return '$month/$day $weekday $hour:$minute';
  }

  @override
  String get showSummary_280 => 'Just now';

  @override
  String showSummary_281(Object inMinutes) {
    return '${inMinutes}m ago';
  }

  @override
  String get showSummary_285 => 'Yesterday';

  @override
  String showSummary_286(Object inDays) {
    return '${inDays}d ago';
  }

  @override
  String showSummary_287(Object month, Object day) {
    return '$month/$day';
  }

  @override
  String categoryHomePage_116(Object city, Object name) {
    return 'No $name projects in $city';
  }

  @override
  String get categoryHomePage_unknownCategory => 'this category';

  @override
  String get categoryHomePage_117 => 'Try switching cities or browsing other categories';

  @override
  String get categoryHomePage_119 => 'Go to home';

  @override
  String get categoryHomePage_403 => 'From';

  @override
  String categoryHomePage_406(Object wishCount) {
    return '$wishCount want to see';
  }

  @override
  String get showCards_72 => 'Sold out';

  @override
  String get showCards_75 => 'From';

  @override
  String get showCards_156 => 'Sold out';

  @override
  String showCards_175(Object discountLabel) {
    return 'From $discountLabel';
  }

  @override
  String get showCards_270 => 'Sold out';

  @override
  String get showCards_277 => 'From';

  @override
  String get showListPage_78 => 'No projects in this category';

  @override
  String get showListPage_79 => 'Try another category or city';

  @override
  String get showListPage_81 => 'See all projects';

  @override
  String get showListPage_112 => 'All projects';

  @override
  String get showListPage_140 => 'Recommended';

  @override
  String get showListPage_141 => 'Starting soon';

  @override
  String get showListPage_142 => 'Lowest price';

  @override
  String get showListPage_172 => 'All';

  @override
  String showListPage_249(Object total) {
    return '$total shows';
  }

  @override
  String projectCardAchievement(int rate) {
    return '$rate%';
  }

  @override
  String get projectCardAchieved => 'Goal reached';

  @override
  String projectCardGoal(String amount) {
    return 'Goal $amount';
  }

  @override
  String projectCardSupporters(int count) {
    return '$count supporters';
  }

  @override
  String projectCardDays(int days) {
    return '$days days left';
  }

  @override
  String get projectCardEnded => 'Ended';

  @override
  String get projectCardSupportFrom => 'From';
}
