import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_group_buy.dart';
import 'group_buy.dart';

/// 拼团列表 Provider。
/// 对齐 Android `v1/pinTuanOrder/myOrders`（模拟）。
final groupBuyListProvider = Provider<List<GroupBuyInfo>>(
  (ref) => DemoGroupBuy.campaigns,
);

/// 拼团详情 Provider（按 ID）。
/// 对齐 Android `v1/pinTuanCampaign/{id}`。
final groupBuyByIdProvider = Provider.family<GroupBuyInfo?, int>((ref, id) {
  final list = ref.watch(groupBuyListProvider);
  return list.where((GroupBuyInfo g) => g.id == id).firstOrNull;
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
/// 对齐 Android `POST v1/pinTuanOrder/make`（模拟）。
class JoinGroupController extends Notifier<JoinGroupState> {
  @override
  JoinGroupState build() => const JoinGroupState.initial();

  Future<void> join(int groupId) async {
    state = const JoinGroupState.submitting();

    await Future<void>.delayed(const Duration(milliseconds: 800));

    state = const JoinGroupState.success();
  }

  void reset() => state = const JoinGroupState.initial();
}

final joinGroupControllerProvider =
    NotifierProvider<JoinGroupController, JoinGroupState>(
      JoinGroupController.new,
    );
