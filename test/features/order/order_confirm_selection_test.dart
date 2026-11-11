import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/app/network/network_providers.dart';
import 'package:planstar/features/order/application/order_confirm_controller.dart';
import 'package:planstar/features/order/application/order_confirm_selection.dart';
import 'package:planstar/features/order/domain/domain.dart';

/// 回归测试：回报档位选择页的参数必须真正进入确认页草稿，
/// 且提交过程与提交失败后的聚合状态必须一致、可重试。
void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: <Override>[useDemoProvider.overrideWithValue(true)],
    );
    addTearDown(container.dispose);
    return container;
  }

  OrderConfirmArgs argsOf([OrderConfirmSelection? selection]) =>
      OrderConfirmArgs(
        showId: '10086',
        selection: selection ?? const OrderConfirmSelection(),
      );

  OrderConfirmState stateOf(
    ProviderContainer container, [
    OrderConfirmSelection? selection,
  ]) => container.read(orderConfirmControllerProvider(argsOf(selection)));

  OrderConfirmController controllerOf(
    ProviderContainer container, [
    OrderConfirmSelection? selection,
  ]) => container.read(
    orderConfirmControllerProvider(argsOf(selection)).notifier,
  );

  group('选票页参数透传（P0-08）', () {
    test('未传参数：保持原有「首个票档 1 张」行为', () {
      final container = makeContainer();
      final state = stateOf(container);

      expect(state.order.lines.single.id, const TicketTierId('tier-1'));
      expect(state.order.totalTickets, Quantity(1));
      expect(state.quote.paymentAmount, Money.fromYuan(680));
    });

    test('tier=1 & qty=2 → 内场 B 区 2 张，共 1160', () {
      final container = makeContainer();
      final state = stateOf(
        container,
        const OrderConfirmSelection(tierIndex: 1, quantity: 2),
      );

      expect(state.order.lines.single.id, const TicketTierId('tier-2'));
      expect(state.order.totalTickets, Quantity(2));
      expect(state.quote.paymentAmount, Money.fromYuan(1160));
    });

    test('不同选择是独立缓存实例，互不串数据', () {
      final container = makeContainer();
      final a = stateOf(
        container,
        const OrderConfirmSelection(tierIndex: 0, quantity: 1),
      );
      final b = stateOf(
        container,
        const OrderConfirmSelection(tierIndex: 2, quantity: 3),
      );

      expect(a.quote.paymentAmount, Money.fromYuan(680));
      expect(b.order.lines.single.id, const TicketTierId('tier-3'));
      expect(b.quote.paymentAmount, Money.fromYuan(1140));
    });

    test('越界票档回退首个，避免深链参数导致越界崩溃', () {
      final container = makeContainer();
      final state = stateOf(
        container,
        const OrderConfirmSelection(tierIndex: 99, quantity: 1),
      );

      expect(state.order.lines.single.id, const TicketTierId('tier-1'));
      expect(state.quote.paymentAmount, Money.fromYuan(680));
    });

    test('qty 超过限购按 maxPerOrder 收敛（demo 上限 6）', () {
      final container = makeContainer();
      final state = stateOf(
        container,
        const OrderConfirmSelection(tierIndex: 0, quantity: 99),
      );

      expect(state.order.totalTickets, Quantity(6));
      expect(state.quote.paymentAmount, Money.fromYuan(4080));
    });

    test('非法 qty（0 / 负数）回退 1 张', () {
      final container = makeContainer();
      expect(
        stateOf(
          container,
          const OrderConfirmSelection(tierIndex: 0, quantity: -3),
        ).order.totalTickets,
        Quantity(1),
      );
    });
  });

  group('提交链路一致性（P0-09）', () {
    test('提交进行中禁止改数量，避免「页面一个价、请求另一个价」', () async {
      final container = makeContainer();
      final controller = controllerOf(container);
      controller.toggleAgreement();

      final pending = controller.submit();
      // submit 已置 submitting=true 并在 await 仓储保存处挂起。
      expect(stateOf(container).submitting, isTrue);
      controller.increase(const TicketTierId('tier-1'));

      expect(stateOf(container).order.totalTickets, Quantity(1));
      await pending;
    });

    test('reopenForRetry 回滚聚合：恢复可编辑且丢弃幽灵事件', () async {
      final container = makeContainer();
      final controller = controllerOf(container);
      controller.toggleAgreement();
      await controller.submit();

      final order = stateOf(container).order;
      expect(order.status, OrderStatus.awaitingPayment);
      expect(order.isEditable, isFalse);

      final result = order.reopenForRetry();
      expect(result.isSuccess, isTrue);
      expect(order.status, OrderStatus.draft);
      expect(order.isEditable, isTrue);
      expect(order.hasDomainEvents, isFalse);
      // 回滚后仍持有有效报价，可在当前页直接重试。
      expect(order.quote, isNotNull);
      expect(order.agreementAccepted, isTrue);
    });
  });
}
