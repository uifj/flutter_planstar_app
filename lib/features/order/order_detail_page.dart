import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import '../../shared/ui/ps_poster.dart';
import '../../shared/ui/ps_tag.dart';
import '../catalog/application/catalog_providers.dart';
import '../catalog/domain/show_summary.dart';
import 'application/order_list_controller.dart';
import 'domain/domain.dart';
import 'widgets/payment_channel_sheet.dart';

/// 订单详情页（企划星 `MyOrderActivity` 的详情 + `OrderDetailWebFragment` 的原生化）。
///
/// ## 为什么从面板改成独立页
///
/// 订单列表原本用一个 `_OrderDetailSheet` 底部面板展示详情。面板的问题不是
/// 样式，而是**装不下**：完整详情有状态头、演出、票档、观演人、取票方式、
/// 金额明细、订单信息七段，塞进半屏面板只能滚动，且返回手势与列表滚动冲突。
/// 企划星在 Android 侧也是独立 Activity（`OrderDetailWebActivity` 走 H5，
/// 原生详情在 `MyOrderActivity` 里）。
///
/// ## 数据来源
///
/// 通过订单号从 [orderByNumberProvider] 取——**与列表页同一个 provider**，
/// 所以详情里点了「确认收货」，返回列表时状态已经变了，不会出现
/// "详情显示已收货、列表还显示待收货"。
///
/// ## 状态驱动，而不是 if 判断
///
/// 底部按钮组由 [OrderStatus] 决定（`switch` 穷举）。页面里**没有**
/// `if (status == 2)` 这类魔法数字——状态迁移的合法性由聚合把关，
/// 页面只负责"这个状态下该给用户哪几个动作"。
class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderNumber});

  final String orderNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final AsyncValue<TicketOrder?> orderAsync =
        ref.watch(orderByNumberProvider(orderNumber));

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: const AdaptiveAppBar(title: '订单详情'),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => PsEmptyState(
          title: '订单加载失败',
          description: '$error',
          icon: LucideIcons.circleAlert,
          actionLabel: '重试',
          onAction: () => ref.invalidate(orderListProvider),
        ),
        data: (TicketOrder? order) {
          if (order == null) {
            return PsEmptyState(
              title: '订单不存在',
              description: '订单可能已被删除，或链接已过期',
              icon: LucideIcons.receiptText,
              actionLabel: '返回订单列表',
              onAction: () => context.go('/order'),
            );
          }
          return _OrderDetailBody(order: order);
        },
      ),
    );
  }
}

/// 详情主体：可滚动内容 + 固定底部动作栏。
class _OrderDetailBody extends ConsumerWidget {
  const _OrderDetailBody({required this.order});

  final TicketOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final ShowSummary? show = ref.watch(showByIdProvider(order.showId.value));

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: <Widget>[
              _StatusHeader(order: order),
              const SizedBox(height: 8),
              if (show != null) _ShowSection(show: show),
              _Card(
                children: <Widget>[
                  _SectionTitle(title: '票档'),
                  for (final OrderLine line in order.lines)
                    _InfoRow(
                      label: line.tierName,
                      value: '${line.quantity.value} 张 · ${line.subtotal.format()}',
                    ),
                  _InfoRow(
                    label: '取票方式',
                    value: order.delivery.describe(),
                  ),
                  if (order.visitors.isNotEmpty) ...<Widget>[
                    const Divider(height: 20),
                    _SectionTitle(title: '观演人'),
                    for (final Visitor visitor in order.visitors)
                      _InfoRow(
                        label: visitor.name,
                        value: visitor.idCard.masked,
                      ),
                  ],
                ],
              ),
              if (order.quote != null)
                _Card(
                  children: <Widget>[
                    _SectionTitle(title: '金额明细'),
                    for (final QuoteLine line in order.quote!.breakdown)
                      _InfoRow(
                        label: line.label,
                        value: line.isDeduction
                            ? '-${line.amount.format()}'
                            : line.amount.format(),
                        emphasize: line.label == '实付',
                      ),
                  ],
                ),
              _Card(
                children: <Widget>[
                  _SectionTitle(title: '订单信息'),
                  _InfoRow(
                    label: '订单号',
                    value: order.number.value,
                    trailing: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: order.number.value),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('订单号已复制')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          LucideIcons.copy,
                          size: 14,
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  _InfoRow(label: '下单时间', value: _formatTime(order.placedAt)),
                  if (order.paidAt != null)
                    _InfoRow(label: '支付时间', value: _formatTime(order.paidAt!)),
                  if (order.cancelReason != null)
                    _InfoRow(label: '关闭原因', value: order.cancelReason!),
                ],
              ),
            ],
          ),
        ),
        _ActionBar(order: order),
      ],
    );
  }

  static String _formatTime(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}-${two(time.month)}-${two(time.day)} '
        '${two(time.hour)}:${two(time.minute)}';
  }
}

