import 'package:core/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'show_summary.freezed.dart';
part 'show_summary.g.dart';

/// 一个票档。
///
/// 与订单上下文的 `TicketTierOffer` 是**两件事**：这里是演出详情页展示的
/// "卖什么票"，那边是确认页的"这一单选了什么"。两者字段相似但生命周期不同，
/// 所以不共用类型——详情页的票档随时会因余票变化而失效，订单的票档一旦选中
/// 就是这一单的事实。
@freezed
abstract class TicketTier with _$TicketTier {
  const TicketTier._();

  const factory TicketTier({
    @JsonKey(readValue: _readTierName) required String name,
    @JsonKey(
      readValue: _readTierPrice,
      fromJson: _moneyFromCentsOrZero,
      toJson: _moneyToCents,
    )
    required Money price,
    @JsonKey(readValue: _readTierNote) String? note,
    @JsonKey(readValue: _readTierRemaining) int? remaining,
    @JsonKey(readValue: _readTierRewardType) @Default('') String rewardType,
    @JsonKey(readValue: _readTierItems, fromJson: _stringList)
    @Default(<String>[])
    List<String> items,
    @JsonKey(readValue: _readTierEstimatedDeliveryTime)
    @Default('')
    String estimatedDeliveryTime,
  }) = _TicketTier;

  factory TicketTier.fromJson(Map<String, dynamic> json) =>
      _$TicketTierFromJson(json);

  bool get soldOut => remaining != null && remaining! <= 0;
}

/// 一条企划常见问题。
@freezed
abstract class ProjectFaq with _$ProjectFaq {
  const factory ProjectFaq({
    @JsonKey(readValue: _readFaqQuestion) required String question,
    @JsonKey(readValue: _readFaqAnswer) required String answer,
    @JsonKey(readValue: _readFaqSort) @Default(0) int sort,
  }) = _ProjectFaq;

  factory ProjectFaq.fromJson(Map<String, dynamic> json) =>
      _$ProjectFaqFromJson(json);
}

/// 一条支持者评价（可带晒单）。
@freezed
abstract class ProjectReview with _$ProjectReview {
  const ProjectReview._();

  const factory ProjectReview({
    @JsonKey(readValue: _readReviewUserName) required String userName,
    @JsonKey(readValue: _readReviewRating) required int rating,
    @JsonKey(readValue: _readReviewContent) @Default('') String content,
    @JsonKey(readValue: _readReviewImages, fromJson: _stringList)
    @Default(<String>[])
    List<String> images,
    @JsonKey(readValue: _readReviewIsShow) @Default(false) bool isShow,
    @JsonKey(readValue: _readReviewIsAnonymous)
    @Default(false)
    bool isAnonymous,
    @JsonKey(readValue: _readReviewLikeCount) @Default(0) int likeCount,
    @JsonKey(readValue: _readReviewCreatedAt, fromJson: _dateTime)
    DateTime? createdAt,
  }) = _ProjectReview;

  factory ProjectReview.fromJson(Map<String, dynamic> json) =>
      _$ProjectReviewFromJson(json);

  String get displayName => isAnonymous ? '匿名支持者' : userName;
}

/// 一条企划进度更新。
@freezed
abstract class ProjectUpdate with _$ProjectUpdate {
  const factory ProjectUpdate({
    @JsonKey(readValue: _readUpdateTitle) required String title,
    @JsonKey(readValue: _readUpdateContent) required String content,
    @JsonKey(readValue: _readUpdatePublishTime, fromJson: _dateTime)
    DateTime? publishTime,
  }) = _ProjectUpdate;

  factory ProjectUpdate.fromJson(Map<String, dynamic> json) =>
      _$ProjectUpdateFromJson(json);
}

/// 一个场次。
@freezed
abstract class ShowSession with _$ShowSession {
  const factory ShowSession({
    @JsonKey(readValue: _readSessionStartsAt, fromJson: _dateTimeOrNow)
    required DateTime startsAt,
    @JsonKey(readValue: _readSessionTierSummary) required String tierSummary,
    @JsonKey(readValue: _readSessionSoldOut) @Default(false) bool soldOut,
  }) = _ShowSession;

