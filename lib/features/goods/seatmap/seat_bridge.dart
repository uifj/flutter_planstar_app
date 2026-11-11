import 'dart:convert';

import 'seat_map.dart';

/// WebView 侧发往 Flutter 的事件（`PsSeatBridge` 通道的 JSON 载荷）。
sealed class SeatBridgeEvent {
  const SeatBridgeEvent();
}

/// 页面与 JS 通道已就绪：可以下发座位图数据。
final class SeatBridgeReady extends SeatBridgeEvent {
  const SeatBridgeReady();
}

/// 座位选择发生变化（全量快照，不是增量）。
final class SeatBridgeSelection extends SeatBridgeEvent {
  const SeatBridgeSelection(this.seatIds);

  final Set<int> seatIds;
}

/// 已选数量达到上限，用户仍尝试继续选座。
final class SeatBridgeLimit extends SeatBridgeEvent {
  const SeatBridgeLimit(this.maxSeats);

  final int maxSeats;
}

/// 解析 WebView 消息；非本协议或结构不合法时返回 `null`（忽略即可）。
SeatBridgeEvent? parseSeatBridgeEvent(String raw) {
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, dynamic>) return null;

  switch (decoded['type']) {
    case 'ready':
      return const SeatBridgeReady();
    case 'selection':
      final rawIds = decoded['ids'];
      if (rawIds is! List) return null;
      final ids = <int>{};
      for (final id in rawIds) {
        if (id is num) ids.add(id.toInt());
      }
      return SeatBridgeSelection(ids);
    case 'limit':
      final rawMax = decoded['max'];
      return SeatBridgeLimit(rawMax is num ? rawMax.toInt() : 6);
    default:
      return null;
  }
}

/// 生成 `window.PsSeat.init(...)` 脚本：一次性下发座位图与已选状态。
String encodeSeatMapInitScript({
  required SeatMapData mapData,
  required int maxSeats,
  required Set<int> selectedSeatIds,
}) {
  final payload = <String, Object?>{
    'stageLabel': mapData.stageLabel,
    'venueName': mapData.venueName,
    'maxSeats': maxSeats,
    'selection': _sortedIds(selectedSeatIds),
    'areas': <Map<String, Object?>>[
      for (final area in mapData.areas)
        <String, Object?>{
          'id': area.id,
          'name': area.name,
          'color': _hexColor(area.color),
          'price': _areaPrice(area),
          'available': area.availableCount,
          'rows': <Map<String, Object?>>[
            for (final row in area.rows)
              <String, Object?>{
                'label': row.label,
                'seats': <Map<String, Object?>>[
                  for (final seat in row.seats)
                    <String, Object?>{
                      'id': seat.id,
                      'col': seat.col,
                      'status': seat.status.name,
                      'price': seat.price?.minorUnits ?? 0,
                    },
                ],
              },
          ],
        },
    ],
  };
  return 'window.PsSeat.init(${jsonEncode(payload)});';
}

/// 生成 `window.PsSeat.applySelection(...)` 脚本：只同步选中态，不触发回传。
String encodeSeatSelectionScript(Set<int> seatIds) {
  return 'window.PsSeat.applySelection(${jsonEncode(_sortedIds(seatIds))});';
}

List<int> _sortedIds(Set<int> ids) => ids.toList()..sort();

String? _hexColor(int? argb) {
  if (argb == null) return null;
  final rgb = argb & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// 区域单价（同一区域内单价一致；取首个有价座位）。
int _areaPrice(SeatArea area) {
  for (final row in area.rows) {
    for (final seat in row.seats) {
      final price = seat.price;
      if (price != null) return price.minorUnits;
    }
  }
  return 0;
}
