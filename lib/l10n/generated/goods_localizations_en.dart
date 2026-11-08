// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'goods_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class GoodsLocalizationsEn extends GoodsLocalizations {
  GoodsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String goodsShowTitle(String showId) {
    return 'Project $showId';
  }

  @override
  String get goodsGoToOrder => 'Support now';

  @override
  String get goodsSeatMapRefreshHint => 'Seat availability changes in real time; the price at checkout prevails';

  @override
  String get seatContinuityError => 'Please select adjacent seats in the same area and row';

  @override
  String seatSelectionCountdown(String time) {
    return 'Seats held for $time';
  }

  @override
  String get seatSelectionTimeout => 'Seat selection timed out. Please select again';

  @override
  String get chooseTicketPage_71 => 'Select ticket tier';

  @override
  String get chooseTicketPage_73 => 'This project does not exist or has been removed';

  @override
  String chooseTicketPage_74(Object showId) {
    return 'Project ID: $showId';
  }

  @override
  String get chooseTicketPage_76 => 'Back';

  @override
  String get chooseTicketPage_100 => 'Select offline reward session';

  @override
  String get chooseTicketPage_109 => 'Select offline reward session';

  @override
  String get chooseTicketPage_122 => 'Select a reward tier';

  @override
  String get chooseTicketPage_127 => 'No reward tier information yet';

  @override
  String get chooseTicketPage_142 => 'Support quantity';

  @override
  String get chooseTicketPage_171 => 'Please select a reward tier first';

  @override
  String get chooseTicketPage_175 => 'This project is fully subscribed for now';

  @override
  String get chooseTicketPage_355 => 'Fully subscribed';

  @override
  String chooseTicketPage_439(Object remaining) {
    return 'Only $remaining left';
  }

  @override
  String get chooseTicketPage_451 => 'Fully subscribed';

  @override
  String get chooseTicketPage_458 => ' · Selected';

  @override
  String chooseTicketPage_520(Object max) {
    return 'Support up to $max units';
  }

  @override
  String get chooseTicketPage_569 => 'Once confirmed, support cannot be refunded or exchanged unless the project is cancelled.';

  @override
  String get chooseTicketPage_570 => 'Offline participation rewards require on-site check-in. Please arrive at the time notified by the creator.';

  @override
  String get chooseTicketPage_571 => 'Each order supports up to 6 units (some tiers may allow fewer).';

  @override
  String get chooseTicketPage_588 => 'Support notes';

  @override
  String get chooseTicketPage_669 => 'Select seats';

  @override
  String get chooseTicketPage_697 => 'Please select a reward tier';

  @override
  String get chooseTicketPage_707 => 'Total:';

  @override
  String get chooseTicketPage_731 => 'Confirm support';

  @override
  String seatMapView_212(Object name, Object availableCount) {
    return '$name ($availableCount seats available)';
  }

  @override
  String get seatSelectionPage_45 => 'Seat selection';

  @override
  String seatSelectionPage_91(Object count, Object format) {
    return '$count seats selected, total $format';
  }

  @override
  String get seatSelectionPage_116 => 'Available';

  @override
  String get seatSelectionPage_118 => 'Selected';

  @override
  String get seatSelectionPage_120 => 'Sold';

  @override
  String get seatSelectionPage_122 => 'Locked';

  @override
  String seatSelectionPage_191(Object length, Object maxSeats) {
    return '$length/$maxSeats seats selected';
  }

  @override
  String get seatSelectionPage_202 => 'Clear';

  @override
  String seatSelectionPage_226(Object areaName, Object row, Object col) {
    return '$areaName Row $row Seat $col';
  }

  @override
  String seatSelectionPage_273(Object count) {
    return '$count seats selected';
  }

  @override
  String get seatSelectionPage_280 => 'Total ';

  @override
  String get seatSelectionPage_288 => 'Please select seats';

  @override
  String get seatSelectionPage_306 => 'Confirm seat selection';

  @override
  String get seatSelectionPage_306_2 => 'Please select seats first';

  @override
  String get showDetailPage_44 => 'About';

  @override
  String get showDetailPage_44_2 => 'Reward tiers';

  @override
  String get showDetailPage_44_3 => 'Notes';

  @override
  String get showDetailPage_84 => 'This project does not exist or has been removed';

  @override
  String showDetailPage_85(Object showId) {
    return 'Project ID: $showId';
  }

  @override
  String get showDetailPage_87 => 'Back to home';

  @override
  String get showDetailPage_110 => 'Share panel (demo)';

  @override
  String get showDetailPage_125 => 'Planstar support guarantee (demo)';

  @override
  String get showDetailPage_143 => 'Customer service chat (demo)';

  @override
  String get showDetailPage_144 => 'Followed';

  @override
  String get showDetailPage_154 => 'This show is temporarily sold out';

  @override
  String get showDetailPage_228 => 'No ratings yet';

  @override
  String showDetailPage_238(Object ratingCount) {
    return '$ratingCount reviews';
  }

  @override
  String get showDetailPage_264 => 'From';

  @override
  String get showDetailPage_473 => 'Planstar support guarantee';

  @override
  String get showDetailPage_488 => 'Refund if the goal is missed, up to 2x';

  @override
  String get showDetailPage_519 => 'Select a reward tier';

  @override
  String get showDetailPage_560 => 'Sold out';

  @override
  String get showDetailPage_590 => 'Creator lineup';

  @override
  String get showDetailPage_685 => 'Once confirmed, support cannot be refunded or exchanged unless the project is cancelled.';

  @override
  String get showDetailPage_685_2 => 'Security checks apply at the venue. Please arrive 30 minutes early.';

  @override
  String get showDetailPage_693 => 'Support notes';

  @override
  String get showDetailPage_726 => 'Support first, receive later';

  @override
  String get showDetailPage_727 => 'Compensation if the goal is missed';

  @override
  String get showDetailPage_728 => 'Delivery guarantee';

  @override
  String get showDetailPage_729 => 'Shipping guarantee';

  @override
  String get showDetailPage_748 => 'Planstar service guarantee';

  @override
  String get showDetailPage_820 => 'Customer service';

  @override
  String get showDetailPage_823 => 'Follow';

  @override
  String get showDetailPage_840 => 'Temporarily sold out';

  @override
  String get showDetailPage_840_2 => 'Support now';

  @override
  String get venuePage_45 => 'Venue details';

  @override
  String get venuePage_48 => 'Venue not found';

  @override
  String get venuePage_49 => 'The venue may have been renamed, or it has no projects in this city';

  @override
  String get venuePage_51 => 'Back';

  @override
  String get venuePage_58 => 'Upcoming projects';

  @override
  String get venuePage_61 => 'No upcoming projects';

  @override
  String get venuePage_62 => 'Try another city or check back later';

  @override
  String get venuePage_124 => 'Address copied';

  @override
  String get venuePage_134 => 'Copy';

  @override
  String get venuePage_146 => 'projects';

  @override
  String get venuePage_148 => 'Open for support';

  @override
  String get projectDetailTitle => 'Project details';

  @override
  String get projectTabProgress => 'Goal progress';

  @override
  String get projectTabRewards => 'Reward tiers';

  @override
  String get projectTabUpdates => 'Updates';

  @override
  String get projectTabRisk => 'Risks';

  @override
  String get projectGoalAmount => 'Goal amount';

  @override
  String get projectRaisedAmount => 'Raised amount';

  @override
  String get projectAchievement => 'Achievement rate';

  @override
  String get projectSupporters => 'Supporters';

  @override
  String get projectDeadline => 'Deadline';

  @override
  String projectDaysLeft(int days) {
    return '$days days left';
  }

  @override
  String get projectStatusPreheating => 'Preheating';

  @override
  String get projectStatusOngoing => 'Ongoing';

  @override
  String get projectStatusAchieved => 'Achieved';

  @override
  String get projectStatusDelivered => 'Delivered';

  @override
  String get projectStatusFailed => 'Not achieved';

  @override
  String get projectProgressTitle => 'Goal progress';

  @override
  String get projectRewardsTitle => 'Reward tiers';

  @override
  String get projectRewardsEmpty => 'No reward tiers available yet';

  @override
  String projectRewardDelivery(String time) {
    return 'Estimated delivery $time';
  }

  @override
  String get projectUpdatesTitle => 'Progress updates';

  @override
  String get projectUpdatesEmpty => 'The creator hasn\'t posted progress yet. Supporters will receive updates as soon as they\'re published.';

  @override
  String get projectRiskTitle => 'Risk notice';

  @override
  String get projectRiskNote => 'Risk notice';

  @override
  String get projectDeliveryPlan => 'Delivery plan';

  @override
  String get projectFundUsage => 'Use of funds';

  @override
  String get projectRiskEmpty => 'The organizer hasn\'t added a risk notice yet. Please confirm with the creator before supporting.';

  @override
  String get projectCreatorTitle => 'About the creator';

  @override
  String get projectCreatorVerified => 'Verified creator';

  @override
  String get projectCreatorUnverified => 'Unverified creator';

  @override
  String projectCreatorStats(int projects, int success, int rate) {
    return '$projects projects · $success succeeded · $rate% fulfillment rate';
  }

  @override
  String get projectCreatorBioEmpty => 'This creator hasn\'t written a bio yet.';

  @override
  String get projectSupportButton => 'Support this project';

  @override
  String get projectSupportClosed => 'This project has ended';

  @override
  String get projectSupportFrom => 'Support from';

  @override
  String get projectStoryTitle => 'Project story';

  @override
  String get projectNoticeTitle => 'Support notes';

  @override
  String get projectGuaranteeTitle => 'Support guarantee';

  @override
  String get projectGuaranteeFund => 'Fund escrow';

  @override
  String get projectGuaranteeRefund => 'Refund if not achieved';

  @override
  String get projectGuaranteeProgress => 'Transparent progress';

  @override
  String get projectGuaranteeDelivery => 'Delivery by tier';

  @override
  String get projectRefundRule => 'Refund policy';

  @override
  String projectRefundArrival(int days) {
    return 'Original payment refunded within $days days';
  }

  @override
  String get projectReviewsTitle => 'Reviews & Showcase';

  @override
  String get projectReviewsEmpty => 'No reviews yet. Supporters can share feedback after delivery.';

  @override
  String projectReviewsSummary(String rating, int count, int shows) {
    return '$rating / 10 · $count reviews · $shows showcases';
  }

  @override
  String get projectReviewShowBadge => 'Showcase';

  @override
  String get projectFaqTitle => 'FAQ';

  @override
  String get projectFaqEmpty => 'The creator has not added FAQs yet.';

  @override
  String get projectReportEntry => 'Report this project';

  @override
  String get projectReportTitle => 'Select a reason';

  @override
  String get projectReportFraud => 'Fraud or false claims';

  @override
  String get projectReportInfringe => 'Infringement or stolen assets';

  @override
  String get projectReportPorn => 'Sexual or vulgar content';

  @override
  String get projectReportOther => 'Other issues';

  @override
  String get projectReportSubmitted => 'Report submitted. We will review it within 24 hours.';
}
