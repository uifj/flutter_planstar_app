import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:planstar/app/app.dart';
import 'package:planstar/app/theme.dart';
import 'package:planstar/l10n/generated/app_localizations.dart';
import 'package:planstar/shell/root_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// 四个 Tab 的**空壳**路由，只为了拿到一个真实的 `StatefulNavigationShell`。
///
/// 刻意不 import 任何真实页面。`RootShell` 的契约只有一条——底栏文案来自
/// l10n 而不是硬编码中文——把真实页面拉进来只会让这条断言跟着每个页面的
/// 改版一起红（首页改一次布局、价格组件多占一像素，底栏测试就挂，久了就
/// 没人跑它）。页面内容属于各 feature 自己的测试职责。
///
/// 这正是 `test/l10n_wiring_test.dart` 里同一条原则的延续：断言稳定契约，
/// 不断言易变的渲染结果。
GoRouter _stubRouter() {
  // 顺序必须与 `RootShell._tabs` 一致：分支索引就是底栏 tab 索引。
  // 消息 / 订单已收敛为「我的」的二级页（顶层路由），不再是底栏分支。
  const List<String> paths = <String>[
    '/',
    '/discover',
    '/project-idea',
    '/me',
  ];
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            RootShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          for (final String path in paths)
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: path,
                  builder: (context, state) => const SizedBox.shrink(),
                ),
              ],
            ),
        ],
      ),
    ],
  );
}

/// 渲染「外壳 + 空分支」，并锁定语言。
Future<void> _pumpShell(WidgetTester tester, Locale locale) async {
  // 用 localesTestValue 整体替换：localeTestValue 是在默认 en_US 之外追加，
  // 解析仍会命中 en。
  tester.platformDispatcher.localesTestValue = <Locale>[locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  final GoRouter router = _stubRouter();
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light(),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('主题令牌', () {
    test('品牌色是 TUIKit 蓝色，且不是 fromSeed 派生出来的', () {
      final ThemeData light = AppTheme.light();

      // 品牌色必须**等于**色板里的常量。`ColorScheme.fromSeed` 会把种子色
      // 派生成一套"更协调"的色调，品牌蓝就失真了——这条断言就是防它回潮。
      expect(light.colorScheme.primary, BasePalette.primary);
      expect(light.brightness, Brightness.light);

      // 语义槽必须挂得上，否则所有 Pn* 组件都会回落到硬编码色。
      expect(light.extension<AppColors>(), isNotNull);
    });

    test('暗色不是亮色的复制品', () {
      final AppColors lightColors = AppTheme.light().extension<AppColors>()!;
      final AppColors darkColors = AppTheme.dark().extension<AppColors>()!;

      expect(AppTheme.dark().brightness, Brightness.dark);
      // `AppColors` 手写了 `operator ==` 覆盖全部 24 个槽（缺陷 30-10）；
      // 这里同时验证了「相等判断是对的」和「暗色确实换了一套值」。
      expect(darkColors, isNot(equals(lightColors)));
      expect(darkColors, equals(AppColors.dark));
      expect(lightColors, equals(lightColors.copyWith()));
    });

    testWidgets('主题令牌下发到 widget 树', (WidgetTester tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (BuildContext context) {
              captured = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final ThemeData theme = Theme.of(captured);
      expect(theme.colorScheme.primary, BasePalette.primary);
      expect(theme.extension<AppColors>(), isNotNull);
      // 走扩展方法取语义槽，证明 `context.appColors` 这条读取路径可用。
      expect(captured.appColors.price, AppColors.light.price);
    });
  });

  group('底栏文案走 l10n', () {
    testWidgets('中文', (WidgetTester tester) async {
      await _pumpShell(tester, const Locale('zh', 'CN'));

      expect(find.text('首页'), findsWidgets);
      expect(find.text('发现'), findsWidgets);
      expect(find.text('企划'), findsWidgets);
      expect(find.text('我的'), findsWidgets);
      // 消息 / 订单已移出底栏，底栏上不应再出现这两个标签。
      expect(find.text('消息'), findsNothing);
      expect(find.text('订单'), findsNothing);
    });

    testWidgets('英文（证明没有硬编码中文）', (WidgetTester tester) async {
      await _pumpShell(tester, const Locale('en', 'US'));

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Discover'), findsWidgets);
      // app_en.arb 里 tabProject 的实际值是 "Pitches"（不是 "Projects"）。
      expect(find.text('Pitches'), findsWidgets);
      expect(find.text('Me'), findsWidgets);
      // 消息 / 订单已移出底栏（英文标签同样不应出现）。
      expect(find.text('Messages'), findsNothing);
      expect(find.text('Orders'), findsNothing);

      // 最关键的一条：切成英文后中文必须一个都不剩。
      expect(find.text('首页'), findsNothing);
      expect(find.text('发现'), findsNothing);
      expect(find.text('企划'), findsNothing);
      expect(find.text('我的'), findsNothing);
    });
  });

  group('四个 tab 在小屏不溢出', () {
    const List<(double width, double height)> viewports =
        <(double, double)>[
          (360, 800),
          (390, 844),
          (430, 932),
        ];

    for (final (double width, double height) in viewports) {
      testWidgets('${width.toInt()}x${height.toInt()} 下 4 个标签完整存在', (
        WidgetTester tester,
      ) async {
        const double dpr = 2.0;
        tester.view.devicePixelRatio = dpr;
        tester.view.physicalSize = Size(width * dpr, height * dpr);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await _pumpShell(tester, const Locale('zh', 'CN'));

        // 任何 RenderFlex overflow 都会在这里冒出来。
        expect(tester.takeException(), isNull);

        expect(find.text('首页'), findsWidgets);
        expect(find.text('发现'), findsWidgets);
        expect(find.text('企划'), findsWidgets);
        expect(find.text('我的'), findsWidgets);
      });
    }
  });

  test('themeModeProvider 可切换', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);
    container.read(themeModeProvider.notifier).set(ThemeMode.dark);
    expect(container.read(themeModeProvider), ThemeMode.dark);

    // system + 系统为暗 → 切到亮。
    container.read(themeModeProvider.notifier).set(ThemeMode.system);
    container.read(themeModeProvider.notifier).toggle(Brightness.dark);
    expect(container.read(themeModeProvider), ThemeMode.light);
  });
}
