// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'auth_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AuthLocalizationsEn extends AuthLocalizations {
  AuthLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authTitle => 'Sign in';

  @override
  String get authLoginTitle => 'Sign in / Sign up';

  @override
  String get authClose => 'Close';

  @override
  String get authPhoneHint => 'Enter your phone number';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authCodeHint => 'Enter the code';

  @override
  String get authSendCode => 'Get code';

  @override
  String authResendCode(int seconds) {
    return 'Resend (${seconds}s)';
  }

  @override
  String get authAgreementPrefix => 'I have read and agree to';

  @override
  String get authAgreementRegister => 'the Terms';

  @override
  String get authAgreementAnd => 'and';

  @override
  String get authAgreementPrivacy => 'the Privacy Policy';

  @override
  String get authSwitchToPassword => 'Sign in with password';

  @override
  String get authSwitchToCode => 'Sign in with code';

  @override
  String get authMoreWays => 'More ways to sign in';

  @override
  String get authWechatLogin => 'WeChat';

  @override
  String get authPhoneInvalid => 'Enter a valid phone number';

  @override
  String get authPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get authCodeTooShort => 'Enter the 6-digit code';

  @override
  String get authAgreementRequired => 'Please accept the Terms and Privacy Policy first';

  @override
  String get authCodeSent => 'Code sent, please check your messages';

  @override
  String get authSendingCode => 'Sending…';

  @override
  String get authLoggingIn => 'Signing in…';

  @override
  String get authWechatUnavailable => 'WeChat SDK is not integrated in this build';

  @override
  String get authTermsTitle => 'Agreement';

  @override
  String get authTermsBody => 'The demo build ships no real agreement text; production opens the Planstar web agreement.';

  @override
  String get authTermsConfirm => 'Got it';

  @override
  String get authCaptchaTitle => 'Verification code';

  @override
  String get authCaptchaHint => 'Enter the characters above';

  @override
  String get authCaptchaRefresh => 'Refresh';

  @override
  String get authCaptchaConfirm => 'OK';

  @override
  String get authCaptchaCancel => 'Cancel';

  @override
  String get authCaptchaLoadFailed => 'Could not load the code, please retry';

  @override
  String get authAccountLockedTitle => 'Account locked';

  @override
  String get authNetworkError => 'Network unavailable, check your connection and retry';

  @override
  String get authTimeoutError => 'Request timed out, please retry';

  @override
  String get authUnknownError => 'Sign-in failed, please retry';

  @override
  String get loginResponseDto_50 => '登录响应的 user 字段';

  @override
  String get planstarAuthApi_101 => '发验证码响应';

  @override
  String get planstarAuthApi_123 => '登录响应';

  @override
  String get remoteAuthRepository_55 => '需要图形验证码';

  @override
  String get remoteAuthRepository_63 => '验证码发送失败';

  @override
  String get remoteAuthRepository_118 => '需要图形验证码';

  @override
  String get remoteAuthRepository_128 => '登录成功，但服务端没有返回有效的用户信息';

  @override
  String get remoteAuthRepository_163 => '锁定';

  @override
  String authSession_31(Object userId, Object tokenState) {
    return 'AuthSession($userId, token: $tokenState)';
  }

  @override
  String get authUser_119 => '票友';
}
