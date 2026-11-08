import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'project_idea_localizations_en.dart';
import 'project_idea_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ProjectIdeaLocalizations
/// returned by `ProjectIdeaLocalizations.of(context)`.
///
/// Applications need to include `ProjectIdeaLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/project_idea_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ProjectIdeaLocalizations.localizationsDelegates,
///   supportedLocales: ProjectIdeaLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the ProjectIdeaLocalizations.supportedLocales
/// property.
abstract class ProjectIdeaLocalizations {
  ProjectIdeaLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ProjectIdeaLocalizations of(BuildContext context) {
    return Localizations.of<ProjectIdeaLocalizations>(context, ProjectIdeaLocalizations)!;
  }

  static const LocalizationsDelegate<ProjectIdeaLocalizations> delegate = _ProjectIdeaLocalizationsDelegate();

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

  /// No description provided for @ideaViewedToday.
  ///
  /// In zh, this message translates to:
  /// **'今日已看 {count} 张'**
  String ideaViewedToday(int count);

  /// No description provided for @ideaRefresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get ideaRefresh;

  /// No description provided for @ideaEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'今天的创意都看完啦'**
  String get ideaEmptyTitle;

  /// No description provided for @ideaEmptyDescription.
  ///
  /// In zh, this message translates to:
  /// **'去发现看看，或刷新试试'**
  String get ideaEmptyDescription;

  /// No description provided for @ideaLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get ideaLoadFailed;

  /// No description provided for @ideaSkip.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get ideaSkip;

  /// No description provided for @ideaCategoryFallback.
  ///
  /// In zh, this message translates to:
  /// **'未分类'**
  String get ideaCategoryFallback;

  /// No description provided for @ideaCreatorLabel.
  ///
  /// In zh, this message translates to:
  /// **'发起人'**
  String get ideaCreatorLabel;

  /// No description provided for @ideaSupportCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 支持'**
  String ideaSupportCount(int count);

  /// No description provided for @ideaOpposeCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 不支持'**
  String ideaOpposeCount(int count);

  /// No description provided for @ideaSupport.
  ///
  /// In zh, this message translates to:
  /// **'支持'**
  String get ideaSupport;

  /// No description provided for @ideaOppose.
  ///
  /// In zh, this message translates to:
  /// **'不支持'**
  String get ideaOppose;

  /// No description provided for @ideaNotLaunched.
  ///
  /// In zh, this message translates to:
  /// **'尚未立项'**
  String get ideaNotLaunched;

  /// No description provided for @ideaDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'创意详情'**
  String get ideaDetailTitle;

  /// No description provided for @ideaDetailLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'详情加载失败'**
  String get ideaDetailLoadFailed;

  /// No description provided for @ideaDetailDescription.
  ///
  /// In zh, this message translates to:
  /// **'企划介绍'**
  String get ideaDetailDescription;

  /// No description provided for @ideaDetailGallery.
  ///
  /// In zh, this message translates to:
  /// **'图集'**
  String get ideaDetailGallery;

  /// No description provided for @ideaDetailPublishedAt.
  ///
  /// In zh, this message translates to:
  /// **'发布于 {date}'**
  String ideaDetailPublishedAt(String date);

  /// No description provided for @ideaDetailSupportRate.
  ///
  /// In zh, this message translates to:
  /// **'支持率'**
  String get ideaDetailSupportRate;

  /// No description provided for @ideaDetailTierDistribution.
  ///
  /// In zh, this message translates to:
  /// **'意愿档位分布'**
  String get ideaDetailTierDistribution;

  /// No description provided for @ideaDetailReasons.
  ///
  /// In zh, this message translates to:
  /// **'不支持理由'**
  String get ideaDetailReasons;

  /// No description provided for @ideaDetailNoReasons.
  ///
  /// In zh, this message translates to:
  /// **'还没有理由数据'**
  String get ideaDetailNoReasons;

  /// No description provided for @ideaDetailVotedSupport.
  ///
  /// In zh, this message translates to:
  /// **'已支持'**
  String get ideaDetailVotedSupport;

  /// No description provided for @ideaDetailVotedOppose.
  ///
  /// In zh, this message translates to:
  /// **'已不支持'**
  String get ideaDetailVotedOppose;

  /// No description provided for @ideaDetailSupportPeople.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人支持'**
  String ideaDetailSupportPeople(int count);

  /// No description provided for @ideaDetailOpposePeople.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人不支持'**
  String ideaDetailOpposePeople(int count);

  /// No description provided for @ideaDetailNotLaunchedHint.
  ///
  /// In zh, this message translates to:
  /// **'这是一个创意想法，尚未立项，不涉及购买或扣费'**
  String get ideaDetailNotLaunchedHint;

