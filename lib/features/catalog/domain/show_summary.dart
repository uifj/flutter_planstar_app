import 'package:core/domain.dart';

/// 一个票档。
///
/// 与订单上下文的 `TicketTierOffer` 是**两件事**：这里是演出详情页展示的
/// "卖什么票"，那边是确认页的"这一单选了什么"。两者字段相似但生命周期不同，
/// 所以不共用类型——详情页的票档随时会因余票变化而失效，订单的票档一旦选中
/// 就是这一单的事实。
final class TicketTier {
  const TicketTier({
    required this.name,
    required this.price,
    this.note,
    this.remaining,
  });

  factory TicketTier.fromJson(Map<String, dynamic> json) {
    final int? priceRaw = json['price'];
    return TicketTier(
      name: json['name']?.toString() ?? json['tierName']?.toString() ?? '',
      price: priceRaw != null ? Money.fromYuan(priceRaw / 100) : Money.zero(),
      note: json['note']?.toString(),
      remaining: json['remaining'] as int?,
    );
  }

  final String name;
  final Money price;

  /// 附加说明（`含VIP礼包` / `需实名`）。
  final String? note;

  /// 剩余张数（`null` = 不展示）。
  final int? remaining;

  bool get soldOut => remaining != null && remaining! <= 0;
}

/// 一个场次。
final class ShowSession {
  const ShowSession({
    required this.startsAt,
    required this.tierSummary,
    this.soldOut = false,
  });

  factory ShowSession.fromJson(Map<String, dynamic> json) {
    final String? atRaw = json['startsAt'] ?? json['showTime'];
    return ShowSession(
      startsAt: atRaw != null
          ? DateTime.tryParse(atRaw) ?? DateTime.now()
          : DateTime.now(),
      tierSummary: json['tierSummary']?.toString() ?? '',
      soldOut: json['soldOut'] == true,
    );
  }

  final DateTime startsAt;

  /// 该场次的票价区间（`680/580/380`）。
  final String tierSummary;

  final bool soldOut;
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
final class ShowSummary {
  const ShowSummary({
    required this.id,
    required this.title,
    required this.artist,
    required this.categoryId,
    required this.categoryName,
    required this.city,
    required this.venue,
    required this.venueAddress,
    required this.firstSessionAt,
    required this.priceFrom,
    this.listPriceFrom,
    this.discountPermille,
    this.tags = const <String>[],
    this.wishCount = 0,
    this.soldOut = false,
    this.proxyBuy = false,
    this.rating = 0,
    this.ratingCount = 0,
    this.duration = '',
    this.intro = '',
    this.sessions = const <ShowSession>[],
    this.tiers = const <TicketTier>[],
    this.lineup = const <String>[],
    this.purchaseNotice = const <String>[],
  });

  final String id;
  final String title;

  /// 艺人 / 主办（企划星的 `tv_star` 一行）。
  final String artist;

  final int categoryId;
  final String categoryName;

  final String city;
  final String venue;
  final String venueAddress;

  final DateTime firstSessionAt;

  /// 起价。
  final Money priceFrom;

  /// 划线原价（`null` = 无优惠）。
  final Money? listPriceFrom;

  /// 折扣，单位千分比：`980` = 9.8 折。
  final int? discountPermille;

  /// 角标（`电子票` / `选座` / `无票赔付`）。
  final List<String> tags;

  /// 想看人数。
  final int wishCount;

  final bool soldOut;

  /// 代抢（企划星的 `proxyBuy`，影响角标与底部按钮）。
  final bool proxyBuy;

  /// 评分（`0` = 暂无评分）。
  final double rating;
  final int ratingCount;

  /// 时长文案（`约 150 分钟`）。
  final String duration;

  /// 演出介绍（详情页「演出详情」段）。
  final String intro;

  final List<ShowSession> sessions;
  final List<TicketTier> tiers;

  /// 阵容（详情页「艺人阵容」段）。
  final List<String> lineup;

  /// 购票须知（详情页「购买须知」段）。
  final List<String> purchaseNotice;

  /// `9.8折` 角标文案；无折扣返回 `null`。
  String? get discountLabel {
    final permille = discountPermille;
    if (permille == null || permille <= 0 || permille >= 1000) return null;
    final tenth = permille / 100;
    final text = tenth == tenth.roundToDouble()
        ? tenth.toStringAsFixed(0)
        : tenth.toStringAsFixed(1);
    return '$text折';
  }

  /// 起价文案（`¥680`），详情页与卡片都用它。
  String get priceFromText => priceFrom.format();

  /// 首场时间：`11月8日 周日 19:30`。
  String get firstSessionLabel => formatSessionLabel(firstSessionAt);

  /// 城市 + 场馆：`上海 · 上海大剧院`。
  String get venueLabel => '$city · $venue';

