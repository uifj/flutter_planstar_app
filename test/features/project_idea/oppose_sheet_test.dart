import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/app/app.dart' show appLocalizationsDelegates;
import 'package:planstar/app/theme.dart';
import 'package:planstar/features/project_idea/model/project_idea.dart';
import 'package:planstar/features/project_idea/oppose_sheet.dart';
import 'package:planstar/l10n/generated/app_localizations.dart';

void main() {
  const IdeaVoteResult result = IdeaVoteResult(
    supportCount: 12,
    opposeCount: 4,
    alreadyVoted: false,
    myVote: IdeaVote(voteType: 2, reasonCode: 'too_many_similar'),
  );

  Future<void> pumpSheet(
    WidgetTester tester, {
    required OpposeSubmitCallback onSubmit,
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
                onPressed: () => OpposeSheet.show(context, onSubmit: onSubmit),
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

  FilledButton submitButton(WidgetTester tester) => tester.widget<FilledButton>(
    find.byKey(const ValueKey<String>('oppose-submit')),
  );

  testWidgets('未选理由时提交按钮置灰', (WidgetTester tester) async {
    await pumpSheet(
      tester,
      onSubmit: (OpposeSelection selection) async => result,
    );

    expect(find.text('为什么不支持？'), findsOneWidget);
    expect(submitButton(tester).onPressed, isNull);
  });

  testWidgets('选「其他」后必须填写自定义理由才能提交', (WidgetTester tester) async {
    final List<OpposeSelection> submitted = <OpposeSelection>[];
    await pumpSheet(
      tester,
      onSubmit: (OpposeSelection selection) async {
        submitted.add(selection);
        return result;
      },
    );

    await tester.tap(find.byKey(const ValueKey<String>('oppose-reason-other')));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('oppose-reason-field')),
      findsOneWidget,
    );
    expect(submitButton(tester).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey<String>('oppose-reason-field')),
      '和已有企划重复了',
    );
    await tester.pump();

    expect(submitButton(tester).onPressed, isNotNull);
    await tester.tap(find.byKey(const ValueKey<String>('oppose-submit')));
    await tester.pumpAndSettle();

    expect(submitted.single.reasonCode, IdeaOpposeReason.other.code);
    expect(submitted.single.reasonText, '和已有企划重复了');
  });

  testWidgets('选择标准理由后提交回调参数正确', (WidgetTester tester) async {
    final List<OpposeSelection> submitted = <OpposeSelection>[];
    await pumpSheet(
      tester,
      onSubmit: (OpposeSelection selection) async {
        submitted.add(selection);
        return result;
      },
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('oppose-reason-too_many_similar')),
    );
    await tester.pump();

    expect(submitButton(tester).onPressed, isNotNull);
    await tester.tap(find.byKey(const ValueKey<String>('oppose-submit')));
    await tester.pumpAndSettle();

    expect(submitted, hasLength(1));
    expect(submitted.single.reasonCode, 'too_many_similar');
    expect(submitted.single.reasonText, isEmpty);
  });
}