  /// No description provided for @supportSheetTitle.
  ///
  /// In zh, this message translates to:
  /// **'支持这个企划'**
  String get supportSheetTitle;

  /// No description provided for @supportSheetSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'你的支持会帮助它更快立项'**
  String get supportSheetSubtitle;

  /// No description provided for @ideaTierOption.
  ///
  /// In zh, this message translates to:
  /// **'{tier} 星币'**
  String ideaTierOption(int tier);

  /// No description provided for @supportDisclaimer.
  ///
  /// In zh, this message translates to:
  /// **'仅表达支持意愿，不会扣除星币'**
  String get supportDisclaimer;

  /// No description provided for @supportReasonHint.
  ///
  /// In zh, this message translates to:
  /// **'说说你的理由（选填）'**
  String get supportReasonHint;

  /// No description provided for @supportReasonCreative.
  ///
  /// In zh, this message translates to:
  /// **'看好创意'**
  String get supportReasonCreative;

  /// No description provided for @supportReasonJoin.
  ///
  /// In zh, this message translates to:
  /// **'愿意参与'**
  String get supportReasonJoin;

  /// No description provided for @supportReasonLaunch.
  ///
  /// In zh, this message translates to:
  /// **'希望尽快立项'**
  String get supportReasonLaunch;

  /// No description provided for @supportSubmit.
  ///
  /// In zh, this message translates to:
  /// **'提交支持'**
  String get supportSubmit;

  /// No description provided for @supportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已支持，感谢你的态度'**
  String get supportSuccess;

  /// No description provided for @opposeSheetTitle.
  ///
  /// In zh, this message translates to:
  /// **'为什么不支持？'**
  String get opposeSheetTitle;

  /// No description provided for @opposeSheetSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'你的理由会帮助作者改进，并减少类似企划推荐'**
  String get opposeSheetSubtitle;

  /// No description provided for @opposeReasonNotInterested.
  ///
  /// In zh, this message translates to:
  /// **'不感兴趣'**
  String get opposeReasonNotInterested;

  /// No description provided for @opposeReasonTooManySimilar.
  ///
  /// In zh, this message translates to:
  /// **'同类企划太多'**
  String get opposeReasonTooManySimilar;

  /// No description provided for @opposeReasonNotEnoughInfo.
  ///
  /// In zh, this message translates to:
  /// **'信息太少，无法判断'**
  String get opposeReasonNotEnoughInfo;

  /// No description provided for @opposeReasonNotExecutable.
  ///
  /// In zh, this message translates to:
  /// **'不看好可执行性'**
  String get opposeReasonNotExecutable;

  /// No description provided for @opposeReasonUnreasonablePricing.
  ///
  /// In zh, this message translates to:
  /// **'定价或回报不合理'**
  String get opposeReasonUnreasonablePricing;

  /// No description provided for @opposeReasonOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get opposeReasonOther;

  /// No description provided for @opposeReasonTextHint.
  ///
  /// In zh, this message translates to:
  /// **'请补充你的理由'**
  String get opposeReasonTextHint;

  /// No description provided for @opposeSubmit.
  ///
  /// In zh, this message translates to:
  /// **'提交'**
  String get opposeSubmit;

  /// No description provided for @opposeSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已记录，将减少类似企划推荐'**
  String get opposeSuccess;

  /// No description provided for @ideaAlreadyVoted.
  ///
  /// In zh, this message translates to:
  /// **'已支持过'**
  String get ideaAlreadyVoted;

  /// No description provided for @ideaErrorSelfVote.
  ///
  /// In zh, this message translates to:
  /// **'不能给自己的企划投票'**
  String get ideaErrorSelfVote;

  /// No description provided for @ideaErrorTooFrequent.
  ///
  /// In zh, this message translates to:
  /// **'操作太频繁，请稍后再试'**
  String get ideaErrorTooFrequent;

  /// No description provided for @ideaErrorNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络开小差了，请重试'**
  String get ideaErrorNetwork;
}

class _ProjectIdeaLocalizationsDelegate extends LocalizationsDelegate<ProjectIdeaLocalizations> {
  const _ProjectIdeaLocalizationsDelegate();

  @override
  Future<ProjectIdeaLocalizations> load(Locale locale) {
    return SynchronousFuture<ProjectIdeaLocalizations>(lookupProjectIdeaLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_ProjectIdeaLocalizationsDelegate old) => false;
}

ProjectIdeaLocalizations lookupProjectIdeaLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return ProjectIdeaLocalizationsEn();
    case 'zh': return ProjectIdeaLocalizationsZh();
  }

  throw FlutterError(
    'ProjectIdeaLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
