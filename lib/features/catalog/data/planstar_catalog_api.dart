import 'package:core/network.dart';
import 'package:core/result.dart';

import '../domain/show_summary.dart';

/// 演出库 API（首页 Banner、演出列表、热门演出）。
///
/// ## 端点
///
/// | 用途 | 方法 | 路径 |
/// |---|---|---|
/// | 首页 Banner | GET | `v1/home/banners` |
/// | 热门演出 | GET | `v1/activities/hot` |
/// | 演出列表（全部/分类） | GET | `v1/activities` |
/// | 演出详情 | GET | `v3/activities/{id}` |
///
/// 全部走裸模型 + HTTP 状态码（与登录接口一致），信封用 [PassthroughEnvelope]。
final class PlanstarCatalogApi {
  PlanstarCatalogApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  /// 首页运营 Banner。
  Future<Result<List<BannerDto>>> fetchBanners() {
    return _client.get<List<BannerDto>>(
      'v1/home/banners',
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

  /// 热门演出。
  Future<Result<List<ShowSummary>>> fetchHotShows({
    int page = 1,
    int pageSize = 20,
  }) {
    return _client.get<List<ShowSummary>>(
      'v1/activities/hot',
      queryParameters: <String, dynamic>{'page': page, 'pageSize': pageSize},
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

  /// 演出列表（支持分类过滤）。
  Future<Result<List<ShowSummary>>> fetchShows({
    int? categoryId,
    String? city,
    int page = 1,
    int pageSize = 20,
  }) {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      'categoryId': ?categoryId,
      if (city != null && city.isNotEmpty) 'city': city,
    };
    return _client.get<List<ShowSummary>>(
      'v1/activities',
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

  /// 演出详情。
  Future<Result<ShowSummary?>> fetchShowDetail(String id) {
    return _client.get<ShowSummary?>(
      'v3/activities/$id',
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is! Map<String, dynamic>) return null;
        return ShowSummary.fromJson(data);
      },
    );
  }
}

/// Banner DTO。
///
/// 来源 `v1/home/banners` 返回的每一项：
/// `{id, title, image, url?, showId?}`
final class BannerDto {
  const BannerDto({
    required this.id,
    required this.title,
    required this.image,
    this.url,
    this.showId,
  });

  final String id;
  final String title;
  final String image;
  final String? url;
  final String? showId;

  factory BannerDto.fromJson(Map<String, dynamic> json) {
    return BannerDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      url: json['url']?.toString(),
      showId: json['showId']?.toString(),
    );
  }
}
