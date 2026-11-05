// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'auth_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AuthLocalizationsZh extends AuthLocalizations {
  AuthLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get authTitle => '登录';

  @override
  String get authLoginTitle => '登录 / 注册';

  @override
  String get authClose => '关闭';

  @override
  String get authPhoneHint => '请输入手机号';

  @override
  String get authPasswordHint => '请输入密码';

  @override
  String get authCodeHint => '请输入验证码';

  @override
  String get authSendCode => '获取验证码';

  @override
  String authResendCode(int seconds) {
    return '重新获取(${seconds}s)';
  }

  @override
  String get authAgreementPrefix => '已阅读并同意';

  @override
  String get authAgreementRegister => '《注册协议》';

  @override
  String get authAgreementAnd => '和';

  @override
  String get authAgreementPrivacy => '《隐私协议》';

  @override
  String get authSwitchToPassword => '密码登录';

  @override
  String get authSwitchToCode => '验证码登录';

  @override
  String get authMoreWays => '更多登录方式';

  @override
  String get authWechatLogin => '微信登录';

  @override
  String get authPhoneInvalid => '请输入正确的手机号';

  @override
  String get authPasswordTooShort => '密码至少 6 位';

  @override
  String get authCodeTooShort => '请输入 6 位验证码';

  @override
  String get authAgreementRequired => '请先阅读并同意《注册协议》和《隐私协议》';

  @override
  String get authCodeSent => '验证码已发送，请注意查收';

  @override
  String get authSendingCode => '发送中…';

  @override
  String get authLoggingIn => '登录中…';

  @override
  String get authWechatUnavailable => '当前构建未集成微信 SDK';

  @override
  String get authTermsTitle => '协议说明';

  @override
  String get authTermsBody => '演示版本未内置真实协议文本，正式环境会跳转企划星官网协议页。';

  @override
  String get authTermsConfirm => '我知道了';

  @override
  String get authCaptchaTitle => '图形验证码';

  @override
  String get authCaptchaHint => '请输入图中字符';

  @override
  String get authCaptchaRefresh => '换一张';

  @override
  String get authCaptchaConfirm => '确定';

  @override
  String get authCaptchaCancel => '取消';

  @override
  String get authCaptchaLoadFailed => '验证码加载失败，请重试';

  @override
  String get authAccountLockedTitle => '账号已被锁定';

  @override
  String get authNetworkError => '网络不给力，请检查网络后重试';

  @override
  String get authTimeoutError => '请求超时，请稍后重试';

  @override
  String get authUnknownError => '登录失败，请稍后重试';
}
