import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'auth_localizations_en.dart';
import 'auth_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AuthLocalizations
/// returned by `AuthLocalizations.of(context)`.
///
/// Applications need to include `AuthLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/auth_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AuthLocalizations.localizationsDelegates,
///   supportedLocales: AuthLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AuthLocalizations.supportedLocales
/// property.
abstract class AuthLocalizations {
  AuthLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AuthLocalizations of(BuildContext context) {
    return Localizations.of<AuthLocalizations>(context, AuthLocalizations)!;
  }

  static const LocalizationsDelegate<AuthLocalizations> delegate = _AuthLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @authTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get authTitle;

  /// No description provided for @authLoginTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录 / 注册'**
  String get authLoginTitle;

  /// No description provided for @authClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get authClose;

  /// No description provided for @authPhoneHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入手机号'**
  String get authPhoneHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get authPasswordHint;

  /// No description provided for @authCodeHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入验证码'**
  String get authCodeHint;

  /// No description provided for @authSendCode.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get authSendCode;

  /// No description provided for @authResendCode.
  ///
  /// In zh, this message translates to:
  /// **'重新获取({seconds}s)'**
  String authResendCode(int seconds);

  /// No description provided for @authAgreementPrefix.
  ///
  /// In zh, this message translates to:
  /// **'已阅读并同意'**
  String get authAgreementPrefix;

  /// No description provided for @authAgreementRegister.
  ///
  /// In zh, this message translates to:
  /// **'《注册协议》'**
  String get authAgreementRegister;

  /// No description provided for @authAgreementAnd.
  ///
  /// In zh, this message translates to:
  /// **'和'**
  String get authAgreementAnd;

  /// No description provided for @authAgreementPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'《隐私协议》'**
  String get authAgreementPrivacy;

  /// No description provided for @authSwitchToPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码登录'**
  String get authSwitchToPassword;

  /// No description provided for @authSwitchToCode.
  ///
  /// In zh, this message translates to:
  /// **'验证码登录'**
  String get authSwitchToCode;

  /// No description provided for @authMoreWays.
  ///
  /// In zh, this message translates to:
  /// **'更多登录方式'**
  String get authMoreWays;

  /// No description provided for @authWechatLogin.
  ///
  /// In zh, this message translates to:
  /// **'微信登录'**
  String get authWechatLogin;

  /// No description provided for @authPhoneInvalid.
  ///
  /// In zh, this message translates to:
  /// **'请输入正确的手机号'**
  String get authPhoneInvalid;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In zh, this message translates to:
  /// **'密码至少 6 位'**
  String get authPasswordTooShort;

  /// No description provided for @authCodeTooShort.
  ///
  /// In zh, this message translates to:
  /// **'请输入 6 位验证码'**
  String get authCodeTooShort;

  /// No description provided for @authAgreementRequired.
  ///
  /// In zh, this message translates to:
  /// **'请先阅读并同意《注册协议》和《隐私协议》'**
  String get authAgreementRequired;

  /// No description provided for @authCodeSent.
  ///
  /// In zh, this message translates to:
  /// **'验证码已发送，请注意查收'**
  String get authCodeSent;

  /// No description provided for @authSendingCode.
  ///
  /// In zh, this message translates to:
  /// **'发送中…'**
  String get authSendingCode;

  /// No description provided for @authLoggingIn.
  ///
  /// In zh, this message translates to:
  /// **'登录中…'**
  String get authLoggingIn;

  /// No description provided for @authWechatUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'当前构建未集成微信 SDK'**
  String get authWechatUnavailable;

  /// No description provided for @authTermsTitle.
  ///
  /// In zh, this message translates to:
  /// **'协议说明'**
  String get authTermsTitle;

  /// No description provided for @authTermsBody.
  ///
  /// In zh, this message translates to:
  /// **'演示版本未内置真实协议文本，正式环境会跳转企划星官网协议页。'**
  String get authTermsBody;

  /// No description provided for @authTermsConfirm.
  ///
  /// In zh, this message translates to:
  /// **'我知道了'**
  String get authTermsConfirm;

  /// No description provided for @authCaptchaTitle.
  ///
  /// In zh, this message translates to:
  /// **'图形验证码'**
  String get authCaptchaTitle;

