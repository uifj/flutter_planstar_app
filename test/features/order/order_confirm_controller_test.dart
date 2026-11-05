import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planstar/features/order/application/order_confirm_controller.dart';
import 'package:planstar/features/order/application/order_providers.dart';
import 'package:planstar/features/order/data/in_memory_ticket_order_repository.dart';
import 'package:planstar/features/order/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// 应用层测试：**不建 Widget 树**，直接驱动控制器。
///
/// 这本身就是分层带来的收益——企划星的确认页逻辑长在 Activity 里，
/// 想测"改数量后金额对不对"必须先跑起整个页面。
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  OrderConfirmController controller() =>
      container.read(orderConfirmControllerProvider('10086').notifier);

  OrderConfirmState state() => container.read(orderConfirmControllerProvider('10086'));

  group('确认页控制器', () {
    test('初始状态：1 张内场 A 区，应付 ¥680.00，协议未勾', () {
      final current = state();

      expect(current.order.lines, hasLength(1));
      expect(current.order.lines.single.quantity, Quantity(1));
      expect(current.quote.paymentAmount, Money.fromYuan(680));
      expect(current.order.agreementAccepted, isFalse);
      expect(current.canSubmit, isFalse, reason: '没勾协议不能提交');
      expect(current.order.requiredVisitorCount, 1);
    });

    test('选优惠券：应付 −50', () {
      controller().selectCoupon();
      expect(state().order.discount, isA<CouponSelection>());
      expect(state().quote.paymentAmount, Money.fromYuan(630));
    });

    test('选营销活动：9 折封顶 100 → 减 68', () {
      controller().selectCampaign();
      expect(state().quote.discountApplied, Money.fromYuan(68));
      expect(state().quote.paymentAmount, Money.fromYuan(612));
    });

    test('券与活动互斥：后选的覆盖前一个', () {
      controller()
        ..selectCampaign()
        ..selectCoupon();
      expect(state().order.discount, isA<CouponSelection>());

      controller().selectCampaign();
      expect(state().order.discount, isA<CampaignSelection>());
    });

    test('礼品卡：余额 200 全部抵扣', () {
      controller().useGiftCard();
      expect(state().quote.giftCardApplied, Money.fromYuan(200));
      expect(state().quote.paymentAmount, Money.fromYuan(480));
    });

    test('加速包：余额 30 抵扣掉，现金部分 0', () {
      controller().buySpeedPack();
      final quote = state().quote;
      expect(quote.speedPackCash, Money.zero());
      expect(quote.speedPackBalance, Money.fromYuan(30));
      expect(quote.paymentAmount, Money.fromYuan(680));
    });

    test('加数量到 7 张被限购拒绝，并给出可读原因', () {
      for (var i = 0; i < 6; i++) {
        controller().increase(const TicketTierId('tier-1'));
      }
      expect(state().notice, contains('每单最多购买 6 张'));
      expect(state().order.totalTickets, Quantity(6));
    });

    test('减到 0 张：应付归零，且不能提交', () {
      controller().decrease(const TicketTierId('tier-1'));
      expect(state().order.lines, isEmpty);
      expect(state().quote.paymentAmount, Money.zero());
      expect(state().canSubmit, isFalse);
    });

    test('未选观演人时提交被聚合拒绝', () async {
      controller()
        ..toggleAgreement()
        ..selectCoupon();

      await controller().submit();

      expect(state().submitted, isFalse);
      expect(state().notice, contains('请选择 1 位观演人'));
      expect(state().order.status, OrderStatus.draft, reason: '失败不应改状态');
    });

    test('完整提交：状态迁移 + 落库 + 领域事件分发', () async {
      controller()
        ..selectCoupon()
        ..toggleAgreement()
        ..assignDemoVisitor();

      expect(state().canSubmit, isTrue);

      final TicketOrderRepository repository =
          container.read(ticketOrderRepositoryProvider);
      expect(repository, isA<InMemoryTicketOrderRepository>());
      final memory = repository as InMemoryTicketOrderRepository;
      // 仓储不是空的：`ticketOrderRepositoryProvider` 会
      // `seed(buildDemoOrderHistory())` 预置演示历史单。所以这里断言的是
      // **增量**（提交恰好落库 1 单），而不是写死总数——写死总数会在演示
      // 数据增减时莫名其妙地红。
      final before = memory.count;

      await controller().submit();

      final after = state();
      expect(after.submitted, isTrue);
      expect(after.order.status, OrderStatus.awaitingPayment);
      expect(after.notice, contains('订单已提交'));
      expect(after.recentEvents, contains('order.placed'));

      expect(memory.count, before + 1);
    });

    test('提交后页面进入只读态', () async {
      controller()
        ..toggleAgreement()
        ..assignDemoVisitor();
      await controller().submit();

      expect(state().order.isEditable, isFalse);
      expect(state().canSubmit, isFalse);
    });
  });
}
