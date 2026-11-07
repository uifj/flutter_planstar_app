import 'package:core/result.dart';

import '../seat_map.dart';

/// 连座策略 —— **无状态领域服务**。
///
/// 与企划星 `isContinuousSeat` 对齐：选中座位必须满足
/// 「同一区域 + 同一排 + 列号（`x`）连续」。
final class SeatContinuityPolicy {
  const SeatContinuityPolicy();

  /// 校验选中座位是否连座。
  ///
  /// 空选 / 单座视为通过（单座天然连座）。
  Result<void> validate(List<Seat> seats) {
    if (seats.length <= 1) return const Success<void>(null);

    final areaName = seats.first.areaName;
    final row = seats.first.row;
    for (final seat in seats) {
      if (seat.areaName != areaName || seat.row != row) {
        return _fail();
      }
    }

    final columns = seats.map((seat) => seat.x).toSet().toList()..sort();
    if (columns.length != seats.length) return _fail();
    for (var i = 1; i < columns.length; i++) {
      if (columns[i] - columns[i - 1] != 1) return _fail();
    }
    return const Success<void>(null);
  }

  Result<void> _fail() {
    return const Fail<void>(
      Failure(
        code: 'SEAT_NOT_CONTINUOUS',
        message: '请选择同一区域同一排的相邻座席',
        type: FailureType.validation,
      ),
    );
  }
}