  /// 演出状态文案（`售票中` / `暂时售罄` / `预售`）。
  String get saleStatusLabel => soldOut ? '暂时售罄' : '售票中';

  /// 同分类判断（首页楼层按分类筛选时用）。
  bool belongsTo(int category) => categoryId == category;

  /// 从 API JSON 构造（字段名与企划星响应对齐）。
  factory ShowSummary.fromJson(Map<String, dynamic> json) {
    final int? priceRaw = json['priceFrom'] ?? json['minPrice'];
    final int? listPriceRaw = json['listPriceFrom'] ?? json['originalPrice'];
    final String? firstAtRaw = json['firstSessionAt'] ?? json['showTime'];

    return ShowSummary(
      id: json['id']?.toString() ?? json['activityId']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      artist: json['artist']?.toString() ?? json['star']?.toString() ?? '',
      categoryId: json['categoryId'] ?? json['category'] ?? 0,
      categoryName: json['categoryName']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      venue: json['venue']?.toString() ?? json['venueName']?.toString() ?? '',
      venueAddress: json['venueAddress']?.toString() ?? '',
      firstSessionAt: firstAtRaw != null
          ? DateTime.tryParse(firstAtRaw) ?? DateTime.now()
          : DateTime.now(),
      priceFrom: priceRaw != null
          ? Money.fromYuan(priceRaw / 100)
          : Money.zero(),
      listPriceFrom: listPriceRaw != null
          ? Money.fromYuan(listPriceRaw / 100)
          : null,
      discountPermille: json['discountPermille'] ?? json['discount'],
      tags: _stringList(json['tags']),
      wishCount: json['wishCount'] ?? json['wannaSeeCount'] ?? 0,
      soldOut: json['soldOut'] == true || json['status'] == 0,
      proxyBuy: json['proxyBuy'] == true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      duration: json['duration']?.toString() ?? '',
      intro: json['intro']?.toString() ?? json['description']?.toString() ?? '',
      sessions: _sessionList(json['sessions']),
      tiers: _tierList(json['tiers']),
      lineup: _stringList(json['lineup']),
      purchaseNotice: _stringList(json['purchaseNotice']),
    );
  }

  ShowSummary copyWith({
    Money? priceFrom,
    bool? soldOut,
    int? wishCount,
  }) {
    return ShowSummary(
      id: id,
      title: title,
      artist: artist,
      categoryId: categoryId,
      categoryName: categoryName,
      city: city,
      venue: venue,
      venueAddress: venueAddress,
      firstSessionAt: firstSessionAt,
      priceFrom: priceFrom ?? this.priceFrom,
      listPriceFrom: listPriceFrom,
      discountPermille: discountPermille,
      tags: tags,
      wishCount: wishCount ?? this.wishCount,
      soldOut: soldOut ?? this.soldOut,
      proxyBuy: proxyBuy,
      rating: rating,
      ratingCount: ratingCount,
      duration: duration,
      intro: intro,
      sessions: sessions,
      tiers: tiers,
      lineup: lineup,
      purchaseNotice: purchaseNotice,
    );
  }
}

/// 场次时间格式：`11月8日 周日 19:30`。
///
/// 不用 `intl` 的 `DateFormat`：这里只需要中文的固定格式，而 `DateFormat`
/// 依赖 `Intl.defaultLocale` 被初始化（否则会静默回落到 en_US，
/// 出现「Nov 8, 2026」这种中英混排）。
String formatSessionLabel(DateTime time) {
  const weekdays = <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '${time.month}月${time.day}日 ${weekdays[time.weekday - 1]} $hour:$minute';
}

/// 日期格式：`2026.11.08`（订单列表的场次行用）。
String formatDate(DateTime time) {
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  return '${time.year}.$month.$day';
}

/// 相对时间：`刚刚` / `5分钟前` / `昨天` / `11月1日`。
String formatRelativeTime(DateTime time, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final delta = reference.difference(time);
  if (delta.inMinutes < 1) return '刚刚';
  if (delta.inMinutes < 60) return '${delta.inMinutes}分钟前';
  if (delta.inHours < 24 && reference.day == time.day) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  if (delta.inDays == 1) return '昨天';
  if (delta.inDays < 7) return '${delta.inDays}天前';
  return '${time.month}月${time.day}日';
}

// ── JSON 辅助 ───────────────────────────────────────────────────────────

List<String> _stringList(dynamic raw) {
  if (raw is List) {
    return raw.whereType<String>().toList(growable: false);
  }
  return const <String>[];
}

List<ShowSession> _sessionList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ShowSession.fromJson)
        .toList(growable: false);
  }
  return const <ShowSession>[];
}

List<TicketTier> _tierList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(TicketTier.fromJson)
        .toList(growable: false);
  }
  return const <TicketTier>[];
}
