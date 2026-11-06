/// 真实登录实现：调接口 + 落盘会话 + 归一失败。
///
/// 归一失败的口径：**把"哪一类失败"编码进 `Failure.code`**，把"给用户看
/// 什么"放进 `Failure.message`。这样端口仍然只返回全项目统一的 `Result`，
/// UI 侧再经 `AuthFailure.fromFailure` 换成枚举（见 domain/auth_failure.dart）。
library;

import 'package:core/result.dart';

import '../../../app/network/ps_request_context.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import '../domain/auth_user.dart';
import 'auth_session_store.dart';
import 'dto/login_response_dto.dart';
import 'dto/send_code_response_dto.dart';
import 'planstar_auth_api.dart';

/// 基于 HTTP 接口的认证仓库。
final class RemoteAuthRepository implements AuthRepository {
  /// 创建仓库。
  RemoteAuthRepository({
    required PlanstarAuthApi api,
    required AuthSessionStore store,
    required PsRequestContext context,
  })  : _api = api,
        _store = store,
        _context = context;

  final PlanstarAuthApi _api;
  final AuthSessionStore _store;
  final PsRequestContext _context;

  @override
  Future<Result<SendCodeOutcome>> sendLoginCode(
    String phone, {
    String? captcha,
  }) async {
    final result = await _api.sendLoginCode(phone: phone, captcha: captcha);
    return result.fold(
      onFailure: (Failure failure) =>
          Fail<SendCodeOutcome>(_normalize(failure)),
      onSuccess: (SendCodeResponseDto dto) {
        if (dto.success) {
          return const Success<SendCodeOutcome>(SendCodeOutcome());
        }
        if (dto.needCaptcha) {
          // 用服务端原文当对话框的说明：风控触发时是 `请输入图形验证码`，
          // 补错码之后是 `图形验证码错误`——这两句的差别对用户有意义
          // （一句是"要先输码"，一句是"你输错了"），不要统一成一句。
          return Fail<SendCodeOutcome>(
            Failure(
              code: AuthFailureCodes.needsCaptcha,
              message: dto.errorMsg ?? '需要图形验证码',
              type: FailureType.validation,
            ),
          );
        }
        return Fail<SendCodeOutcome>(
          Failure(
            code: AuthFailureCodes.business,
            message: dto.errorMsg ?? '验证码发送失败',
            type: FailureType.server,
          ),
        );
      },
    );
  }

  @override
  Future<Result<AuthSession>> loginWithCode(
    String phone,
    String code, {
    String? captcha,
  }) =>
      _login(phone: phone, code: code, captcha: captcha);

  @override
  Future<Result<AuthSession>> loginWithPassword(
    String phone,
    String password, {
    String? captcha,
  }) =>
      _login(phone: phone, password: password, captcha: captcha);

  @override
  Future<Result<List<int>>> fetchCaptchaImage() => _api.fetchCaptchaImage();

  @override
  Future<AuthSession?> restoreSession() => _store.read();

  @override
  Future<void> logout() => _store.clear();

  Future<Result<AuthSession>> _login({
    required String phone,
    String? code,
    String? password,
    String? captcha,
  }) async {
    final result = await _api.login(
      phone: phone,
      code: code,
      password: password,
      captcha: captcha,
    );
    return result.fold(
      // 两个分支都必须是 async，否则 fold 的 R 推不出来（一边 Result
      // 一边 Future<Result>）。
      onFailure: (Failure failure) async =>
          Fail<AuthSession>(_normalize(failure)),
      onSuccess: (LoginResponseDto dto) async {
        if (dto.needCaptcha) {
          return const Fail<AuthSession>(
            Failure(
              code: AuthFailureCodes.needsCaptcha,
              message: '需要图形验证码',
              type: FailureType.validation,
            ),
          );
        }
        final AuthUser? user = dto.user;
        if (user == null || !user.isValid) {
          return const Fail<AuthSession>(
            Failure(
              code: 'AUTH_NO_USER',
              message: '登录成功，但服务端没有返回有效的用户信息',
              type: FailureType.data,
            ),
          );
        }
        // 令牌由拦截器从响应头 `psSession` 捞进上下文（见 PsNetworkInterceptor），
        // 这里只负责取出来落盘。
        final session = AuthSession(user: user, token: _context.psSession);
        await _store.write(session);
        return Success<AuthSession>(session);
      },
    );
  }

  /// 把传输层失败归一成认证失败。
  ///
  /// 关键词判断来自来源 `BaseLoginActivity`：
  ///
  /// ```java
  /// if (strString.contains("该账号已被锁定")) showAccountLockedAlert(...);
  /// else if (strString.contains("图形验证码错误")) { reloadCaptcha(); ... }
  /// ```
  ///
  /// 来源靠两次 `contains` 做分支，这里把它提成 `Failure.code`；
  /// 判断依据保持一致，因为**服务端文案没有错误码**，只能靠文本。
  static Failure _normalize(Failure failure) {
    // 网络 / 超时 / 401 原样透传：`Failure.type` 已经足够表达，
    // `AuthFailure.fromFailure` 会按类型归一。
    if (failure.type == FailureType.network ||
        failure.type == FailureType.timeout ||
        failure.type == FailureType.authentication) {
      return failure;
    }

    final String message = failure.message;
    if (message.contains('锁定')) {
      return Failure(
        code: AuthFailureCodes.accountLocked,
        message: message,
        type: FailureType.server,
        statusCode: failure.statusCode,
        cause: failure.cause,
      );
    }
    if (message.contains('图形验证码')) {
      return Failure(
        code: AuthFailureCodes.needsCaptcha,
        message: message,
        type: FailureType.validation,
        statusCode: failure.statusCode,
        cause: failure.cause,
      );
    }
    return Failure(
      code: AuthFailureCodes.business,
      message: message.isEmpty ? '登录失败，请稍后重试' : message,
      type: FailureType.server,
      statusCode: failure.statusCode,
      cause: failure.cause,
    );
  }
}
