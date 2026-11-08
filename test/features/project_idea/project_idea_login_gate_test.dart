import 'dart:convert';
import 'dart:typed_data';

import 'package:core/network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planstar/app/app.dart' show appLocalizationsDelegates;
import 'package:planstar/app/session.dart';
import 'package:planstar/app/theme.dart';
import 'package:planstar/features/project_idea/application/project_idea_providers.dart';
import 'package:planstar/features/project_idea/data/project_idea_api.dart';
import 'package:planstar/features/project_idea/project_idea_page.dart';
import 'package:planstar/l10n/generated/app_localizations.dart';

/// 固定返回一张卡片的假 feed：真实控制器 + 假网络层，不碰生产逻辑。
final class _FeedAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(<String, Object?>{
        'items': <Map<String, Object?>>[
          <String, Object?>{
            'ideaId': 1,
            'title': '会唱歌的冰箱贴',
            'summary': '贴在冰箱上，做饭时提醒你下一步放什么。',
            // 封面 / 头像留空，避免 widget test 触发网络图片。
            'cover': '',
            'categoryId': 1,
            'categoryName': '生活创意',
            'creatorName': '小牛',
            'creatorAvatar': '',
            'supportCount': 10,
            'opposeCount': 2,
            'createdAt': '2026-01-01T00:00:00Z',
          },
        ],
        'hasMore': false,
      }),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  testWidgets('游客点「支持」被登录门禁拦下，并带上来源跳登录', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.localesTestValue = <Locale>[
      const Locale('zh', 'CN'),
    ];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test/'));
    dio.httpClientAdapter = _FeedAdapter();

    Uri? loginUri;
    final GoRouter router = GoRouter(
      initialLocation: '/project-idea',
      routes: <RouteBase>[
        GoRoute(
          path: '/project-idea',
          builder: (BuildContext context, GoRouterState state) =>
              const ProjectIdeaPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) {
            loginUri = state.uri;
            return const Scaffold(body: Text('login-stub'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sessionProvider.overrideWithValue(const Session()),
          projectIdeaApiProvider.overrideWithValue(
            ProjectIdeaApi(client: ApiClient(dio)),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light(),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('支持'));
    await tester.pumpAndSettle();

    expect(loginUri, isNotNull);
    expect(loginUri!.path, '/login');
    expect(loginUri!.queryParameters['from'], '/project-idea');
    expect(find.text('login-stub'), findsOneWidget);
    // 未登录时不能直接把支持弹窗打开。
    expect(find.text('提交支持'), findsNothing);
  });

  testWidgets('已登录且存在待续做动作时，feed 异步加载完成后自动重开支持弹窗', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.localesTestValue = <Locale>[
      const Locale('zh', 'CN'),
    ];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test/'));
    dio.httpClientAdapter = _FeedAdapter();

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        sessionProvider.overrideWithValue(
          const Session(isLoggedIn: true, nickname: '小牛', userId: 1),
        ),
        projectIdeaApiProvider.overrideWithValue(
          ProjectIdeaApi(client: ApiClient(dio)),
        ),
      ],
    );
    addTearDown(container.dispose);

    // 模拟登录门禁留下的待续做动作；feed 尚未加载，由页面 initState 触发加载。
    container
        .read(projectIdeaPendingActionProvider.notifier)
        .set(IdeaPendingAction.support);
    expect(container.read(projectIdeaFeedProvider).ideas, isEmpty);

    final GoRouter router = GoRouter(
      initialLocation: '/project-idea',
      routes: <RouteBase>[
        GoRoute(
          path: '/project-idea',
          builder: (BuildContext context, GoRouterState state) =>
              const ProjectIdeaPage(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light(),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('提交支持'), findsOneWidget);
    // 只消费一次，避免再次进入页面时误弹窗。
    expect(container.read(projectIdeaPendingActionProvider), isNull);
  });

  testWidgets('页面不重建时，登录态变化也能续做待表态动作', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.localesTestValue = <Locale>[
      const Locale('zh', 'CN'),
    ];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test/'));
    dio.httpClientAdapter = _FeedAdapter();

    // 登录页用 context.go 替换路由栈，页面 state 不重建，只能靠登录态监听续做。
    final StateProvider<bool> loggedIn = StateProvider<bool>((ref) => false);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        sessionProvider.overrideWith(
          (Ref ref) => Session(isLoggedIn: ref.watch(loggedIn)),
        ),
        projectIdeaApiProvider.overrideWithValue(
          ProjectIdeaApi(client: ApiClient(dio)),
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(projectIdeaPendingActionProvider.notifier)
        .set(IdeaPendingAction.support);

    final GoRouter router = GoRouter(
      initialLocation: '/project-idea',
      routes: <RouteBase>[
        GoRoute(
          path: '/project-idea',
          builder: (BuildContext context, GoRouterState state) =>
              const ProjectIdeaPage(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light(),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 未登录时不弹窗，动作保留。
    expect(find.text('提交支持'), findsNothing);
    expect(
      container.read(projectIdeaPendingActionProvider),
      IdeaPendingAction.support,
    );

    container.read(loggedIn.notifier).state = true;
    await tester.pumpAndSettle();

    expect(find.text('提交支持'), findsOneWidget);
    expect(container.read(projectIdeaPendingActionProvider), isNull);
  });
}
