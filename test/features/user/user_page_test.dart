import 'package:core/result.dart';
import 'package:flutter/material.dart';
import 'package:planstar/app/app.dart' show appLocalizationsDelegates;
import 'package:planstar/app/theme.dart';
import 'package:planstar/features/auth/application/auth_providers.dart';
import 'package:planstar/features/auth/domain/auth_repository.dart';
import 'package:planstar/features/auth/domain/auth_session.dart';
import 'package:planstar/features/auth/domain/auth_user.dart';
import 'package:planstar/features/user/user_page.dart';
import 'package:planstar/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// 「我的」页对登录态的响应。
///
/// 这一层是登录流程的**出口**：接口回来了、会话写好了，但页面上还是"点击登录"
/// 的话，联调等于没做完。所以这里从 `restoreSession()` 这条真实路径进入
/// 已登录态（不是直接塞一个 `AuthState`），顺带把冷启动恢复也覆盖一遍。
void main() {
  const Size kSurface = Size(360, 1200);

  Future<ProviderContainer> pumpUserPage(
    WidgetTester tester, {
    AuthSession? restored,
  }) async {
    tester.view.physicalSize = kSurface * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        authRepositoryProvider.overrideWithValue(
          _RestoreOnlyRepository(restored),
        ),
      ],
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/me',
      routes: <RouteBase>[
        GoRoute(path: '/me', builder: (_, _) => const UserPage()),
        GoRoute(
          path: '/message',
          builder: (_, _) => const Scaffold(body: Text('message-page')),
        ),
        GoRoute(
          path: '/order',
          builder: (_, _) => const Scaffold(body: Text('order-page')),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('login-page')),
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
          locale: const Locale('zh'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('未登录：显示占位昵称与登录按钮', (WidgetTester tester) async {
    await pumpUserPage(tester);

    expect(find.text('登录更精彩'), findsOneWidget);
    expect(find.text('点击登录，查看订单与优惠券'), findsOneWidget);
    expect(find.text('登录 / 注册'), findsOneWidget);
    expect(find.text('退出登录'), findsNothing);
  });

  testWidgets('冷启动恢复会话后：昵称/等级/想看/关注都是接口真值', (WidgetTester tester) async {
    await pumpUserPage(
      tester,
      restored: AuthSession(
        user: const AuthUser(
          userId: 90012345,
          userName: '票友小张',
          level: 3,
          wantWatchNum: 7,
          followingNum: 38,
        ),
        token: 'tok_abc123',
      ),
    );

    expect(find.text('票友小张'), findsOneWidget);
    // 等级来自 `user.level`，不是硬编的 V3。
    expect(find.text('V3 资深票友'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('38'), findsOneWidget);
    expect(find.text('退出登录'), findsOneWidget);
    // 已登录就不该再出现"点击登录"。
    expect(find.text('点击登录，查看订单与优惠券'), findsNothing);
  });

  testWidgets('等级为 0 时不硬编 V3，用脱敏手机号占位', (WidgetTester tester) async {
    await pumpUserPage(
      tester,
      restored: AuthSession(
        user: const AuthUser(
          userId: 90012345,
          userName: '票友小张',
          mobileNo: '13800138000',
        ),
        token: 'tok_abc123',
      ),
    );

    expect(find.text('票友小张'), findsOneWidget);
    expect(find.textContaining('V0'), findsNothing);
    expect(find.text('138****8000'), findsOneWidget);
    expect(find.text('点击登录，查看订单与优惠券'), findsNothing);
  });
}

/// 只负责"冷启动恢复"的假仓库——登录/发码都不该在「我的」页被调用。
final class _RestoreOnlyRepository implements AuthRepository {
  _RestoreOnlyRepository(this._restored);

  final AuthSession? _restored;

  @override
  Future<AuthSession?> restoreSession() async => _restored;

  @override
  Future<void> logout() async {}

  @override
  Future<Result<List<int>>> fetchCaptchaImage() async =>
      Success<List<int>>(<int>[]);

  @override
  Future<Result<AuthSession>> loginWithCode(
    String phone,
    String code, {
    String? captcha,
  }) async => throw StateError('「我的」页不该发起登录');

  @override
  Future<Result<AuthSession>> loginWithPassword(
    String phone,
    String password, {
    String? captcha,
  }) async => throw StateError('「我的」页不该发起登录');

  @override
  Future<Result<SendCodeOutcome>> sendLoginCode(
    String phone, {
    String? captcha,
  }) async => throw StateError('「我的」页不该发验证码');
}
