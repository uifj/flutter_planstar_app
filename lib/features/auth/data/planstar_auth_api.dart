/// 企划星登录接口（**纯 Dart**，不 import Flutter）。
///
/// 三个端点的路径、请求体与响应形状全部来自来源
/// `lib\services\LoginService.java` 与 `account\QuickLoginCell.java` /
/// `account\BaseLoginActivity.java`：
///
/// | 用途 | 方法 | 路径 | body |
/// |---|---|---|---|
/// | 密码登录 | POST | `v1/user/login` | `{ua, pw, captcha?, ct}` |
/// | 验证码登录 | POST | `v1/user/login` | `{ua, code, captcha?, ct}` |
/// | 发登录码 | POST | `v3/user/sendLoginCode` | `{ua, captcha?}` |
/// | 图形验证码 | GET | `v1/user/captcha` | —（返回 `image/png`） |
///
/// 为什么这个文件刻意保持纯 Dart：`tool/verify_login_api.dart` 要用
/// `dart run` 直连真实接口做验证，而 `dart run` 加载不了 Flutter 引擎。
/// 把"请求形状"和"Flutter 装配"分开，验证脚本就能复用**同一份**代码，
/// 而不是另抄一遍 curl。
///
/// `⚠` 版本号是错位的：发码在 **v3**，提交登录在 **v1**（M6-16 记的
/// "发码 v3、提交 v1 的版本错配"）。这里照抄，不"顺手统一"——服务端就是这么挂的。
library;

import 'package:core_network/core_network.dart';
import 'package:core_result/core_result.dart';
import 'package:dio/dio.dart' show Options, ResponseType;

import 'dto/json_shape.dart';
import 'dto/login_response_dto.dart';
import 'dto/send_code_response_dto.dart';

/// 登录接口客户端。
final class PlanstarAuthApi {
  /// 创建客户端。
  PlanstarAuthApi({required ApiClient client, this.clientType = 11})
      : _client = client;

  final ApiClient _client;

  /// 客户端类型（请求体的 `ct`，来源 `PlanstarConstants.CLIENT_TYPE = 11` = Android）。
  final int clientType;

  /// 登录路径。
  static const String loginPath = 'v1/user/login';

  /// 发登录验证码路径。
  static const String sendLoginCodePath = 'v3/user/sendLoginCode';

  /// 图形验证码路径。
  static const String captchaPath = 'v1/user/captcha';

  /// 登录。`code` 与 `password` 二选一（都为空时服务端会报错，这里不拦）。
  ///
  /// 来源的密码分支还会带一个 `channelAttributeInfo`（广告归因的 JSON 字符串，
  /// 内含 androidId / clickid / oaid）。这里**不发**：它只影响投放归因，不影响
  /// 鉴权，而我们没有 OAID/clickId 可填，发一串 null 反而可能被服务端判成
  /// 脏数据。等接了归因 SDK 再补。
  Future<Result<LoginResponseDto>> login({
    required String phone,
    String? password,
    String? code,
    String? captcha,
  }) {
    final Map<String, Object?> body = <String, Object?>{
      'ua': phone,
      'ct': clientType,
    };
    if (code != null && code.isNotEmpty) {
      body['code'] = code;
    }
    if (password != null && password.isNotEmpty) {
      body['pw'] = password;
    }
    if (captcha != null && captcha.isNotEmpty) {
      body['captcha'] = captcha;
    }
    return _client.post<LoginResponseDto>(
      loginPath,
      data: body,
      // 登录返回的是**裸 LoginBean**（不是 {code,message,data}），
      // 失败靠 HTTP 状态码 + text/plain 正文表达。
      envelope: const PassthroughEnvelope(),
      parser: _parseLogin,
    );
  }

  /// 发送登录验证码。
  Future<Result<SendCodeResponseDto>> sendLoginCode({
    required String phone,
    String? captcha,
  }) {
    final Map<String, Object?> body = <String, Object?>{'ua': phone};
    if (captcha != null && captcha.isNotEmpty) {
      body['captcha'] = captcha;
    }
    return _client.post<SendCodeResponseDto>(
      sendLoginCodePath,
      data: body,
      // 这个接口是 200 + {success, needCaptcha, errorMsg}。
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => SendCodeResponseDto.fromJson(
        asStringKeyedMap(data, what: '发验证码响应'),
      ),
    );
  }

  /// 拉图形验证码（PNG 字节）。
  Future<Result<List<int>>> fetchCaptchaImage() {
    return _client.get<List<int>>(
      captchaPath,
      options: Options(responseType: ResponseType.bytes),
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        if (data is List<int>) {
          return data;
        }
        throw FormatException('图形验证码不是二进制：$data');
      },
    );
  }

  static LoginResponseDto _parseLogin(Object? data) {
    return LoginResponseDto.fromJson(
      asStringKeyedMap(data, what: '登录响应'),
    );
  }
}
