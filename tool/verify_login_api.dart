// 登录接口联调验证脚本（默认域名来自 `ApiConfig.resolve()`）。
//
// 为什么要有这个脚本：单元测试用的是**回放**的假响应，"真接口还认不认这套
// 请求形状"是另一件事——服务端可能改路径、改字段、加风控。这个脚本用
// **生产代码里同一份** `PlanstarAuthApi`（不是另抄的 curl）去打接口，
// 所以它验证的是"我们实际会发出去的请求"，而不是"我以为会发出去的请求"。
//
// ⚠ 品牌重构后 `ApiConfig` 里的 host 是 `planstar` 占位域名，不指向真实线上服务。
// 要联调真接口，请显式传 `--base=<真实 host>` 或设 `PS_API_BASE`；
// 否则脚本只能验证请求形状，无法拿到真实响应。
//
// 用法：
//
// ```bash
// # 1) 只跑失败路径（不需要验证码，随时可跑）
// dart run tool/verify_login_api.dart
//
// # 2) 跑完整成功路径：把手机上收到的验证码填进去
// dart run tool/verify_login_api.dart --phone=13800001234 --code=123456
//
// # 3) 指定真实 base（占位域名不可用时）
// dart run tool/verify_login_api.dart --base=https://<real-host>/
// ```
//
// 退出码：全部符合预期 → 0；有任何一条不符合 → 1（可直接进 CI 的 smoke）。
//
// `⚠` 这个脚本**不**碰 Flutter：`PlanstarAuthApi` / `PsNetworkInterceptor` /
// `ApiConfig` 都刻意保持纯 Dart，`dart run` 能直接加载。凡是 import 了
// `package:flutter/*` 的文件（例如 `AuthSessionStore`）都不在这里用——
// 会话落盘那一环由 `test/features/auth/remote_auth_repository_test.dart` 覆盖。
//
// `⚠` 关于"发码"：`v3/user/sendLoginCode` 有两道门——正常时直接下发短信，
// 风控触发时回 `{"success":false,"needCaptcha":true,"errorMsg":"请输入图形验证码"}`
// （实测 2026-11，机房 IP 基本必触发）。这不是客户端请求形状的问题，
// 所以脚本把"发码"当**观测项**，只对"补了图形码之后服务端怎么回"做断言。
// 要跑通完整的成功路径，需要在真机 App 上手动过图形码收一次短信验证码，
// 再用 `--code=<验证码>` 重跑本脚本。
library;

import 'dart:io';

import 'package:core_network/core_network.dart';
import 'package:core_result/core_result.dart';
import 'package:dio/dio.dart';
import 'package:planstar/app/network/api_config.dart';
import 'package:planstar/app/network/device_identity.dart';
import 'package:planstar/app/network/ps_network_interceptor.dart';
import 'package:planstar/app/network/ps_request_context.dart';
import 'package:planstar/features/auth/data/dto/login_response_dto.dart';
import 'package:planstar/features/auth/data/dto/send_code_response_dto.dart';
import 'package:planstar/features/auth/data/planstar_auth_api.dart';
import 'package:planstar/features/auth/domain/auth_failure.dart';

/// 一条检查的结果。
final class CheckResult {
  const CheckResult({
    required this.name,
    required this.passed,
    required this.detail,
    this.observation = false,
  });

  final String name;
  final bool passed;

  /// 实际发生了什么（失败时就是"为什么不算通过"）。
  final String detail;

  /// `true` = 只观测不断言（服务端行为不可控的项）。
  final bool observation;

  bool get failed => !passed && !observation;
}

Future<void> main(List<String> args) async {
  final Map<String, String> options = _parseArgs(args);

  final ApiConfig config = ApiConfig.resolve();
  final String baseUrl = options['base'] ?? config.baseUrl;
  final String phone = options['phone'] ?? '13800138000';
  final String? code = options['code'];

  final context = PsRequestContext(dvid: generateDvid());
  final dio = buildDio(
    baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    interceptors: <Interceptor>[
      PsNetworkInterceptor(context: context, userAgent: config.userAgent),
    ],
  );
  final api = PlanstarAuthApi(client: ApiClient(dio), clientType: config.clientType);

  _banner('企划星登录接口联调', <String, String>{
    'base': baseUrl,
    'ua': config.userAgent,
    'dvid': context.dvid ?? '',
    'ct': '${config.clientType}',
    'phone': phone,
    'code': code == null ? '（未提供 → 只跑失败路径）' : '已提供',
  });

  final results = <CheckResult>[];
  results.add(await _checkCaptcha(api));
  final sendCode = await _checkSendCode(api, phone);
  results.add(sendCode.result);
  if (sendCode.needCaptcha) {
    results.add(await _checkCaptchaRetry(api, phone));
  }
  results.add(await _checkWrongCode(api, phone));
  results.add(await _checkPasswordDisabled(api, phone));
  results.add(await _checkEmptyCode(api, phone));
  if (code != null) {
    results.add(await _checkRealLogin(api, context, phone, code));
  }

  _summary(results, context);
  exit(results.any((CheckResult r) => r.failed) ? 1 : 0);
}

