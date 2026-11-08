// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'project_idea_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class ProjectIdeaLocalizationsZh extends ProjectIdeaLocalizations {
  ProjectIdeaLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String ideaViewedToday(int count) {
    return '今日已看 $count 张';
  }

  @override
  String get ideaRefresh => '刷新';

  @override
  String get ideaEmptyTitle => '今天的创意都看完啦';

  @override
  String get ideaEmptyDescription => '去发现看看，或刷新试试';

  @override
  String get ideaLoadFailed => '加载失败';

  @override
  String get ideaSkip => '跳过';

  @override
  String get ideaCategoryFallback => '未分类';

  @override
  String get ideaCreatorLabel => '发起人';

  @override
  String ideaSupportCount(int count) {
    return '$count 支持';
  }

  @override
  String ideaOpposeCount(int count) {
    return '$count 不支持';
  }

  @override
  String get ideaSupport => '支持';

  @override
  String get ideaOppose => '不支持';

  @override
  String get ideaNotLaunched => '尚未立项';

  @override
  String get ideaDetailTitle => '创意详情';

  @override
  String get ideaDetailLoadFailed => '详情加载失败';

  @override
  String get ideaDetailDescription => '企划介绍';

  @override
  String get ideaDetailGallery => '图集';

  @override
  String ideaDetailPublishedAt(String date) {
    return '发布于 $date';
  }

  @override
  String get ideaDetailSupportRate => '支持率';

  @override
  String get ideaDetailTierDistribution => '意愿档位分布';

  @override
  String get ideaDetailReasons => '不支持理由';

  @override
  String get ideaDetailNoReasons => '还没有理由数据';

  @override
  String get ideaDetailVotedSupport => '已支持';

  @override
  String get ideaDetailVotedOppose => '已不支持';

  @override
  String ideaDetailSupportPeople(int count) {
    return '$count 人支持';
  }

  @override
  String ideaDetailOpposePeople(int count) {
    return '$count 人不支持';
  }

  @override
  String get ideaDetailNotLaunchedHint => '这是一个创意想法，尚未立项，不涉及购买或扣费';

  @override
  String get supportSheetTitle => '支持这个企划';

  @override
  String get supportSheetSubtitle => '你的支持会帮助它更快立项';

  @override
  String ideaTierOption(int tier) {
    return '$tier 星币';
  }

  @override
  String get supportDisclaimer => '仅表达支持意愿，不会扣除星币';

  @override
  String get supportReasonHint => '说说你的理由（选填）';

  @override
  String get supportReasonCreative => '看好创意';

  @override
  String get supportReasonJoin => '愿意参与';

  @override
  String get supportReasonLaunch => '希望尽快立项';

  @override
  String get supportSubmit => '提交支持';

  @override
  String get supportSuccess => '已支持，感谢你的态度';

  @override
  String get opposeSheetTitle => '为什么不支持？';

  @override
  String get opposeSheetSubtitle => '你的理由会帮助作者改进，并减少类似企划推荐';

  @override
  String get opposeReasonNotInterested => '不感兴趣';

  @override
  String get opposeReasonTooManySimilar => '同类企划太多';

  @override
  String get opposeReasonNotEnoughInfo => '信息太少，无法判断';

  @override
  String get opposeReasonNotExecutable => '不看好可执行性';

  @override
  String get opposeReasonUnreasonablePricing => '定价或回报不合理';

  @override
  String get opposeReasonOther => '其他';

  @override
  String get opposeReasonTextHint => '请补充你的理由';

  @override
  String get opposeSubmit => '提交';

  @override
  String get opposeSuccess => '已记录，将减少类似企划推荐';

  @override
  String get ideaAlreadyVoted => '已支持过';

  @override
  String get ideaErrorSelfVote => '不能给自己的企划投票';

  @override
  String get ideaErrorTooFrequent => '操作太频繁，请稍后再试';

  @override
  String get ideaErrorNetwork => '网络开小差了，请重试';
}
