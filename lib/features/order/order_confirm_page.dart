import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'application/order_confirm_controller.dart';
import 'application/order_draft_seed.dart';
import 'domain/domain.dart';
import '../goods/seatmap/seat_selection_providers.dart';
import 'widgets/selected_seats_section.dart';
import '../../l10n/l10n.dart';
import 'order_l10n.dart';

/// 确认订单页。
///
/// 页面是**纯展示**：所有金额来自 [OrderConfirmState.displayQuote]
/// （服务端报价优先、领域服务预演兜底），所有校验来自聚合返回的 `Result`。
/// 页面自己不做任何业务判断——
/// 这与企划星 `OrderConfirmActivity`（2,633 行，金额/校验/埋点/跳转混在一起）相反。
class OrderConfirmPage extends ConsumerWidget {
  const OrderConfirmPage({super.key, this.showId = '10086'});

  /// 演出 id（从路由 query 来；缺省时用演示值）。
  final String showId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderConfirmControllerProvider(showId));
    final seed = ref.watch(orderDraftSeedProvider(showId));
    // 选座结果：与选座页共享同一个 provider family，座位对象完整传递。
    final selectedSeats = ref
        .watch(seatSelectionProvider(showId))
        .selectedSeats;
    final controller = ref.read(
      orderConfirmControllerProvider(showId).notifier,
    );
    final theme = Theme.of(context);

    // 提交成功后跳转到支付页。
    // 用 ref.listen 而不是在 build 里直接 go：直接 go 会在 build 期间触发路由。
    ref.listen<OrderConfirmState>(orderConfirmControllerProvider(showId), (
      previous,
      next,
    ) {
      if (previous != null && !previous.submitted && next.submitted) {
        final number = next.placedOrderNumber ?? next.order.number.value;
        context.go(
          '/order/pay'
          '?number=${Uri.encodeComponent(number)}'
          '&amount=${next.displayQuote.paymentAmount.minorUnits}'
          '&title=${Uri.encodeComponent(seed.showTitle)}',
        );
      }
    });

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: context.l10n.orderConfirmPage_48),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: <Widget>[
                _ShowHeader(seed: seed),
                SelectedSeatsSection(seats: selectedSeats),
                if (state.notice != null)
                  _NoticeBar(
                    message: state.notice!.messageOf(context),
                    onDismiss: controller.dismissNotice,
                  ),
                _Section(
                  title: context.l10n.orderConfirmPage_59,
                  child: Column(
                    children: <Widget>[
                      for (final offer in seed.tiers)
                        _TierRow(
                          offer: offer,
                          quantity: _quantityOf(state.order, offer.id),
                          onIncrease: () => controller.increase(offer.id),
                          onDecrease: () => controller.decrease(offer.id),
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: context.l10n.orderConfirmPage_73,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _ChoiceChip(
                        label: context.l10n.orderConfirmPage_79,
                        selected: state.order.discount is NoDiscount,
                        onSelected: controller.clearDiscount,
                      ),
                      if (seed.availableCampaign != null)
                        _ChoiceChip(
                          label: seed.availableCampaign!.describeOf(context),
                          selected: state.order.discount is CampaignSelection,
                          onSelected: controller.selectCampaign,
                        ),
                      if (seed.availableCoupon != null)
                        _ChoiceChip(
                          label: seed.availableCoupon!.describeOf(context),
                          selected: state.order.discount is CouponSelection,
                          onSelected: controller.selectCoupon,
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: context.l10n.orderConfirmPage_99,
                  child: Column(
                    children: <Widget>[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          seed.giftCard == null
                              ? context.l10n.orderConfirmPage_107
                              : context.l10n.orderConfirmPage_109(
                                  seed.giftCard!.balance.format(),
                                ),
                        ),
                        value: state.order.giftCard != null,
                        onChanged: seed.giftCard == null
                            ? null
                            : (enabled) => enabled
                                  ? controller.useGiftCard()
                                  : controller.clearGiftCard(),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          seed.speedPackUnitPrice == null
                              ? context.l10n.orderConfirmPage_123
                              : context.l10n.orderConfirmPage_125(
                                  seed.speedPackUnitPrice!.format(),
                                ),
                        ),
                        value: state.order.speedPack != null,
                        onChanged: seed.speedPackUnitPrice == null
                            ? null
                            : (enabled) => enabled
                                  ? controller.buySpeedPack()
                                  : controller.clearSpeedPack(),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: context.l10n.orderConfirmPage_138,
                  trailing: TextButton(
                    onPressed: controller.assignDemoVisitor,
                    child: Text(
                      state.order.visitors.isEmpty
                          ? context.l10n.orderConfirmPage_143(
                              state.order.requiredVisitorCount,
                            )
                          : context.l10n.orderConfirmPage_145(
                              state.order.visitors.length,
                            ),
                    ),
                  ),
                  child: state.order.visitors.isEmpty
                      ? Text(
                          context.l10n.orderConfirmPage_150,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            for (final visitor in state.order.visitors)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  '${visitor.name} · ${visitor.idCard}',
                                ),
                              ),
                          ],
                        ),
                ),
                _Section(
                  title: context.l10n.orderConfirmPage_167,
                  child: Column(
                    children: <Widget>[
                      for (final line in state.displayQuote.breakdown)
                        _AmountRow(
                          label: line.labelOf(context),
                          value: line.amount.format(),
                        ),
                      const Divider(height: 20),
                      _AmountRow(
                        label: context.l10n.orderConfirmPage_173,
                        value: state.displayQuote.totalAmount.format(),
                      ),
                      _AmountRow(
                        label: context.l10n.orderConfirmPage_175,
                        value: state.displayQuote.paymentAmount.format(),
                        emphasized: true,
                      ),
                    ],
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  // ⚠ 默认不勾：企划星默认勾选是合规问题（M5-01）。
                  value: state.order.agreementAccepted,
                  onChanged: state.order.isEditable
                      ? (_) => controller.toggleAgreement()
                      : null,
                  title: Text(
                    context.l10n.orderConfirmPage_190(
                      state.order.buyType.agreementTitleOf(context),
                    ),
                  ),
                ),
                if (state.recentEvents.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      context.l10n.orderConfirmPage_196(
                        state.recentEvents.join(' → '),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          _SubmitBar(
            payable: state.displayQuote.paymentAmount,
            enabled: state.canSubmit,
            submitting: state.submitting,
            submitted: state.submitted,
            onSubmit: controller.submit,
          ),
        ],
      ),
    );
  }

  static int _quantityOf(TicketOrder order, TicketTierId tierId) {
    for (final line in order.lines) {
      if (line.id == tierId) return line.quantity.value;
    }
    return 0;
  }
}