  factory ShowSession.fromJson(Map<String, dynamic> json) =>
      _$ShowSessionFromJson(json);
}

/// 演出摘要 —— 首页 / 发现 / 详情 / 订单共用的一张"演出卡片"。
///
/// ## 为什么叫 Summary 而不是 Show
///
/// 列表页要的是"够画一张卡"的字段；详情页要的是完整信息。企划星的
/// `ActivityDetailBean` 与列表用的 `ActivityBean` 是两个类、字段高度重叠。
/// 这里只做一个 [ShowSummary]，详情页在此基础上扩展
/// （[intro] / [tiers] / [lineup] / [purchaseNotice]），
/// 避免"列表模型 20 个字段 + 详情模型 60 个字段"里那 20 个字段被抄两遍。
@freezed
abstract class ShowSummary with _$ShowSummary {
  const ShowSummary._();

  const factory ShowSummary({
    @JsonKey(readValue: _readShowId) required String id,
    @JsonKey(readValue: _readShowTitle) required String title,
    @JsonKey(readValue: _readShowArtist) required String artist,
    @JsonKey(readValue: _readShowCategoryId) required int categoryId,
    @JsonKey(readValue: _readShowCategoryName) required String categoryName,
    @JsonKey(readValue: _readShowCity) required String city,
    @JsonKey(readValue: _readShowVenue) required String venue,
    @JsonKey(readValue: _readShowVenueAddress) required String venueAddress,
    @JsonKey(readValue: _readShowFirstSessionAt, fromJson: _dateTimeOrNow)
    required DateTime firstSessionAt,
    @JsonKey(
      readValue: _readShowPriceFrom,
      fromJson: _moneyFromCentsOrZero,
      toJson: _moneyToCents,
    )
    required Money priceFrom,
    @JsonKey(
      readValue: _readShowListPriceFrom,
      fromJson: _moneyFromCentsOrNull,
      toJson: _moneyToCentsOrNull,
    )
    Money? listPriceFrom,
    @JsonKey(readValue: _readShowDiscountPermille) int? discountPermille,
    @JsonKey(readValue: _readShowTags, fromJson: _stringList)
    @Default(<String>[])
    List<String> tags,
    @JsonKey(readValue: _readShowWishCount) @Default(0) int wishCount,
    @JsonKey(readValue: _readShowSoldOut) @Default(false) bool soldOut,
    @JsonKey(readValue: _readShowProxyBuy) @Default(false) bool proxyBuy,
    @Default(0) double rating,
    @JsonKey(readValue: _readShowRatingCount) @Default(0) int ratingCount,
    @JsonKey(readValue: _readShowDuration) @Default('') String duration,
    @JsonKey(readValue: _readShowIntro) @Default('') String intro,
    @JsonKey(readValue: _readShowSessions, fromJson: _sessionList)
    @Default(<ShowSession>[])
    List<ShowSession> sessions,
    @JsonKey(readValue: _readShowTiers, fromJson: _tierList)
    @Default(<TicketTier>[])
    List<TicketTier> tiers,
    @JsonKey(readValue: _readShowLineup, fromJson: _stringList)
    @Default(<String>[])
    List<String> lineup,
    @JsonKey(readValue: _readShowPurchaseNotice, fromJson: _stringList)
    @Default(<String>[])
    List<String> purchaseNotice,
    @JsonKey(
      readValue: _readShowGoalAmount,
      fromJson: _moneyFromCentsOrNull,
      toJson: _moneyToCentsOrNull,
    )
    Money? goalAmount,
    @JsonKey(
      readValue: _readShowRaisedAmount,
      fromJson: _moneyFromCentsOrNull,
      toJson: _moneyToCentsOrNull,
    )
    Money? raisedAmount,
    @JsonKey(readValue: _readShowSupporterCount) @Default(0) int supporterCount,
    @JsonKey(readValue: _readShowDeadline, fromJson: _dateTime)
    DateTime? deadline,
    @JsonKey(readValue: _readShowFundingStatus)
    @Default('')
    String fundingStatus,
    @JsonKey(readValue: _readShowRiskNote) @Default('') String riskNote,
    @JsonKey(readValue: _readShowDeliveryPlan) @Default('') String deliveryPlan,
    @JsonKey(readValue: _readShowFundUsage) @Default('') String fundUsage,
    @JsonKey(readValue: _readShowRefundRule) @Default('') String refundRule,
    @JsonKey(readValue: _readShowRefundDays) @Default(7) int refundDays,
    @JsonKey(readValue: _readShowFaqs, fromJson: _faqList)
    @Default(<ProjectFaq>[])
    List<ProjectFaq> faqs,
    @JsonKey(readValue: _readShowReviews, fromJson: _reviewList)
    @Default(<ProjectReview>[])
    List<ProjectReview> reviews,
    @Default(0) double ratingAvg,
    @JsonKey(readValue: _readShowApiReviewCount) @Default(0) int apiReviewCount,
    @JsonKey(readValue: _readShowApiShowCount) @Default(0) int apiShowCount,
    @JsonKey(readValue: _readShowUpdates, fromJson: _updateList)
    @Default(<ProjectUpdate>[])
    List<ProjectUpdate> updates,
    @JsonKey(readValue: _readShowCreatorVerified)
    @Default(false)
    bool creatorVerified,
    @JsonKey(readValue: _readShowCreatorProjectNum)
    @Default(0)
    int creatorProjectNum,
    @JsonKey(readValue: _readShowCreatorSuccessNum)
    @Default(0)
    int creatorSuccessNum,
    @JsonKey(readValue: _readShowCreatorFulfillmentPermille)
    @Default(0)
    int creatorFulfillmentPermille,
    @JsonKey(readValue: _readShowCreatorBio) @Default('') String creatorBio,
  }) = _ShowSummary;