// ---------------------------------------------------------------------------
// 检查项
// ---------------------------------------------------------------------------

/// `GET v1/user/captcha` 必须返回真 PNG（不是 JSON、不是 HTML）。
Future<CheckResult> _checkCaptcha(PlanstarAuthApi api) async {
  const String name = '图形验证码 GET v1/user/captcha';
  final Result<List<int>> result = await api.fetchCaptchaImage();
  return result.fold(
    onFailure: (Failure failure) => CheckResult(
      name: name,
      passed: false,
      detail: '失败：${failure.type.name} / ${failure.message}',
    ),
    onSuccess: (List<int> bytes) {
      final bool isPng = bytes.length > 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47;
      return CheckResult(
        name: name,
        passed: isPng,
        detail: isPng
            ? '${bytes.length} 字节，PNG 魔数正确'
            : '返回了 ${bytes.length} 字节，但不是 PNG（头 4 字节：'
                '${bytes.take(4).map((int b) => b.toRadixString(16)).join(' ')}）',
      );
    },
  );
}

/// `POST v3/user/sendLoginCode`：**只观测**。
///
/// 服务端有两道门：正常时直接下发；风控触发时回
/// `{success:false, needCaptcha:true, errorMsg:"请输入图形验证码"}`。
/// 后者既不是我们的 bug 也不代表契约变了，所以不断言，只把
/// `needCaptcha` 带出去，决定要不要跑 [_checkCaptchaRetry]。
Future<({CheckResult result, bool needCaptcha})> _checkSendCode(
  PlanstarAuthApi api,
  String phone,
) async {
  const String name = '发送登录验证码 POST v3/user/sendLoginCode';
  final Result<SendCodeResponseDto> result =
      await api.sendLoginCode(phone: phone);
  return result.fold(
    onFailure: (Failure failure) => (
      result: CheckResult(
        name: name,
        passed: false,
        observation: true,
        detail: 'HTTP 层失败：${failure.type.name} / ${failure.message}',
      ),
      needCaptcha: false,
    ),
    onSuccess: (SendCodeResponseDto dto) => (
      result: CheckResult(
        name: name,
        passed: dto.success,
        observation: true,
        detail: dto.success
            ? 'success=true，短信已下发'
            : 'success=false needCaptcha=${dto.needCaptcha} '
                'errorMsg=${dto.errorMsg ?? '(空)'}'
                '（契约形状正确）',
      ),
      needCaptcha: dto.needCaptcha,
    ),
  );
}

/// 风控要图形码时补一个**故意错误**的图形码：服务端必须明确说"图形验证码错误"。
///
/// 这一条是 [AuthController] 那个"补码重放"循环的依据——如果服务端在这里
/// 回的是 `发送失败` 而不是 `图形验证码错误`，对话框就该被判为无效（用户
/// 怎么输都过不去），UI 得改成"直接放弃"而不是继续弹框。
Future<CheckResult> _checkCaptchaRetry(PlanstarAuthApi api, String phone) async {
  const String name = '错误图形码 POST v3/user/sendLoginCode (captcha)';
  final Result<SendCodeResponseDto> result = await api.sendLoginCode(
    phone: phone,
    captcha: 'zzzz',
  );
  return result.fold(
    onFailure: (Failure failure) => CheckResult(
      name: name,
      passed: false,
      detail: 'HTTP 层失败：${failure.type.name} / ${failure.message}',
    ),
    onSuccess: (SendCodeResponseDto dto) {
      final String message = dto.errorMsg ?? '';
      final bool ok = dto.needCaptcha && message.contains('图形验证码');
      return CheckResult(
        name: name,
        passed: ok,
        detail: 'success=${dto.success} needCaptcha=${dto.needCaptcha} '
            'errorMsg=${message.isEmpty ? '(空)' : '「$message」'}'
            '${ok ? ' ← 补码重放循环有效' : ' ← 期望 needCaptcha=true 且文案含「图形验证码」'}',
      );
    },
  );
}

/// 错误验证码：**核心断言**——服务端的中文原文必须一路穿到 [AuthFailure]。
///
/// 这一条同时验证了 `ApiClient._messageOf` 对 `text/plain` 的支持：
/// 少了它，这里会退化成 `服务开小差了，请稍后重试`。
Future<CheckResult> _checkWrongCode(PlanstarAuthApi api, String phone) async {
  const String name = '错误验证码 POST v1/user/login (code)';
  final Result<LoginResponseDto> result = await api.login(
    phone: phone,
    code: '000000',
  );
  return result.fold(
    onFailure: (Failure failure) {
      final AuthFailure auth = AuthFailure.fromFailure(failure);
      final bool ok = failure.message.contains('验证码') &&
          auth.kind == AuthFailureKind.business;
      return CheckResult(
        name: name,
        passed: ok,
        detail: 'HTTP ${failure.statusCode ?? '-'} → '
            '「${failure.message}」（kind=${auth.kind.name}）'
            '${ok ? '' : ' ← 期望含「验证码」且归类为 business'}',
      );
    },
    onSuccess: (LoginResponseDto dto) => CheckResult(
      name: name,
      passed: false,
      detail: '居然登录成功了（userId=${dto.user?.userId}）——'
          '000000 不可能是有效验证码，契约已变',
    ),
  );
}

