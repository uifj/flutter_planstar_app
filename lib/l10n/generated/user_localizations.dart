import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'user_localizations_en.dart';
import 'user_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of UserLocalizations
/// returned by `UserLocalizations.of(context)`.
///
/// Applications need to include `UserLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/user_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: UserLocalizations.localizationsDelegates,
///   supportedLocales: UserLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the UserLocalizations.supportedLocales
/// property.
abstract class UserLocalizations {
  UserLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static UserLocalizations of(BuildContext context) {
    return Localizations.of<UserLocalizations>(context, UserLocalizations)!;
  }

  static const LocalizationsDelegate<UserLocalizations> delegate = _UserLocalizationsDelegate();

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

  /// No description provided for @userTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get userTitle;

  /// No description provided for @userLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'已登录：{nickname}'**
  String userLoggedIn(String nickname);

  /// No description provided for @userNotLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'未登录'**
  String get userNotLoggedIn;

  /// No description provided for @userLogout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get userLogout;

  /// No description provided for @userMockLogin.
  ///
  /// In zh, this message translates to:
  /// **'模拟登录'**
  String get userMockLogin;

  /// No description provided for @userViewOrders.
  ///
  /// In zh, this message translates to:
  /// **'查看订单（受门禁保护）'**
  String get userViewOrders;

  /// No description provided for @addressPage_49.
  ///
  /// In zh, this message translates to:
  /// **'收货地址'**
  String get addressPage_49;

  /// No description provided for @addressPage_55.
  ///
  /// In zh, this message translates to:
  /// **'还没有收货地址'**
  String get addressPage_55;

  /// No description provided for @addressPage_56.
  ///
  /// In zh, this message translates to:
  /// **'寄送线下回报时需要地址，先添加一个吧'**
  String get addressPage_56;

  /// No description provided for @addressPage_58.
  ///
  /// In zh, this message translates to:
  /// **'新增地址'**
  String get addressPage_58;

  /// No description provided for @addressPage_131.
  ///
  /// In zh, this message translates to:
  /// **'删除地址'**
  String get addressPage_131;

  /// No description provided for @addressPage_132.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{name} {maskedMobile}」这个地址吗？'**
  String addressPage_132(Object name, Object maskedMobile);

  /// No description provided for @addressPage_140.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get addressPage_140;

  /// No description provided for @addressPage_150.
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get addressPage_150;

  /// No description provided for @addressPage_211.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get addressPage_211;

  /// No description provided for @addressPage_263.
  ///
  /// In zh, this message translates to:
  /// **'默认地址'**
  String get addressPage_263;

  /// No description provided for @addressPage_263_2.
  ///
  /// In zh, this message translates to:
  /// **'设为默认'**
  String get addressPage_263_2;

  /// No description provided for @addressPage_276.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get addressPage_276;

  /// No description provided for @addressPage_278.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get addressPage_278;

  /// No description provided for @addressPage_349.
  ///
  /// In zh, this message translates to:
  /// **'新增地址'**
  String get addressPage_349;

  /// No description provided for @addressPage_472.
  ///
  /// In zh, this message translates to:
  /// **'编辑地址'**
  String get addressPage_472;

  /// No description provided for @addressPage_472_2.
  ///
  /// In zh, this message translates to:
  /// **'新增地址'**
  String get addressPage_472_2;

  /// No description provided for @addressPage_493.
  ///
  /// In zh, this message translates to:
  /// **'收件人'**
  String get addressPage_493;

  /// No description provided for @addressPage_494.
  ///
  /// In zh, this message translates to:
  /// **'真实姓名'**
  String get addressPage_494;

  /// No description provided for @addressPage_500.
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get addressPage_500;

  /// No description provided for @addressPage_501.
  ///
  /// In zh, this message translates to:
  /// **'11 位手机号'**
  String get addressPage_501;

  /// No description provided for @addressPage_511.
  ///
  /// In zh, this message translates to:
  /// **'所在地区'**
  String get addressPage_511;

