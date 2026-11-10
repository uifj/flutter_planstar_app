import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import '../catalog/application/catalog_providers.dart';
import '../catalog/domain/show_summary.dart';
import 'application/order_list_controller.dart';
import 'order_l10n.dart';
import 'domain/domain.dart';
import 'widgets/order_list_card.dart';
import '../../l10n/l10n.dart';

/// 我的支持（`activity_my_order.xml` + `fragment_my_activity_order.xml`），
/// 「我的 → 订单」的二级页。
///
/// ## 两层 tab
///
/// 1. 顶部 40dp 的「企划 / 商品」——企划星把企划支持记录和商品（周边）分成两个列表；
/// 2. 40dp 的「全部 / 待支付 / 众筹中 / 交付中 / 待评价」——等宽、24×2dp 下划线。
///
/// 商品列表**没有数据源**（本项目只做了企划支持链路），所以那一栏渲染空态
/// 而不是假装有数据。
///
/// ## 层级
///
/// 原为底部 tab 的一级页；现在收敛为个人中心的二级页，顶栏恢复返回箭头
/// （`context.maybePop`），返回回到个人中心。
///
/// ## 筛选在应用层做
///
/// 仓储只返回"全部支持"，过滤发生在 [OrderListFilter.matches]。
/// 理由写在 `order_list_controller.dart`：企划星列表的 0–3 筛选码是第三套编码，
/// 不该污染仓储端口。
class OrderListPage extends ConsumerStatefulWidget {
  const OrderListPage({super.key});

