/// 认证端口。
///
/// 只有这一个抽象：UI/应用层依赖它，真实实现（[RemoteAuthRepository]）在
/// `data/`，测试用假实现。端口方法全部返回 `Result`，**不抛异常**——
/// 与 `core_network` 的契约一致（来源同时存在"抛异常"和"返码"两条路径，
/// 30-02）。
library;

import 'package:core_result/core_result.dart';

import 'auth_failure.dart';
import 'auth_session.dart';

/// 发送验证码的结果。
///
/// 服务端只回 `{success, needCaptcha, errorMsg}`，没有冷却时长；60 秒是
/// 客户端写死的（来源 `mValidateLeftCount = 60`）。
final class SendCodeOutcome {
  /// 创建结果。
  const SendCodeOutcome({this.cooldownSeconds = 60});

  /// 冷却秒数（UI 倒计时用）。
  final int cooldownSeconds;
}

/// 认证仓库。
abstract interface class AuthRepository {
  /// 发送登录验证码（`POST v3/user/sendLoginCode`）。
  ///
  /// 失败时可能是 [AuthFailureKind.needsCaptcha]（风控要求图形验证码）
  /// 或 [AuthFailureKind.business]（服务端原文，例如"发送失败"）。
  Future<Result<SendCodeOutcome>> sendLoginCode(
    String phone, {
    String? captcha,
  });

  /// 验证码登录（`POST v1/user/login`，body 带 `code`）。
  Future<Result<AuthSession>> loginWithCode(
    String phone,
    String code, {
    String? captcha,
  });

  /// 密码登录（`POST v1/user/login`，body 带 `pw`）。
  ///
  /// `⚠` 实测服务端当前**已关闭密码登录**：任何 `pw` 请求都返回
  /// `500 请使用手机号验证码登录，若手机号登录异常，请联系客服`。
  /// 端口保留是因为接口还在、开关在服务端，客户端不该替它做决定。
  Future<Result<AuthSession>> loginWithPassword(
    String phone,
    String password, {
    String? captcha,
  });

  /// 拉取图形验证码图片（`GET v1/user/captcha`，`image/png`）。
  Future<Result<List<int>>> fetchCaptchaImage();

  /// 读取本地缓存的会话（冷启动）。
  Future<AuthSession?> restoreSession();

  /// 登出：清本地会话 + 清请求上下文。
  ///
  /// `⚠` 来源**不发登出请求**（`AccountService.logout()` 只清本地），
  /// 服务端的 `psSession` 只能等它自己过期。这里保持一致：没有 `/logout` 接口。
  Future<void> logout();
}
