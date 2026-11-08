/// 企划创意（`GET v1/projectIdeas/feed`）。
///
/// 字段严格对齐后端契约（camelCase）；解析一律宽松：缺字段、类型不符时落
/// 默认值，避免一条脏数据把整页叠卡打挂。
class ProjectIdea {
  const ProjectIdea({
    required this.ideaId,
    required this.title,
    required this.summary,
    required this.cover,
    required this.categoryId,
    required this.categoryName,
    required this.creatorName,
    required this.creatorAvatar,
    required this.supportCount,
    required this.opposeCount,
    required this.createdAt,
  });

  factory ProjectIdea.fromJson(Map<String, dynamic> json) {
    return ProjectIdea(
      ideaId: _asInt(json['ideaId']) ?? 0,
      title: _asText(json['title']),
      summary: _asText(json['summary']),
      cover: _asText(json['cover']),
      categoryId: _asInt(json['categoryId']) ?? 0,
      categoryName: _asText(json['categoryName']),
      creatorName: _asText(json['creatorName'] ?? json['userName']),
      creatorAvatar: _asText(json['creatorAvatar'] ?? json['userAvatar']),
      supportCount: _asInt(json['supportCount']) ?? 0,
      opposeCount: _asInt(json['opposeCount']) ?? 0,
      createdAt: _asDateTime(json['createdAt'] ?? json['gmtCreate']) ?? _epoch,
    );
  }

  final int ideaId;
  final String title;
  final String summary;
  final String cover;
  final int categoryId;
  final String categoryName;
  final String creatorName;
  final String creatorAvatar;
  final int supportCount;
  final int opposeCount;
  final DateTime createdAt;
}

/// 创意详情（`GET v1/projectIdeas/{ideaId}`）。
final class ProjectIdeaDetail extends ProjectIdea {
  const ProjectIdeaDetail({
    required super.ideaId,
    required super.title,
    required super.summary,
    required super.cover,
    required super.categoryId,
    required super.categoryName,
    required super.creatorName,
    required super.creatorAvatar,
    required super.supportCount,
    required super.opposeCount,
    required super.createdAt,
    required this.description,
    required this.gallery,
    required this.myVote,
    required this.tierDistribution,
    required this.supportRate,
    this.reasonCounts = const <String, int>{},
  });

  factory ProjectIdeaDetail.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? myVoteJson = _asMap(json['myVote']);
    return ProjectIdeaDetail(
      ideaId: _asInt(json['ideaId']) ?? 0,
      title: _asText(json['title']),
      summary: _asText(json['summary']),
      cover: _asText(json['cover']),
      categoryId: _asInt(json['categoryId']) ?? 0,
      categoryName: _asText(json['categoryName']),
      creatorName: _asText(json['creatorName'] ?? json['userName']),
      creatorAvatar: _asText(json['creatorAvatar'] ?? json['userAvatar']),
      supportCount: _asInt(json['supportCount']) ?? 0,
      opposeCount: _asInt(json['opposeCount']) ?? 0,
      createdAt: _asDateTime(json['createdAt'] ?? json['gmtCreate']) ?? _epoch,
      description: _asText(json['description']),
      gallery: _asStringList(json['gallery']),
      myVote: myVoteJson == null || myVoteJson.isEmpty
          ? null
          : IdeaVote.fromJson(myVoteJson),
      tierDistribution: IdeaTierDistribution.fromJson(
        _asMap(json['tierDistribution']) ?? const <String, dynamic>{},
      ),
      supportRate: _asDouble(json['supportRate']) ?? 0,
      // 并非所有环境都下发理由聚合；缺失时退回空表，详情页显示"暂无"。
      reasonCounts: _asReasonCounts(
        json['reasonCounts'] ?? json['opposeReasonCounts'],
      ),
    );
  }

  final String description;
  final List<String> gallery;

  /// 我的表态；未投票时为 `null`。
  final IdeaVote? myVote;
  final IdeaTierDistribution tierDistribution;
  final double supportRate;

  /// 不支持理由的计数聚合（`reasonCode → count`），不包含用户原文。
  final Map<String, int> reasonCounts;
}

/// 一次表态（支持 / 不支持）。
final class IdeaVote {
  const IdeaVote({
    required this.voteType,
    this.coinTier,
    this.reasonCode,
    this.reasonText,
  });

  factory IdeaVote.fromJson(Map<String, dynamic> json) {
    return IdeaVote(
      voteType: _asInt(json['voteType']) ?? 0,
      coinTier: _asInt(json['coinTier']),
      reasonCode: _asTextOrNull(json['reasonCode']),
      reasonText: _asTextOrNull(json['reasonText']),
    );
  }

