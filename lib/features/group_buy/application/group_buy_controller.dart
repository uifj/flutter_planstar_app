import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/demo_group_buy_repository.dart';
import '../data/remote_group_buy_repository.dart';
import '../domain/group_buy.dart';
import '../domain/repositories/group_buy_repository.dart';
import '../domain/services/group_buy_pricing.dart';
import '../domain/services/group_buy_progress.dart';

/// 拼团仓储：演示 / 真实数据源由全局 [DataSourcePolicy] 决定。
final groupBuyRepositoryProvider = Provider<GroupBuyRepository>((ref) {
  final policy = ref.watch(dataSourcePolicyProvider);
  return policy.pick(
    demo: DemoGroupBuyRepository.new,
    remote: () =>
        RemoteGroupBuyRepository(client: ref.watch(apiClientProvider)),
  );
});

/// 拼团卡片/详情页的视图状态：进度、价格都在这里算好，页面只渲染。
final class GroupBuyView {
  const GroupBuyView({
    required this.info,
    required this.progress,
    required this.hasDiscount,
    required this.savedAmount,
    required this.discountRate,
  });

  final GroupBuyInfo info;
  final GroupBuyProgress progress;
  final bool hasDiscount;
  final Money savedAmount;

  /// 折扣档位；无折扣为 `null`。
  final int? discountRate;
}

const GroupBuyProgressPolicy _progressPolicy = GroupBuyProgressPolicy();
const GroupBuyPricing _pricing = GroupBuyPricing();

/// 把领域实体装配成视图状态。
GroupBuyView buildGroupBuyView(GroupBuyInfo info, {required DateTime now}) {
  return GroupBuyView(
    info: info,
    progress: _progressPolicy.evaluate(info, now: now),
    hasDiscount: _pricing.hasDiscount(info),
    savedAmount: _pricing.savedAmount(info),
    discountRate: _pricing.discountRate(info),
  );
}

/// 拼团列表。
class GroupBuyListController extends AsyncNotifier<List<GroupBuyView>> {
  @override
  Future<List<GroupBuyView>> build() async {
    final repository = ref.watch(groupBuyRepositoryProvider);
    final campaigns = (await repository.fetchCampaigns()).fold(
      onSuccess: (List<GroupBuyInfo> value) => value,
      onFailure: (failure) => throw failure,
    );
    final DateTime now = DateTime.now();
    return campaigns
        .map((GroupBuyInfo info) => buildGroupBuyView(info, now: now))
        .toList(growable: false);
  }
}

final groupBuyListProvider =
    AsyncNotifierProvider<GroupBuyListController, List<GroupBuyView>>(
      GroupBuyListController.new,
    );

/// 拼团详情（按 ID）；不存在返回 `null`。
final groupBuyByIdProvider = FutureProvider.family<GroupBuyView?, int>((
  ref,
  id,
) async {
  final repository = ref.watch(groupBuyRepositoryProvider);
  final info = (await repository.fetchCampaign(id)).fold(
    onSuccess: (GroupBuyInfo? value) => value,
    onFailure: (failure) => throw failure,
  );
  if (info == null) return null;
  return buildGroupBuyView(info, now: DateTime.now());
});

/// 参团状态。
sealed class JoinGroupState {
  const JoinGroupState();
  const factory JoinGroupState.initial() = JoinGroupInitial;
  const factory JoinGroupState.submitting() = JoinGroupSubmitting;
  const factory JoinGroupState.success() = JoinGroupSuccess;
  const factory JoinGroupState.error(String message) = JoinGroupError;
}

class JoinGroupInitial extends JoinGroupState {
  const JoinGroupInitial();
}

class JoinGroupSubmitting extends JoinGroupState {
  const JoinGroupSubmitting();
}

class JoinGroupSuccess extends JoinGroupState {
  const JoinGroupSuccess();
}

class JoinGroupError extends JoinGroupState {
  const JoinGroupError(this.message);
  final String message;
}

/// 参团 Controller。
///
/// 状态 / 过期 / 满团 / 库存校验走领域策略；请求走仓储；页面只转发点击。
class JoinGroupController extends Notifier<JoinGroupState> {
  @override
  JoinGroupState build() => const JoinGroupState.initial();

  Future<void> join(int groupId) async {
    state = const JoinGroupState.submitting();

    final GroupBuyView? view = await ref.read(
      groupBuyByIdProvider(groupId).future,
    );
    if (view == null) {
      state = const JoinGroupState.error('拼团活动不存在');
      return;
    }
    final GroupBuyJoinBlock block = view.progress.block;
    if (block != GroupBuyJoinBlock.none) {
      state = JoinGroupState.error(_messageOf(block));
      return;
    }

    final result = await ref.read(groupBuyRepositoryProvider).join(groupId);
    result.fold(
      onSuccess: (_) {
        state = const JoinGroupState.success();
        ref.invalidate(groupBuyListProvider);
        ref.invalidate(groupBuyByIdProvider(groupId));
      },
      onFailure: (failure) => state = JoinGroupState.error(failure.message),
    );
  }

  void reset() => state = const JoinGroupState.initial();

  static String _messageOf(GroupBuyJoinBlock block) => switch (block) {
    GroupBuyJoinBlock.none => '',
    GroupBuyJoinBlock.notGrouping => '当前拼团不可参与',
    GroupBuyJoinBlock.full => '拼团已满员',
    GroupBuyJoinBlock.expired => '拼团已过期',
    GroupBuyJoinBlock.outOfStock => '库存不足，无法参团',
  };
}

final joinGroupControllerProvider =
    NotifierProvider<JoinGroupController, JoinGroupState>(
      JoinGroupController.new,
    );