  factory ShowSummary.fromJson(Map<String, dynamic> json) =>
      _$ShowSummaryFromJson(json);

  /// 评价平均分（十分制，保留一位小数）；无评价时为 `0`。
  double get ratingAverage {
    if (ratingAvg > 0) return ratingAvg;
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return (total * 2 / reviews.length * 10).round() / 10;
  }

  /// 评价总数（优先取服务端聚合值，避免分页导致少算）。
  int get reviewCount => apiReviewCount > 0 ? apiReviewCount : reviews.length;

  /// 晒单总数。
  int get showCount => apiShowCount > 0
      ? apiShowCount
      : reviews.where((review) => review.isShow).length;

  /// 是否是企划数据（有目标金额）。
  bool get isProject => goalAmount != null;

  /// 企划截止时间；未单独给出时退回首场/首交付时间。
  DateTime get projectDeadline => deadline ?? firstSessionAt;

  /// 达成率，千分比：`1280` = 128%。
  int get achievementPermille {
    final goal = goalAmount;
    final raised = raisedAmount;
    if (goal == null || raised == null) return 0;
    final goalMinor = goal.minorUnits;
    if (goalMinor <= 0) return 0;
    return (raised.minorUnits * 1000 / goalMinor).round();
  }

  /// 剩余天数（截止当天算 1 天；已结束为 0）。
  int get remainingDays {
    final diff = projectDeadline.difference(DateTime.now()).inDays;
    return diff <= 0 ? 0 : diff;
  }

  /// 是否仍在筹资（预热 / 进行中）。
  bool get isFundingOpen =>
      fundingStatusValue == 'preheating' || fundingStatusValue == 'ongoing';

  /// 归一化后的状态值（缺省时按是否售罄推断）。
  String get fundingStatusValue {
    if (fundingStatus.isNotEmpty) return fundingStatus;
    return soldOut ? 'failed' : 'ongoing';
  }

  /// 起价文案（`¥680`），详情页与卡片都用它。
  String get priceFromText => priceFrom.format();

  /// 城市 + 场馆：`上海 · 上海大剧院`。
  ///
  /// 企划数据没有城市/场馆（全国发行），此时返回空串，由 UI 自行隐藏。
  String get venueLabel {
    if (city.isEmpty) return venue;
    if (venue.isEmpty) return city;
    return '$city · $venue';
  }

  /// 同分类判断（首页楼层按分类筛选时用）。
  bool belongsTo(int category) => categoryId == category;
}

