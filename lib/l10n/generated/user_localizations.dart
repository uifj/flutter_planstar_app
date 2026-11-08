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

  /// 来源：lib/features/user/address_page.dart:49；原文：'收货地址'
  ///
  /// In zh, this message translates to:
  /// **'收货地址'**
  String get addressPage_49;

  /// 来源：lib/features/user/address_page.dart:55；原文：'还没有收货地址'
  ///
  /// In zh, this message translates to:
  /// **'还没有收货地址'**
  String get addressPage_55;

  /// 来源：lib/features/user/address_page.dart:56；原文：'寄送线下回报时需要地址，先添加一个吧'
  ///
  /// In zh, this message translates to:
  /// **'寄送线下回报时需要地址，先添加一个吧'**
  String get addressPage_56;

  /// 来源：lib/features/user/address_page.dart:58；原文：'新增地址'
  ///
  /// In zh, this message translates to:
  /// **'新增地址'**
  String get addressPage_58;

  /// 来源：lib/features/user/address_page.dart:131；原文：'删除地址'
  ///
  /// In zh, this message translates to:
  /// **'删除地址'**
  String get addressPage_131;

  /// 来源：lib/features/user/address_page.dart:132；原文：'确定删除「${address.name} ${address.maskedMobile}」这个地址吗？'
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{name} {maskedMobile}」这个地址吗？'**
  String addressPage_132(Object name, Object maskedMobile);

  /// 来源：lib/features/user/address_page.dart:140；原文：'删除'
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get addressPage_140;

  /// 来源：lib/features/user/address_page.dart:150；原文：'已删除'
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get addressPage_150;

  /// 来源：lib/features/user/address_page.dart:211；原文：'默认'
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get addressPage_211;

  /// 来源：lib/features/user/address_page.dart:263；原文：'默认地址'
  ///
  /// In zh, this message translates to:
  /// **'默认地址'**
  String get addressPage_263;

  /// 来源：lib/features/user/address_page.dart:263；原文：'设为默认'
  ///
  /// In zh, this message translates to:
  /// **'设为默认'**
  String get addressPage_263_2;

  /// 来源：lib/features/user/address_page.dart:276；原文：'编辑'
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get addressPage_276;

  /// 来源：lib/features/user/address_page.dart:278；原文：'删除'
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get addressPage_278;

  /// 来源：lib/features/user/address_page.dart:349；原文：'新增地址'
  ///
  /// In zh, this message translates to:
  /// **'新增地址'**
  String get addressPage_349;

  /// 来源：lib/features/user/address_page.dart:472；原文：'编辑地址'
  ///
  /// In zh, this message translates to:
  /// **'编辑地址'**
  String get addressPage_472;

  /// 来源：lib/features/user/address_page.dart:472；原文：'新增地址'
  ///
  /// In zh, this message translates to:
  /// **'新增地址'**
  String get addressPage_472_2;

  /// 来源：lib/features/user/address_page.dart:493；原文：'收件人'
  ///
  /// In zh, this message translates to:
  /// **'收件人'**
  String get addressPage_493;

  /// 来源：lib/features/user/address_page.dart:494；原文：'真实姓名'
  ///
  /// In zh, this message translates to:
  /// **'真实姓名'**
  String get addressPage_494;

  /// 来源：lib/features/user/address_page.dart:500；原文：'手机号'
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get addressPage_500;

  /// 来源：lib/features/user/address_page.dart:501；原文：'11 位手机号'
  ///
  /// In zh, this message translates to:
  /// **'11 位手机号'**
  String get addressPage_501;

  /// 来源：lib/features/user/address_page.dart:511；原文：'所在地区'
  ///
  /// In zh, this message translates to:
  /// **'所在地区'**
  String get addressPage_511;

  /// 来源：lib/features/user/address_page.dart:512；原文：'省 市 区（如：上海市 浦东新区）'
  ///
  /// In zh, this message translates to:
  /// **'省 市 区（如：上海市 浦东新区）'**
  String get addressPage_512;

  /// 来源：lib/features/user/address_page.dart:517；原文：'详细地址'
  ///
  /// In zh, this message translates to:
  /// **'详细地址'**
  String get addressPage_517;

  /// 来源：lib/features/user/address_page.dart:518；原文：'街道、门牌号、回报领取点'
  ///
  /// In zh, this message translates to:
  /// **'街道、门牌号、回报领取点'**
  String get addressPage_518;

  /// 来源：lib/features/user/application/profile_providers.dart:58；原文：'登录更精彩'
  ///
  /// In zh, this message translates to:
  /// **'登录更精彩'**
  String get profileProviders_58;

  /// 来源：lib/features/user/application/profile_providers.dart:86；原文：'V${user.level} 资深支持人'
  ///
  /// In zh, this message translates to:
  /// **'V{level} 资深支持人'**
  String profileProviders_86(Object level);

  /// 来源：lib/features/user/edit_profile_page.dart:65；原文：'编辑资料'
  ///
  /// In zh, this message translates to:
  /// **'编辑资料'**
  String get editProfilePage_65;

  /// 来源：lib/features/user/edit_profile_page.dart:75；原文：'头像上传待接入'
  ///
  /// In zh, this message translates to:
  /// **'头像上传待接入'**
  String get editProfilePage_75;

  /// 来源：lib/features/user/edit_profile_page.dart:107；原文：'点击更换头像'
  ///
  /// In zh, this message translates to:
  /// **'点击更换头像'**
  String get editProfilePage_107;

  /// 来源：lib/features/user/edit_profile_page.dart:116；原文：'昵称'
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get editProfilePage_116;

  /// 来源：lib/features/user/edit_profile_page.dart:140；原文：'性别'
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get editProfilePage_140;

  /// 来源：lib/features/user/edit_profile_page.dart:145；原文：'保密'
  ///
  /// In zh, this message translates to:
  /// **'保密'**
  String get editProfilePage_145;

  /// 来源：lib/features/user/edit_profile_page.dart:151；原文：'男'
  ///
  /// In zh, this message translates to:
  /// **'男'**
  String get editProfilePage_151;

  /// 来源：lib/features/user/edit_profile_page.dart:157；原文：'女'
  ///
  /// In zh, this message translates to:
  /// **'女'**
  String get editProfilePage_157;

  /// 来源：lib/features/user/edit_profile_page.dart:165；原文：'个性签名'
  ///
  /// In zh, this message translates to:
  /// **'个性签名'**
  String get editProfilePage_165;

  /// 来源：lib/features/user/edit_profile_page.dart:180；原文：'写点什么介绍自己吧…'
  ///
  /// In zh, this message translates to:
  /// **'写点什么介绍自己吧…'**
  String get editProfilePage_180;

  /// 来源：lib/features/user/edit_profile_page.dart:229；原文：'资料已记录（演示模式，未实际提交到服务器）'
  ///
  /// In zh, this message translates to:
  /// **'资料已记录（演示模式，未实际提交到服务器）'**
  String get editProfilePage_229;

  /// 来源：lib/features/user/feedback_page.dart:32；原文：'功能建议'
  ///
  /// In zh, this message translates to:
  /// **'功能建议'**
  String get feedbackPage_32;

  /// 来源：lib/features/user/feedback_page.dart:33；原文：'企划问题'
  ///
  /// In zh, this message translates to:
  /// **'企划问题'**
  String get feedbackPage_33;

  /// 来源：lib/features/user/feedback_page.dart:34；原文：'支付问题'
  ///
  /// In zh, this message translates to:
  /// **'支付问题'**
  String get feedbackPage_34;

  /// 来源：lib/features/user/feedback_page.dart:35；原文：'支持体验'
  ///
  /// In zh, this message translates to:
  /// **'支持体验'**
  String get feedbackPage_35;

  /// 来源：lib/features/user/feedback_page.dart:36；原文：'其他'
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get feedbackPage_36;

  /// 来源：lib/features/user/feedback_page.dart:58；原文：'意见反馈'
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get feedbackPage_58;

  /// 来源：lib/features/user/feedback_page.dart:66；原文：'反馈类型'
  ///
  /// In zh, this message translates to:
  /// **'反馈类型'**
  String get feedbackPage_66;

  /// 来源：lib/features/user/feedback_page.dart:114；原文：'反馈内容'
  ///
  /// In zh, this message translates to:
  /// **'反馈内容'**
  String get feedbackPage_114;

  /// 来源：lib/features/user/feedback_page.dart:123；原文：'请至少填写 10 个字，以便我们更好地理解您的问题'
  ///
  /// In zh, this message translates to:
  /// **'请至少填写 10 个字，以便我们更好地理解您的问题'**
  String get feedbackPage_123;

  /// 来源：lib/features/user/feedback_page.dart:140；原文：'请描述您遇到的问题或建议…'
  ///
  /// In zh, this message translates to:
  /// **'请描述您遇到的问题或建议…'**
  String get feedbackPage_140;

  /// 来源：lib/features/user/feedback_page.dart:160；原文：'联系方式（选填）'
  ///
  /// In zh, this message translates to:
  /// **'联系方式（选填）'**
  String get feedbackPage_160;

  /// 来源：lib/features/user/feedback_page.dart:169；原文：'留下手机号或邮箱，方便我们与您联系'
  ///
  /// In zh, this message translates to:
  /// **'留下手机号或邮箱，方便我们与您联系'**
  String get feedbackPage_169;

  /// 来源：lib/features/user/feedback_page.dart:184；原文：'手机号 / 邮箱'
  ///
  /// In zh, this message translates to:
  /// **'手机号 / 邮箱'**
  String get feedbackPage_184;

  /// 来源：lib/features/user/feedback_page.dart:211；原文：'提交反馈'
  ///
  /// In zh, this message translates to:
  /// **'提交反馈'**
  String get feedbackPage_211;

  /// 来源：lib/features/user/feedback_page.dart:230；原文：'反馈已记录（演示模式，未实际提交到服务器）'
  ///
  /// In zh, this message translates to:
  /// **'反馈已记录（演示模式，未实际提交到服务器）'**
  String get feedbackPage_230;

  /// 来源：lib/features/user/settings_page.dart:53；原文：'设置'
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsPage_53;

  /// 来源：lib/features/user/settings_page.dart:60；原文：'昵称'
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get settingsPage_60;

  /// 来源：lib/features/user/settings_page.dart:64；原文：'请先登录'
  ///
  /// In zh, this message translates to:
  /// **'请先登录'**
  String get settingsPage_64;

  /// 来源：lib/features/user/settings_page.dart:67；原文：'手机号'
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get settingsPage_67;

  /// 来源：lib/features/user/settings_page.dart:68；原文：'未绑定'
  ///
  /// In zh, this message translates to:
  /// **'未绑定'**
  String get settingsPage_68;

  /// 来源：lib/features/user/settings_page.dart:69；原文：'换绑手机号需要先验证原手机号'
  ///
  /// In zh, this message translates to:
  /// **'换绑手机号需要先验证原手机号'**
  String get settingsPage_69;

  /// 来源：lib/features/user/settings_page.dart:72；原文：'意见反馈'
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get settingsPage_72;

  /// 来源：lib/features/user/settings_page.dart:76；原文：'实名认证'
  ///
  /// In zh, this message translates to:
  /// **'实名认证'**
  String get settingsPage_76;

  /// 来源：lib/features/user/settings_page.dart:77；原文：'未认证'
  ///
  /// In zh, this message translates to:
  /// **'未认证'**
  String get settingsPage_77;

  /// 来源：lib/features/user/settings_page.dart:79；原文：'实名认证属于独立的 id 聚合，本示例未实现'
  ///
  /// In zh, this message translates to:
  /// **'实名认证属于独立的 id 聚合，本示例未实现'**
  String get settingsPage_79;

  /// 来源：lib/features/user/settings_page.dart:86；原文：'消息通知'
  ///
  /// In zh, this message translates to:
  /// **'消息通知'**
  String get settingsPage_86;

  /// 来源：lib/features/user/settings_page.dart:95；原文：'深色模式'
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get settingsPage_95;

  /// 来源：lib/features/user/settings_page.dart:107；原文：'清除缓存'
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get settingsPage_107;

  /// 来源：lib/features/user/settings_page.dart:108；原文：'图片与接口缓存'
  ///
  /// In zh, this message translates to:
  /// **'图片与接口缓存'**
  String get settingsPage_108;

  /// 来源：lib/features/user/settings_page.dart:110；原文：'缓存清理待接入 package:core/cache.dart 的 HttpCacheStore'
  ///
  /// In zh, this message translates to:
  /// **'缓存清理待接入 package:core/cache.dart 的 HttpCacheStore'**
  String get settingsPage_110;

  /// 来源：lib/features/user/settings_page.dart:117；原文：'版本号'
  ///
  /// In zh, this message translates to:
  /// **'版本号'**
  String get settingsPage_117;

  /// 来源：lib/features/user/settings_page.dart:119；原文：'已是最新版本'
  ///
  /// In zh, this message translates to:
  /// **'已是最新版本'**
  String get settingsPage_119;

  /// 来源：lib/features/user/settings_page.dart:122；原文：'用户协议'
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get settingsPage_122;

  /// 来源：lib/features/user/settings_page.dart:123；原文：'协议页待接入 WebView（`web` 包 64 个类的等价物）'
  ///
  /// In zh, this message translates to:
  /// **'协议页待接入 WebView（`web` 包 64 个类的等价物）'**
  String get settingsPage_123;

  /// 来源：lib/features/user/settings_page.dart:126；原文：'隐私政策'
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get settingsPage_126;

  /// 来源：lib/features/user/settings_page.dart:128；原文：'隐私政策页待接入 WebView'
  ///
  /// In zh, this message translates to:
  /// **'隐私政策页待接入 WebView'**
  String get settingsPage_128;

  /// 来源：lib/features/user/settings_page.dart:162；原文：'跟随系统'
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsPage_162;

  /// 来源：lib/features/user/settings_page.dart:164；原文：'开启'
  ///
  /// In zh, this message translates to:
  /// **'开启'**
  String get settingsPage_164;

  /// 来源：lib/features/user/settings_page.dart:164；原文：'关闭'
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get settingsPageDarkModeOff;

  /// 来源：lib/features/user/settings_page.dart:172；原文：'退出后需要重新登录才能查看订单，确定继续吗？'
  ///
  /// In zh, this message translates to:
  /// **'退出后需要重新登录才能查看订单，确定继续吗？'**
  String get settingsPage_172;

  /// 来源：lib/features/user/settings_page.dart:180；原文：'退出'
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get settingsPage_180;

  /// 来源：lib/features/user/settings_page.dart:188；原文：'已退出登录'
  ///
  /// In zh, this message translates to:
  /// **'已退出登录'**
  String get settingsPage_188;

  /// 来源：lib/features/user/settings_page.dart；设置页分组标题（账号）
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get settingsPageGroupAccount;

  /// 来源：lib/features/user/settings_page.dart；设置页分组标题（通用）
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settingsPageGroupGeneral;

  /// 来源：lib/features/user/settings_page.dart；设置页分组标题（关于）
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsPageGroupAbout;

  /// 来源：lib/features/user/user_page.dart:81；原文：'支持人管理待接入，敬请期待'
  ///
  /// In zh, this message translates to:
  /// **'支持人管理待接入，敬请期待'**
  String get userPage_81;

  /// 来源：lib/features/user/user_page.dart:82；原文：'客服会话（演示）'
  ///
  /// In zh, this message translates to:
  /// **'客服会话（演示）'**
  String get userPage_82;

  /// 来源：lib/features/user/user_page.dart:83；原文：'卖家招募不在本次范围内'
  ///
  /// In zh, this message translates to:
  /// **'卖家招募不在本次范围内'**
  String get userPage_83;

  /// 来源：lib/features/user/user_page.dart:98；原文：'已退出登录'
  ///
  /// In zh, this message translates to:
  /// **'已退出登录'**
  String get userPage_98;

  /// 来源：lib/features/user/user_page.dart:254；原文：'点击登录，查看订单与优惠券'
  ///
  /// In zh, this message translates to:
  /// **'点击登录，查看订单与更多服务'**
  String get userPage_254;

  /// 来源：lib/features/user/user_page.dart:333；原文：'支持过'
  ///
  /// In zh, this message translates to:
  /// **'支持过'**
  String get userPage_333;

  /// 来源：lib/features/user/user_page.dart:340；原文：'关注'
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get userPage_340;

  /// 来源：lib/features/user/user_page.dart:483；原文：'全部支持'
  ///
  /// In zh, this message translates to:
  /// **'全部支持'**
  String get userPage_483;

  /// 来源：lib/features/user/user_page.dart:569；原文：'优惠券'
  ///
  /// In zh, this message translates to:
  /// **'优惠券'**
  String get userPage_569;

  /// 来源：lib/features/user/user_page.dart:580；原文：'我的钱包'
  ///
  /// In zh, this message translates to:
  /// **'我的钱包'**
  String get userPage_580;

  /// 来源：lib/features/user/user_page.dart:650；原文：'礼品卡'
  ///
  /// In zh, this message translates to:
  /// **'礼品卡'**
  String get userPage_650;

  /// 来源：lib/features/user/user_page.dart:653；原文：'地址管理'
  ///
  /// In zh, this message translates to:
  /// **'地址管理'**
  String get userPage_653;

  /// 来源：lib/features/user/user_page.dart:654；原文：'支持人'
  ///
  /// In zh, this message translates to:
  /// **'支持人'**
  String get userPage_654;

  /// 来源：lib/features/user/user_page.dart:655；原文：'联系客服'
  ///
  /// In zh, this message translates to:
  /// **'联系客服'**
  String get userPage_655;

  /// 来源：lib/features/user/user_page.dart:656；原文：'卖家招募'
  ///
  /// In zh, this message translates to:
  /// **'卖家招募'**
  String get userPage_656;

  /// 来源：lib/features/user/user_page.dart；菜单入口
  ///
  /// In zh, this message translates to:
  /// **'星币商城'**
  String get userMenuMall;

  /// 来源：lib/features/user/user_page.dart；个人中心二级页入口
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get userMenuMessage;

  /// 来源：lib/features/user/user_page.dart；个人中心二级页入口
  ///
  /// In zh, this message translates to:
  /// **'订单'**
  String get userMenuOrder;

  /// 来源：lib/features/user/user_page.dart；分组菜单标题（低频设置）
  ///
  /// In zh, this message translates to:
  /// **'更多服务'**
  String get userMenuGroupMore;

  /// 来源：lib/features/user/user_page.dart；未签到按钮
  ///
  /// In zh, this message translates to:
  /// **'每日签到 · +{amount} 星币'**
  String signInReward(Object amount);

  /// 来源：lib/features/user/user_page.dart；已签到按钮
  ///
  /// In zh, this message translates to:
  /// **'今日已签到'**
  String get signInDone;

  /// 来源：lib/features/user/user_page.dart；签到成功提示
  ///
  /// In zh, this message translates to:
  /// **'签到成功，+{amount} 星币'**
  String signInSuccess(Object amount);

  /// 来源：lib/features/user/user_page.dart；签到失败提示
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
