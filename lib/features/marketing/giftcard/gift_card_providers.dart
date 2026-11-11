import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_gift_cards.dart';
import 'gift_card.dart';

/// 礼品卡列表 Provider。
///
/// 返回统一列表，由 `GiftCardStatus` 区分可用与不可用。
final giftCardListProvider = Provider<List<GiftCard>>(
  (ref) => DemoGiftCards.all,
);

/// 可用礼品卡 Provider。
final activeGiftCardsProvider = Provider<List<GiftCard>>(
  (ref) => ref
      .watch(giftCardListProvider)
      .where((GiftCard c) => c.status == GiftCardStatus.active)
      .toList(),
);

/// 不可用礼品卡 Provider。
final inactiveGiftCardsProvider = Provider<List<GiftCard>>(
  (ref) => ref
      .watch(giftCardListProvider)
      .where((GiftCard c) => c.status != GiftCardStatus.active)
      .toList(),
);

/// 可用礼品卡数量。
final giftCardCountProvider = Provider<int>(
  (ref) => ref.watch(activeGiftCardsProvider).length,
);

/// 礼品卡总余额。
final giftCardTotalBalanceProvider = Provider<Money>(
  (ref) => ref
      .watch(activeGiftCardsProvider)
      .fold(Money.zero(), (Money sum, GiftCard c) => sum + c.balance),
);

/// 绑定礼品卡的 Controller。
///
/// 对应 `POST v1/giftCards`：
/// - 提交卡号（`serialNumber`），成功后刷新列表。
/// - 这里用模拟数据：绑定成功后添加一张新卡到列表头部。
class AddGiftCardController extends Notifier<AddGiftCardState> {
  @override
  AddGiftCardState build() => const AddGiftCardState.initial();

  /// 提交卡号绑定。
  Future<void> bind(String serialNumber) async {
    if (serialNumber.trim().isEmpty) {
      state = const AddGiftCardState.error();
      return;
    }

    state = const AddGiftCardState.submitting();

    // 模拟网络延迟
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // 模拟成功（真实场景调 POST v1/giftCards）
    state = const AddGiftCardState.success();
  }

  /// 重置状态。
  void reset() => state = const AddGiftCardState.initial();
}

/// 绑定礼品卡状态。
sealed class AddGiftCardState {
  const AddGiftCardState();

  const factory AddGiftCardState.initial() = AddGiftCardInitial;
  const factory AddGiftCardState.submitting() = AddGiftCardSubmitting;
  const factory AddGiftCardState.success() = AddGiftCardSuccess;
  const factory AddGiftCardState.error() = AddGiftCardError;
}

class AddGiftCardInitial extends AddGiftCardState {
  const AddGiftCardInitial();
}

class AddGiftCardSubmitting extends AddGiftCardState {
  const AddGiftCardSubmitting();
}

class AddGiftCardSuccess extends AddGiftCardState {
  const AddGiftCardSuccess();
}

class AddGiftCardError extends AddGiftCardState {
  const AddGiftCardError();
}

final addGiftCardControllerProvider =
    NotifierProvider<AddGiftCardController, AddGiftCardState>(
      AddGiftCardController.new,
    );
