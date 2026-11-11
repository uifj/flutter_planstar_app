import 'package:core/domain.dart';

/// 座位状态。
enum SeatStatus {
  /// 可选。
  available,

  /// 已占用（不可再选）。
  sold,

  /// 已锁定（别人正在选）。
  locked,

  /// 通道 / 间隔（不是真正的座位）。
  aisle,

  /// 不可选（遮挡 / 设备位）。
  blocked,
}

/// 单个座位。
class Seat {
  const Seat({
    required this.id,
    required this.row,
    required this.col,
    required this.x,
    required this.y,
    required this.status,
    this.areaName,
    this.price,
    this.categoryId,
  });

  /// 座位 ID。
  final int id;

  /// 排号（显示用，如 "A" / "1"）。
  final String row;

  /// 座号（显示用，如 "12"）。
  final String col;

  /// X 坐标（网格列索引，从 0 开始）。
  final int x;

  /// Y 坐标（网格行索引，从 0 开始）。
  final int y;

  /// 状态。
  final SeatStatus status;

  /// 所属区域名。
  final String? areaName;

  /// 座位单价（可选，不同区域不同价）。
  final Money? price;

  /// 回报档位 ID。
  final int? categoryId;

  /// 是否可选。
  bool get isSelectable => status == SeatStatus.available;
}

/// 一个区域。
class SeatArea {
  const SeatArea({
    required this.id,
    required this.name,
    required this.rows,
    required this.width,
    required this.height,
    this.color,
  });

  /// 区域 ID。
  final int id;

  /// 区域名（如 "A区" / "VIP" / "池座"）。
  final String name;

  /// 该区域的所有座位（按行排列）。
  final List<SeatRow> rows;

  /// 网格宽度（列数）。
  final int width;

  /// 网格高度（行数）。
  final int height;

  /// 区域颜色（用于区域标签 / 座位底色）。
  final int? color;

  /// 该区域的可选座位数。
  int get availableCount =>
      rows.expand((r) => r.seats).where((s) => s.isSelectable).length;
}

/// 一排座位。
class SeatRow {
  const SeatRow({required this.label, required this.seats, required this.y});

  /// 排号标签（如 "A" / "1"）。
  final String label;

  /// 这排的座位列表。
  final List<Seat> seats;

  /// Y 坐标（网格行索引）。
  final int y;
}

/// 完整的座位图数据。
///
/// 线下回报场次的可选座位图（POSITIONING.md §10 降级能力），仅线下活动型企划使用。
/// 用**网格表格模式**直接渲染区域 → 排 → 座位的三级结构，
/// 不做地图引擎的场地俯视图 + 点击区域展开座位那套交互。
class SeatMapData {
  const SeatMapData({
    required this.areas,
    required this.venueName,
    required this.stageLabel,
  });

  /// 所有区域。
  final List<SeatArea> areas;

  /// 活动场地名。
  final String venueName;

  /// 舞台标签（显示在座位图顶部）。
  final String stageLabel;

  /// 所有区域的可选座位总数。
  int get totalAvailable =>
      areas.fold(0, (sum, area) => sum + area.availableCount);

  /// 按 ID 查座位（WebView 回传的选中集合需要映射回领域对象）。
  Seat? seatById(int id) {
    for (final area in areas) {
      for (final row in area.rows) {
        for (final seat in row.seats) {
          if (seat.id == id) return seat;
        }
      }
    }
    return null;
  }

  /// 网格总宽度（取最大区域宽度）。
  int get gridWidth => areas.isEmpty
      ? 0
      : areas.map((a) => a.width).reduce((a, b) => a > b ? a : b);

  /// 网格总高度（所有区域行数之和 + 间距）。
  int get gridHeight =>
      areas.fold(0, (sum, area) => sum + area.height) + areas.length;
}

/// 选座结果。
class SeatSelection {
  const SeatSelection({required this.seats, required this.totalPrice});

  /// 选中的座位列表。
  final List<Seat> seats;

  /// 总价。
  final Money totalPrice;

  /// 是否为空。
  bool get isEmpty => seats.isEmpty;

  /// 座位数。
  int get count => seats.length;
}
