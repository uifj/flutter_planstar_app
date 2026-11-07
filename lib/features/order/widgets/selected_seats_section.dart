import 'package:core/domain.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../goods/seatmap/seat_map.dart';

/// 确认订单页的「已选座位」区块。
///
/// 数据来自选座页写入的 `seatSelectionProvider(showId)`：
/// 座位对象（区域 / 排 / 座 / 票价）原样带过来，不做二次编码，
/// 因此不会出现"确认页只拿到数量、丢了座位信息"的情况。
/// 没有选座（普通票档下单）时不渲染任何内容。
class SelectedSeatsSection extends StatelessWidget {
  const SelectedSeatsSection({super.key, required this.seats});

  final List<Seat> seats;

  @override
  Widget build(BuildContext context) {
    if (seats.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    var totalMinor = 0;
    for (final seat in seats) {
      totalMinor += seat.price?.minorUnits ?? 0;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                context.l10n.orderConfirmPage_seatsTitle,
                style: theme.textTheme.titleSmall,
              ),
              Text(
                context.l10n.seatSelectionPage_273(seats.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: colors.bgSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final seat in seats)
                      _SeatChip(
                        label: context.l10n.seatSelectionPage_226(
                          seat.areaName ?? '',
                          seat.row,
                          seat.col,
                        ),
                        colors: colors,
                      ),
                  ],
                ),
                if (totalMinor > 0) ...<Widget>[
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Text(
                        context.l10n.orderConfirmPage_seatsSubtotal,
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        Money.fromMinorUnits(totalMinor).format(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.price,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatChip extends StatelessWidget {
  const _SeatChip({required this.label, required this.colors});

  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.brandSubtle,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: colors.brand)),
    );
  }
}
