import 'dart:async';

import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../../shared/ui/ps_poster.dart';
import '../../../shared/ui/ps_price.dart';
import '../../../shared/ui/ps_tag.dart';
import '../../catalog/domain/show_summary.dart';
import '../../catalog/ui/catalog_l10n.dart';
import '../order_l10n.dart';
import '../domain/domain.dart';
import '../../../l10n/l10n.dart';

/// 支持卡片（`item_order_ticket.xml`）。
///
/// 结构：14dp 内边距的白卡 →
/// 标题行（16dp 标题 + 可选「代支持」标 + 右侧 12dp 品牌色状态）→
/// 58×76 海报 + 右侧描述区 → 1dp 分隔线（上边距 16）→
/// 46dp 的金额 / 按钮行。
///
/// 金额在企划星是 14dp `text_2` 的灰字。这里把"支持金额"几个字保持灰色、
/// 数字改用价格色 16dp 加粗——支持卡上最该被一眼看到的数字是支持金额，
/// 灰掉它是可读性问题，属于刻意改动。
class OrderListCard extends StatelessWidget {
  const OrderListCard({
    super.key,
    required this.order,
    required this.show,
    this.onTap,
    this.onPay,
    this.onCancel,
    this.onConfirmReceipt,
    this.onReview,
    this.onBuyAgain,
    this.onContactService,
  });

  final TicketOrder order;

  /// 关联企划（标题 / 交付信息 / 海报都从这里取）。
  final ShowSummary? show;

  final VoidCallback? onTap;
  final VoidCallback? onPay;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirmReceipt;
  final VoidCallback? onReview;
  final VoidCallback? onBuyAgain;
  final VoidCallback? onContactService;

