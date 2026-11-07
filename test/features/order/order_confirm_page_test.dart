import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planstar/app/app.dart' show appLocalizationsDelegates;
import 'package:planstar/app/network/network_providers.dart';
import 'package:planstar/features/order/order_confirm_page.dart';
import 'package:planstar/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[useDemoProvider.overrideWithValue(true)],
        child: MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OrderConfirmPage(showId: '10086'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('渲染演出信息与应付金额', (WidgetTester tester) async {
    await pumpPage(tester);

    expect(find.text('《星海回声》企划'), findsOneWidget);
    expect(find.text('内场 A 区'), findsOneWidget);
    expect(find.text('¥680.00'), findsWidgets);
  });

  testWidgets('勾选协议后提交按钮才可用（默认不勾）', (WidgetTester tester) async {
    await pumpPage(tester);

    // 协议行在列表下方，先滚动到可见（ListView 是懒构建的）。
    final agreement = find.textContaining('我已阅读并同意');
    await tester.scrollUntilVisible(agreement, 300);
    await tester.drag(find.byType(ListView), const Offset(0, -120));
    await tester.pumpAndSettle();

    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.pumpAndSettle();
    expect(checkbox, findsOneWidget);
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    expect(tester.widget<Checkbox>(checkbox).onChanged, isNotNull);
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).onChanged,
      isNotNull,
    );

    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
  });

  testWidgets('加票档后应付金额翻倍', (WidgetTester tester) async {
    await pumpPage(tester);

    await tester.tap(find.byIcon(LucideIcons.circlePlus).first);
    await tester.pumpAndSettle();

    expect(find.text('¥1,360.00'), findsWidgets);
  });
}
