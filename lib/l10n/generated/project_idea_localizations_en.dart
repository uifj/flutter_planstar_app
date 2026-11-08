// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'project_idea_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ProjectIdeaLocalizationsEn extends ProjectIdeaLocalizations {
  ProjectIdeaLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String ideaViewedToday(int count) {
    return 'Viewed $count today';
  }

  @override
  String get ideaRefresh => 'Refresh';

  @override
  String get ideaEmptyTitle => 'You\'re all caught up for today';

  @override
  String get ideaEmptyDescription => 'Explore Discover or refresh for more';

  @override
  String get ideaLoadFailed => 'Failed to load';

  @override
  String get ideaSkip => 'Skip';

  @override
  String get ideaCategoryFallback => 'Uncategorized';

  @override
  String get ideaCreatorLabel => 'Creator';

  @override
  String ideaSupportCount(int count) {
    return '$count support';
  }

  @override
  String ideaOpposeCount(int count) {
    return '$count oppose';
  }

  @override
  String get ideaSupport => 'Support';

  @override
  String get ideaOppose => 'Oppose';

  @override
  String get ideaNotLaunched => 'Not launched';

  @override
  String get ideaDetailTitle => 'Idea details';

  @override
  String get ideaDetailLoadFailed => 'Failed to load details';

  @override
  String get ideaDetailDescription => 'About this idea';

  @override
  String get ideaDetailGallery => 'Gallery';

  @override
  String ideaDetailPublishedAt(String date) {
    return 'Published $date';
  }

  @override
  String get ideaDetailSupportRate => 'Support rate';

  @override
  String get ideaDetailTierDistribution => 'Intent tiers';

  @override
  String get ideaDetailReasons => 'Oppose reasons';

  @override
  String get ideaDetailNoReasons => 'No reasons yet';

  @override
  String get ideaDetailVotedSupport => 'Supported';

  @override
  String get ideaDetailVotedOppose => 'Opposed';

  @override
  String ideaDetailSupportPeople(int count) {
    return '$count supporters';
  }

  @override
  String ideaDetailOpposePeople(int count) {
    return '$count opposed';
  }

  @override
  String get ideaDetailNotLaunchedHint => 'This is an idea that has not been launched yet. No purchase or deduction is involved.';

  @override
  String get supportSheetTitle => 'Support this idea';

  @override
  String get supportSheetSubtitle => 'Your support helps it get launched sooner';

  @override
  String ideaTierOption(int tier) {
    return '$tier coins';
  }

  @override
  String get supportDisclaimer => 'Expresses intent only. No coins will be deducted.';

  @override
  String get supportReasonHint => 'Add a reason (optional)';

  @override
  String get supportReasonCreative => 'Great idea';

  @override
  String get supportReasonJoin => 'I\'d join';

  @override
  String get supportReasonLaunch => 'Launch it soon';

  @override
  String get supportSubmit => 'Submit support';

  @override
  String get supportSuccess => 'Supported. Thanks for weighing in.';

  @override
  String get opposeSheetTitle => 'Why not support it?';

  @override
  String get opposeSheetSubtitle => 'Your reason helps the creator improve and reduces similar recommendations';

  @override
  String get opposeReasonNotInterested => 'Not interested';

  @override
  String get opposeReasonTooManySimilar => 'Too many similar ideas';

  @override
  String get opposeReasonNotEnoughInfo => 'Not enough information';

  @override
  String get opposeReasonNotExecutable => 'Not feasible';

  @override
  String get opposeReasonUnreasonablePricing => 'Unreasonable pricing or rewards';

  @override
  String get opposeReasonOther => 'Other';

  @override
  String get opposeReasonTextHint => 'Please add your reason';

  @override
  String get opposeSubmit => 'Submit';

  @override
  String get opposeSuccess => 'Recorded. Fewer similar ideas will be recommended.';

  @override
  String get ideaAlreadyVoted => 'Already voted';

  @override
  String get ideaErrorSelfVote => 'You cannot vote on your own idea';

  @override
  String get ideaErrorTooFrequent => 'Too many actions, please try again later';

  @override
  String get ideaErrorNetwork => 'Network hiccup, please retry';
}