/// 日期格式：`2026.11.08`（订单列表的场次行用）。
String formatDate(DateTime time) {
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  return '${time.year}.$month.$day';
}

// ── JSON 兼容读取（字段名别名）──────────────────────────────────────────

Object? _readTierName(Map<dynamic, dynamic> json, String key) =>
    json['title']?.toString() ??
    json['name']?.toString() ??
    json['tierName']?.toString() ??
    '';

Object? _readTierPrice(Map<dynamic, dynamic> json, String key) => json['price'];

Object? _readTierNote(Map<dynamic, dynamic> json, String key) =>
    json['note']?.toString();

Object? _readTierRemaining(Map<dynamic, dynamic> json, String key) =>
    json['remainingNum'] ?? json['remaining'];

Object? _readTierRewardType(Map<dynamic, dynamic> json, String key) =>
    json['rewardType']?.toString() ?? '';

Object? _readTierItems(Map<dynamic, dynamic> json, String key) => json['items'];

Object? _readTierEstimatedDeliveryTime(
  Map<dynamic, dynamic> json,
  String key,
) => json['estimatedDeliveryTime']?.toString() ?? '';

Object? _readFaqQuestion(Map<dynamic, dynamic> json, String key) =>
    json['question']?.toString() ?? '';

Object? _readFaqAnswer(Map<dynamic, dynamic> json, String key) =>
    json['answer']?.toString() ?? '';

Object? _readFaqSort(Map<dynamic, dynamic> json, String key) =>
    json['sort'] as int? ?? 0;

Object? _readReviewUserName(Map<dynamic, dynamic> json, String key) =>
    json['userName']?.toString() ?? '匿名支持者';

Object? _readReviewRating(Map<dynamic, dynamic> json, String key) =>
    json['rating'] as int? ?? 5;

Object? _readReviewContent(Map<dynamic, dynamic> json, String key) =>
    json['content']?.toString() ?? '';

Object? _readReviewImages(Map<dynamic, dynamic> json, String key) =>
    json['images'];

Object? _readReviewIsShow(Map<dynamic, dynamic> json, String key) =>
    json['isShow'] == true;

Object? _readReviewIsAnonymous(Map<dynamic, dynamic> json, String key) =>
    json['isAnonymous'] == true;

Object? _readReviewLikeCount(Map<dynamic, dynamic> json, String key) =>
    json['likeCount'] as int? ?? 0;

Object? _readReviewCreatedAt(Map<dynamic, dynamic> json, String key) =>
    json['gmtCreate'] ?? json['createdAt'];

Object? _readUpdateTitle(Map<dynamic, dynamic> json, String key) =>
    json['title']?.toString() ?? '';

Object? _readUpdateContent(Map<dynamic, dynamic> json, String key) =>
    json['content']?.toString() ?? '';

Object? _readUpdatePublishTime(Map<dynamic, dynamic> json, String key) =>
    json['publishTime'] ?? json['publish_time'];

Object? _readSessionStartsAt(Map<dynamic, dynamic> json, String key) =>
    json['startsAt'] ?? json['showTime'];

Object? _readSessionTierSummary(Map<dynamic, dynamic> json, String key) =>
    json['tierSummary']?.toString() ?? '';

Object? _readSessionSoldOut(Map<dynamic, dynamic> json, String key) =>
    json['soldOut'] == true;

Object? _readShowId(Map<dynamic, dynamic> json, String key) =>
    json['id']?.toString() ??
    json['projectId']?.toString() ??
    json['activityId']?.toString() ??
    '';

Object? _readShowTitle(Map<dynamic, dynamic> json, String key) =>
    json['title']?.toString() ?? json['name']?.toString() ?? '';

Object? _readShowArtist(Map<dynamic, dynamic> json, String key) {
  final Object? creatorRaw = json['creator'];
  final Object? creatorName = creatorRaw is Map
      ? creatorRaw['displayName']
      : null;
  return json['artist']?.toString() ??
      json['creatorName']?.toString() ??
      creatorName?.toString() ??
      json['star']?.toString() ??
      '';
}

