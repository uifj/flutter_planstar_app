import 'package:core/domain.dart';

import 'seat_map.dart';

/// 演示座位图数据生成器。
///
/// 生成一个 3 区域 × 各 5 排 × 各 10 座的场馆座位图。
/// 状态分布：
/// - 约 60% available
/// - 约 25% sold
/// - 约 5% locked
/// - 约 10% aisle / blocked
///
/// 这不是真实数据——真实数据来自 `v5/ticketCategories` + `v1/ticketGroup`。
/// 这里的目的是让选座 UI 有可渲染的内容，验证交互逻辑。
class DemoSeatMap {
  DemoSeatMap._();

  /// 生成演示座位图。
  static SeatMapData generate({String venueName = '上海文化广场'}) {
    final areas = <SeatArea>[
      _buildArea(
        id: 1,
        name: 'VIP区',
        rowCount: 5,
        seatsPerRow: 12,
        startY: 0,
        pricePerSeat: Money.fromMinorUnits(128000), // ¥1280
        areaColor: 0xFFFFD700,
      ),
      _buildArea(
        id: 2,
        name: 'A区',
        rowCount: 6,
        seatsPerRow: 14,
        startY: 6, // 5 行 + 1 行间距
        pricePerSeat: Money.fromMinorUnits(88000), // ¥880
        areaColor: 0xFFFF2261,
      ),
      _buildArea(
        id: 3,
        name: 'B区',
        rowCount: 8,
        seatsPerRow: 16,
        startY: 13, // 5 + 1 + 6 + 1 行
        pricePerSeat: Money.fromMinorUnits(48000), // ¥480
        areaColor: 0xFF4A90D9,
      ),
    ];

    return SeatMapData(
      areas: areas,
      venueName: venueName,
      stageLabel: '舞台',
    );
  }

  /// 构建一个区域。
  static SeatArea _buildArea({
    required int id,
    required String name,
    required int rowCount,
    required int seatsPerRow,
    required int startY,
    required Money pricePerSeat,
    int? areaColor,
  }) {
    final rowLabels = _generateRowLabels(rowCount);
    final rows = <SeatRow>[];

    for (var r = 0; r < rowCount; r++) {
      final seats = <Seat>[];
      // 在每排中间留一个通道（aisle）。
      final aisleIndex = seatsPerRow ~/ 2;

      for (var c = 0; c < seatsPerRow; c++) {
        final seatId = id * 10000 + r * 100 + c;
        final colLabel = '${c + 1}';

        if (c == aisleIndex) {
          seats.add(Seat(
            id: seatId,
            row: rowLabels[r],
            col: colLabel,
            x: c,
            y: startY + r,
            status: SeatStatus.aisle,
            areaName: name,
          ));
          continue;
        }

        // 用确定性伪随机分布状态。
        final hash = (id * 31 + r * 17 + c * 7) % 100;
        SeatStatus status;
        if (hash < 55) {
          status = SeatStatus.available;
        } else if (hash < 85) {
          status = SeatStatus.sold;
        } else if (hash < 92) {
          status = SeatStatus.locked;
        } else {
          status = SeatStatus.blocked;
        }

        seats.add(Seat(
          id: seatId,
          row: rowLabels[r],
          col: colLabel,
          x: c,
          y: startY + r,
          status: status,
          areaName: name,
          price: pricePerSeat,
          categoryId: id,
        ));
      }

      rows.add(SeatRow(
        label: rowLabels[r],
        seats: seats,
        y: startY + r,
      ));
    }

    return SeatArea(
      id: id,
      name: name,
      rows: rows,
      width: seatsPerRow,
      height: rowCount,
      color: areaColor,
    );
  }

  /// 生成排号标签（A, B, C, ...）。
  static List<String> _generateRowLabels(int count) {
    final labels = <String>[];
    for (var i = 0; i < count; i++) {
      labels.add(String.fromCharCode(65 + i)); // A=65
    }
    return labels;
  }
}
