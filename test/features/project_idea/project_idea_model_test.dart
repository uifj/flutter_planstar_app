import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/project_idea/model/project_idea.dart';

/// DTO 宽松解析：字段缺失 / 类型异常 / 可选表态。
void main() {
  test('完整解析：数字兼容字符串，详情含表态与档位分布', () {
    final detail = ProjectIdeaDetail.fromJson(<String, dynamic>{
      'ideaId': '1001',
      'title': '城市露营企划',
      'summary': '周末去城市边缘露营',
      'cover': 'https://cdn.example.com/cover.jpg',
      'categoryId': '7',
      'categoryName': '户外',
      'creatorName': '小明',
      'creatorAvatar': 'https://cdn.example.com/avatar.jpg',
      'supportCount': '128',
      'opposeCount': 12,
      'createdAt': '2026-10-01T12:00:00Z',
      'description': '详细描述',
      'gallery': <dynamic>['a.jpg', 2, null, ''],
      'myVote': <String, dynamic>{'voteType': '1', 'coinTier': '10'},
      'tierDistribution': <String, dynamic>{'5': '60', '10': 48},
      'supportRate': '0.914',
    });

    expect(detail.ideaId, 1001);
    expect(detail.title, '城市露营企划');
    expect(detail.categoryId, 7);
    expect(detail.supportCount, 128);
    expect(detail.opposeCount, 12);
    expect(detail.createdAt, DateTime.parse('2026-10-01T12:00:00Z'));
    expect(detail.description, '详细描述');
    expect(detail.gallery, <String>['a.jpg', '2']);
    expect(detail.myVote, isNotNull);
    expect(detail.myVote!.voteType, 1);
    expect(detail.myVote!.coinTier, 10);
    expect(detail.tierDistribution.five, 60);
    expect(detail.tierDistribution.ten, 48);
    expect(detail.tierDistribution.twenty, 0);
    expect(detail.supportRate, 0.914);
  });

  test('缺字段全部落默认值', () {
    final idea = ProjectIdea.fromJson(<String, dynamic>{});

    expect(idea.ideaId, 0);
    expect(idea.title, '');
    expect(idea.summary, '');
    expect(idea.cover, '');
    expect(idea.categoryId, 0);
    expect(idea.categoryName, '');
    expect(idea.creatorName, '');
    expect(idea.creatorAvatar, '');
    expect(idea.supportCount, 0);
    expect(idea.opposeCount, 0);
    expect(idea.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('类型异常不抛：非法数字回落默认值，毫秒时间戳可解析', () {
    final idea = ProjectIdea.fromJson(<String, dynamic>{
      'ideaId': 'abc',
      'supportCount': null,
      'opposeCount': <String, dynamic>{},
      'createdAt': 1700000000000,
    });

    expect(idea.ideaId, 0);
    expect(idea.supportCount, 0);
    expect(idea.opposeCount, 0);
    expect(idea.createdAt, DateTime.fromMillisecondsSinceEpoch(1700000000000));
  });

  test('后端形态：userName / userAvatar / gmtCreate 兼容映射', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'ideaId': 1794,
      'title': '纸飞机',
      'userName': '纸飞机',
      'userAvatar': 'https://cdn.example.com/u.jpg',
      'gmtCreate': 1794117141000,
    };

    final idea = ProjectIdea.fromJson(json);
    final detail = ProjectIdeaDetail.fromJson(json);
    final expectedAt = DateTime.fromMillisecondsSinceEpoch(1794117141000);

    expect(idea.creatorName, '纸飞机');
    expect(idea.creatorAvatar, 'https://cdn.example.com/u.jpg');
    expect(idea.createdAt, expectedAt);
    expect(detail.creatorName, '纸飞机');
    expect(detail.creatorAvatar, 'https://cdn.example.com/u.jpg');
    expect(detail.createdAt, expectedAt);

    // 旧字段优先，避免两个字段同时下发时行为漂移。
    final both = ProjectIdea.fromJson(<String, dynamic>{
      'creatorName': '小明',
      'userName': '纸飞机',
    });
    expect(both.creatorName, '小明');
  });

  test('myVote 为 null 或空对象时视为未表态', () {
    final withNull = ProjectIdeaDetail.fromJson(<String, dynamic>{
      'ideaId': 1,
      'myVote': null,
    });
    final withEmpty = ProjectIdeaDetail.fromJson(<String, dynamic>{
      'ideaId': 1,
      'myVote': <String, dynamic>{},
    });

    expect(withNull.myVote, isNull);
    expect(withEmpty.myVote, isNull);
  });

  test('tierDistribution 缺档时缺失档位为 0', () {
    final onlyFive = ProjectIdeaDetail.fromJson(<String, dynamic>{
      'ideaId': 1,
      'tierDistribution': <String, dynamic>{'5': 3},
    });
    final withoutDistribution = ProjectIdeaDetail.fromJson(<String, dynamic>{
      'ideaId': 1,
    });

    expect(onlyFive.tierDistribution.five, 3);
    expect(onlyFive.tierDistribution.ten, 0);
    expect(onlyFive.tierDistribution.twenty, 0);
    expect(onlyFive.tierDistribution.total, 3);

    expect(withoutDistribution.tierDistribution.five, 0);
    expect(withoutDistribution.tierDistribution.ten, 0);
    expect(withoutDistribution.tierDistribution.twenty, 0);
  });

  test('feed 页兼容 items / data 列表与游标推断', () {
    final withItems = ProjectIdeaFeedPage.fromJson(<String, dynamic>{
      'items': <dynamic>[
        <String, dynamic>{'ideaId': 1},
        <String, dynamic>{'ideaId': '2'},
      ],
      'nextCursor': 'c2',
    });
    final withDataList = ProjectIdeaFeedPage.fromJson(<String, dynamic>{
      'data': <dynamic>[
        <String, dynamic>{'ideaId': 3},
      ],
      'hasMore': 'false',
    });
    final empty = ProjectIdeaFeedPage.fromJson(<String, dynamic>{});

    expect(withItems.items.map((ProjectIdea idea) => idea.ideaId), <int>[1, 2]);
    expect(withItems.nextCursor, 'c2');
    // 未下发 hasMore 时，有游标即视为还能翻页。
    expect(withItems.hasMore, isTrue);

    expect(withDataList.items.single.ideaId, 3);
    expect(withDataList.nextCursor, isNull);
    expect(withDataList.hasMore, isFalse);

    expect(empty.items, isEmpty);
    expect(empty.hasMore, isFalse);
  });

  test('IdeaVoteResult 解析幂等标记与我的表态', () {
    final result = IdeaVoteResult.fromJson(<String, dynamic>{
      'supportCount': '128',
      'opposeCount': 12,
      'alreadyVoted': 1,
      'myVote': <String, dynamic>{'voteType': 2, 'reasonCode': 'other'},
    });

    expect(result.supportCount, 128);
    expect(result.opposeCount, 12);
    expect(result.alreadyVoted, isTrue);
    expect(result.myVote!.voteType, 2);
    expect(result.myVote!.reasonCode, 'other');
  });
}
