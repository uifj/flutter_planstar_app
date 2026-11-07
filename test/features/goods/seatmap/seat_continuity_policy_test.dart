import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/goods/seatmap/domain/seat_continuity_policy.dart';
import 'package:planstar/features/goods/seatmap/seat_map.dart';

Seat _seat({
  required int id,
  required String area,
  required String row,
  required int x,
}) {
  return Seat(
    id: id,
    row: row,
    col: '${x + 1}',
    x: x,
    y: 0,
    status: SeatStatus.available,
    areaName: area,
  );
}

void main() {
  const policy = SeatContinuityPolicy();

  test('同排相邻座位通过', () {
    final result = policy.validate(<Seat>[
      _seat(id: 1, area: 'VIP区', row: 'A', x: 1),
      _seat(id: 2, area: 'VIP区', row: 'A', x: 2),
      _seat(id: 3, area: 'VIP区', row: 'A', x: 3),
    ]);

    expect(result.isSuccess, isTrue);
  });

  test('单座视为通过', () {
    final result = policy.validate(<Seat>[
      _seat(id: 1, area: 'VIP区', row: 'A', x: 1),
    ]);

    expect(result.isSuccess, isTrue);
  });

  test('跨排选择被拒绝', () {
    final result = policy.validate(<Seat>[
      _seat(id: 1, area: 'VIP区', row: 'A', x: 1),
      _seat(id: 2, area: 'VIP区', row: 'B', x: 2),
    ]);

    expect(result.isFailure, isTrue);
    expect(result.failure?.code, 'SEAT_NOT_CONTINUOUS');
  });

  test('跨区域选择被拒绝', () {
    final result = policy.validate(<Seat>[
      _seat(id: 1, area: 'VIP区', row: 'A', x: 1),
      _seat(id: 2, area: 'A区', row: 'A', x: 2),
    ]);

    expect(result.isFailure, isTrue);
    expect(result.failure?.code, 'SEAT_NOT_CONTINUOUS');
  });

  test('同排但列号不连续被拒绝', () {
    final result = policy.validate(<Seat>[
      _seat(id: 1, area: 'VIP区', row: 'A', x: 1),
      _seat(id: 2, area: 'VIP区', row: 'A', x: 3),
    ]);

    expect(result.isFailure, isTrue);
    expect(result.failure?.message, '请选择同一区域同一排的相邻座席');
  });
}