  @override
  ConsumerState<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends ConsumerState<OrderListPage> {
  /// `0` = 企划，`1` = 商品。
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final filter = ref.watch(orderListFilterProvider);
    final ordersAsync = ref.watch(filteredOrderListProvider);
    final isStale = ref.watch(orderListStaleProvider);
    final actions = ref.read(orderActionsProvider);

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      body: Column(
        children: <Widget>[
          _PrimaryTabs(
            selected: _tab,
            onSelect: (index) => setState(() => _tab = index),
          ),
          if (_tab == 0) ...<Widget>[
            _StatusTabs(
              selected: filter,
              onSelect: (next) =>
                  ref.read(orderListFilterProvider.notifier).state = next,
            ),
            Container(height: 1, color: colors.divider),
            if (isStale)
              Container(
                width: double.infinity,
                color: colors.warning.withValues(alpha: 0.12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      LucideIcons.cloudOff,
                      size: 14,
                      color: colors.warning,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.l10n.stateOfflineCache,
                        style: TextStyle(fontSize: 12, color: colors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.refresh(orderListProvider.future),
                child: ordersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => PsEmptyState(
                    title: context.l10n.orderListPage_71,
                    description: psErrorMessage(error),
                    icon: LucideIcons.circleAlert,
                    actionLabel: context.l10n.actionRetry,
                    onAction: () => ref.invalidate(orderListProvider),
                  ),
                  data: (orders) {
                    if (orders.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: <Widget>[
                          const SizedBox(height: 80),
                          PsEmptyState(
                            title: filter == OrderListFilter.all
                                ? context.l10n.orderListPage_85
                                : context.l10n.orderListPage_87(
                                    filter.labelOf(context),
                                  ),
                            description: context.l10n.orderListPage_88,
                            icon: LucideIcons.receiptText,
                            actionLabel: context.l10n.orderListPage_90,
                            onAction: () => context.go('/'),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        top: 10,
                        // 二级页全屏显示，底部只留系统安全区，不再为悬浮 tab 栏让位。
                        bottom: MediaQuery.viewPaddingOf(context).bottom + 16,
                      ),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final ShowSummary? show = ref.watch(
                          showByIdProvider(order.showId.value),
                        );
                        return OrderListCard(
                          order: order,
                          show: show,
                          onTap: () => _showOrderDetail(context, order),
                          onPay: () => _pay(context, order, actions),
                          onCancel: () => _cancel(context, order, actions),
                          onConfirmReceipt: () =>
                              _confirmReceipt(context, order, actions),
                          onReview: () =>
                              _toast(context, context.l10n.orderListPage_115),
                          onBuyAgain: () => context.push(
                            '/order/confirm?showId=${order.showId.value}',
                          ),
                          onContactService: () =>
                              _toast(context, context.l10n.orderListPage_119),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ] else
            Expanded(
              child: PsEmptyState(
                title: context.l10n.orderListPage_130,
                description: context.l10n.orderListPage_131,
                icon: LucideIcons.shoppingBag,
              ),
            ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 进订单详情页。
  ///
  /// 以前这里是 `_OrderDetailSheet`（半屏面板）。改成独立页的原因写在
  /// `order_detail_page.dart`：七段内容塞不进半屏，且面板的滚动手势会和
  /// 列表冲突。列表只负责"带订单号跳过去"。
  void _showOrderDetail(BuildContext context, TicketOrder order) {
    context.push(
      '/order/detail?number=${Uri.encodeComponent(order.number.value)}',
    );
  }

  Future<void> _pay(
    BuildContext context,
    TicketOrder order,
    OrderActions _,
  ) async {
    // 跳到独立支付页，由支付页选渠道并模拟 SDK 调用。
    // 以前是直接在列表里弹渠道 sheet + 内存支付，现在改为走完整支付流程。
    final show = ref.read(showByIdProvider(order.showId.value));
    context.push(
      '/order/pay'
      '?number=${Uri.encodeComponent(order.number.value)}'
      // P1-01：应付金额取报价快照的 paymentAmount（含折扣/礼品卡/运费/加速包），
      // goodsTotal 只是票面子小计，用它跳转支付页会多付或少付。
      '&amount=${order.quote?.paymentAmount.minorUnits ?? order.goodsTotal.minorUnits}'
      '&title=${Uri.encodeComponent(show?.title ?? '')}',
    );
  }

  Future<void> _cancel(
    BuildContext context,
    TicketOrder order,
    OrderActions actions,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.orderListPage_181),
        content: Text(context.l10n.orderListPage_182),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.orderListPage_186),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.orderListPage_190),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (!(confirmed ?? false)) return;
    final error = await actions.cancel(order, OrderCancelReason.userCancelled);
    if (!context.mounted) return;
    _toast(context, error ?? context.l10n.orderListPage_198);
  }

  Future<void> _confirmReceipt(
    BuildContext context,
    TicketOrder order,
    OrderActions actions,
  ) async {
    final error = await actions.confirmReceipt(order);
    if (!context.mounted) return;
    _toast(context, error ?? context.l10n.orderListPage_208);
  }
}

/// 演出 / 商品 一级 tab（`activity_my_order.xml`，40dp）。
class _PrimaryTabs extends StatelessWidget {
  const _PrimaryTabs({required this.selected, required this.onSelect});

  final int selected;
  final void Function(int index) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: SizedBox(
        height: 40,
        child: Row(
          children: <Widget>[
            // 二级页返回箭头，回到个人中心。
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (context.canPop()) context.pop();
              },
              child: SizedBox(
                width: 44,
                child: Center(
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 20,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            for (final (index, label) in <String>[
              context.l10n.orderListPage_229,
              context.l10n.orderListPage_229_2,
            ].indexed)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: index == selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: index == selected
                              ? colors.price
                              : colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 24,
                        height: 2,
                        color: index == selected
                            ? colors.price
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 状态 tab（`fragment_my_activity_order.xml`，40dp，等宽）。
class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.selected, required this.onSelect});

  final OrderListFilter selected;
  final void Function(OrderListFilter filter) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      height: 40,
      child: Row(
        children: <Widget>[
          for (final filter in OrderListFilter.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(filter),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      filter.labelOf(context),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: filter == selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: filter == selected
                            ? colors.brand
                            : colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 24,
                      height: 2,
                      decoration: BoxDecoration(
                        color: filter == selected
                            ? colors.brand
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
