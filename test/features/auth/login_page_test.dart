import 'package:core_design_system/core_design_system.dart';
import 'package:core/result.dart';
import 'package:flutter/material.dart';
import 'package:planstar/app/theme.dart';
import 'package:planstar/features/auth/application/auth_providers.dart';
import 'package:planstar/features/auth/application/auth_state.dart';
import 'package:planstar/features/auth/domain/auth_failure.dart';
import 'package:planstar/features/auth/domain/auth_repository.dart';
import 'package:planstar/features/auth/domain/auth_session.dart';
import 'package:planstar/features/auth/domain/auth_user.dart';
import 'package:planstar/l10n/auth_localizations.dart';
import 'package:planstar/features/auth/login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// 登录页测试。
///
/// 只断言**契约**：哪些输入行在、模式切换换掉了哪一行、校验与门禁是否生效、
/// 服务端失败怎么落到 UI 上、登录成功后是否回到来源页。不去比对像素——
/// 布局数字每改一次都要跟着改的断言没有价值（同 `test/app_shell_test.dart`）。
///
/// 网络层被 [AuthRepository] 这个端口挡在测试之外：这里断言的是"拿到某种
/// `Result` 之后页面怎么反应"。真实的 HTTP 形状（`500 + text/plain 中文`、
/// `200 + {success:false}`）由 `remote_auth_repository_test.dart` 回放真实
/// 抓包来覆盖，两层各管一段。
void main() {
  /// 来源设计稿的窄屏基线。协议行（勾选框 + 两段协议名 + 右侧切换按钮）
  /// 是这一页最容易溢出的地方，所以默认就在 360×640 下跑。
  const Size kSurface = Size(360, 640);

  Future<({ProviderContainer container, _FakeAuthRepository repo})> pumpLogin(
    WidgetTester tester, {
    String? from,
    _FakeAuthRepository? repository,
  }) async {
    tester.view.physicalSize = kSurface * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    tester.platformDispatcher.localesTestValue = <Locale>[
      const Locale('zh', 'CN'),
    ];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final repo = repository ?? _FakeAuthRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/login',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home-page')),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => LoginPage(from: from),
        ),
        GoRoute(
          path: '/me',
          builder: (_, _) => const Scaffold(body: Text('me-page')),
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
          localizationsDelegates: AuthLocalizations.localizationsDelegates,
          supportedLocales: AuthLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (container: container, repo: repo);
  }

  Future<void> fill(WidgetTester tester, String phone, String credential) async {
    final List<TextField> fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    await tester.enterText(find.byWidget(fields[0]), phone);
    await tester.enterText(find.byWidget(fields[1]), credential);
    await tester.pumpAndSettle();
  }

  /// 填好表单 + 勾协议，停在"可以点登录"的状态。
  Future<void> fillAndAgree(
    WidgetTester tester,
    String phone,
    String credential,
  ) async {
    await fill(tester, phone, credential);
    await tester.tap(find.byKey(const ValueKey<String>('login.agreement')));
    await tester.pumpAndSettle();
  }

  testWidgets('验证码模式：手机号 + 验证码 + 获取验证码 + 协议行 + 微信入口', (WidgetTester tester) async {
    await pumpLogin(tester);

    expect(find.text('登录 / 注册'), findsOneWidget);
    expect(find.text('请输入手机号'), findsOneWidget);
    expect(find.text('请输入验证码'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
    // 登录按钮（`authTitle`）与右侧的模式切换按钮同时在。
    expect(find.text('登录'), findsOneWidget);
    expect(find.text('密码登录'), findsOneWidget);
    expect(find.text('更多登录方式'), findsOneWidget);
    expect(find.text('微信登录'), findsOneWidget);
  });

  testWidgets('切到密码模式后验证码行被替换', (WidgetTester tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('密码登录'));
    await tester.pumpAndSettle();

    expect(find.text('请输入密码'), findsOneWidget);
    expect(find.text('请输入验证码'), findsNothing);
    expect(find.text('获取验证码'), findsNothing);
    // 切换按钮的文案变成反向操作。
    expect(find.text('验证码登录'), findsOneWidget);
  });

  testWidgets('未勾选协议时提交被拦下，不调接口也不写登录态', (WidgetTester tester) async {
    final env = await pumpLogin(tester);
    await fill(tester, '13800138000', '123456');

    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    expect(find.text('请先阅读并同意《注册协议》和《隐私协议》'), findsOneWidget);
    // 关键：不是"提交了但失败"，而是**根本没发请求**。
    expect(env.repo.loginCalls, 0);
    expect(env.container.read(authControllerProvider).isLoggedIn, isFalse);
  });

  testWidgets('手机号非法时不发验证码', (WidgetTester tester) async {
    final env = await pumpLogin(tester);

    await tester.enterText(find.byType(TextField).first, '138');
    await tester.pumpAndSettle();
    await tester.tap(find.text('获取验证码'));
    await tester.pumpAndSettle();

    expect(find.text('请输入正确的手机号'), findsOneWidget);
    expect(env.repo.sendCodeCalls, 0);
  });

  testWidgets('发码成功 → 按钮进入倒计时并禁用', (WidgetTester tester) async {
    final env = await pumpLogin(tester);
    env.repo.sendCodeResult =
        const Success<SendCodeOutcome>(SendCodeOutcome(cooldownSeconds: 60));

    await tester.enterText(find.byType(TextField).first, '13800138000');
    await tester.pumpAndSettle();
    await tester.tap(find.text('获取验证码'));
    // 两帧：一帧发出请求，一帧应用返回结果。
    await tester.pump();
    await tester.pump();

    expect(env.repo.sendCodeCalls, 1);
    expect(env.repo.lastPhone, '13800138000');
    expect(find.text('重新获取(60s)'), findsOneWidget);

    // 把倒计时走完：否则测试结束时还挂着 `Timer.periodic`，
    // flutter_test 会报 "A Timer is still pending"。
    await tester.pump(const Duration(seconds: 61));
    expect(find.text('获取验证码'), findsOneWidget);
  });

  testWidgets('发码被风控要求图形码 → 弹图形验证码对话框', (WidgetTester tester) async {
    final env = await pumpLogin(tester);
    env.repo.sendCodeResult = const Fail<SendCodeOutcome>(
      Failure(
        code: AuthFailureCodes.needsCaptcha,
        message: '请输入图形验证码',
        type: FailureType.validation,
      ),
    );
    env.repo.captchaResult = Success<List<int>>(<int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    ]);

    await tester.enterText(find.byType(TextField).first, '13800138000');
    await tester.pumpAndSettle();
    await tester.tap(find.text('获取验证码'));
    await tester.pumpAndSettle();

    expect(find.text('图形验证码'), findsOneWidget);
    // 服务端给的原因要显示出来，不能只弹个空框。
    expect(find.text('请输入图形验证码'), findsOneWidget);
    expect(env.repo.captchaCalls, 1);

    // 取消后不该继续重试。
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('图形验证码'), findsNothing);
    expect(env.repo.sendCodeCalls, 1);
  });

  testWidgets('验证码错误：把服务端原文弹出来，并且仍停在登录页', (WidgetTester tester) async {
    final env = await pumpLogin(tester, from: '/me');
    env.repo.loginResult = const Fail<AuthSession>(
      Failure(
        code: AuthFailureCodes.business,
        message: '验证码不正确',
        type: FailureType.server,
        statusCode: 500,
      ),
    );

    await fillAndAgree(tester, '13800138000', '000000');
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    // 来源就是 `showToast(errorBody().string())`，这里保持"原文直弹"。
    expect(find.text('验证码不正确'), findsOneWidget);
    expect(find.text('me-page'), findsNothing);
    expect(env.container.read(authControllerProvider).isLoggedIn, isFalse);
    expect(env.repo.lastCode, '000000');
  });

  testWidgets('账号被锁定：弹不可取消的对话框', (WidgetTester tester) async {
    final env = await pumpLogin(tester);
    env.repo.loginResult = const Fail<AuthSession>(
      Failure(
        code: AuthFailureCodes.accountLocked,
        message: '该账号已被锁定，请联系客服',
        type: FailureType.server,
        statusCode: 500,
      ),
    );

    await fillAndAgree(tester, '13800138000', '123456');
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    expect(find.text('账号已被锁定'), findsOneWidget);
    expect(find.text('该账号已被锁定，请联系客服'), findsOneWidget);

    // 点遮罩不能关（来源就是不可取消的）。
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('账号已被锁定'), findsOneWidget);

    await tester.tap(find.text('我知道了'));
    await tester.pumpAndSettle();
    expect(find.text('账号已被锁定'), findsNothing);
  });

  testWidgets('网络失败：用本地化文案而不是服务端原文', (WidgetTester tester) async {
    final env = await pumpLogin(tester);
    env.repo.loginResult = const Fail<AuthSession>(
      Failure(
        code: 'NETWORK',
        message: '网络连接失败，请检查网络',
        type: FailureType.network,
      ),
    );

    await fillAndAgree(tester, '13800138000', '123456');
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    expect(find.text('网络不给力，请检查网络后重试'), findsOneWidget);
    expect(env.container.read(authControllerProvider).isLoggedIn, isFalse);
  });

  testWidgets('勾选协议 + 合法手机号 + 6 位验证码 → 登录并回到来源页', (WidgetTester tester) async {
    final env = await pumpLogin(tester, from: '/me');
    env.repo.loginResult = Success<AuthSession>(
      AuthSession(
        user: const AuthUser(userId: 90012345, userName: '票友小张'),
        token: 'tok_abc123',
      ),
    );

    await fillAndAgree(tester, '13800138000', '123456');
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    final AuthState auth = env.container.read(authControllerProvider);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.user?.displayName, '票友小张');
    expect(find.text('me-page'), findsOneWidget);
  });

  testWidgets('没有来源页时回到首页', (WidgetTester tester) async {
    final env = await pumpLogin(tester);
    env.repo.loginResult = Success<AuthSession>(
      AuthSession(
        user: const AuthUser(userId: 90012345, userName: '票友小张'),
        token: 'tok_abc123',
      ),
    );

    await fillAndAgree(tester, '13800138000', '123456');
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    expect(env.container.read(authControllerProvider).isLoggedIn, isTrue);
    expect(find.text('home-page'), findsOneWidget);
  });

  testWidgets('密码不足 6 位时给出提示', (WidgetTester tester) async {
    final env = await pumpLogin(tester);

    await tester.tap(find.text('密码登录'));
    await tester.pumpAndSettle();
    await fill(tester, '13800138000', '123');
    await tester.tap(find.byKey(const ValueKey<String>('login.agreement')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    expect(find.text('密码至少 6 位'), findsOneWidget);
    expect(env.repo.loginCalls, 0);
    expect(env.container.read(authControllerProvider).isLoggedIn, isFalse);
  });

  testWidgets('密码模式走 loginWithPassword（不是 code 分支）', (WidgetTester tester) async {
    final env = await pumpLogin(tester);
    env.repo.loginResult = const Fail<AuthSession>(
      Failure(
        code: AuthFailureCodes.business,
        message: '请使用手机号验证码登录，若手机号登录异常，请联系客服',
        type: FailureType.server,
        statusCode: 500,
      ),
    );

    await tester.tap(find.text('密码登录'));
    await tester.pumpAndSettle();
    await fillAndAgree(tester, '13800138000', 'a1234567');
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();

    expect(env.repo.lastPassword, 'a1234567');
    expect(env.repo.lastCode, isNull);
    // 服务端已关闭密码登录，原文如实展示，不自造"密码错误"。
    expect(
      find.text('请使用手机号验证码登录，若手机号登录异常，请联系客服'),
      findsOneWidget,
    );
  });
}

/// 假仓库：只负责按测试给的 [Result] 返回，不发请求。
final class _FakeAuthRepository implements AuthRepository {
  Result<AuthSession>? loginResult;
  Result<SendCodeOutcome>? sendCodeResult;
  Result<List<int>>? captchaResult;

  int loginCalls = 0;
  int sendCodeCalls = 0;
  int captchaCalls = 0;
  int logoutCalls = 0;

  String? lastPhone;
  String? lastCode;
  String? lastPassword;
  String? lastCaptcha;

  @override
  Future<Result<SendCodeOutcome>> sendLoginCode(
    String phone, {
    String? captcha,
  }) async {
    sendCodeCalls++;
    lastPhone = phone;
    lastCaptcha = captcha;
    return sendCodeResult ??
        const Success<SendCodeOutcome>(SendCodeOutcome());
  }

  @override
  Future<Result<AuthSession>> loginWithCode(
    String phone,
    String code, {
    String? captcha,
  }) async {
    loginCalls++;
    lastPhone = phone;
    lastCode = code;
    lastCaptcha = captcha;
    return loginResult ?? _unconfigured();
  }

  @override
  Future<Result<AuthSession>> loginWithPassword(
    String phone,
    String password, {
    String? captcha,
  }) async {
    loginCalls++;
    lastPhone = phone;
    lastPassword = password;
    lastCaptcha = captcha;
    return loginResult ?? _unconfigured();
  }

  @override
  Future<Result<List<int>>> fetchCaptchaImage() async {
    captchaCalls++;
    return captchaResult ?? Success<List<int>>(<int>[]);
  }

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }

  static Fail<AuthSession> _unconfigured() => Fail<AuthSession>(
        const Failure(
          code: 'TEST_UNCONFIGURED',
          message: '测试没给 loginResult',
          type: FailureType.server,
        ),
      );
}
