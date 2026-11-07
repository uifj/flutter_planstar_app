import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/goods/seatmap/seat_map.dart';
import 'package:planstar/features/goods/seatmap/seat_selection_providers.dart';

void main() {
  ProviderContainer createContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  List<Seat> allSeats(SeatMapData map) => <Seat>[
    for (final area in map.areas)
      for (final row in area.rows) ...row.seats,
  ];

  test('setSelection：忽略未知 / 不可选 id，并限制最多 6 座', () {
    final container = createContainer();
    const showId = '1001';
    final controller = container.read(seatSelectionProvider(showId).notifier);
    final map = container.read(seatSelectionProvider(showId)).mapData;
    final seats = allSeats(map);

    final available = seats.where((s) => s.isSelectable).toList();
    final sold = seats.firstWhere((s) => s.status == SeatStatus.sold);
    expect(available.length, greaterThan(8));

    controller.setSelection(<int>[
      available[0].id,
      sold.id,
      -1,
      available[1].id,
      available[0].id,
    ]);
    var state = container.read(seatSelectionProvider(showId));
    expect(state.selectedSeatIds, <int>{available[0].id, available[1].id});

    controller.setSelection(available.take(9).map((s) => s.id));
    state = container.read(seatSelectionProvider(showId));
    expect(state.count, SeatSelectionState.maxSeats);
    expect(state.selectedSeats, hasLength(SeatSelectionState.maxSeats));
  });

  test('toggleSeat：重复点击同一座位即取消选座', () {
    final container = createContainer();
    const showId = '1001';
    final controller = container.read(seatSelectionProvider(showId).notifier);
    final map = container.read(seatSelectionProvider(showId)).mapData;
    final seat = allSeats(map).firstWhere((s) => s.isSelectable);

    controller.toggleSeat(seat);
    expect(container.read(seatSelectionProvider(showId)).selectedSeatIds, <int>{
      seat.id,
    });

    controller.toggleSeat(seat);
    expect(
      container.read(seatSelectionProvider(showId)).selectedSeatIds,
      isEmpty,
    );
  });

  test('已选 6 座后再点新座位不生效，取消后可继续选', () {
    final container = createContainer();
    const showId = '1001';
    final controller = container.read(seatSelectionProvider(showId).notifier);
    final map = container.read(seatSelectionProvider(showId)).mapData;
    final available = allSeats(map).where((s) => s.isSelectable).toList();

    for (final seat in available.take(6)) {
      controller.toggleSeat(seat);
    }
    expect(container.read(seatSelectionProvider(showId)).atMax, isTrue);

    controller.toggleSeat(available[6]);
    expect(container.read(seatSelectionProvider(showId)).count, 6);

    controller.toggleSeat(available[0]);
    controller.toggleSeat(available[6]);
    final state = container.read(seatSelectionProvider(showId));
    expect(state.count, 6);
    expect(state.selectedSeatIds, contains(available[6].id));
  });

  test('totalPrice 按选中座位的票价求和；clear 清空', () {
    final container = createContainer();
    const showId = '1001';
    final controller = container.read(seatSelectionProvider(showId).notifier);
    final map = container.read(seatSelectionProvider(showId)).mapData;
    final seats = allSeats(map);
    final vip = map.areas[0].rows.first.seats.firstWhere((s) => s.isSelectable);
    final areaA = map.areas[1].rows.first.seats.firstWhere(
      (s) => s.isSelectable,
    );
    expect(seats, contains(vip));

    controller.setSelection(<int>[vip.id, areaA.id]);
    final state = container.read(seatSelectionProvider(showId));
    expect(
      state.totalPrice,
      Money.fromMinorUnits(vip.price!.minorUnits + areaA.price!.minorUnits),
    );
    expect(state.selectedSeats.map((s) => s.areaName), <String>['VIP区', 'A区']);

    controller.clear();
    expect(
      container.read(seatSelectionProvider(showId)).selectedSeats,
      isEmpty,
    );
    expect(
      container.read(seatSelectionProvider(showId)).totalPrice,
      Money.zero(),
    );
  });

  test('选中态跨页面保留（同一 showId 的 provider 不被重建）', () {
    final container = createContainer();
    const showId = '1001';
    final map = container.read(seatSelectionProvider(showId)).mapData;
    final seat = allSeats(map).firstWhere((s) => s.isSelectable);

    container.read(seatSelectionProvider(showId).notifier).setSelection(<int>[
      seat.id,
    ]);

    // 模拟从确认订单页返回：重新读取同一个 family，状态仍在。
    expect(container.read(seatSelectionProvider(showId)).selectedSeatIds, <int>{
      seat.id,
    });
  });
}
