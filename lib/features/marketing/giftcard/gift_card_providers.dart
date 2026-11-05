import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_gift_cards.dart';
import 'gift_card.dart';

/// 礼品卡列表 Provider。
///
/// 对齐 Android `GiftCardService.fetchGiftCards()` → `GiftCardInfo`：
/// - Android 返回 `enableGiftCards` + `disableGiftCards`。
/// - 这里返回统一列表，由 `GiftCardStatus` 区分。
final giftCardListProvider =
    Provider<List<GiftCard>>((ref) => DemoGiftCards.all);

/// 可用礼品卡 Provider。
final activeGiftCardsProvider = Provider<List<GiftCard>>(
  (ref) => ref.watch(giftCardListProvider).where(
        (GiftCard c) => c.status == GiftCardStatus.active,
      ).toList(),
);

/// 不可用礼品卡 Provider。
final inactiveGiftCardsProvider = Provider<List<GiftCard>>(
  (ref) => ref.watch(giftCardListProvider).where(
        (GiftCard c) => c.status != GiftCardStatus.active,
      ).toList(),
);

/// 可用礼品卡数量。
final giftCardCountProvider = Provider<int>(
  (ref) => ref.watch(activeGiftCardsProvider).length,
);

/// 礼品卡总余额。
final giftCardTotalBalanceProvider = Provider<Money>(
  (ref) => ref.watch(activeGiftCardsProvider).fold(
        Money.zero(),
        (Money sum, GiftCard c) => sum + c.balance,
      ),
);

/// 绑定礼品卡的 Controller。
///
/// 对齐 Android `AddGiftCardActivity` → `POST v1/giftCards`：
/// - 提交卡号（`serialNumber`），成功后刷新列表。
/// - 这里用模拟数据：绑定成功后添加一张新卡到列表头部。
class AddGiftCardController extends Notifier<AddGiftCardState> {
  @override
  AddGiftCardState build() => const AddGiftCardState.initial();

  /// 提交卡号绑定。
  Future<void> bind(String serialNumber) async {
    if (serialNumber.trim().isEmpty) {
      state = const AddGiftCardState.error('请输入礼品卡卡号');
      return;
    }

    state = const AddGiftCardState.submitting();

    // 模拟网络延迟
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // 模拟成功（真实场景调 POST v1/giftCards）
    state = AddGiftCardState.success(
      '礼品卡绑定成功，已添加 ¥200 余额',
    );
  }

  /// 重置状态。
  void reset() => state = const AddGiftCardState.initial();
}

/// 绑定礼品卡状态。
sealed class AddGiftCardState {
  const AddGiftCardState();

  const factory AddGiftCardState.initial() = AddGiftCardInitial;
  const factory AddGiftCardState.submitting() = AddGiftCardSubmitting;
  const factory AddGiftCardState.success(String message) = AddGiftCardSuccess;
  const factory AddGiftCardState.error(String message) = AddGiftCardError;
}

class AddGiftCardInitial extends AddGiftCardState {
  const AddGiftCardInitial();
}

class AddGiftCardSubmitting extends AddGiftCardState {
  const AddGiftCardSubmitting();
}

class AddGiftCardSuccess extends AddGiftCardState {
  const AddGiftCardSuccess(this.message);
  final String message;
}

class AddGiftCardError extends AddGiftCardState {
  const AddGiftCardError(this.message);
  final String message;
}

final addGiftCardControllerProvider =
    NotifierProvider<AddGiftCardController, AddGiftCardState>(
  AddGiftCardController.new,
);
