import 'package:core/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/goods/seatmap/seat_lock_service.dart';
import 'package:planstar/features/goods/seatmap/seat_map.dart';
import 'package:planstar/features/goods/seatmap/seat_selection_providers.dart';

const String showId = '1001';

SeatMapData _mapData() {
  SeatRow buildRow(String label, int y, int baseId) {
    return SeatRow(
      label: label,
      y: y,
      seats: <Seat>[
        for (var x = 0; x < 4; x++)
          Seat(
            id: baseId + x,
            row: label,
            col: '${x + 1}',
            x: x,
            y: y,
            status: SeatStatus.available,
            areaName: 'A区',
            price: Money.fromMinorUnits(10000),
          ),
      ],
    );
  }

  return SeatMapData(
    venueName: '测试场馆',
    stageLabel: '舞台',
    areas: <SeatArea>[
      SeatArea(
        id: 1,
        name: 'A区',
        width: 4,
        height: 2,
        rows: <SeatRow>[buildRow('A', 0, 1), buildRow('B', 1, 100)],
      ),
    ],
  );
}

ProviderContainer _createContainer({
  required SeatLockService locks,
  Duration window = const Duration(minutes: 10),
}) {
  return ProviderContainer(
    overrides: <Override>[
      seatMapDataProvider(showId).overrideWithValue(_mapData()),
      seatLockServiceProvider(showId).overrideWithValue(locks),
      seatSelectionDurationProvider.overrideWithValue(window),
    ],
  );
}

void main() {
  test('取消选择释放锁；已被他人锁定的座位不可选', () {
    final locks = SeatLockService();
    final container = _createContainer(locks: locks);
    addTearDown(container.dispose);

    final controller = container.read(seatSelectionProvider(showId).notifier);
    final state = container.read(seatSelectionProvider(showId));
    final first = state.mapData.areas.first.rows.first.seats[0];
    final second = state.mapData.areas.first.rows.first.seats[1];

    controller.toggleSeat(first);
    expect(locks.isLocked(first.id), isTrue);

    controller.toggleSeat(first);
    expect(locks.isLocked(first.id), isFalse);

    expect(locks.lock(second.id), isTrue);
    controller.toggleSeat(second);
    expect(
      container.read(seatSelectionProvider(showId)).selectedSeatIds,
      isEmpty,
    );
  });

  testWidgets('倒计时归零后清空选择并释放全部锁', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());

    final locks = SeatLockService();
    final container = _createContainer(
      locks: locks,
      window: const Duration(seconds: 2),
    );

    try {
      final initial = container.read(seatSelectionProvider(showId));
      expect(initial.leftSeconds, 2);

      final seat = initial.mapData.areas.first.rows.first.seats[0];
      container.read(seatSelectionProvider(showId).notifier).toggleSeat(seat);
      expect(locks.isLocked(seat.id), isTrue);

      await tester.pump(const Duration(seconds: 2));

      final state = container.read(seatSelectionProvider(showId));
      expect(state.count, 0);
      expect(state.leftSeconds, 0);
      expect(state.timedOut, isTrue);
      expect(locks.isLocked(seat.id), isFalse);
    } finally {
      container.dispose();
    }
  });
}
