import 'package:core/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/app/app.dart';
import 'package:planstar/app/theme.dart';
import 'package:planstar/features/goods/seatmap/seat_map.dart';
import 'package:planstar/features/order/widgets/selected_seats_section.dart';
import 'package:planstar/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('zh'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

Seat _seat({
  required int id,
  required String area,
  required String row,
  required String col,
  required int priceMinor,
}) {
  return Seat(
    id: id,
    row: row,
    col: col,
    x: 0,
    y: 0,
    status: SeatStatus.available,
    areaName: area,
    price: Money.fromMinorUnits(priceMinor),
  );
}

void main() {
  testWidgets('展示全部座位信息与座位小计', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SelectedSeatsSection(
          seats: <Seat>[
            _seat(id: 1, area: 'VIP区', row: 'A', col: '2', priceMinor: 128000),
            _seat(id: 2, area: 'A区', row: 'B', col: '3', priceMinor: 88000),
          ],
        ),
      ),
    );

    expect(find.text('已选座位'), findsOneWidget);
    expect(find.text('已选 2 座'), findsOneWidget);
    expect(find.text('VIP区 A排2座'), findsOneWidget);
    expect(find.text('A区 B排3座'), findsOneWidget);
    expect(find.text('座位小计'), findsOneWidget);
    expect(find.text('¥2,160.00'), findsOneWidget);
  });

  testWidgets('未选座时不渲染任何内容', (tester) async {
    await tester.pumpWidget(_wrap(const SelectedSeatsSection(seats: <Seat>[])));

    expect(find.text('已选座位'), findsNothing);
    expect(find.text('座位小计'), findsNothing);
  });
}
