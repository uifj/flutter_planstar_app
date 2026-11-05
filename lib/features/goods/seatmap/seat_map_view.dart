import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import 'seat_map.dart';
import 'seat_selection_providers.dart';

/// 座位图渲染组件（对齐企划星 `SeatTableView` + `ChooseTicketSeatTableFragment`）。
///
/// ## 渲染策略
///
/// 用 [CustomPainter] 绘制座位网格，外层包裹 [InteractiveViewer] 提供缩放/拖拽。
/// 这比嵌套 Widget 性能更好——一个区域可能有 100+ 个座位，
/// 每个 20×20dp 的 Widget 会让树过深。
///
/// ## 交互
///
/// 点击座位 → 调 [onToggle]。
/// 座位状态用颜色区分：
/// - available（灰底）→ 选中后变品牌色
/// - sold（深灰，不可点）
/// - locked（黄色斜线）
/// - aisle（不画）
/// - blocked（画 ×）
class SeatMapView extends StatelessWidget {
  const SeatMapView({
    super.key,
    required this.state,
    required this.onToggle,
  });

  final SeatSelectionState state;
  final void Function(Seat) onToggle;

  /// 单个座位的绘制尺寸（dp）。
  static const double seatSize = 22;

  /// 座位之间的间距（dp）。
  static const double seatGap = 3;

  /// 排号标签宽度（dp）。
  static const double rowLabelWidth = 24;

  /// 区域间距（dp）。
  static const double areaGap = 20;

  /// 列号标签高度（dp）。
  static const double colLabelHeight = 20;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final mapData = state.mapData;

    // 计算内容总尺寸。
    final contentWidth = _calculateWidth(mapData);
    final contentHeight = _calculateHeight(mapData);

    return InteractiveViewer(
      constrained: false,
      minScale: 0.5,
      maxScale: 2.5,
      child: SizedBox(
        width: contentWidth,
        height: contentHeight,
        child: GestureDetector(
          onTapDown: (details) => _handleTap(details.localPosition, colors),
          child: CustomPaint(
            size: Size(contentWidth, contentHeight),
            painter: _SeatMapPainter(
              mapData: mapData,
              selectedSeatIds: state.selectedSeatIds,
              colors: colors,
              seatSize: seatSize,
              seatGap: seatGap,
              rowLabelWidth: rowLabelWidth,
              colLabelHeight: colLabelHeight,
              areaGap: areaGap,
            ),
          ),
        ),
      ),
    );
  }

  /// 处理点击：找到点击位置对应的座位。
  void _handleTap(Offset localPosition, AppColors colors) {
    final mapData = state.mapData;
    var currentY = colLabelHeight.toDouble();

    for (final area in mapData.areas) {
      // 区域标题行
      currentY += 20;

      for (final row in area.rows) {
        final rowY = currentY;
        final seatStartX = rowLabelWidth.toDouble();

        for (final seat in row.seats) {
          final seatX = seatStartX + seat.x * (seatSize + seatGap);
          final seatRect = Rect.fromLTWH(seatX, rowY, seatSize, seatSize);

          if (seatRect.contains(localPosition)) {
            onToggle(seat);
            return;
          }
        }

        currentY += seatSize + seatGap;
      }

      currentY += areaGap;
    }
  }

  /// 计算内容总宽度。
  double _calculateWidth(SeatMapData mapData) {
    final maxRowWidth = mapData.gridWidth;
    return rowLabelWidth + maxRowWidth * (seatSize + seatGap) + 20;
  }

  /// 计算内容总高度。
  double _calculateHeight(SeatMapData mapData) {
    var height = colLabelHeight.toDouble();
    for (final area in mapData.areas) {
      height += 20; // 区域标题
      height += area.rows.length * (seatSize + seatGap);
      height += areaGap;
    }
    return height + 40;
  }
}

/// 座位图画笔。
class _SeatMapPainter extends CustomPainter {
  _SeatMapPainter({
    required this.mapData,
    required this.selectedSeatIds,
    required this.colors,
    required this.seatSize,
    required this.seatGap,
    required this.rowLabelWidth,
    required this.colLabelHeight,
    required this.areaGap,
  });

