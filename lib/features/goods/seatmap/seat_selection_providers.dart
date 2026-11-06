import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_seat_map.dart';
import 'seat_map.dart';

/// 座位图数据 Provider（按演出 id 分族）。
///
/// 企划星的 `SelectTicketSeatMapActivity` 调 `GET v5/ticketCategories` 拿座位图。
/// 本演示模式用 [DemoSeatMap.generate] 生成。
final seatMapDataProvider = Provider.family<SeatMapData, String>((ref, showId) {
  return DemoSeatMap.generate();
});

/// 选座状态。
class SeatSelectionState {
  const SeatSelectionState({
    required this.mapData,
    this.selectedSeatIds = const <int>{},
  });

  final SeatMapData mapData;

  /// 选中座位 ID 集合。
  final Set<int> selectedSeatIds;

  /// 选中的座位列表。
  List<Seat> get selectedSeats {
    final result = <Seat>[];
    for (final area in mapData.areas) {
      for (final row in area.rows) {
        for (final seat in row.seats) {
          if (selectedSeatIds.contains(seat.id)) {
            result.add(seat);
          }
        }
      }
    }
    return result;
  }

  /// 总价。
  Money get totalPrice {
    if (selectedSeats.isEmpty) return Money.zero();
    var sum = 0;
    for (final seat in selectedSeats) {
      sum += seat.price?.minorUnits ?? 0;
    }
    return Money.fromMinorUnits(sum);
  }

  /// 选中数量。
  int get count => selectedSeatIds.length;

  /// 是否达到最大选择数。
  bool get atMax => count >= maxSeats;

  /// 最大可选数量（企划星默认 6，可通过 `buyCount` 参数控制）。
  static const int maxSeats = 6;

  SeatSelectionState copyWith({Set<int>? selectedSeatIds}) {
    return SeatSelectionState(
      mapData: mapData,
      selectedSeatIds: selectedSeatIds ?? this.selectedSeatIds,
    );
  }
}

/// 选座控制器。
///
/// ## 与 Android 的差异
///
/// - **不做锁座**：企划星在 `purchaseTicket` 时调 `checkGoodStock` 验证库存。
///   这里只做本地选择状态的增减，不与服务端交互。
/// - **不做连座**：企划星的 `isContinuousSeat` 参数要求选连续座位。
///   这里允许任意选——连座逻辑需要根据 `x` 坐标判断相邻性，
///   作为 P0 切片先不做，留 P1 补齐。
class SeatSelectionController
    extends FamilyNotifier<SeatSelectionState, String> {
  @override
  SeatSelectionState build(arg) {
    final mapData = ref.read(seatMapDataProvider(arg));
    return SeatSelectionState(mapData: mapData);
  }

  /// 切换座位选择状态。
  ///
  /// 可选座位 → 选中 / 取消选中。
  /// 不可选座位 → 忽略。
  /// 已达上限 → 再选新的不生效（先取消一个才能选新的）。
  void toggleSeat(Seat seat) {
    if (!seat.isSelectable) return;

    final ids = Set<int>.of(state.selectedSeatIds);
    if (ids.contains(seat.id)) {
      ids.remove(seat.id);
    } else {
      if (state.atMax) return;
      ids.add(seat.id);
    }
    state = state.copyWith(selectedSeatIds: ids);
  }

  /// 清空选择。
  void clear() {
    state = state.copyWith(selectedSeatIds: <int>{});
  }
}

/// 选座控制器 Provider。
final seatSelectionProvider =
    NotifierProvider.family<
      SeatSelectionController,
      SeatSelectionState,
      String
    >(SeatSelectionController.new);