  /// No description provided for @addressPage_512.
  ///
  /// In zh, this message translates to:
  /// **'省 市 区（如：上海市 浦东新区）'**
  String get addressPage_512;

  /// No description provided for @addressPage_517.
  ///
  /// In zh, this message translates to:
  /// **'详细地址'**
  String get addressPage_517;

  /// No description provided for @addressPage_518.
  ///
  /// In zh, this message translates to:
  /// **'街道、门牌号、回报领取点'**
  String get addressPage_518;

  /// No description provided for @profileProviders_58.
  ///
  /// In zh, this message translates to:
  /// **'登录更精彩'**
  String get profileProviders_58;

  /// No description provided for @profileProviders_86.
  ///
  /// In zh, this message translates to:
  /// **'V{level} 资深支持人'**
  String profileProviders_86(Object level);

  /// No description provided for @editProfilePage_65.
  ///
  /// In zh, this message translates to:
  /// **'编辑资料'**
  String get editProfilePage_65;

  /// No description provided for @editProfilePage_75.
  ///
  /// In zh, this message translates to:
  /// **'头像上传待接入'**
  String get editProfilePage_75;

  /// No description provided for @editProfilePage_107.
  ///
  /// In zh, this message translates to:
  /// **'点击更换头像'**
  String get editProfilePage_107;

  /// No description provided for @editProfilePage_116.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get editProfilePage_116;

  /// No description provided for @editProfilePage_140.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get editProfilePage_140;

  /// No description provided for @editProfilePage_145.
  ///
  /// In zh, this message translates to:
  /// **'保密'**
  String get editProfilePage_145;

  /// No description provided for @editProfilePage_151.
  ///
  /// In zh, this message translates to:
  /// **'男'**
  String get editProfilePage_151;

  /// No description provided for @editProfilePage_157.
  ///
  /// In zh, this message translates to:
  /// **'女'**
  String get editProfilePage_157;

  /// No description provided for @editProfilePage_165.
  ///
  /// In zh, this message translates to:
  /// **'个性签名'**
  String get editProfilePage_165;

  /// No description provided for @editProfilePage_180.
  ///
  /// In zh, this message translates to:
  /// **'写点什么介绍自己吧…'**
  String get editProfilePage_180;

  /// No description provided for @editProfilePage_229.
  ///
  /// In zh, this message translates to:
  /// **'资料已记录（演示模式，未实际提交到服务器）'**
  String get editProfilePage_229;

  /// No description provided for @feedbackPage_32.
  ///
  /// In zh, this message translates to:
  /// **'功能建议'**
  String get feedbackPage_32;

  /// No description provided for @feedbackPage_33.
  ///
  /// In zh, this message translates to:
  /// **'企划问题'**
  String get feedbackPage_33;

  /// No description provided for @feedbackPage_34.
  ///
  /// In zh, this message translates to:
  /// **'支付问题'**
  String get feedbackPage_34;

  /// No description provided for @feedbackPage_35.
  ///
  /// In zh, this message translates to:
  /// **'支持体验'**
  String get feedbackPage_35;

  /// No description provided for @feedbackPage_36.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get feedbackPage_36;

  /// No description provided for @feedbackPage_58.
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get feedbackPage_58;

  /// No description provided for @feedbackPage_66.
  ///
  /// In zh, this message translates to:
  /// **'反馈类型'**
  String get feedbackPage_66;

  /// No description provided for @feedbackPage_114.
  ///
  /// In zh, this message translates to:
  /// **'反馈内容'**
  String get feedbackPage_114;

  /// No description provided for @feedbackPage_123.
  ///
  /// In zh, this message translates to:
  /// **'请至少填写 10 个字，以便我们更好地理解您的问题'**
  String get feedbackPage_123;

  /// No description provided for @feedbackPage_140.
  ///
  /// In zh, this message translates to:
  /// **'请描述您遇到的问题或建议…'**
  String get feedbackPage_140;

  /// No description provided for @feedbackPage_160.
  ///
  /// In zh, this message translates to:
  /// **'联系方式（选填）'**
  String get feedbackPage_160;

