import 'dart:typed_data';

import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/project_idea/data/project_idea_api.dart';

/// 用本地假 adapter 断言路径 / query / 请求体，不依赖真实网络。
void main() {
  late _RecordingAdapter adapter;
  late ProjectIdeaApi api;

  setUp(() {
    adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/'));
    dio.httpClientAdapter = adapter;
    api = ProjectIdeaApi(client: ApiClient(dio));
  });

  test('feed：GET v1/projectIdeas/feed，默认 size=10 且不带 cursor', () async {
    adapter.replies.add(
      const _Reply(
        body:
            '{"items":[{"ideaId":1001,"title":"城市露营企划"}],'
            '"nextCursor":"c2","hasMore":true}',
      ),
    );

    final page = await api.feed();

    final RequestOptions request = adapter.requests.single;
    expect(request.method, 'GET');
    expect(request.path, 'v1/projectIdeas/feed');
    expect(request.queryParameters, containsPair('size', 10));
    expect(request.queryParameters.containsKey('cursor'), isFalse);
    expect(page.items.single.ideaId, 1001);
    expect(page.nextCursor, 'c2');
    expect(page.hasMore, isTrue);
  });

  test('feed：候选游标与自定义 size 原样传递', () async {
    adapter.replies.add(const _Reply(body: '{"items":[]}'));

    await api.feed(cursor: 'c2', size: 20);

    final RequestOptions request = adapter.requests.single;
    expect(request.queryParameters['cursor'], 'c2');
    expect(request.queryParameters['size'], 20);
  });

  test('feed：兼容 {code,message,data} 信封', () async {
    adapter.replies.add(
      const _Reply(
        body:
            '{"code":0,"message":"","data":{"items":[{"ideaId":7}],'
            '"nextCursor":null,"hasMore":false}}',
      ),
    );

    final page = await api.feed();

    expect(page.items.single.ideaId, 7);
    expect(page.hasMore, isFalse);
  });

  test('detail：GET v1/projectIdeas/{id} 并解出 data 段', () async {
    adapter.replies.add(
      const _Reply(
        body:
            '{"code":0,"message":"","data":{"ideaId":"1001","title":"城市露营企划",'
            '"tierDistribution":{"5":6,"10":3,"20":1},"supportRate":0.914}}',
      ),
    );

    final detail = await api.detail(1001);

    final RequestOptions request = adapter.requests.single;
    expect(request.method, 'GET');
    expect(request.path, 'v1/projectIdeas/1001');
    expect(detail.ideaId, 1001);
    expect(detail.tierDistribution.five, 6);
    expect(detail.supportRate, 0.914);
  });

  test('vote：POST 支持请求体只带非空字段', () async {
    adapter.replies.add(
      const _Reply(
        body:
            '{"supportCount":128,"opposeCount":12,"alreadyVoted":true,'
            '"myVote":{"voteType":1,"coinTier":10}}',
      ),
    );

    final result = await api.vote(
      1001,
      voteType: 1,
      coinTier: 10,
      reasonText: '看好创意',
    );

    final RequestOptions request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, 'v1/projectIdeas/1001/vote');
    expect(request.data, <String, dynamic>{
      'voteType': 1,
      'coinTier': 10,
      'reasonText': '看好创意',
    });
    expect(result.supportCount, 128);
    expect(result.alreadyVoted, isTrue);
    expect(result.myVote!.coinTier, 10);
  });

  test('vote：不支持只带 reasonCode，空 reasonText 不下发', () async {
    adapter.replies.add(
      const _Reply(body: '{"supportCount":1,"opposeCount":2}'),
    );

    await api.vote(
      1001,
      voteType: 2,
      reasonCode: 'too_many_similar',
      reasonText: '',
    );

    final RequestOptions request = adapter.requests.single;
    expect(request.path, 'v1/projectIdeas/1001/vote');
    expect(request.data, <String, dynamic>{
      'voteType': 2,
      'reasonCode': 'too_many_similar',
    });
  });

  test('vote：服务端失败抛 Failure，不吞异常', () async {
    adapter.replies.add(
      const _Reply(
        status: 403,
        body:
            '{"code":"IDEA_SELF_VOTE_FORBIDDEN",'
            '"message":"不能给自己的企划投票"}',
      ),
    );

    await expectLater(
      api.vote(1001, voteType: 1, coinTier: 5),
      throwsA(
        isA<Failure>()
            .having(
              (Failure failure) => failure.code,
              'code',
              'IDEA_SELF_VOTE_FORBIDDEN',
            )
            .having(
              (Failure failure) => failure.message,
              'message',
              '不能给自己的企划投票',
            ),
      ),
    );
  });
}

final class _Reply {
  const _Reply({this.status = 200, this.body = '{}'});

  final int status;
  final String body;
}

final class _RecordingAdapter implements HttpClientAdapter {
  final List<_Reply> replies = <_Reply>[];
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final _Reply reply = replies.isEmpty ? const _Reply() : replies.removeAt(0);
    return ResponseBody.fromString(
      reply.body,
      reply.status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