  /// 企划默认展示预计交付时间；线下回报场次型企划保留场次信息。
  String _deliveryLabel(BuildContext context) {
    final show = this.show;
    if (show == null) {
      return context.l10n.orderListCard_53;
    }
    if (!show.isProject) {
      return show.firstSessionLabelOf(context);
    }
    for (final line in order.lines) {
      for (final tier in show.tiers) {
        if (tier.name != line.tierName) {
          continue;
        }
        if (tier.rewardType == '线下参与') {
          return show.firstSessionLabelOf(context);
        }
        if (tier.estimatedDeliveryTime.isNotEmpty) {
          return context.l10n.orderListCard_delivery(
            tier.estimatedDeliveryTime,
          );
        }
      }
    }
    if (show.deliveryPlan.isNotEmpty) {
      return context.l10n.orderListCard_delivery(show.deliveryPlan);
    }
    return context.l10n.orderListCard_53;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final title =
        show?.title ?? context.l10n.orderListCard_52(order.showId.value);
    final deliveryLabel = _deliveryLabel(context);
    final payable = order.quote?.paymentAmount;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        color: colors.bgCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.2,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (order.buyType == BuyType.proxy) ...<Widget>[
                  const SizedBox(width: 8),
                  PsTag(
                    label: context.l10n.orderListCard_78,
                    tone: PsTagTone.outline,
                    fontSize: 10,
                  ),
                ],
                const Spacer(),
                Text(
                  order.status.labelOf(context),
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    color: order.status.unpaid ? colors.price : colors.brand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PsPoster(
                  seed: title,
                  width: 58,
                  height: 76,
                  radius: 4,
                  dimmed: order.status == OrderStatus.cancelled,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        deliveryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      for (final line in order.lines)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${line.tierName} × ${line.quantity.value}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                      if (order.visitors.isNotEmpty)
                        Text(
                          context.l10n.orderListCard_130(
                            order.visitors.map((v) => v.name).join('、'),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: colors.textTertiary,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.orderListCard_141(order.number.value),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textDisabled,
                        ),
                      ),
                      if (order.status == OrderStatus.awaitingPayment)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _PaymentCountdown(deadline: order.payDeadline),
                        ),
                      if (order.status == OrderStatus.cancelled &&
                          order.cancelReason != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            order.cancelReason!.labelOf(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textDisabled,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(height: 1, color: colors.divider),
            ),
            SizedBox(
              height: 46,
              child: Row(
                children: <Widget>[
                  // 左侧「共 N 张 实付 + 金额」必须能收缩：按钮是按状态给的，
                  // 「查看物流 + 确认收货」这种两枚四字胶囊已经吃掉 160dp，
                  // 剩下的宽度在 360dp 屏上装不下不收缩的金额行（实测溢出 8~21px）。
                  // 来源 `item_order_ticket.xml` 同样是左文字 + 右按钮固定，
                  // 超出直接裁掉；这里让金额等比缩，信息不丢。
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            context.l10n.orderListCard_184(
                              order.totalTickets.value,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (payable != null)
                          Flexible(child: PsPrice(amount: payable, size: 16))
                        else
                          Text(
                            '—',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ..._buttons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 按状态给按钮——和企划星 `OrderItemBtnClickEvent` 的按钮矩阵一致。
  List<Widget> _buttons(BuildContext context) {
    switch (order.status) {
      case OrderStatus.draft:
      case OrderStatus.awaitingPayment:
        return <Widget>[
          if (onCancel != null)
            _OrderButton(
              label: context.l10n.orderListCard_217,
              onTap: onCancel,
            ),
          if (onPay != null) ...<Widget>[
            const SizedBox(width: 8),
            _OrderButton(
              label: context.l10n.orderListCard_220,
              primary: true,
              onTap: onPay,
            ),
          ],
        ];
      case OrderStatus.awaitingTickets:
        return <Widget>[
          if (onContactService != null)
            _OrderButton(
              label: context.l10n.orderListCard_225,
              onTap: onContactService,
            ),
          if (onCancel != null) ...<Widget>[
            const SizedBox(width: 8),
            _OrderButton(
              label: context.l10n.orderListCard_228,
              onTap: onCancel,
            ),
          ],
        ];
      case OrderStatus.ticketsInTransit:
        return <Widget>[
          if (onContactService != null)
            _OrderButton(
              label: context.l10n.orderListCard_233,
              onTap: onContactService,
            ),
          if (onConfirmReceipt != null) ...<Widget>[
            const SizedBox(width: 8),
            _OrderButton(
              label: context.l10n.orderListCard_236,
              primary: true,
              onTap: onConfirmReceipt,
            ),
          ],
        ];
      case OrderStatus.completed:
        return <Widget>[
          if (onBuyAgain != null)
            _OrderButton(
              label: context.l10n.orderListCard_241,
              onTap: onBuyAgain,
            ),
          if (onReview != null) ...<Widget>[
            const SizedBox(width: 8),
            _OrderButton(
              label: context.l10n.orderListCard_244,
              primary: true,
              onTap: onReview,
            ),
          ],
        ];
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return <Widget>[
          if (onBuyAgain != null)
            _OrderButton(
              label: context.l10n.orderListCard_250,
              onTap: onBuyAgain,
            ),
        ];
    }
  }
}

/// 支付倒计时（`剩余支付时间 05:12`）。
///
/// 只有「待付款」订单会创建定时器——放在列表页统一计时会让整页每秒重建。
class _PaymentCountdown extends StatefulWidget {
  const _PaymentCountdown({required this.deadline});

  final DateTime deadline;

  @override
  State<_PaymentCountdown> createState() => _PaymentCountdownState();
}

class _PaymentCountdownState extends State<_PaymentCountdown> {
  Timer? _timer;
  late Duration _left = _remaining();

  Duration _remaining() {
    final left = widget.deadline.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _left = _remaining());
      if (_left == Duration.zero) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    if (_left == Duration.zero) {
      return Text(
        context.l10n.orderListCard_298,
        style: TextStyle(fontSize: 11, color: colors.textDisabled),
      );
    }
    final minutes = _left.inMinutes.toString().padLeft(2, '0');
    final seconds = (_left.inSeconds % 60).toString().padLeft(2, '0');
    return Text(
      context.l10n.orderListCard_305(minutes, seconds),
      style: TextStyle(fontSize: 11, color: colors.price),
    );
  }
}

/// 订单卡上的小按钮（28dp 高、圆角 14、描边或实心）。
class _OrderButton extends StatelessWidget {
  const _OrderButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? colors.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: primary ? null : Border.all(color: colors.border, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 1.1,
            color: primary ? colors.onBrand : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
