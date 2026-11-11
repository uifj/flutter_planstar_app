import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/network/api_paths.dart';
import '../domain/show_summary.dart';

part 'planstar_catalog_api.freezed.dart';
part 'planstar_catalog_api.g.dart';

/// 企划库 API（首页 Banner、企划列表、热门企划、榜单、企划详情）。
///
/// ## 端点
///
/// | 用途 | 方法 | 路径 |
/// |---|---|---|
/// | 首页 Banner | GET | `v1/home/banners` |
/// | 热门企划 | GET | `v1/projects/hot` |
/// | 企划列表（全部/分类） | GET | `v1/projects` |
/// | 企划详情 | GET | `v1/projects/{id}` |
/// | 企划榜单 | GET | `v1/rankings` |
///
/// 全部走裸模型 + HTTP 状态码（与登录接口一致），信封用 [PassthroughEnvelope]。
final class PlanstarCatalogApi {
  PlanstarCatalogApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  /// 首页运营 Banner。
  Future<Result<List<BannerDto>>> fetchBanners() {
    return _client.get<List<BannerDto>>(
      ApiPaths.homeBanners,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final list = data as List<dynamic>? ?? <dynamic>[];
        return list
            .whereType<Map<String, dynamic>>()
            .map(BannerDto.fromJson)
            .toList(growable: false);
      },
    );
  }

  /// 热门企划。
  Future<Result<List<ShowSummary>>> fetchHotShows({
    int pageIndex = 1,
    int pageSize = 20,
  }) {
    return _client.get<List<ShowSummary>>(
      ApiPaths.projectsHot,
      queryParameters: <String, dynamic>{
        'page': pageIndex,
        'pageSize': pageSize,
      },
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final list = data as List<dynamic>? ?? <dynamic>[];
        return list
            .whereType<Map<String, dynamic>>()
            .map(ShowSummary.fromJson)
            .toList(growable: false);
      },
    );
  }

  /// 企划列表（支持分类 / 筹资状态 / 排序）。
  Future<Result<List<ShowSummary>>> fetchShows({
    int? categoryId,
    String? fundingStatus,
    String? sort,
    int pageIndex = 1,
    int pageSize = 20,
  }) {
    final query = <String, dynamic>{
      'page': pageIndex,
      'pageSize': pageSize,
      'categoryId': ?categoryId,
      'fundingStatus': ?fundingStatus,
      'sort': ?sort,
    };
    return _client.get<List<ShowSummary>>(
      ApiPaths.projects,
      queryParameters: query,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final list = data as List<dynamic>? ?? <dynamic>[];
        return list
            .whereType<Map<String, dynamic>>()
            .map(ShowSummary.fromJson)
            .toList(growable: false);
      },
    );
  }

  /// 企划详情。
  Future<Result<ShowSummary?>> fetchShowDetail(String id) {
    return _client.get<ShowSummary?>(
      ApiPaths.projectDetail(id),
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is! Map<String, dynamic>) return null;
        return ShowSummary.fromJson(data);
      },
    );
  }

  /// 企划榜单。
  ///
  /// `type`：`hot`（默认）/ `achievement` / `ending`；
  /// `limit` 默认 10、上限 50。仅统计进行中与已达成的企划。
  Future<Result<List<RankingEntry>>> fetchRankings({
    String type = 'hot',
    int? categoryId,
    int limit = 10,
  }) {
    return _client.get<List<RankingEntry>>(
      ApiPaths.rankings,
      queryParameters: <String, dynamic>{
        'type': type,
        'categoryId': ?categoryId,
        'limit': limit,
      },
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is! Map<String, dynamic>) return const <RankingEntry>[];
        final items = data['items'] as List<dynamic>? ?? <dynamic>[];
        return items
            .whereType<Map<String, dynamic>>()
            .where((item) => item['project'] is Map<String, dynamic>)
            .map(RankingEntry.fromJson)
            .toList(growable: false);
      },
    );
  }
}

/// 榜单中的一条：名次 + 服务端指标 + 企划摘要。
@freezed
abstract class RankingEntry with _$RankingEntry {
  const factory RankingEntry({
    @JsonKey(readValue: _readRank) required int rank,

    /// 指标值：热榜为支持人数，达成榜为达成率（千分比），冲刺榜为剩余天数。
    @JsonKey(readValue: _readMetricValue) required int metricValue,

    @JsonKey(readValue: _readProject) required ShowSummary show,
  }) = _RankingEntry;

  factory RankingEntry.fromJson(Map<String, dynamic> json) =>
      _$RankingEntryFromJson(json);
}

/// Banner DTO。
///
/// 对应 `v1/home/banners` 返回的每一项：
/// `{id, title, image, url?, showId?}`
@freezed
abstract class BannerDto with _$BannerDto {
  const factory BannerDto({
    @JsonKey(fromJson: _toStringOrEmpty) required String id,
    @JsonKey(fromJson: _toStringOrEmpty) required String title,
    @JsonKey(fromJson: _toStringOrEmpty) required String image,
    @JsonKey(fromJson: _toStringOrNull) String? url,
    @JsonKey(fromJson: _toStringOrNull) String? showId,
  }) = _BannerDto;

  factory BannerDto.fromJson(Map<String, dynamic> json) =>
      _$BannerDtoFromJson(json);
}

// ── JSON 兼容读取 ───────────────────────────────────────────────────────

Object? _readRank(Map<dynamic, dynamic> json, String key) =>
    json['rank'] as int? ?? 0;

Object? _readMetricValue(Map<dynamic, dynamic> json, String key) =>
    json['metricValue'] as int? ?? 0;

Object? _readProject(Map<dynamic, dynamic> json, String key) => json['project'];

String _toStringOrEmpty(Object? value) => value?.toString() ?? '';

String? _toStringOrNull(Object? value) => value?.toString();