class _ShowHeader extends StatelessWidget {
  const _ShowHeader({required this.seed});

  final OrderDraftSeed seed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(seed.showTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '${seed.sessionLabel} · 演出 ${seed.showId.value}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title, style: theme.textTheme.titleSmall),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.offer,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  final TicketTierOffer offer;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(offer.name),
                Text(offer.price.format(), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            onPressed: quantity > 0 ? onDecrease : null,
            icon: const Icon(LucideIcons.circleMinus),
          ),
          SizedBox(
            width: 28,
            child: Text('$quantity', textAlign: TextAlign.center),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(LucideIcons.circlePlus),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasized
        ? theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          )
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _NoticeBar extends StatelessWidget {
  const _NoticeBar({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(LucideIcons.x, size: 16),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.payable,
    required this.enabled,
    required this.submitting,
    required this.submitted,
    required this.onSubmit,
  });

  final Money payable;
  final bool enabled;
  final bool submitting;
  final bool submitted;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    context.l10n.orderConfirmPage_175,
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    payable.format(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            AdaptiveButton(
              label: submitted
                  ? context.l10n.orderConfirmPage_457
                  : submitting
                  ? context.l10n.orderConfirmPage_460
                  : context.l10n.orderConfirmPage_462,
              onPressed: enabled ? () => onSubmit() : null,
            ),
          ],
        ),
      ),
    );
  }
}
