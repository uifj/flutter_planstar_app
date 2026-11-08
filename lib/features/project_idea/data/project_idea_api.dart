import 'package:core/network.dart';
import 'package:core/result.dart';

import '../../../app/network/api_paths.dart';
import '../model/project_idea.dart';

/// 企划创意接口。
///
/// | 用途 | 方法 | 路径 |
/// |---|---|---|
/// | 叠卡流 | GET | `v1/projectIdeas/feed?cursor=&size=10` |
/// | 详情 | GET | `v1/projectIdeas/{ideaId}` |
/// | 表态 | POST | `v1/projectIdeas/{ideaId}/vote` |
///
/// 后端响应可能直接是裸模型，也可能包在 `{code,message,data}` 里；统一用
/// [PassthroughEnvelope] 取原始 body，再由 `_payload` 兼容两种形状。
final class ProjectIdeaApi {
  const ProjectIdeaApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  /// 叠卡流（每页 10 条，游标翻页）。
  Future<ProjectIdeaFeedPage> feed({String? cursor, int size = 10}) async {
    final Result<ProjectIdeaFeedPage> result = await _client
        .get<ProjectIdeaFeedPage>(
          ApiPaths.projectIdeasFeed,
          queryParameters: <String, dynamic>{
            'size': size,
            if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          },
          envelope: const PassthroughEnvelope(),
          parser: (Object? data) =>
              ProjectIdeaFeedPage.fromJson(_payload(data)),
        );
    return _unwrap(result);
  }

  /// 创意详情（含我的表态与档位分布）。
  Future<ProjectIdeaDetail> detail(int ideaId) async {
    final Result<ProjectIdeaDetail> result = await _client
        .get<ProjectIdeaDetail>(
          ApiPaths.projectIdeaDetail(ideaId),
          envelope: const PassthroughEnvelope(),
          parser: (Object? data) => ProjectIdeaDetail.fromJson(_payload(data)),
        );
    return _unwrap(result);
  }

  /// 表态（`voteType=1` 支持 / `2` 不支持）。
  Future<IdeaVoteResult> vote(
    int ideaId, {
    required int voteType,
    int? coinTier,
    String? reasonCode,
    String? reasonText,
  }) async {
    final Result<IdeaVoteResult> result = await _client.post<IdeaVoteResult>(
      ApiPaths.projectIdeaVote(ideaId),
      data: <String, dynamic>{
        'voteType': voteType,
        'coinTier': ?coinTier,
        if (reasonCode != null && reasonCode.isNotEmpty)
          'reasonCode': reasonCode,
        if (reasonText != null && reasonText.isNotEmpty)
          'reasonText': reasonText,
      },
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => IdeaVoteResult.fromJson(_payload(data)),
    );
    return _unwrap(result);
  }

  /// 失败即抛出 [Failure]，由调用方决定提示文案；不吞异常。
  static T _unwrap<T>(Result<T> result) => result.fold(
    onSuccess: (T data) => data,
    onFailure: (Failure failure) => throw failure,
  );
}

/// 兼容裸模型与 `{code,message,data}` 两种响应。
Map<String, dynamic> _payload(Object? data) {
  final Map<String, dynamic> json = _asMap(data);
  final Object? inner = json['data'];
  if (inner is Map<String, dynamic>) return inner;
  if (inner is Map<Object?, Object?>) return _asMap(inner);
  return json;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map<Object?, Object?>) {
    return value.map(
      (Object? key, Object? item) => MapEntry<String, dynamic>('$key', item),
    );
  }
  return const <String, dynamic>{};
}
