import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui/ps_price.dart';
import 'seat_map.dart';
import 'seat_map_view.dart';
import 'seat_selection_providers.dart';

/// 选座页（企划星 `SelectTicketSeatMapActivity` / `ChooseTicketSeatTableFragment`）。
///
/// ## 结构
///
/// 舞台标签 → 座位图（缩放/拖拽）→ 已选座位列表 → 底部确认栏。
///
/// ## 与 Android 的差异
///
/// - **不做 Mapbox**：企划星用 Mapbox GL 渲染场馆俯视图，点击区域后展开座位。
///   本项目用**网格表格模式**（对齐 `ChooseTicketSeatTableFragment`），
///   用 `CustomPainter` + `InteractiveViewer` 渲染。
///   理由：Mapbox SDK 需要独立 token + 平台配置，演示项目不引入。
///   网格模式的数据结构（区域→排→座）与 Mapbox 模式相同，
///   后续接 Mapbox 时只需替换渲染层。
/// - **不做锁座**：企划星在 `purchaseTicket` 时调 `checkGoodStock` 验证库存。
///   这里只做本地选择，不与服务端交互。
/// - **不做连座**：企划星的 `isContinuousSeat` 要求选连续座位。
///   这里允许任意选，连座逻辑留 P1 补齐。
/// - **不做倒计时**：演示模式没有真实库存锁定，倒计时无意义。
class SeatSelectionPage extends ConsumerWidget {
  const SeatSelectionPage({super.key, required this.showId});

  final String showId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final state = ref.watch(seatSelectionProvider(showId));

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(
        title: '选座',
        subtitle: state.mapData.venueName,
      ),
      body: Column(
        children: <Widget>[
          // 图例
          _LegendBar(colors: colors),
          // 座位图
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: colors.bgSubtle,
                child: SeatMapView(
                  state: state,
                  onToggle: (seat) =>
                      ref.read(seatSelectionProvider(showId).notifier).toggleSeat(seat),
                ),
              ),
            ),
          ),
          // 已选座位列表
          if (state.selectedSeats.isNotEmpty)
            _SelectedSeatsBar(
              seats: state.selectedSeats,
              colors: colors,
              onRemove: (seat) =>
                  ref.read(seatSelectionProvider(showId).notifier).toggleSeat(seat),
              onClear: () =>
                  ref.read(seatSelectionProvider(showId).notifier).clear(),
            ),
          // 底部确认栏
          _ConfirmBar(
            state: state,
            colors: colors,
            onConfirm: () {
              // 跳到确认订单页，带上选座信息。
              // 目前 order/confirm 只接受 showId，选座信息暂不传入
              // （需要扩展 OrderConfirmPage 以接受 seatIds 参数）。
              // P0 切片先跳转，P1 补齐参数传递。
              context.push(
                '/order/confirm?showId=$showId',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '已选 ${state.count} 个座位，总价 ${state.totalPrice.format()}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 图例条。
class _LegendBar extends StatelessWidget {
  const _LegendBar({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: colors.bgCard,
      child: Row(
        children: <Widget>[
          _LegendDot(color: colors.bgSubtle, label: '可选'),
          const SizedBox(width: 12),
          _LegendDot(color: colors.brand, label: '已选'),
          const SizedBox(width: 12),
          _LegendDot(color: colors.textDisabled.withValues(alpha: 0.3), label: '已售'),
          const SizedBox(width: 12),
          _LegendDot(color: const Color(0xFFFFB238), label: '锁定'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).extension<AppColors>()?.textTertiary ??
                AppColors.light.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// 已选座位条。
class _SelectedSeatsBar extends StatelessWidget {
  const _SelectedSeatsBar({
    required this.seats,
    required this.colors,
    required this.onRemove,
    required this.onClear,
  });

  final List<Seat> seats;
  final AppColors colors;
  final void Function(Seat) onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 100),
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border(top: BorderSide(color: colors.divider, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '已选 ${seats.length}/${SeatSelectionState.maxSeats} 座',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  '清空',
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: <Widget>[
              for (final seat in seats)
                GestureDetector(
                  onTap: () => onRemove(seat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.brandSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${seat.areaName ?? ''} ${seat.row}排${seat.col}座',
                          style: TextStyle(fontSize: 11, color: colors.brand),
                        ),
                        const SizedBox(width: 4),
                        Icon(LucideIcons.x, size: 12, color: colors.brand),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 底部确认栏。
class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({
    required this.state,
    required this.colors,
    required this.onConfirm,
  });

  final SeatSelectionState state;
  final AppColors colors;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final canConfirm = state.count > 0;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border(top: BorderSide(color: colors.divider, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10 + MediaQuery.paddingOf(context).bottom),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '已选 ${state.count} 座',
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
                if (state.count > 0)
                  Row(
                    children: <Widget>[
                      Text(
                        '合计 ',
                        style: TextStyle(fontSize: 13, color: colors.textSecondary),
                      ),
                      PsPrice(amount: state.totalPrice, size: 18),
                    ],
                  )
                else
                  Text(
                    '请选择座位',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: canConfirm ? onConfirm : null,
              style: FilledButton.styleFrom(
                backgroundColor: colors.brand,
                disabledBackgroundColor: colors.brandDisabled,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                canConfirm ? '确认选座' : '请先选座',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
