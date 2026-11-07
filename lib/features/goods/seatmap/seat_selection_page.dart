import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui/ps_price.dart';
import 'seat_map.dart';
import 'seat_map_webview.dart';
import 'seat_selection_providers.dart';
import '../../../l10n/l10n.dart';

/// 选座页（企划星 `SelectTicketSeatMapActivity` / `ChooseTicketSeatTableFragment`）。
///
/// ## 结构
///
/// 舞台标签 → 座位图（WebView，支持拖动/双指缩放）→ 已选座位列表 → 底部确认栏。
///
/// ## 渲染方案
///
/// 座位图由 `assets/seatmap/seat_map.html` 在 WebView 里渲染：
/// 手势与动画交给浏览器内核，Flutter 只保留图例、已选标签与确认栏。
/// 选中态以 Riverpod 为唯一真源，WebView 通过 `PsSeatBridge` 通道回传全量
/// 选中集合，Flutter 校验后落库，并在返回/重建时回写 WebView 完成回显。
///
/// ## 与 Android 的差异
///
/// - **不做 Mapbox**：企划星用 Mapbox GL 渲染场馆俯视图，点击区域后展开座位。
///   本项目用**网格表格模式**（对齐 `ChooseTicketSeatTableFragment`）。
/// - **锁座是本地锁**：选中即写入本地锁表（默认 10 分钟），取消 / 清空 / 超时释放。
///   服务端座位库存尚未接入，锁只在当前 App 进程内有效。
/// - **连座校验**：进入确认页前校验「同一区域 + 同一排 + 列号连续」。
/// - **选座倒计时**：默认 10 分钟，归零后清空选择并释放本地锁。
class SeatSelectionPage extends ConsumerWidget {
  const SeatSelectionPage({super.key, required this.showId});

  final String showId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final state = ref.watch(seatSelectionProvider(showId));

    // 倒计时归零：控制器已清空选择并释放锁，这里只负责提示。
    ref.listen<bool>(seatSelectionProvider(showId).select((s) => s.timedOut), (
      previous,
      next,
    ) {
      if (!next) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.seatSelectionTimeout)),
        );
    });

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(
        title: context.l10n.seatSelectionPage_45,
        subtitle: state.mapData.venueName,
      ),
      body: Column(
        children: <Widget>[
          // 图例
          _LegendBar(colors: colors),
          // 选座倒计时
          _CountdownBar(seconds: state.leftSeconds, colors: colors),
          // 座位图（WebView 渲染，Flutter 侧只保留状态真源）
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              color: colors.bgSubtle,
              child: SeatMapWebView(
                showId: showId,
                onLimitReached: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n.seatSelectionPage_191(
                            state.count,
                            SeatSelectionState.maxSeats,
                          ),
                        ),
                        duration: const Duration(milliseconds: 1500),
                      ),
                    );
                },
              ),
            ),
          ),
          // 已选座位列表
          if (state.selectedSeats.isNotEmpty)
            _SelectedSeatsBar(
              seats: state.selectedSeats,
              colors: colors,
              onRemove: (seat) => ref
                  .read(seatSelectionProvider(showId).notifier)
                  .toggleSeat(seat),
              onClear: () =>
                  ref.read(seatSelectionProvider(showId).notifier).clear(),
            ),
          // 底部确认栏
          _ConfirmBar(
            state: state,
            colors: colors,
            onConfirm: () {
              // 进入确认页前做连座校验，不通过时提示并阻止跳转。
              final result = ref
                  .read(seatSelectionProvider(showId).notifier)
                  .validateContinuity();
              if (result.isFailure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(context.l10n.seatContinuityError)),
                  );
                return;
              }
              // 选座结果通过 `seatSelectionProvider(showId)` 传给确认订单页：
              // 确认页与本页共享同一个 ProviderScope，读取到的是同一份
              // 座位对象（区域/排/座/票价），无需在 URL 里重复编码。
              context.push('/order/confirm?showId=$showId');
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
          _LegendDot(
            color: colors.bgSubtle,
            label: context.l10n.seatSelectionPage_116,
          ),
          const SizedBox(width: 12),
          _LegendDot(
            color: colors.brand,
            label: context.l10n.seatSelectionPage_118,
          ),
          const SizedBox(width: 12),
          _LegendDot(
            color: colors.textDisabled.withValues(alpha: 0.3),
            label: context.l10n.seatSelectionPage_120,
          ),
          const SizedBox(width: 12),
          _LegendDot(
            color: const Color(0xFFFFB238),
            label: context.l10n.seatSelectionPage_122,
          ),
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
            color:
                Theme.of(context).extension<AppColors>()?.textTertiary ??
                AppColors.light.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// 选座倒计时条。
class _CountdownBar extends StatelessWidget {
  const _CountdownBar({required this.seconds, required this.colors});

  final int seconds;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final urgent = seconds < 60;
    final color = urgent ? colors.error : colors.textTertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: colors.bgCard,
      child: Row(
        children: <Widget>[
          Icon(LucideIcons.timer, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            context.l10n.seatSelectionCountdown(
              SeatSelectionController.formatCountdown(seconds),
            ),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
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
                context.l10n.seatSelectionPage_191(
                  seats.length,
                  SeatSelectionState.maxSeats,
                ),
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
                  context.l10n.seatSelectionPage_202,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.brandSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          context.l10n.seatSelectionPage_226(
                            seat.areaName ?? '',
                            seat.row,
                            seat.col,
                          ),
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
      padding: EdgeInsets.fromLTRB(
        15,
        10,
        15,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  context.l10n.seatSelectionPage_273(state.count),
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
                if (state.count > 0)
                  Row(
                    children: <Widget>[
                      Text(
                        context.l10n.seatSelectionPage_280,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                      PsPrice(amount: state.totalPrice, size: 18),
                    ],
                  )
                else
                  Text(
                    context.l10n.seatSelectionPage_288,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: canConfirm ? onConfirm : null,
              style: FilledButton.styleFrom(
                // 主题把 FilledButton 的 minimumSize 设为 Size.fromHeight(44)，
                // 即 minWidth 为无穷大；放在 Row 的非 flex 槽位会拿到无界宽度，
                // 触发布局断言。这里显式给出有限最小宽度。
                minimumSize: const Size(96, 44),
                backgroundColor: colors.brand,
                disabledBackgroundColor: colors.brandDisabled,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                canConfirm
                    ? context.l10n.seatSelectionPage_306
                    : context.l10n.seatSelectionPage_306_2,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