  final SeatMapData mapData;
  final Set<int> selectedSeatIds;
  final AppColors colors;
  final double seatSize;
  final double seatGap;
  final double rowLabelWidth;
  final double colLabelHeight;
  final double areaGap;

  @override
  void paint(Canvas canvas, Size size) {
    var currentY = colLabelHeight;

    // 画舞台标签。
    _drawStageLabel(canvas, size);

    for (final area in mapData.areas) {
      // 画区域标题。
      _drawAreaLabel(canvas, area, currentY);
      currentY += 20;

      // 画列号标签（第一行）。
      _drawColLabels(canvas, area, currentY);

      for (final row in area.rows) {
        // 画排号标签。
        _drawRowLabel(canvas, row, currentY);

        // 画座位。
        for (final seat in row.seats) {
          final seatX = rowLabelWidth + seat.x * (seatSize + seatGap);
          final seatRect = Rect.fromLTWH(seatX, currentY, seatSize, seatSize);
          final isSelected = selectedSeatIds.contains(seat.id);

          _drawSeat(canvas, seatRect, seat.status, isSelected);
        }

        currentY += seatSize + seatGap;
      }

      currentY += areaGap;
    }
  }

  void _drawStageLabel(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: TextSpan(
        text: '◀ ${mapData.stageLabel} ▶',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colors.textSecondary,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset((size.width - painter.width) / 2, 0),
    );
  }

  void _drawAreaLabel(Canvas canvas, SeatArea area, double y) {
    final painter = TextPainter(
      text: TextSpan(
        text: '${area.name} (${area.availableCount}席可选)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _areaColor(area),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, Offset(rowLabelWidth, y));
  }

  void _drawColLabels(Canvas canvas, SeatArea area, double y) {
    for (final seat in area.rows.first.seats) {
      if (seat.status == SeatStatus.aisle) continue;
      final painter = TextPainter(
        text: TextSpan(
          text: seat.col,
          style: TextStyle(fontSize: 9, color: colors.textTertiary),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      final x = rowLabelWidth + seat.x * (seatSize + seatGap) +
          (seatSize - painter.width) / 2;
      painter.paint(canvas, Offset(x, y));
    }
  }

  void _drawRowLabel(Canvas canvas, SeatRow row, double y) {
    final painter = TextPainter(
      text: TextSpan(
        text: row.label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.textTertiary),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(0, y + (seatSize - painter.height) / 2),
    );
  }

  void _drawSeat(Canvas canvas, Rect rect, SeatStatus status, bool selected) {
    final paint = Paint();

    switch (status) {
      case SeatStatus.available:
        paint.color = selected ? colors.brand : colors.bgSubtle;
        paint.style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          paint,
        );
        // 边框。
        paint.color = selected ? colors.brand : colors.divider;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 0.5;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          paint,
        );

      case SeatStatus.sold:
        paint.color = colors.textDisabled.withValues(alpha: 0.3);
        paint.style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          paint,
        );

      case SeatStatus.locked:
        paint.color = const Color(0xFFFFB238).withValues(alpha: 0.2);
        paint.style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          paint,
        );
        // 斜线表示锁定。
        paint.color = const Color(0xFFFFB238);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 0.8;
        canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
        canvas.drawLine(rect.topRight, rect.bottomLeft, paint);

      case SeatStatus.aisle:
        // 不画——留白即可。

      case SeatStatus.blocked:
        paint.color = colors.textDisabled.withValues(alpha: 0.1);
        paint.style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          paint,
        );
        // 画 ×。
        paint.color = colors.textDisabled;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 0.8;
        canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
        canvas.drawLine(rect.topRight, rect.bottomLeft, paint);
    }
  }

  Color _areaColor(SeatArea area) {
    if (area.color != null) return Color(area.color!);
    return colors.brand;
  }

  @override
  bool shouldRepaint(_SeatMapPainter oldDelegate) =>
      oldDelegate.selectedSeatIds != selectedSeatIds;
}