  /// No description provided for @feedbackPage_169.
  ///
  /// In zh, this message translates to:
  /// **'留下手机号或邮箱，方便我们与您联系'**
  String get feedbackPage_169;

  /// No description provided for @feedbackPage_184.
  ///
  /// In zh, this message translates to:
  /// **'手机号 / 邮箱'**
  String get feedbackPage_184;

  /// No description provided for @feedbackPage_211.
  ///
  /// In zh, this message translates to:
  /// **'提交反馈'**
  String get feedbackPage_211;

  /// No description provided for @feedbackPage_230.
  ///
  /// In zh, this message translates to:
  /// **'反馈已记录（演示模式，未实际提交到服务器）'**
  String get feedbackPage_230;

  /// No description provided for @settingsPage_53.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsPage_53;

  /// No description provided for @settingsPage_60.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get settingsPage_60;

  /// No description provided for @settingsPage_64.
  ///
  /// In zh, this message translates to:
  /// **'请先登录'**
  String get settingsPage_64;

  /// No description provided for @settingsPage_67.
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get settingsPage_67;

  /// No description provided for @settingsPage_68.
  ///
  /// In zh, this message translates to:
  /// **'未绑定'**
  String get settingsPage_68;

  /// No description provided for @settingsPage_69.
  ///
  /// In zh, this message translates to:
  /// **'换绑手机号需要先验证原手机号'**
  String get settingsPage_69;

  /// No description provided for @settingsPage_72.
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get settingsPage_72;

  /// No description provided for @settingsPage_76.
  ///
  /// In zh, this message translates to:
  /// **'实名认证'**
  String get settingsPage_76;

  /// No description provided for @settingsPage_77.
  ///
  /// In zh, this message translates to:
  /// **'未认证'**
  String get settingsPage_77;

  /// No description provided for @settingsPage_79.
  ///
  /// In zh, this message translates to:
  /// **'实名认证属于独立的 id 聚合，本示例未实现'**
  String get settingsPage_79;

  /// No description provided for @settingsPage_86.
  ///
  /// In zh, this message translates to:
  /// **'消息通知'**
  String get settingsPage_86;

  /// No description provided for @settingsPage_95.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get settingsPage_95;

  /// No description provided for @settingsPage_107.
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get settingsPage_107;

  /// No description provided for @settingsPage_108.
  ///
  /// In zh, this message translates to:
  /// **'图片与接口缓存'**
  String get settingsPage_108;

  /// No description provided for @settingsPage_110.
  ///
  /// In zh, this message translates to:
  /// **'缓存清理待接入 package:core/cache.dart 的 HttpCacheStore'**
  String get settingsPage_110;

  /// No description provided for @settingsPage_117.
  ///
  /// In zh, this message translates to:
  /// **'版本号'**
  String get settingsPage_117;

  /// No description provided for @settingsPage_119.
  ///
  /// In zh, this message translates to:
  /// **'已是最新版本'**
  String get settingsPage_119;

  /// No description provided for @settingsPage_122.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get settingsPage_122;

  /// No description provided for @settingsPage_123.
  ///
  /// In zh, this message translates to:
  /// **'协议页待接入 WebView（`web` 包 64 个类的等价物）'**
  String get settingsPage_123;

  /// No description provided for @settingsPage_126.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get settingsPage_126;

  /// No description provided for @settingsPage_128.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策页待接入 WebView'**
  String get settingsPage_128;

  /// No description provided for @settingsPage_162.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsPage_162;

  /// No description provided for @settingsPage_164.
  ///
  /// In zh, this message translates to:
  /// **'开启'**
  String get settingsPage_164;

  /// No description provided for @settingsPageDarkModeOff.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get settingsPageDarkModeOff;

  /// No description provided for @settingsPage_172.
  ///
  /// In zh, this message translates to:
  /// **'退出后需要重新登录才能查看订单，确定继续吗？'**
  String get settingsPage_172;

  /// No description provided for @settingsPage_180.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get settingsPage_180;

  /// No description provided for @settingsPage_188.
  ///
  /// In zh, this message translates to:
  /// **'已退出登录'**
  String get settingsPage_188;

