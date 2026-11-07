import 'dart:convert';

import 'package:core/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/goods/seatmap/seat_bridge.dart';
import 'package:planstar/features/goods/seatmap/seat_map.dart';

SeatMapData _mapData() {
  return SeatMapData(
    venueName: '上海文化广场',
    stageLabel: '舞台',
    areas: <SeatArea>[
      SeatArea(
        id: 1,
        name: 'VIP区',
        width: 2,
        height: 1,
        color: 0xFFFFD700,
        rows: <SeatRow>[
          SeatRow(
            label: 'A',
            y: 0,
            seats: <Seat>[
              Seat(
                id: 10001,
                row: 'A',
                col: '1',
                x: 0,
                y: 0,
                status: SeatStatus.available,
                areaName: 'VIP区',
                price: Money.fromMinorUnits(128000),
                categoryId: 1,
              ),
              Seat(
                id: 10002,
                row: 'A',
                col: '2',
                x: 1,
                y: 0,
                status: SeatStatus.sold,
                areaName: 'VIP区',
                price: Money.fromMinorUnits(128000),
                categoryId: 1,
              ),
              Seat(
                id: 10003,
                row: 'A',
                col: '3',
                x: 2,
                y: 0,
                status: SeatStatus.aisle,
                areaName: 'VIP区',
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  group('parseSeatBridgeEvent', () {
    test('ready 事件', () {
      expect(parseSeatBridgeEvent('{"type":"ready"}'), isA<SeatBridgeReady>());
    });

    test('selection 事件解析为整型集合（全量快照）', () {
      final event = parseSeatBridgeEvent(
        '{"type":"selection","ids":[10001,10002,10001]}',
      );
      expect(event, isA<SeatBridgeSelection>());
      expect((event as SeatBridgeSelection).seatIds, <int>{10001, 10002});
    });

    test('limit 事件携带上限', () {
      final event = parseSeatBridgeEvent('{"type":"limit","max":6}');
      expect((event as SeatBridgeLimit).maxSeats, 6);
    });

    test('非法载荷返回 null', () {
      expect(parseSeatBridgeEvent('not-json'), isNull);
      expect(parseSeatBridgeEvent('[]'), isNull);
      expect(parseSeatBridgeEvent('{"type":"unknown"}'), isNull);
      expect(parseSeatBridgeEvent('{"type":"selection"}'), isNull);
    });
  });

  group('encodeSeatMapInitScript', () {
    test('下发座位图、票价与已选状态', () {
      final script = encodeSeatMapInitScript(
        mapData: _mapData(),
        maxSeats: 6,
        selectedSeatIds: <int>{10001},
      );

      expect(script, startsWith('window.PsSeat.init('));
      final decoded =
          jsonDecode(
                script.substring(
                  'window.PsSeat.init('.length,
                  script.length - 2,
                ),
              )
              as Map<String, dynamic>;

      expect(decoded['stageLabel'], '舞台');
      expect(decoded['maxSeats'], 6);
      expect(decoded['selection'], <int>[10001]);

      final area =
          (decoded['areas'] as List<dynamic>).single as Map<String, dynamic>;
      expect(area['name'], 'VIP区');
      expect(area['price'], 128000);
      expect(area['color'], '#FFD700');
      expect(area['available'], 1);

      final seats =
          ((area['rows'] as List<dynamic>).single
                  as Map<String, dynamic>)['seats']
              as List<dynamic>;
      expect(seats, hasLength(3));
      expect((seats[0] as Map<String, dynamic>)['status'], 'available');
      expect((seats[1] as Map<String, dynamic>)['status'], 'sold');
      expect((seats[2] as Map<String, dynamic>)['status'], 'aisle');
    });
  });

  test('applySelection 脚本按 id 升序同步且不回传', () {
    expect(
      encodeSeatSelectionScript(<int>{10003, 10001}),
      'window.PsSeat.applySelection([10001,10003]);',
    );
  });
}