  /// 1 支持 / 2 不支持。
  final int voteType;
  final int? coinTier;
  final String? reasonCode;
  final String? reasonText;
}

/// 投票接口返回值（`POST v1/projectIdeas/{ideaId}/vote`）。
final class IdeaVoteResult {
  const IdeaVoteResult({
    required this.supportCount,
    required this.opposeCount,
    required this.alreadyVoted,
    required this.myVote,
  });

  factory IdeaVoteResult.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? myVoteJson = _asMap(json['myVote']);
    return IdeaVoteResult(
      supportCount: _asInt(json['supportCount']) ?? 0,
      opposeCount: _asInt(json['opposeCount']) ?? 0,
      alreadyVoted: _asBool(json['alreadyVoted']) ?? false,
      myVote: myVoteJson == null || myVoteJson.isEmpty
          ? null
          : IdeaVote.fromJson(myVoteJson),
    );
  }

  final int supportCount;
  final int opposeCount;

  /// 重复投票时为 true（幂等，不重复计数）。
  final bool alreadyVoted;
  final IdeaVote? myVote;
}

/// 支持档位分布（仅统计意愿，不涉及扣费）。
final class IdeaTierDistribution {
  const IdeaTierDistribution({this.five = 0, this.ten = 0, this.twenty = 0});

  factory IdeaTierDistribution.fromJson(Map<String, dynamic> json) {
    return IdeaTierDistribution(
      five: _asInt(json['5']) ?? 0,
      ten: _asInt(json['10']) ?? 0,
      twenty: _asInt(json['20']) ?? 0,
    );
  }

  final int five;
  final int ten;
  final int twenty;

  int get total => five + ten + twenty;
}

/// 叠卡流分页（`GET v1/projectIdeas/feed`）。
final class ProjectIdeaFeedPage {
  const ProjectIdeaFeedPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  factory ProjectIdeaFeedPage.fromJson(Map<String, dynamic> json) {
    final Object? rawItems =
        json['items'] ?? json['list'] ?? json['records'] ?? json['data'];
    final List<ProjectIdea> items = rawItems is List<dynamic>
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(ProjectIdea.fromJson)
              .toList(growable: false)
        : const <ProjectIdea>[];
    final String? nextCursor = _asTextOrNull(
      json['nextCursor'] ?? json['cursor'],
    );
    return ProjectIdeaFeedPage(
      items: items,
      nextCursor: nextCursor,
      // 未下发 hasMore 时用游标推断：有游标就还能翻页。
      hasMore: _asBool(json['hasMore']) ?? nextCursor != null,
    );
  }

  final List<ProjectIdea> items;
  final String? nextCursor;
  final bool hasMore;
}

final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return num.tryParse(value)?.toInt();
  return null;
}

double? _asDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return num.tryParse(value)?.toDouble();
  return null;
}

bool? _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    if (value == 'true' || value == '1') return true;
    if (value == 'false' || value == '0') return false;
  }
  return null;
}

String _asText(Object? value) {
  if (value == null) return '';
  return value.toString();
}

String? _asTextOrNull(Object? value) {
  if (value == null) return null;
  final String text = value.toString();
  return text.isEmpty ? null : text;
}

DateTime? _asDateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  if (value is String) {
    final int? millis = int.tryParse(value);
    if (millis != null) return DateTime.fromMillisecondsSinceEpoch(millis);
    return DateTime.tryParse(value);
  }
  return null;
}

List<String> _asStringList(Object? value) {
  if (value is! List<dynamic>) return const <String>[];
  return value
      .where((Object? item) => item != null)
      .map((Object? item) => item.toString())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

/// 理由聚合同时兼容 `{code: count}` 与 `[{reasonCode, count}]` 两种下发形态。
Map<String, int> _asReasonCounts(Object? value) {
  final Map<String, int> counts = <String, int>{};
  if (value is Map) {
    value.forEach((Object? key, Object? item) {
      final int? count = _asInt(item);
      if (key != null && count != null && count > 0) {
        counts['$key'] = count;
      }
    });
    return counts;
  }
  if (value is List<dynamic>) {
    for (final Object? item in value) {
      final Map<String, dynamic>? json = _asMap(item);
      if (json == null) continue;
      final String? code = _asTextOrNull(
        json['reasonCode'] ?? json['code'] ?? json['reason'],
      );
      final int? count = _asInt(json['count'] ?? json['value']);
      if (code != null && count != null && count > 0) {
        counts[code] = count;
      }
    }
    return counts;
  }
  return counts;
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map<Object?, Object?>) {
    return value.map(
      (Object? key, Object? item) => MapEntry<String, dynamic>('$key', item),
    );
  }
  return null;
}