Object? _readShowCategoryId(Map<dynamic, dynamic> json, String key) =>
    json['categoryId'] ?? json['category'] ?? 0;

Object? _readShowCategoryName(Map<dynamic, dynamic> json, String key) =>
    json['categoryName']?.toString() ?? '';

Object? _readShowCity(Map<dynamic, dynamic> json, String key) =>
    json['city']?.toString() ?? '';

Object? _readShowVenue(Map<dynamic, dynamic> json, String key) =>
    json['venue']?.toString() ?? json['venueName']?.toString() ?? '';

Object? _readShowVenueAddress(Map<dynamic, dynamic> json, String key) =>
    json['venueAddress']?.toString() ?? '';

Object? _readShowFirstSessionAt(Map<dynamic, dynamic> json, String key) =>
    json['firstSessionAt'] ?? json['showTime'];

Object? _readShowPriceFrom(Map<dynamic, dynamic> json, String key) =>
    json['priceFrom'] ?? json['minPrice'] ?? json['minSupportAmount'];

Object? _readShowListPriceFrom(Map<dynamic, dynamic> json, String key) =>
    json['listPriceFrom'] ?? json['originalPrice'];

Object? _readShowDiscountPermille(Map<dynamic, dynamic> json, String key) =>
    json['discountPermille'] ?? json['discount'];

Object? _readShowTags(Map<dynamic, dynamic> json, String key) => json['tags'];

Object? _readShowWishCount(Map<dynamic, dynamic> json, String key) =>
    json['wishCount'] ?? json['wannaSeeCount'] ?? 0;

Object? _readShowSoldOut(Map<dynamic, dynamic> json, String key) =>
    json['soldOut'] == true || json['status'] == 0;

Object? _readShowProxyBuy(Map<dynamic, dynamic> json, String key) =>
    json['proxyBuy'] == true;

Object? _readShowRatingCount(Map<dynamic, dynamic> json, String key) =>
    json['ratingCount'] ?? 0;

Object? _readShowDuration(Map<dynamic, dynamic> json, String key) =>
    json['duration']?.toString() ?? '';

Object? _readShowIntro(Map<dynamic, dynamic> json, String key) =>
    json['intro']?.toString() ??
    json['story']?.toString() ??
    json['description']?.toString() ??
    '';

Object? _readShowSessions(Map<dynamic, dynamic> json, String key) =>
    json['sessions'];

Object? _readShowTiers(Map<dynamic, dynamic> json, String key) =>
    json['tiers'] ?? json['rewardTiers'];

Object? _readShowLineup(Map<dynamic, dynamic> json, String key) =>
    json['lineup'];

Object? _readShowPurchaseNotice(Map<dynamic, dynamic> json, String key) =>
    json['purchaseNotice'];

Object? _readShowGoalAmount(Map<dynamic, dynamic> json, String key) =>
    json['goalAmount'];

Object? _readShowRaisedAmount(Map<dynamic, dynamic> json, String key) =>
    json['raisedAmount'];

Object? _readShowSupporterCount(Map<dynamic, dynamic> json, String key) =>
    json['supporterCount'] as int? ?? 0;

Object? _readShowDeadline(Map<dynamic, dynamic> json, String key) =>
    json['deadline'];

Object? _readShowFundingStatus(Map<dynamic, dynamic> json, String key) =>
    json['fundingStatus']?.toString() ?? '';

Object? _readShowRiskNote(Map<dynamic, dynamic> json, String key) =>
    json['riskNote']?.toString() ?? '';

Object? _readShowDeliveryPlan(Map<dynamic, dynamic> json, String key) =>
    json['deliveryPlan']?.toString() ?? '';

Object? _readShowFundUsage(Map<dynamic, dynamic> json, String key) =>
    json['fundUsage']?.toString() ?? '';

Object? _readShowRefundRule(Map<dynamic, dynamic> json, String key) =>
    json['refundRule']?.toString() ?? '';

Object? _readShowRefundDays(Map<dynamic, dynamic> json, String key) =>
    json['refundDays'] as int? ?? 7;

Object? _readShowFaqs(Map<dynamic, dynamic> json, String key) =>
    json['faqs'] ?? json['faq'];

