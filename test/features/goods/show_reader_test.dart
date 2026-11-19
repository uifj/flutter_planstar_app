import 'package:flutter/material.dart';
import 'package:flutter_book_reader/flutter_book_reader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planstar/app/app.dart' show appLocalizationsDelegates;
import 'package:planstar/app/network/network_providers.dart';
import 'package:planstar/app/theme.dart';
import 'package:planstar/features/catalog/data/demo_catalog.dart';
import 'package:planstar/features/catalog/domain/show_summary.dart';
import 'package:planstar/features/goods/reader/show_book_source.dart';
import 'package:planstar/features/goods/reader/show_reader_page.dart';
import 'package:planstar/features/goods/show_detail_page.dart';
import 'package:planstar/l10n/l10n.dart';

/// 「阅读企划」链路：详情页按钮 → 阅读页 → 章节正文。
///
/// 这里只断言链路与数据结构，不比对分页像素：分页结果依赖字号与屏宽，
/// 断言具体页码会让每次排版微调都变成一次改测试。
void main() {
  ShowSummary demoShow() =>
      buildDemoCatalog().firstWhere((ShowSummary show) => show.id == '1001');

  testWidgets('企划章节结构完整，正文按区块映射', (WidgetTester tester) async {
    late List<ShowBookChapter> chapters;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        home: Builder(
          builder: (BuildContext context) {
            chapters = buildShowChapters(demoShow(), AppL10n.of(context));
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(chapters, hasLength(8));
    expect(
      chapters.map((ShowBookChapter c) => c.title),
      <String>['企划故事', '目标进度', '回报档位', '进度更新', '风险说明', '常见问题', '支持须知', '创作者信息'],
    );
    for (final ShowBookChapter chapter in chapters) {
      expect(chapter.body.trim(), isNotEmpty, reason: '${chapter.title} 正文为空');
    }
    // 关键区块确实带上了企划数据，而不是只有空态兜底。
    final ShowSummary show = demoShow();
    expect(chapters[0].body, show.intro.trim());
    if (show.tiers.isNotEmpty) {
      expect(chapters[2].body, contains(show.tiers.first.name));
    }
    if (show.updates.isNotEmpty) {
      expect(chapters[3].body, contains(show.updates.first.title));
    }
    if (show.faqs.isNotEmpty) {
      expect(chapters[5].body, contains(show.faqs.first.question));
    }
    expect(chapters[7].body, contains(show.artist));
  });

  testWidgets('详情页点击「阅读企划」进入阅读页', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final GoRouter router = GoRouter(
      initialLocation: '/show/1001',
      routes: <RouteBase>[
        GoRoute(
          path: '/show/:showId',
          builder: (BuildContext context, GoRouterState state) =>
              ShowDetailPage(showId: state.pathParameters['showId']!),
        ),
        GoRoute(
          path: '/show/:showId/read',
          builder: (BuildContext context, GoRouterState state) => ShowReaderPage(
            showId: state.pathParameters['showId']!,
            initialShow: switch (state.extra) {
              final ShowSummary show => show,
              _ => null,
            },
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[useDemoProvider.overrideWithValue(true)],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light(),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('zh'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('阅读企划'), findsOneWidget);
    expect(find.byType(ShowReaderPage), findsNothing);

    await tester.tap(find.text('阅读企划'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ShowReaderPage), findsOneWidget);
    // 阅读器挂在页面根上，证明数据已就绪并完成首屏分页。
    expect(find.byType(BookReader), findsOneWidget);
  });

  testWidgets('阅读页可打开目录并切换章节', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[useDemoProvider.overrideWithValue(true)],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('zh'),
          home: ShowReaderPage(showId: '1001', initialShow: demoShow()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 点正文中间唤起阅读器菜单，再进目录。
    await tester.tapAt(tester.getCenter(find.byType(BookReader)));
    await tester.pumpAndSettle();
    expect(find.text('目录'), findsWidgets);

    await tester.tap(find.text('目录').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('目标进度').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('目标进度'), findsWidgets);
  });
}
