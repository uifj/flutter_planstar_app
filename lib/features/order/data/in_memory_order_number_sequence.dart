import 'package:core_result/core_result.dart';

import '../domain/domain.dart';

/// 内存订单号序列 —— 适配器。
///
/// 真实实现由服务端分配（企划星的订单号在 `makeOrder` 响应里），
/// 或者走 Redis `INCR` 的本地预分配。这里按"当天重置"的规则模拟。
final class InMemoryOrderNumberSequence implements OrderNumberSequence {
  int _sequence = 0;
  String? _currentDay;

  @override
  Future<Result<OrderNumber>> next(DateTime date) async {
    final day = '${date.year}${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    if (_currentDay != day) {
      _currentDay = day;
      _sequence = 0;
    }
    _sequence++;
    return Success<OrderNumber>(
      OrderNumber.generate(date: date, sequence: _sequence),
    );
  }
}
