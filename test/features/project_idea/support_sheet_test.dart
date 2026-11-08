import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/app/app.dart' show appLocalizationsDelegates;
import 'package:planstar/app/theme.dart';
import 'package:planstar/features/project_idea/model/project_idea.dart';
import 'package:planstar/features/project_idea/support_sheet.dart';
import 'package:planstar/l10n/generated/app_localizations.dart';

void main() {
  const IdeaVoteResult result = IdeaVoteResult(
    supportCount: 12,
    opposeCount: 3,
    alreadyVoted: false,
    myVote: IdeaVote(voteType: 1, coinTier: 5),
  );

  /// 打开真实的 modal bottom sheet：与线上入口一致，同时让成功后的 pop 有
  /// 路由可回，不会把测试里的根路由弹空。
  Future<void> pumpSheet(
    WidgetTester tester, {
    required SupportSubmitCallback onSubmit,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('zh'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => SupportSheet.show(context, onSubmit: onSubmit),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('默认选中 5 星币，展示免责文案，提交参数为默认档', (WidgetTester tester) async {
    final List<SupportSelection> submitted = <SupportSelection>[];
    await pumpSheet(
      tester,
      onSubmit: (SupportSelection selection) async {
        submitted.add(selection);
        return result;
      },
    );

    expect(find.text('支持这个企划'), findsOneWidget);
    expect(find.text('仅表达支持意愿，不会扣除星币'), findsOneWidget);
    expect(find.text('5 星币'), findsOneWidget);
    expect(find.text('10 星币'), findsOneWidget);
    expect(find.text('20 星币'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('support-submit')));
    await tester.pumpAndSettle();

    expect(submitted, hasLength(1));
    expect(submitted.single.tier, 5);
    expect(submitted.single.reason, isEmpty);
  });

  testWidgets('切换 10 / 20 档位后提交对应档位', (WidgetTester tester) async {
    for (final int tier in <int>[10, 20]) {
      final List<SupportSelection> submitted = <SupportSelection>[];
      await pumpSheet(
        tester,
        onSubmit: (SupportSelection selection) async {
          submitted.add(selection);
          return result;
        },
      );

      await tester.tap(find.byKey(ValueKey<String>('support-tier-$tier')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('support-submit')));
      await tester.pumpAndSettle();

      expect(submitted.single.tier, tier);
    }
  });

  testWidgets('理由输入限制 60 字且计数同步', (WidgetTester tester) async {
    final List<SupportSelection> submitted = <SupportSelection>[];
    await pumpSheet(
      tester,
      onSubmit: (SupportSelection selection) async {
        submitted.add(selection);
        return result;
      },
    );

    final Finder field = find.byKey(
      const ValueKey<String>('support-reason-field'),
    );
    await tester.enterText(field, '看' * 70);
    await tester.pump();

    expect(find.text('60/60'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('support-submit')));
    await tester.pumpAndSettle();

    expect(submitted.single.reason.length, ideaSupportReasonMaxLength);
  });
}
