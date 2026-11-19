import 'dart:ui' show Color;

import 'package:flutter_book_reader/flutter_book_reader.dart';

import '../../../l10n/l10n.dart';
import '../../catalog/domain/show_summary.dart';

/// 阅读器里的一章：标题 + 纯文本正文。
///
/// 正文按段落用 `\n` 分隔、段间用空行 `\n\n`，交给 `flutter_book_reader`
/// 做分页 / 排版；这里不拼任何富文本，否则换字号后行高与分页会算不准。
class ShowBookChapter {
  const ShowBookChapter({required this.title, required this.body});

  final String title;
  final String body;
}

/// 把企划详情映射成电子书章节。
///
/// 章节顺序与详情页阅读动线一致：故事 → 进度 → 档位 → 更新 → 风险 → FAQ →
/// 支持须知 → 创作者。详情页的每一个正文区块都能在书里找到，避免"读一半缺一段"。
///
/// 文案统一从 [l10n] 取，中英文与详情页保持一致；不做第二套硬编码中文。
List<ShowBookChapter> buildShowChapters(ShowSummary show, AppL10n l10n) {
  return <ShowBookChapter>[
    ShowBookChapter(
      title: l10n.projectStoryTitle,
      body: _storyBody(show, l10n),
    ),
    ShowBookChapter(
      title: l10n.projectTabProgress,
      body: _progressBody(show, l10n),
    ),
    ShowBookChapter(
      title: l10n.projectRewardsTitle,
      body: _rewardsBody(show, l10n),
    ),
    ShowBookChapter(
      title: l10n.projectTabUpdates,
      body: _updatesBody(show, l10n),
    ),
    ShowBookChapter(
      title: l10n.projectTabRisk,
      body: _riskBody(show, l10n),
    ),
    ShowBookChapter(
      title: l10n.projectFaqTitle,
      body: _faqBody(show, l10n),
    ),
    ShowBookChapter(
      title: l10n.projectNoticeTitle,
      body: _noticeBody(show, l10n),
    ),
    ShowBookChapter(
      title: l10n.projectCreatorTitle,
      body: _creatorBody(show, l10n),
    ),
  ];
}

/// 企划内容数据源：清单只给章节标题，正文按章懒加载。
class ShowBookSource extends BookSource {
  ShowBookSource({
    required this.show,
    required this.l10n,
    required this.coverColor,
  });

  final ShowSummary show;
  final AppL10n l10n;
  final Color coverColor;

  late final List<ShowBookChapter> _chapters = buildShowChapters(show, l10n);

  @override
  Future<BookManifest> loadManifest() async {
    return BookManifest(
      id: 'show-${show.id}',
      title: show.title,
      author: show.artist,
      intro: show.intro,
      coverColor: coverColor,
      chapterTitles: <String>[for (final chapter in _chapters) chapter.title],
    );
  }

  @override
  Future<String> loadChapterBody(int chapterIndex) async {
    if (chapterIndex < 0 || chapterIndex >= _chapters.length) return '';
    return _chapters[chapterIndex].body;
  }
}

String _storyBody(ShowSummary show, AppL10n l10n) {
  final intro = show.intro.trim();
  if (intro.isNotEmpty) return intro;
  return l10n.readerIntroEmpty;
}

String _progressBody(ShowSummary show, AppL10n l10n) {
  final goal = show.goalAmount;
  final raised = show.raisedAmount;
  final achievement = (show.achievementPermille / 10).toStringAsFixed(1);
  return <String>[
    '${l10n.projectAchievement}　$achievement%',
    '${l10n.projectGoalAmount}　${goal?.format() ?? '—'}',
    '${l10n.projectRaisedAmount}　${raised?.format() ?? '—'}',
    '${l10n.projectSupporters}　${show.supporterCount}',
    '${l10n.projectDeadline}　${formatDate(show.projectDeadline)}',
    '${l10n.readerStatus}　${_statusText(show, l10n)}',
  ].join('\n\n');
}

String _rewardsBody(ShowSummary show, AppL10n l10n) {
  if (show.tiers.isEmpty) return l10n.projectRewardsEmpty;
  final blocks = <String>[];
  for (final tier in show.tiers) {
    final lines = <String>[
      '${tier.name}　${tier.price.format()}',
      for (final item in tier.items) '· $item',
      if (tier.estimatedDeliveryTime.isNotEmpty)
        l10n.projectRewardDelivery(tier.estimatedDeliveryTime),
      if (tier.remaining != null) l10n.readerRemaining(tier.remaining!),
      if ((tier.note ?? '').isNotEmpty) tier.note!,
    ];
    blocks.add(lines.join('\n'));
  }
  return blocks.join('\n\n');
}

String _updatesBody(ShowSummary show, AppL10n l10n) {
  if (show.updates.isEmpty) return l10n.projectUpdatesEmpty;
  return show.updates
      .map((update) {
        final time = update.publishTime;
        final heading = time == null
            ? update.title
            : '${formatDate(time)}　${update.title}';
        return '$heading\n\n${update.content}';
      })
      .join('\n\n');
}

String _riskBody(ShowSummary show, AppL10n l10n) {
  final refund = show.refundRule.isEmpty
      ? ''
      : '${show.refundRule}\n${l10n.projectRefundArrival(show.refundDays)}';
  final entries = <(String, String)>[
    (l10n.projectRiskNote, show.riskNote),
    (l10n.projectDeliveryPlan, show.deliveryPlan),
    (l10n.projectFundUsage, show.fundUsage),
    (l10n.projectRefundRule, refund),
  ].where((entry) => entry.$2.isNotEmpty).toList(growable: false);
  if (entries.isEmpty) return l10n.projectRiskEmpty;
  return entries
      .map((entry) => '${entry.$1}\n\n${entry.$2}')
      .join('\n\n');
}

String _faqBody(ShowSummary show, AppL10n l10n) {
  if (show.faqs.isEmpty) return l10n.projectFaqEmpty;
  return show.faqs
      .map((faq) => '${faq.question}\n\n${faq.answer}')
      .join('\n\n');
}

String _noticeBody(ShowSummary show, AppL10n l10n) {
  final notices = show.purchaseNotice.isEmpty
      ? <String>[l10n.showDetailPage_685, l10n.showDetailPage_685_2]
      : show.purchaseNotice;
  return notices.map((notice) => '· $notice').join('\n\n');
}

String _creatorBody(ShowSummary show, AppL10n l10n) {
  final bio = show.creatorBio.trim();
  final stats = l10n.projectCreatorStats(
    show.creatorProjectNum,
    show.creatorSuccessNum,
    (show.creatorFulfillmentPermille / 10).round(),
  );
  return <String>[
    show.artist,
    stats,
    bio.isEmpty ? l10n.projectCreatorBioEmpty : bio,
  ].join('\n\n');
}

String _statusText(ShowSummary show, AppL10n l10n) {
  return switch (show.fundingStatusValue) {
    'preheating' => l10n.projectStatusPreheating,
    'achieved' => l10n.projectStatusAchieved,
    'delivered' => l10n.projectStatusDelivered,
    'failed' => l10n.projectStatusFailed,
    _ => l10n.projectStatusOngoing,
  };
}
