import 'package:core/result.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:planstar/app/app.dart' show appLocalizationsDelegates;
import 'package:planstar/app/network/network_providers.dart';
import 'package:planstar/app/theme.dart';
import 'package:planstar/features/auth/application/auth_providers.dart';
import 'package:planstar/features/auth/domain/auth_repository.dart';
import 'package:planstar/features/auth/domain/auth_session.dart';
import 'package:planstar/features/auth/domain/auth_user.dart';
import 'package:planstar/features/marketing/demo_wallet_state.dart';
import 'package:planstar/features/message/message_page.dart';
import 'package:planstar/features/order/order_list_page.dart';
import 'package:planstar/features/user/user_page.dart';
import 'package:planstar/l10n/generated/app_localizations.dart';
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
    bool signedToday = false,
  }) async {
    tester.view.physicalSize = kSurface * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        useDemoProvider.overrideWithValue(true),
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
          path: '/mall',
          builder: (_, _) => const Scaffold(body: Text('mall-page')),
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
    if (signedToday) {
      container.read(demoWalletStateProvider.notifier).signIn();
      await tester.pumpAndSettle();
    }
    return container;
  }

  AuthSession loggedInSession() => AuthSession(
    user: const AuthUser(
      userId: 90012345,
      userName: '票友小张',
      level: 3,
      wantWatchNum: 7,
      followingNum: 38,
    ),
    token: 'tok_abc123',
  );

  testWidgets('未登录：显示占位昵称与登录按钮', (WidgetTester tester) async {
    await pumpUserPage(tester);

    expect(find.text('登录更精彩'), findsOneWidget);
    expect(find.text('点击登录，查看订单与更多服务'), findsOneWidget);
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
    expect(find.text('V3 资深支持人'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('38'), findsOneWidget);
    expect(find.text('退出登录'), findsOneWidget);
    // 已登录就不该再出现"点击登录"。
    expect(find.text('点击登录，查看订单与更多服务'), findsNothing);
  });

  testWidgets('未签到：点击每日签到后变为今日已签到并提示奖励', (WidgetTester tester) async {
    await pumpUserPage(tester, restored: loggedInSession());

    expect(find.text('每日签到 · +100 星币'), findsOneWidget);
    await tester.tap(find.text('每日签到 · +100 星币'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('今日已签到'), findsOneWidget);
    expect(find.text('签到成功，+100 星币'), findsOneWidget);
  });

  testWidgets('已签到：卡片禁用，点击不再触发签到', (WidgetTester tester) async {
    await pumpUserPage(tester, restored: loggedInSession(), signedToday: true);

    expect(find.text('今日已签到'), findsOneWidget);
    final InkWell card = tester.widget<InkWell>(
      find
          .ancestor(of: find.text('今日已签到'), matching: find.byType(InkWell))
          .first,
    );
    expect(card.onTap, isNull);
  });

  testWidgets('未登录：点击签到跳转登录页', (WidgetTester tester) async {
    await pumpUserPage(tester);

    await tester.tap(find.text('每日签到 · +100 星币'));
    await tester.pumpAndSettle();

    expect(find.text('login-page'), findsOneWidget);
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
    expect(find.text('点击登录，查看订单与更多服务'), findsNothing);
  });

  testWidgets('个人中心「消息」入口（头部 icon）跳转消息二级页', (WidgetTester tester) async {
    await pumpUserPage(tester);

    expect(find.byIcon(LucideIcons.mail), findsOneWidget);
    await tester.tap(find.byIcon(LucideIcons.mail));
    await tester.pumpAndSettle();

    expect(find.text('message-page'), findsOneWidget);
  });

  testWidgets('个人中心「订单」入口（订单卡整行）跳转订单二级页', (WidgetTester tester) async {
    await pumpUserPage(tester);

    expect(find.text('我的支持'), findsOneWidget);
    await tester.tap(find.text('我的支持'));
    await tester.pumpAndSettle();

    expect(find.text('order-page'), findsOneWidget);
  });

  testWidgets('个人中心菜单已移除代购服务与超低价拼团', (WidgetTester tester) async {
    await pumpUserPage(tester);

    expect(find.text('代购服务'), findsNothing);
    expect(find.text('超低价拼团'), findsNothing);
  });

  testWidgets('个人中心菜单分组：快捷区与「更多服务」齐全、高频服务组已移除', (WidgetTester tester) async {
    await pumpUserPage(tester);

    // 「我的服务」分组已移除，只保留「更多服务」。
    expect(find.text('我的服务'), findsNothing);
    expect(find.text('更多服务'), findsOneWidget);

    // 横向快捷区 3 个入口（优惠券已暂时隐藏）。
    expect(find.text('星币商城'), findsOneWidget);
    expect(find.text('我的钱包'), findsOneWidget);
    expect(find.text('礼品卡'), findsOneWidget);
    // 优惠券入口已按产品要求暂时隐藏。
    expect(find.text('优惠券'), findsNothing);
    expect(find.byIcon(LucideIcons.ticket), findsNothing);

    // 低频组：地址 / 支持人 / 客服 / 招募。
    expect(find.text('地址管理'), findsOneWidget);
    expect(find.text('支持人'), findsOneWidget);
    expect(find.text('联系客服'), findsOneWidget);
    expect(find.text('卖家招募'), findsOneWidget);

    // 快捷区图标：品牌色 24dp 三宫格。
    expect(find.byIcon(LucideIcons.store), findsWidgets);
    expect(find.byIcon(LucideIcons.wallet), findsWidgets);
    expect(find.byIcon(LucideIcons.gift), findsWidgets);
    // 已随「我的服务」组移除的行首图标不再出现。
    expect(find.byIcon(LucideIcons.messagesSquare), findsNothing);
    expect(find.byIcon(LucideIcons.receiptText), findsNothing);
    // 更多服务组行首图标仍在。
    expect(find.byIcon(LucideIcons.mapPin), findsWidgets);
    expect(find.byIcon(LucideIcons.users), findsWidgets);
    expect(find.byIcon(LucideIcons.headset), findsWidgets);
    expect(find.byIcon(LucideIcons.megaphone), findsWidgets);
  });

  testWidgets('快捷区「星币商城」入口跳转商城二级页', (WidgetTester tester) async {
    await pumpUserPage(tester);

    await tester.tap(find.text('星币商城'));
    await tester.pumpAndSettle();

    expect(find.text('mall-page'), findsOneWidget);
  });

  testWidgets('消息/订单二级页：顶栏返回键回到个人中心', (WidgetTester tester) async {
    // 用真实二级页验证「入口 → 二级页 → 返回」链路（含顶栏返回箭头）。
    tester.view.physicalSize = kSurface * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        useDemoProvider.overrideWithValue(true),
        authRepositoryProvider.overrideWithValue(
          _RestoreOnlyRepository(null),
        ),
      ],
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/me',
      routes: <RouteBase>[
        GoRoute(path: '/me', builder: (_, _) => const UserPage()),
        GoRoute(path: '/message', builder: (_, _) => const MessagePage()),
        GoRoute(path: '/order', builder: (_, _) => const OrderListPage()),
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

    // 我的 → 消息（头部 icon）
    await tester.tap(find.byIcon(LucideIcons.mail));
    await tester.pumpAndSettle();
    expect(find.text('消息中心'), findsOneWidget);

    // 顶栏返回 → 回到个人中心
    await tester.tap(find.byIcon(LucideIcons.chevronLeft));
    await tester.pumpAndSettle();
    expect(find.text('登录更精彩'), findsOneWidget);

    // 我的 → 订单（订单卡整行）
    await tester.tap(find.text('我的支持'));
    await tester.pumpAndSettle();
    expect(find.text('商品'), findsOneWidget);

    // 顶栏返回 → 回到个人中心
    await tester.tap(find.byIcon(LucideIcons.chevronLeft));
    await tester.pumpAndSettle();
    expect(find.text('登录更精彩'), findsOneWidget);
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