  /// No description provided for @authCaptchaHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入图中字符'**
  String get authCaptchaHint;

  /// No description provided for @authCaptchaRefresh.
  ///
  /// In zh, this message translates to:
  /// **'换一张'**
  String get authCaptchaRefresh;

  /// No description provided for @authCaptchaConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get authCaptchaConfirm;

  /// No description provided for @authCaptchaCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get authCaptchaCancel;

  /// No description provided for @authCaptchaLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'验证码加载失败，请重试'**
  String get authCaptchaLoadFailed;

  /// No description provided for @authAccountLockedTitle.
  ///
  /// In zh, this message translates to:
  /// **'账号已被锁定'**
  String get authAccountLockedTitle;

  /// No description provided for @authNetworkError.
  ///
  /// In zh, this message translates to:
  /// **'网络不给力，请检查网络后重试'**
  String get authNetworkError;

  /// No description provided for @authTimeoutError.
  ///
  /// In zh, this message translates to:
  /// **'请求超时，请稍后重试'**
  String get authTimeoutError;

  /// No description provided for @authUnknownError.
  ///
  /// In zh, this message translates to:
  /// **'登录失败，请稍后重试'**
  String get authUnknownError;

  /// 来源：lib/features/auth/data/dto/login_response_dto.dart:50；原文：'登录响应的 user 字段'
  ///
  /// In zh, this message translates to:
  /// **'登录响应的 user 字段'**
  String get loginResponseDto_50;

  /// 来源：lib/features/auth/data/planstar_auth_api.dart:101；原文：'发验证码响应'
  ///
  /// In zh, this message translates to:
  /// **'发验证码响应'**
  String get planstarAuthApi_101;

  /// 来源：lib/features/auth/data/planstar_auth_api.dart:123；原文：'登录响应'
  ///
  /// In zh, this message translates to:
  /// **'登录响应'**
  String get planstarAuthApi_123;

  /// 来源：lib/features/auth/data/remote_auth_repository.dart:55；原文：'需要图形验证码'
  ///
  /// In zh, this message translates to:
  /// **'需要图形验证码'**
  String get remoteAuthRepository_55;

  /// 来源：lib/features/auth/data/remote_auth_repository.dart:63；原文：'验证码发送失败'
  ///
  /// In zh, this message translates to:
  /// **'验证码发送失败'**
  String get remoteAuthRepository_63;

  /// 来源：lib/features/auth/data/remote_auth_repository.dart:118；原文：'需要图形验证码'
  ///
  /// In zh, this message translates to:
  /// **'需要图形验证码'**
  String get remoteAuthRepository_118;

  /// 来源：lib/features/auth/data/remote_auth_repository.dart:128；原文：'登录成功，但服务端没有返回有效的用户信息'
  ///
  /// In zh, this message translates to:
  /// **'登录成功，但服务端没有返回有效的用户信息'**
  String get remoteAuthRepository_128;

  /// 来源：lib/features/auth/data/remote_auth_repository.dart:163；原文：'锁定'
  ///
  /// In zh, this message translates to:
  /// **'锁定'**
  String get remoteAuthRepository_163;

  /// 来源：lib/features/auth/domain/auth_session.dart:31；原文：'AuthSession(${user.userId}, token: ${token == null ? '无' : '有'})'
  ///
  /// In zh, this message translates to:
  /// **'AuthSession({userId}, token: {tokenState})'**
  String authSession_31(Object userId, Object tokenState);

  /// 来源：lib/features/auth/domain/auth_user.dart:119；原文：'票友'
  ///
  /// In zh, this message translates to:
  /// **'同好'**
  String get authUser_119;
}

class _AuthLocalizationsDelegate extends LocalizationsDelegate<AuthLocalizations> {
  const _AuthLocalizationsDelegate();

  @override
  Future<AuthLocalizations> load(Locale locale) {
    return SynchronousFuture<AuthLocalizations>(lookupAuthLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AuthLocalizationsDelegate old) => false;
}

AuthLocalizations lookupAuthLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AuthLocalizationsEn();
    case 'zh': return AuthLocalizationsZh();
  }

  throw FlutterError(
    'AuthLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
