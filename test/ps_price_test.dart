import 'package:core_design_system/core_design_system.dart';
import 'package:core/domain.dart';
import 'package:flutter/material.dart';
import 'package:planstar/shared/ui/ps_price.dart';
import 'package:flutter_test/flutter_test.dart';

/// `ShowCardChoiceness` 是固定 105dp 的卡片，底部那行把剩余空间按 flex
/// 均分给价格和角标，价格实际只拿到 **52.5dp**。
const double _squeezedWidth = 52.5;

Widget _host(Widget child, {double width = _squeezedWidth}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Center(
        // SizedBox 给的是紧约束（minWidth == maxWidth），和卡片里
        // `Expanded` 分到 52.5dp 时的约束完全一致。
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

void main() {
  // 回归缺陷：`PsPrice` 的根是一个 `mainAxisSize: min` 且无 flex 子节点的
  // Row，被塞进紧约束时子节点无法收缩，`¥880起` 需要约 71dp → 溢出 19px。
  // 症状是每个带角标的精选卡片在真机上也溢出（卡片宽度写死 105dp，
  // 与屏幕宽度无关），不只是测试环境。
  testWidgets('被挤到 52.5dp 时不溢出（回归）', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(PsPrice(amount: Money.fromYuan(880), size: 16, suffix: '起')),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('空间够时保持原尺寸，不无谓缩小', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(
        PsPrice(amount: Money.fromYuan(880), size: 16, suffix: '起'),
        width: 300,
      ),
    );

    expect(tester.takeException(), isNull);
    // 自然宽度约 71dp，明显大于 52.5dp：说明只有空间不足时才缩放，
    // 空间充足时不会把价格缩小（否则列表里的价格会莫名其妙变小）。
    expect(
      tester.getSize(find.byType(PsPrice)).width,
      greaterThan(_squeezedWidth),
    );
  });

  testWidgets('前缀 + 后缀 + 划线价全开时也不溢出', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(
        PsPrice(
          amount: Money.fromYuan(1880),
          size: 16,
          prefix: '代抢费：',
          suffix: '起',
          strikeThroughAmount: Money.fromYuan(2280),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('负数金额带上负号', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(PsPrice(amount: Money.fromYuan(-50), size: 16), width: 300),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('-¥'), findsOneWidget);
  });
}
