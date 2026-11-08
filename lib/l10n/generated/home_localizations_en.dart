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
  String get homeEntryShowDetail => 'Project details';

  @override
  String get homeEntryShowDetailSubtitle => 'Deep link planstar://activity_detail?showId=888 → /show/888';

  @override
  String get homeEntryOrderConfirm => 'Confirm order (sign-in required)';

  @override
  String get homeEntryOrderConfirmSubtitle => 'planstar://order_confirm → /order/confirm, triggers the sign-in gate';

  @override
  String cityListPage_46(Object city) {
    return 'No project data for $city (demo data covers only some cities)';
  }

  @override
  String get cityListPage_53 => 'Select city';

  @override
  String get cityListPage_57 => 'Shanghai';

  @override
  String get cityListPage_59 => 'Popular cities';

  @override
  String get cityListPage_65 => 'All cities';

  @override
  String get cityListPage_73 => 'Demo data only covers Shanghai, Beijing, Hangzhou, Guangzhou and Shenzhen; other cities show an empty state.';

  @override
  String get cityListPage_115 => 'Current location: Shanghai';

  @override
  String get cityListPage_120 => 'Location services aren\'t integrated in the demo; it\'s fixed to Shanghai';

  @override
  String get cityListPage_126 => 'Shanghai';

  @override
  String get cityListPage_140 => 'Use';

  @override
  String get homePage_51 => 'Music projects · Live projects · Tour projects';

  @override
  String get homePage_52 => 'Theatre · Musicals · Immersive';

  @override
  String get homePage_53 => 'Symphony · Solo · Chamber';

  @override
  String get homePage_54 => 'Kids · Family';

  @override
  String homePage_132(Object next) {
    return 'No project data for $next (demo data covers only some cities)';
  }

  @override
  String homePage_163(Object title) {
    return '$title · Campaign page (demo)';
  }

  @override
  String homePage_175(Object city) {
    return 'No projects in $city';
  }

  @override
  String get homePage_176 => 'Demo data covers Shanghai, Beijing, Hangzhou, Guangzhou and Shenzhen only';

  @override
  String get homePage_178 => 'Switch to Shanghai';

  @override
  String get homePage_180 => 'Shanghai';

  @override
  String get homePage_193 => 'Popular projects';

  @override
  String get homePage_194 => 'Most wishlisted this week';

  @override
  String get homePage_241 => 'Planstar · Helping good projects get seen';

  @override
  String get homePage_251 => 'Every project worth looking forward to';

  @override
  String get homePage_270 => 'Music projects';

  @override
  String get homePage_271 => 'Theatre & opera';

  @override
  String get homePage_272 => 'Concerts';

  @override
  String get homePage_273 => 'Kids & family';

  @override
  String get homePage_274 => 'Projects';

  @override
  String homePage_323(Object city) {
    return 'Loading projects in $city…';
  }

  @override
  String get homePage_363 => 'Failed to load';

  @override
  String homePage_364(Object city, Object toString) {
    return 'Unable to load projects in $city\n$toString';
  }

  @override
  String get cityPickerSheet_70 => 'Select city';

  @override
  String get cityPickerSheet_90 => 'Current location: Shanghai';

  @override
  String get cityPickerSheet_97 => 'Popular cities';

  @override
  String get cityPickerSheet_127 => 'View all cities';

  @override
  String get homeBannerFloor_47 => 'New project launch: Starfall Scavenger';

  @override
  String get homeBannerFloor_48 => 'Live for 24 hours · supporters see it first';

  @override
  String get homeBannerFloor_49 => 'New';

  @override
  String get homeBannerFloor_53 => 'Reach the goal, unlock rewards';

  @override
  String get homeBannerFloor_54 => 'Every reward tier lists its delivery date';

  @override
  String get homeBannerFloor_55 => 'Funded';

  @override
  String get homeBannerFloor_59 => 'Supporters get progress updates';

  @override
  String get homeBannerFloor_60 => 'Verified creators · every milestone tracked';

  @override
  String get homeBannerFloor_61 => 'Updates';

  @override
  String get homeBannerFloor_66 => 'Funds held in escrow';

  @override
  String get homeBannerFloor_67 => 'Full refund if the goal isn\'t reached';

  @override
  String get homeBannerFloor_68 => 'Protected';

  @override
  String get homeChoicenessFloor_83 => 'Featured picks';

  @override
  String get homeGuaranteeFloor_13 => '100% fulfillment';

  @override
  String get homeGuaranteeFloor_13_2 => 'Refund if unmet';

  @override
  String get homeGuaranteeFloor_13_3 => 'Delivery guarantee';

  @override
  String get homeGuaranteeFloor_13_4 => 'Delivery covered';

  @override
  String get homeHeader_108 => '100% fulfillment · Refund if unmet';

  @override
  String get homeVenuesFloor_48 => 'Popular venues';

  @override
  String get homeProjectPicked => 'Featured projects';

  @override
  String get homeProjectBannerSubtitle => 'Planstar × creators who take content seriously';

  @override
  String get homeHotProjectTitle => 'Projects being supported right now';

  @override
  String get homeHotProjectDesc => 'Sorted by supporter count and funding rate';

  @override
  String get homeFloorGame => 'Game projects';

  @override
  String get homeFloorNovel => 'Novel projects';

  @override
  String get homeFloorDoujin => 'Fan projects';

  @override
  String get homeFloorInterview => 'Interview projects';

  @override
  String get homeFloorOther => 'More projects';

  @override
  String get homeFloorGameDesc => 'Bring the games you love to life';

  @override
  String get homeFloorNovelDesc => 'Turn stories into printed books';

  @override
  String get homeFloorDoujinDesc => 'Create fan works together';

  @override
  String get homeFloorInterviewDesc => 'Turn experience into deliverable handbooks';

  @override
  String get homeRankingTitle => 'Project Rankings';

  @override
  String get homeRankingHot => 'Popular';

  @override
  String get homeRankingAchievement => 'Funded';

  @override
  String get homeRankingEnding => 'Ending Soon';

  @override
  String homeRankingMetricSupporters(int count) {
    return '$count supporters';
  }

  @override
  String homeRankingMetricAchievement(int percent) {
    return '$percent% funded';
  }

  @override
  String homeRankingMetricRemaining(int days) {
    return '$days days left';
  }
}