Object? _readShowReviews(Map<dynamic, dynamic> json, String key) =>
    json['reviews'];

Object? _readShowApiReviewCount(Map<dynamic, dynamic> json, String key) =>
    json['reviewCount'] as int? ?? 0;

Object? _readShowApiShowCount(Map<dynamic, dynamic> json, String key) =>
    json['showCount'] as int? ?? 0;

Object? _readShowUpdates(Map<dynamic, dynamic> json, String key) =>
    json['updates'];

Object? _readShowCreatorVerified(Map<dynamic, dynamic> json, String key) {
  final Object? creator = json['creator'];
  return json['creatorVerified'] == true ||
      (creator is Map && creator['isVerified'] == true);
}

Object? _readShowCreatorProjectNum(Map<dynamic, dynamic> json, String key) {
  final Object? creator = json['creator'];
  final Object? nested = creator is Map ? creator['projectNum'] : null;
  return json['creatorProjectNum'] as int? ?? nested as int? ?? 0;
}

Object? _readShowCreatorSuccessNum(Map<dynamic, dynamic> json, String key) {
  final Object? creator = json['creator'];
  final Object? nested = creator is Map ? creator['successNum'] : null;
  return json['creatorSuccessNum'] as int? ?? nested as int? ?? 0;
}

Object? _readShowCreatorFulfillmentPermille(
  Map<dynamic, dynamic> json,
  String key,
) {
  final Object? creator = json['creator'];
  final Object? nested = creator is Map ? creator['fulfillmentRate'] : null;
  return json['creatorFulfillmentPermille'] as int? ?? nested as int? ?? 0;
}

Object? _readShowCreatorBio(Map<dynamic, dynamic> json, String key) {
  final Object? creator = json['creator'];
  final Object? nested = creator is Map ? creator['bio'] : null;
  return json['creatorBio']?.toString() ?? nested?.toString() ?? '';
}

// ── 值转换 ──────────────────────────────────────────────────────────────

List<String> _stringList(Object? raw) {
  if (raw is List) {
    return raw.whereType<String>().toList(growable: false);
  }
  return const <String>[];
}

List<ShowSession> _sessionList(Object? raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ShowSession.fromJson)
        .toList(growable: false);
  }
  return const <ShowSession>[];
}

List<TicketTier> _tierList(Object? raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(TicketTier.fromJson)
        .toList(growable: false);
  }
  return const <TicketTier>[];
}

List<ProjectUpdate> _updateList(Object? raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ProjectUpdate.fromJson)
        .toList(growable: false);
  }
  return const <ProjectUpdate>[];
}

List<ProjectFaq> _faqList(Object? raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ProjectFaq.fromJson)
        .toList(growable: false);
  }
  return const <ProjectFaq>[];
}

List<ProjectReview> _reviewList(Object? raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ProjectReview.fromJson)
        .toList(growable: false);
  }
  return const <ProjectReview>[];
}

/// 金额字段（API 单位为分）；缺失时返回零元。
Money _moneyFromCentsOrZero(Object? raw) {
  final int? cents = raw is int ? raw : int.tryParse('${raw ?? ''}');
  return cents == null ? Money.zero() : Money.fromYuan(cents / 100);
}

/// 金额字段（API 单位为分）；缺失时返回 `null`。
Money? _moneyFromCentsOrNull(Object? raw) {
  final int? cents = raw is int ? raw : int.tryParse('${raw ?? ''}');
  return cents == null ? null : Money.fromYuan(cents / 100);
}

/// 金额序列化回最小单位（分），与 [Money] 的来源约定一致。
int _moneyToCents(Money money) => money.minorUnits;

int? _moneyToCentsOrNull(Money? money) => money?.minorUnits;

/// 时间字段：兼容毫秒时间戳与 ISO 字符串。
DateTime? _dateTime(Object? raw) {
  if (raw is int && raw > 0) {
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }
  if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
  return null;
}

/// 时间字段：解析失败或缺省时退回当前时间。
DateTime _dateTimeOrNow(Object? raw) => _dateTime(raw) ?? DateTime.now();