/// 状态头（`view_order_detail_status.xml`）。
///
/// 不同状态给不同的副文案。**企划星的"待付款"还带一个倒计时**，这里只给截止
/// 时刻：倒计时需要 1 秒一次的定时器，而定时器会让所有 `pumpAndSettle`
/// 类测试永远等不到静止。截止时刻同样能回答"我还有多久"。
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.order});

  final TicketOrder order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final (String hint, Color tint) = switch (order.status) {
      OrderStatus.draft => ('订单尚未提交', colors.warning),
      OrderStatus.awaitingPayment => (
          '请在 $_deadline 前完成支付，超时订单将自动关闭',
          colors.warning,
        ),
      OrderStatus.awaitingTickets => ('已支付，正在为你出票', colors.brand),
      OrderStatus.ticketsInTransit => ('门票已寄出，请注意查收', colors.brand),
      OrderStatus.completed => ('订单已完成，欢迎发表观演评价', colors.success),
      OrderStatus.cancelled => ('订单已关闭，可重新选购', colors.textTertiary),
      OrderStatus.refunded => ('退款已原路退回', colors.textTertiary),
    };

    return Container(
      width: double.infinity,
      color: colors.bgCard,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                order.status.label,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              PsTag(
                label: order.orderType.label,
                tone: PsTagTone.soft,
                fontSize: 10,
                radius: 3,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(hint, style: TextStyle(fontSize: 12, height: 1.4, color: tint)),
        ],
      ),
    );
  }

  String get _deadline {
    final DateTime deadline = order.payDeadline;
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(deadline.hour)}:${two(deadline.minute)}';
  }
}

/// 演出信息段（点进去看详情）。
class _ShowSection extends StatelessWidget {
  const _ShowSection({required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/show/${show.id}'),
      child: Container(
        color: colors.bgCard,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PsPoster(seed: show.title, width: 72, height: 96, radius: 4),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    show.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    show.firstSessionLabel,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    show.venueLabel,
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 18, color: colors.textDisabled),
          ],
        ),
      ),
    );
  }
}

/// 底部动作栏。按钮组由订单状态决定。
class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.order});

  final TicketOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final OrderActions actions = ref.read(orderActionsProvider);

    // 状态 → 动作。`switch` 穷举，新增状态时编译期就会提醒这里要补。
    final List<_Action> buttons = switch (order.status) {
      OrderStatus.awaitingPayment => <_Action>[
          _Action(
            label: '取消订单',
            onTap: () => _cancel(context, actions),
          ),
          _Action(
            label: '立即支付',
            primary: true,
            onTap: () => _pay(context, actions),
          ),
        ],
      OrderStatus.ticketsInTransit => <_Action>[
          _Action(label: '查看物流', onTap: () => _toast(context, '物流详情待接入快递查询接口')),
          _Action(
            label: '确认收货',
            primary: true,
            onTap: () => _confirmReceipt(context, actions),
          ),
          _Action(
            label: '申请退款',
            onTap: () => context.push(
              '/order/refund'
              '?number=${Uri.encodeComponent(order.number.value)}'
              '&amount=${order.goodsTotal.minorUnits}',
            ),
          ),
        ],
      OrderStatus.completed => <_Action>[
          _Action(label: '去评价', onTap: () => _toast(context, '评价属于独立的评价聚合，本示例未实现')),
          _Action(
            label: '再次购买',
            primary: true,
            onTap: () => context.push('/order/confirm?showId=${order.showId.value}'),
          ),
        ],
      OrderStatus.draft => <_Action>[
          _Action(
            label: '继续填写',
            primary: true,
            onTap: () => context.push('/order/confirm?showId=${order.showId.value}'),
          ),
        ],
      OrderStatus.awaitingTickets => <_Action>[
          _Action(label: '联系客服', onTap: () => _toast(context, '客服会话（演示）')),
          _Action(label: '查看票夹', onTap: () => _toast(context, '电子票面待接入出票接口')),
          _Action(
            label: '申请退款',
            onTap: () => context.push(
              '/order/refund'
              '?number=${Uri.encodeComponent(order.number.value)}'
              '&amount=${order.goodsTotal.minorUnits}',
            ),
          ),
        ],
      OrderStatus.cancelled || OrderStatus.refunded => <_Action>[
          _Action(
            label: '重新选购',
            primary: true,
            onTap: () => context.push('/order/confirm?showId=${order.showId.value}'),
          ),
        ],
    };

    return Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border(top: BorderSide(color: colors.divider, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            for (final _Action action in buttons)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: action.onTap,
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: action.primary ? colors.brand : Colors.transparent,
                      borderRadius: BorderRadius.circular(17),
                      border: action.primary
                          ? null
                          : Border.all(color: colors.border, width: 0.5),
                    ),
                    child: Text(
                      action.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            action.primary ? FontWeight.w700 : FontWeight.w400,
                        color: action.primary ? colors.onBrand : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay(BuildContext context, OrderActions actions) async {
    final PaymentChannel? channel = await PaymentChannelSheet.show(context);
    if (channel == null) return;
    final String? error = await actions.pay(order, channel);
    if (!context.mounted) return;
    _toast(context, error ?? '支付成功，等待出票');
  }

  Future<void> _cancel(BuildContext context, OrderActions actions) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('取消订单'),
        content: const Text('取消后需要重新下单，确定继续吗？'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('再想想'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('取消订单'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    final String? error = await actions.cancel(order, '用户主动取消');
    if (!context.mounted) return;
    _toast(context, error ?? '订单已取消');
  }

  Future<void> _confirmReceipt(
    BuildContext context,
    OrderActions actions,
  ) async {
    final String? error = await actions.confirmReceipt(order);
    if (!context.mounted) return;
    _toast(context, error ?? '已确认收货');
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 一个底部动作。
final class _Action {
  const _Action({required this.label, required this.onTap, this.primary = false});

  final String label;
  final VoidCallback onTap;

  /// 主按钮（品牌色实心）。
  final bool primary;
}

/// 白底分组卡片。
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

/// 一行「左标签 + 右值」。
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Widget? trailing;

  /// 强调（实付金额）。
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: colors.textTertiary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: emphasize ? 15 : 13,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
                color: emphasize ? colors.price : colors.textPrimary,
              ),
            ),
          ),
          if (trailing != null) ?trailing,
        ],
      ),
    );
  }
}
