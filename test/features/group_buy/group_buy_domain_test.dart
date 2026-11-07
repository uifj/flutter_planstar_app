import 'package:core/domain.dart';
import 'package:core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/group_buy/application/group_buy_controller.dart';
import 'package:planstar/features/group_buy/domain/group_buy.dart';
import 'package:planstar/features/group_buy/domain/repositories/group_buy_repository.dart';
import 'package:planstar/features/group_buy/domain/services/group_buy_pricing.dart';
import 'package:planstar/features/group_buy/domain/services/group_buy_progress.dart';

void main() {
  const GroupBuyProgressPolicy policy = GroupBuyProgressPolicy();

  GroupBuyInfo buildGroup({
    int currentMembers = 2,
    int succeedNum = 5,
    int stock = 10,
    GroupBuyStatus status = GroupBuyStatus.grouping,
    DateTime? effectiveTo,
  }) {
    return GroupBuyInfo(
      id: 1,
      showTitle: '测试演出',
      showPoster: null,
      venue: '测试场馆',
      eventTime: '2026-12-01 19:30',
      lowPrice: Money.fromYuan(580),
      originalPrice: Money.fromYuan(880),
      succeedNum: succeedNum,
      currentMembers: currentMembers,
      effectiveFrom: DateTime(2026, 11, 1),
      effectiveTo: effectiveTo ?? DateTime(2026, 12, 1, 12),
      status: status,
      slogan: '测试标语',
      members: const <GroupBuyMember>[],
      stock: stock,
    );
  }

  group('GroupBuyProgressPolicy', () {
    test('计算成团进度、剩余名额与剩余小时', () {
      final GroupBuyProgress progress = policy.evaluate(
        buildGroup(),
        now: DateTime(2026, 12, 1, 10, 30),
      );

      expect(progress.progress, closeTo(0.4, 1e-9));
      expect(progress.remainingSlots, 3);
      expect(progress.isFull, isFalse);
      expect(progress.isExpired, isFalse);
      expect(progress.remainingHours, 1);
      expect(progress.canJoin, isTrue);
      expect(progress.block, GroupBuyJoinBlock.none);
    });

    test('满团时进度封顶 100%，剩余名额为 0', () {
      final GroupBuyProgress progress = policy.evaluate(
        buildGroup(currentMembers: 7, succeedNum: 5),
        now: DateTime(2026, 12, 1, 10),
      );

      expect(progress.progress, 1);
      expect(progress.isFull, isTrue);
      expect(progress.remainingSlots, 0);
      expect(progress.canJoin, isFalse);
      expect(progress.block, GroupBuyJoinBlock.full);
    });

    test('超过有效期判定过期，剩余小时归零', () {
      final GroupBuyProgress progress = policy.evaluate(
        buildGroup(effectiveTo: DateTime(2026, 11, 1)),
        now: DateTime(2026, 11, 7),
      );

      expect(progress.isExpired, isTrue);
      expect(progress.remainingHours, 0);
      expect(progress.canJoin, isFalse);
      expect(progress.block, GroupBuyJoinBlock.expired);
    });

    test('库存为 0 时拒绝参团/下单', () {
      final GroupBuyProgress progress = policy.evaluate(
        buildGroup(stock: 0),
        now: DateTime(2026, 12, 1, 10),
      );

      expect(progress.hasStock, isFalse);
      expect(progress.isFull, isFalse);
      expect(progress.remainingSlots, 3);
      expect(progress.canJoin, isFalse);
      expect(progress.block, GroupBuyJoinBlock.outOfStock);
      expect(
        policy.canJoin(buildGroup(stock: 0), now: DateTime(2026, 12, 1, 10)),
        isFalse,
      );
    });

    test('非拼团中状态不可参团', () {
      final GroupBuyProgress progress = policy.evaluate(
        buildGroup(status: GroupBuyStatus.success),
        now: DateTime(2026, 12, 1, 10),
      );

      expect(progress.canJoin, isFalse);
      expect(progress.block, GroupBuyJoinBlock.notGrouping);
    });
  });

  group('GroupBuyPricing', () {
    const GroupBuyPricing pricing = GroupBuyPricing();

    test('节省金额与折扣档位', () {
      final GroupBuyInfo info = buildGroup();

      expect(pricing.hasDiscount(info), isTrue);
      expect(pricing.savedAmount(info), Money.fromYuan(300));
      expect(pricing.discountRate(info), 6);
    });

    test('原价不高于拼团价时没有折扣', () {
      final GroupBuyInfo info = GroupBuyInfo(
        id: 2,
        showTitle: '测试演出',
        showPoster: null,
        venue: '测试场馆',
        eventTime: '2026-12-01 19:30',
        lowPrice: Money.fromYuan(880),
        originalPrice: Money.fromYuan(880),
        succeedNum: 3,
        currentMembers: 1,
        effectiveFrom: DateTime(2026, 11, 1),
        effectiveTo: DateTime(2026, 12, 1),
        status: GroupBuyStatus.grouping,
        slogan: '',
        members: const <GroupBuyMember>[],
        stock: 10,
      );

      expect(pricing.hasDiscount(info), isFalse);
      expect(pricing.discountRate(info), isNull);
    });
  });

  test('库存不足时 Controller 拒绝参团且不发起请求', () async {
    final _FakeGroupBuyRepository repository = _FakeGroupBuyRepository(
      buildGroup(stock: 0, effectiveTo: DateTime(2099)),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        groupBuyRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(groupBuyByIdProvider(1).future);
    await container.read(joinGroupControllerProvider.notifier).join(1);

    expect(container.read(joinGroupControllerProvider), isA<JoinGroupError>());
    expect(repository.joinCalls, 0);
  });
}

final class _FakeGroupBuyRepository implements GroupBuyRepository {
  _FakeGroupBuyRepository(this.campaign);

  final GroupBuyInfo campaign;
  int joinCalls = 0;

  @override
  Future<Result<List<GroupBuyInfo>>> fetchCampaigns() async =>
      Success<List<GroupBuyInfo>>(<GroupBuyInfo>[campaign]);

  @override
  Future<Result<GroupBuyInfo?>> fetchCampaign(int id) async =>
      Success<GroupBuyInfo?>(campaign.id == id ? campaign : null);

  @override
  Future<Result<void>> join(int id) async {
    joinCalls++;
    return const Success<void>(null);
  }
}