/// 密码登录：服务端**当前已关闭**，必须回那句"请使用手机号验证码登录"。
Future<CheckResult> _checkPasswordDisabled(
  PlanstarAuthApi api,
  String phone,
) async {
  const String name = '密码登录 POST v1/user/login (pw)';
  final Result<LoginResponseDto> result = await api.login(
    phone: phone,
    password: 'a1234567',
  );
  return result.fold(
    onFailure: (Failure failure) => CheckResult(
      name: name,
      passed: failure.message.contains('验证码登录') ||
          failure.message.contains('密码'),
      detail: 'HTTP ${failure.statusCode ?? '-'} → 「${failure.message}」',
    ),
    onSuccess: (LoginResponseDto dto) => CheckResult(
      name: name,
      passed: false,
      detail: '登录成功了（userId=${dto.user?.userId}）——'
          '说明服务端已重新开启密码登录，UI 文案要跟着改',
    ),
  );
}

/// 两个凭证都不带：服务端把它当"密码为空"，回 `请输入密码`（400）。
Future<CheckResult> _checkEmptyCode(PlanstarAuthApi api, String phone) async {
  const String name = '空凭证 POST v1/user/login';
  final Result<LoginResponseDto> result = await api.login(phone: phone);
  return result.fold(
    onFailure: (Failure failure) => CheckResult(
      name: name,
      passed: failure.message.isNotEmpty,
      detail: 'HTTP ${failure.statusCode ?? '-'} → 「${failure.message}」',
    ),
    onSuccess: (_) => const CheckResult(
      name: name,
      passed: false,
      detail: '空凭证登录成功，不可能',
    ),
  );
}

/// 完整成功路径（需要真实验证码）：登录 → 抓 `psSession` → 用户资料可用。
Future<CheckResult> _checkRealLogin(
  PlanstarAuthApi api,
  PsRequestContext context,
  String phone,
  String code,
) async {
  const String name = '真实登录 POST v1/user/login (code)';
  final Result<LoginResponseDto> result =
      await api.login(phone: phone, code: code);
  return result.fold(
    onFailure: (Failure failure) => CheckResult(
      name: name,
      passed: false,
      detail: 'HTTP ${failure.statusCode ?? '-'} → 「${failure.message}」',
    ),
    onSuccess: (LoginResponseDto dto) {
      final token = context.psSession;
      final user = dto.user;
      final bool ok = user != null && user.isValid && token != null;
      return CheckResult(
        name: name,
        passed: ok,
        detail: 'userId=${user?.userId} 昵称=${user?.displayName} '
            'newUser=${dto.newUser} '
            'psSession=${token == null ? '（缺失！）' : '已捕获(${token.length} 字符)'} '
            'avatar=${(user?.avatar ?? '').isEmpty ? '(空)' : '有'}',
      );
    },
  );
}

// ---------------------------------------------------------------------------
// 输出
// ---------------------------------------------------------------------------

void _banner(String title, Map<String, String> rows) {
  stdout.writeln('');
  stdout.writeln('══ $title ══');
  for (final entry in rows.entries) {
    stdout.writeln('  ${entry.key.padRight(6)}: ${entry.value}');
  }
  stdout.writeln('');
}

void _summary(List<CheckResult> results, PsRequestContext context) {
  stdout.writeln('── 结果 ──');
  for (final CheckResult r in results) {
    final String mark = r.observation
        ? (r.passed ? '✓' : '○')
        : (r.passed ? '✓' : '✗');
    stdout.writeln('$mark ${r.name}');
    stdout.writeln('    ${r.detail}');
  }

  final int failures = results.where((CheckResult r) => r.failed).length;
  final int observations = results.where((CheckResult r) => r.observation).length;
  stdout.writeln('');
  if (failures == 0) {
    stdout.writeln('✓ 断言全部通过'
        '（另有 $observations 条观测项不计入断言）');
    if (context.psSession == null) {
      stdout.writeln('  提示：本次没有拿到 psSession（未登录）。要验证成功路径，'
          '请带 --code=<真实验证码> 重跑。');
    }
  } else {
    stdout.writeln('✗ $failures 条断言未通过');
  }
  stdout.writeln('');
}

Map<String, String> _parseArgs(List<String> args) {
  final map = <String, String>{};
  for (final arg in args) {
    if (!arg.startsWith('--')) {
      continue;
    }
    final body = arg.substring(2);
    final eq = body.indexOf('=');
    if (eq < 0) {
      map[body] = 'true';
    } else {
      map[body.substring(0, eq)] = body.substring(eq + 1);
    }
  }
  return map;
}