  /// No description provided for @settingsPageGroupAccount.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get settingsPageGroupAccount;

  /// No description provided for @settingsPageGroupGeneral.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settingsPageGroupGeneral;

  /// No description provided for @settingsPageGroupAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsPageGroupAbout;

  /// No description provided for @userPage_81.
  ///
  /// In zh, this message translates to:
  /// **'支持人管理待接入，敬请期待'**
  String get userPage_81;

  /// No description provided for @userPage_82.
  ///
  /// In zh, this message translates to:
  /// **'客服会话（演示）'**
  String get userPage_82;

  /// No description provided for @userPage_83.
  ///
  /// In zh, this message translates to:
  /// **'卖家招募不在本次范围内'**
  String get userPage_83;

  /// No description provided for @userPage_98.
  ///
  /// In zh, this message translates to:
  /// **'已退出登录'**
  String get userPage_98;

  /// No description provided for @userPage_254.
  ///
  /// In zh, this message translates to:
  /// **'点击登录，查看订单与更多服务'**
  String get userPage_254;

  /// No description provided for @userPage_333.
  ///
  /// In zh, this message translates to:
  /// **'支持过'**
  String get userPage_333;

  /// No description provided for @userPage_340.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get userPage_340;

  /// No description provided for @userPage_483.
  ///
  /// In zh, this message translates to:
  /// **'全部支持'**
  String get userPage_483;

  /// No description provided for @userPage_569.
  ///
  /// In zh, this message translates to:
  /// **'优惠券'**
  String get userPage_569;

  /// No description provided for @userPage_580.
  ///
  /// In zh, this message translates to:
  /// **'我的钱包'**
  String get userPage_580;

  /// No description provided for @userPage_650.
  ///
  /// In zh, this message translates to:
  /// **'礼品卡'**
  String get userPage_650;

  /// No description provided for @userPage_653.
  ///
  /// In zh, this message translates to:
  /// **'地址管理'**
  String get userPage_653;

  /// No description provided for @userPage_654.
  ///
  /// In zh, this message translates to:
  /// **'支持人'**
  String get userPage_654;

  /// No description provided for @userPage_655.
  ///
  /// In zh, this message translates to:
  /// **'联系客服'**
  String get userPage_655;

  /// No description provided for @userPage_656.
  ///
  /// In zh, this message translates to:
  /// **'卖家招募'**
  String get userPage_656;

  /// No description provided for @userMenuMall.
  ///
  /// In zh, this message translates to:
  /// **'星币商城'**
  String get userMenuMall;

  /// No description provided for @userMenuMessage.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get userMenuMessage;

  /// No description provided for @userMenuOrder.
  ///
  /// In zh, this message translates to:
  /// **'订单'**
  String get userMenuOrder;

  /// No description provided for @userMenuGroupMore.
  ///
  /// In zh, this message translates to:
  /// **'更多服务'**
  String get userMenuGroupMore;

  /// No description provided for @signInReward.
  ///
  /// In zh, this message translates to:
  /// **'每日签到 · +{amount} 星币'**
  String signInReward(Object amount);

  /// No description provided for @signInDone.
  ///
  /// In zh, this message translates to:
  /// **'今日已签到'**
  String get signInDone;

  /// No description provided for @signInSuccess.
  ///
  /// In zh, this message translates to:
  /// **'签到成功，+{amount} 星币'**
  String signInSuccess(Object amount);

  /// No description provided for @signInFailed.
  ///
  /// In zh, this message translates to:
  /// **'签到失败，请稍后重试'**
  String get signInFailed;
}

class _UserLocalizationsDelegate extends LocalizationsDelegate<UserLocalizations> {
  const _UserLocalizationsDelegate();

  @override
  Future<UserLocalizations> load(Locale locale) {
    return SynchronousFuture<UserLocalizations>(lookupUserLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_UserLocalizationsDelegate old) => false;
}

UserLocalizations lookupUserLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return UserLocalizationsEn();
    case 'zh': return UserLocalizationsZh();
  }

  throw FlutterError(
    'UserLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
