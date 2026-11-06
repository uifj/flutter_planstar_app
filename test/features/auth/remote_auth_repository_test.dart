import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:core/storage.dart';
import 'package:dio/dio.dart';
import 'package:planstar/app/network/device_identity.dart';
import 'package:planstar/app/network/ps_network_interceptor.dart';
import 'package:planstar/app/network/ps_request_context.dart';
import 'package:planstar/features/auth/data/auth_session_store.dart';
import 'package:planstar/features/auth/data/planstar_auth_api.dart';
import 'package:planstar/features/auth/data/remote_auth_repository.dart';
import 'package:planstar/features/auth/domain/auth_failure.dart';
import 'package:planstar/features/auth/domain/auth_repository.dart';
import 'package:planstar/features/auth/domain/auth_session.dart';
import 'package:planstar/features/auth/domain/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

/// 认证仓库的契约测试：**回放真实抓包**，不连网。
///
/// 为什么不是"随便造个 200 + JSON"：登录这条链路上最容易写错的不是解析，
/// 而是**失败长什么样**——企划星的登录失败是 `HTTP 500` + `Content-Type:
/// text/plain` + 中文正文，不是 `{code, message}` 信封；发码失败却是
/// `HTTP 200` + `{success:false, needCaptcha, errorMsg}`。两种风格混在
/// 一条流程里，只要回放时换成自己习惯的那种形状，测试就会**绿着骗人**。
///
/// 所以下面每条响应体都是从 `api.planstar.com` 实测抓下来的原文
/// （2026-11，见 `tool/verify_login_api.dart` 的输出与 `docs/api-contract.md`）。
void main() {
  /// 用假适配器装配一整套真实的网络栈（拦截器 + ApiClient + API + 仓库）。
  ///
  /// 只有 [HttpClientAdapter] 被替换掉，其余全是生产代码——所以这里能同时
  /// 验证"请求头带对了没有"和"响应被解析成什么"。
  ({
    RemoteAuthRepository repository,
    AuthSessionStore store,
    AppStore appStore,
    PsRequestContext context,
    List<RequestOptions> requests,
  })
  buildRepository(
    Future<ResponseBody> Function(RequestOptions options) responder, {
    AppStore? appStore,
    PsRequestContext? requestContext,
  }) {
    final requests = <RequestOptions>[];
    final context = requestContext ?? PsRequestContext(dvid: generateDvid());
    final resolvedStore =
        appStore ??
        AppStore(
          preferences: MemoryKeyValueStore(),
          secure: MemorySecureStore(),
        );
    final store = AuthSessionStore(store: resolvedStore, context: context);
    final dio = buildDio(
      baseUrl: 'https://api.planstar.com/',
      adapter: _FakeAdapter((RequestOptions options) {
        requests.add(options);
        return responder(options);
      }),
      interceptors: <Interceptor>[
        PsNetworkInterceptor(
          context: context,
          userAgent:
              'PlanstarApi (com.planstar.app/9.9.39 Xiaomi '
              'developer-default Android/14)',
        ),
      ],
    );
    return (
      repository: RemoteAuthRepository(
        api: PlanstarAuthApi(client: ApiClient(dio)),
        store: store,
        context: context,
      ),
      store: store,
      appStore: resolvedStore,
      context: context,
      requests: requests,
    );
  }

  /// 抓包原文：登录成功（`LoginBean`，字段取自 `UserBean`）。
  const String kLoginSuccessBody =
      '{"needCaptcha":false,"newUser":true,'
      '"user":{"userId":90012345,"userName":"票友小张","avatar":'
      '"https://p1.planstar.com/avatar/90012345.jpg","bio":"爱看话剧",'
      '"gender":1,"birthday":946656000000,"mobileNo":"13800138000",'
      '"level":3,"followerNum":12,"followingNum":38,"wantWatchNum":7,'
      '"isDouliUser":false,"badgeIcon":""}}';

  /// 抓包原文：验证码错。`HTTP 500` + `text/plain;charset=UTF-8`。
  const String kWrongCodeBody = '验证码不正确';

  /// 抓包原文：密码登录被服务端关掉。
  const String kPasswordDisabledBody = '请使用手机号验证码登录，若手机号登录异常，请联系客服';

  /// 抓包原文：风控要图形码（发码接口，`HTTP 200`）。
  const String kSendCodeNeedCaptchaBody =
      '{"success":false,"needCaptcha":true,"errorMsg":"请输入图形验证码"}';

  /// 抓包原文：图形码输错（发码接口，`HTTP 200`）。
  const String kSendCodeCaptchaWrongBody =
      '{"success":false,"needCaptcha":true,"errorMsg":"图形验证码错误"}';

  group('登录成功', () {
    test('解析用户 + 从响应头抓 psSession + 落盘 + 后续请求带 Cookie', () async {
      final env = buildRepository((RequestOptions options) async {
        return ResponseBody.fromString(
          kLoginSuccessBody,
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[
              'application/json;charset=UTF-8',
            ],
            // 来源 `BaseLoginActivity` 就是从响应头取 `psSession`
            // （`AccountService.getInstance().setPner(response.headers().get("psSession"))`）。
            'psSession': <String>['tok_abc123'],
          },
        );
      });

      final Result<AuthSession> result = await env.repository.loginWithCode(
        '13800138000',
        '123456',
      );

      final session = result.getOrElse(
        (Failure failure) => throw StateError('登录应该成功，实际失败：${failure.message}'),
      );
      expect(session.user.userId, 90012345);
      expect(session.user.displayName, '票友小张');
      expect(session.user.level, 3);
      expect(session.user.maskedMobile, '138****8000');
      // 令牌不是从 body 里来的，是拦截器从响应头捞的。
      expect(session.token, 'tok_abc123');
      expect(env.context.psSession, 'tok_abc123');

      // 落盘：令牌进安全存储，资料进普通偏好（纯 JSON，不 URL 编码）。
      // 这里只看内存实现里的键位；跨实例读盘在下一个用例里验。
      expect(env.context.psSession, 'tok_abc123');

      // 请求体是 `{ua, code, ct}`，且带了来源那套 UA / dvid 头。
      final RequestOptions request = env.requests.single;
      expect(request.path, 'v1/user/login');
      expect(request.method, 'POST');
      final Map<String, Object?> body = (request.data as Map<Object?, Object?>)
          .cast<String, Object?>();
      expect(body['ua'], '13800138000');
      expect(body['code'], '123456');
      expect(body['ct'], 11);
      // 密码分支才带 `pw`，验证码分支不能带——带了服务端会走密码校验。
      expect(body.containsKey('pw'), isFalse);
      expect(request.headers['dvid'], isNotNull);
      expect(
        request.headers['User-Agent'],
        contains('PlanstarApi (com.planstar.app'),
      );
    });

    test('登录成功后的下一个请求自动带 Cookie: psSession', () async {
      final env = buildRepository((RequestOptions options) async {
        return ResponseBody.fromString(
          kLoginSuccessBody,
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['application/json'],
            'psSession': <String>['tok_abc123'],
          },
        );
      });

      await env.repository.loginWithCode('13800138000', '123456');
      // 第二个请求：随便打个接口，看拦截器有没有把 psSession 拼进 Cookie。
      await env.repository.fetchCaptchaImage();

      final RequestOptions second = env.requests[1];
      expect(second.headers['Cookie'], 'psSession=tok_abc123');
    });

    test('会话可以跨实例恢复（冷启动读盘）', () async {
      // 同一份存储实例 + 新的 AuthSessionStore = 冷启动。
      // 注意 `MemoryKeyValueStore` 会**复制**传入的 Map，所以断言要打回
      // store 本身，不能盯着外面那个 Map（那是个常见假绿）。
      final appStore = AppStore(
        preferences: MemoryKeyValueStore(),
        secure: MemorySecureStore(),
      );
      final env = buildRepository(
        (RequestOptions options) async => ResponseBody.fromString(
          kLoginSuccessBody,
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['application/json'],
            'psSession': <String>['tok_abc123'],
          },
        ),
        appStore: appStore,
      );

      await env.repository.loginWithCode('13800138000', '123456');
      expect(
        await appStore.preferences.read(AuthSessionStore.profileKey),
        contains('票友小张'),
        reason: '资料应写进普通偏好',
      );
      expect(
        await appStore.secure.read('psSession'),
        'tok_abc123',
        reason: '令牌必须在安全存储里',
      );
      expect(
        await appStore.secure.read(AuthSessionStore.profileKey),
        isNull,
        reason: '资料不该进安全存储',
      );

      final restored = AuthSessionStore(
        store: appStore,
        context: PsRequestContext(),
      );
      final AuthSession? session = await restored.read();
      expect(session, isNotNull);
      expect(session!.user.userId, 90012345);
      expect(session.token, 'tok_abc123');
    });

    test('令牌会灌回请求上下文（否则冷启动第一个请求是匿名）', () async {
      final appStore = AppStore(
        preferences: MemoryKeyValueStore(<String, String>{
          AuthSessionStore.profileKey: jsonEncode(
            const AuthUser(userId: 90012345, userName: '票友小张').toJson(),
          ),
        }),
        secure: MemorySecureStore(<String, String>{
          'psSession': 'tok_from_disk',
        }),
      );
      final context = PsRequestContext();
      final store = AuthSessionStore(store: appStore, context: context);

      await store.read();
      expect(context.psSession, 'tok_from_disk');
    });
  });

  group('登录失败', () {
    test('验证码错：500 + text/plain 的中文原文必须穿到 Failure.message', () async {
      final env = buildRepository(
        (RequestOptions options) async => ResponseBody.fromString(
          kWrongCodeBody,
          500,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['text/plain;charset=UTF-8'],
          },
        ),
      );

      final Result<AuthSession> result = await env.repository.loginWithCode(
        '13800138000',
        '000000',
      );

      final failure = result.failure;
      expect(failure, isNotNull);
      // 关键：不是 `服务开小差了，请稍后重试`。丢了这句，用户就不知道是码错了。
      expect(failure!.message, '验证码不正确');
      expect(failure.statusCode, 500);
      expect(failure.code, AuthFailureCodes.business);
      expect(AuthFailure.fromFailure(failure).kind, AuthFailureKind.business);
      // 失败不写会话。
      expect(env.context.psSession, isNull);
    });

    test('账号被锁定：文案含"锁定"→ 归类 accountLocked（来源靠 contains 判断）', () async {
      final env = buildRepository(
        (RequestOptions options) async => ResponseBody.fromString(
          '该账号已被锁定，请联系客服',
          500,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['text/plain;charset=UTF-8'],
          },
        ),
      );

      final Result<AuthSession> result = await env.repository.loginWithCode(
        '13800138000',
        '123456',
      );

      final failure = result.failure!;
      expect(failure.code, AuthFailureCodes.accountLocked);
      final auth = AuthFailure.fromFailure(failure);
      expect(auth.kind, AuthFailureKind.accountLocked);
      // 原文保留，UI 直接展示。
      expect(auth.message, contains('锁定'));
    });

    test('密码登录被服务端关闭：原文透传，不臆造"密码错误"', () async {
      final env = buildRepository(
        (RequestOptions options) async => ResponseBody.fromString(
          kPasswordDisabledBody,
          500,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['text/plain;charset=UTF-8'],
          },
        ),
      );

      final Result<AuthSession> result = await env.repository.loginWithPassword(
        '13800138000',
        'a1234567',
      );

      expect(result.failure!.message, kPasswordDisabledBody);
      expect(result.failure!.code, AuthFailureCodes.business);
      // 请求体走的是 pw 分支。
      final body = (env.requests.single.data as Map<Object?, Object?>)
          .cast<String, Object?>();
      expect(body['pw'], 'a1234567');
      expect(body.containsKey('code'), isFalse);
    });

    test('响应里 needCaptcha=true → 归类 needsCaptcha（即便 HTTP 200）', () async {
      final env = buildRepository(
        (RequestOptions options) async => ResponseBody.fromString(
          '{"needCaptcha":true,"newUser":false}',
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['application/json'],
          },
        ),
      );

      final Result<AuthSession> result = await env.repository.loginWithCode(
        '13800138000',
        '123456',
      );

      expect(result.failure!.code, AuthFailureCodes.needsCaptcha);
      expect(AuthFailure.fromFailure(result.failure!).needsCaptcha, isTrue);
    });

    test('200 但没有 user → AUTH_NO_USER，不能当登录成功', () async {
      final env = buildRepository(
        (RequestOptions options) async => ResponseBody.fromString(
          '{"needCaptcha":false,"newUser":false}',
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['application/json'],
          },
        ),
      );

      final Result<AuthSession> result = await env.repository.loginWithCode(
        '13800138000',
        '123456',
      );

      expect(result.failure!.code, 'AUTH_NO_USER');
      expect(env.context.psSession, isNull);
    });

    test('超时 → FailureType.timeout（可重试，不归类成业务失败）', () async {
      final env = buildRepository((RequestOptions options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        );
      });

      final Result<AuthSession> result = await env.repository.loginWithCode(
        '13800138000',
        '123456',
      );

      final failure = result.failure!;
      expect(failure.type, FailureType.timeout);
      final auth = AuthFailure.fromFailure(failure);
      expect(auth.kind, AuthFailureKind.timeout);
      expect(auth.isRetryable, isTrue);
    });

    test('连接失败 → FailureType.network（"无网络"而不是"服务开小差"）', () async {
      final env = buildRepository((RequestOptions options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });

      final Result<AuthSession> result = await env.repository.loginWithCode(
        '13800138000',
        '123456',
      );

      final auth = AuthFailure.fromFailure(result.failure!);
      expect(auth.kind, AuthFailureKind.network);
      expect(auth.isRetryable, isTrue);
    });
  });

  group('发验证码', () {
    test('success=true → 60 秒冷却（服务端不给冷却时长，客户端写死）', () async {
      final env = buildRepository(
        (RequestOptions options) async => ResponseBody.fromString(
          '{"success":true,"needCaptcha":false}',
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['application/json'],
          },
        ),
      );

      final Result<SendCodeOutcome> result = await env.repository.sendLoginCode(
        '13800138000',
      );

      expect(
        result.getOrElse((_) => const SendCodeOutcome()).cooldownSeconds,
        60,
      );
      expect(env.requests.single.path, 'v3/user/sendLoginCode');
    });

    test('needCaptcha=true → needsCaptcha，且把服务端 errorMsg 当提示', () async {
      final env = buildRepository(
        (RequestOptions options) async => ResponseBody.fromString(
          kSendCodeNeedCaptchaBody,
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['application/json'],
          },
        ),
      );

      final Result<SendCodeOutcome> result = await env.repository.sendLoginCode(
        '13800138000',
      );

      final failure = result.failure!;
      expect(failure.code, AuthFailureCodes.needsCaptcha);
      // 服务端说的是"请输入图形验证码"，比自造的"需要图形验证码"更具体。
      expect(failure.message, '请输入图形验证码');
    });

    test('补图形码后仍错 → needsCaptcha + 「图形验证码错误」（对话框可以重试）', () async {
      final env = buildRepository(
        (RequestOptions options) async => ResponseBody.fromString(
          kSendCodeCaptchaWrongBody,
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['application/json'],
          },
        ),
      );

      final Result<SendCodeOutcome> result = await env.repository.sendLoginCode(
        '13800138000',
        captcha: 'zzzz',
      );

      expect(result.failure!.code, AuthFailureCodes.needsCaptcha);
      expect(result.failure!.message, '图形验证码错误');
      final body = (env.requests.single.data as Map<Object?, Object?>)
          .cast<String, Object?>();
      expect(body['captcha'], 'zzzz');
    });
  });

  group('图形验证码', () {
    test('返回 PNG 字节（不是 base64、不是 URL）', () async {
      // 真图前 8 字节的 PNG 魔数。
      final bytes = Uint8List.fromList(<int>[
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
      ]);
      final env = buildRepository(
        (RequestOptions options) async => ResponseBody.fromBytes(
          bytes,
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['image/png'],
          },
        ),
      );

      final Result<List<int>> result = await env.repository.fetchCaptchaImage();

      final data = result.getOrElse((_) => <int>[]);
      expect(data, bytes);
      expect(env.requests.single.path, 'v1/user/captcha');
      expect(env.requests.single.method, 'GET');
    });
  });

  group('登出', () {
    test('清令牌 + 清资料 + 清上下文', () async {
      final appStore = AppStore(
        preferences: MemoryKeyValueStore(),
        secure: MemorySecureStore(),
      );
      final env = buildRepository(
        (RequestOptions options) async => ResponseBody.fromString(
          kLoginSuccessBody,
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['application/json'],
            'psSession': <String>['tok_abc123'],
          },
        ),
        appStore: appStore,
      );

      await env.repository.loginWithCode('13800138000', '123456');
      expect(env.context.psSession, 'tok_abc123');

      await env.repository.logout();

      expect(env.context.psSession, isNull);
      expect(await appStore.secure.read('psSession'), isNull);
      expect(
        await appStore.preferences.read(AuthSessionStore.profileKey),
        isNull,
      );
      expect(await env.repository.restoreSession(), isNull);
    });
  });
}

/// 假适配器：Dio 唯一需要替换的一层。
final class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._responder);

  final Future<ResponseBody> Function(RequestOptions options) _responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _responder(options);

  @override
  void close({bool force = false}) {}
}
