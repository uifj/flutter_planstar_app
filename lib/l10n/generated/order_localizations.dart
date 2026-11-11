import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'order_localizations_en.dart';
import 'order_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of OrderLocalizations
/// returned by `OrderLocalizations.of(context)`.
///
/// Applications need to include `OrderLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/order_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: OrderLocalizations.localizationsDelegates,
///   supportedLocales: OrderLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the OrderLocalizations.supportedLocales
/// property.
abstract class OrderLocalizations {
  OrderLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static OrderLocalizations of(BuildContext context) {
    return Localizations.of<OrderLocalizations>(context, OrderLocalizations)!;
  }

  static const LocalizationsDelegate<OrderLocalizations> delegate = _OrderLocalizationsDelegate();

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

  /// No description provided for @orderListTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的支持'**
  String get orderListTitle;

  /// No description provided for @orderListPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'支持列表（需登录）'**
  String get orderListPlaceholder;

  /// No description provided for @orderGoConfirm.
  ///
  /// In zh, this message translates to:
  /// **'去确认支持'**
  String get orderGoConfirm;

  /// No description provided for @orderStatusPending.
  ///
  /// In zh, this message translates to:
  /// **'待支付'**
  String get orderStatusPending;

  /// No description provided for @orderStatusPaid.
  ///
  /// In zh, this message translates to:
  /// **'众筹中'**
  String get orderStatusPaid;

  /// No description provided for @orderStatusShipped.
  ///
  /// In zh, this message translates to:
  /// **'交付中'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusFinished.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get orderStatusFinished;

  /// No description provided for @orderStatusRefund.
  ///
  /// In zh, this message translates to:
  /// **'已退款'**
  String get orderStatusRefund;

  /// No description provided for @orderConfirmController_117.
  ///
  /// In zh, this message translates to:
  /// **'回报档位不存在'**
  String get orderConfirmController_117;

  /// No description provided for @orderConfirmController_145.
  ///
  /// In zh, this message translates to:
  /// **'本单没有可用营销活动'**
  String get orderConfirmController_145;

  /// No description provided for @orderConfirmController_156.
  ///
  /// In zh, this message translates to:
  /// **'本单没有可用优惠券'**
  String get orderConfirmController_156;

  /// No description provided for @orderConfirmController_169.
  ///
  /// In zh, this message translates to:
  /// **'本单没有可用礼品卡'**
  String get orderConfirmController_169;

  /// No description provided for @orderConfirmController_183.
  ///
  /// In zh, this message translates to:
  /// **'本企划不提供加急服务'**
  String get orderConfirmController_183;

  /// No description provided for @orderConfirmController_220.
  ///
  /// In zh, this message translates to:
  /// **'张支持人'**
  String get orderConfirmController_220;

  /// No description provided for @orderConfirmController_246.
  ///
  /// In zh, this message translates to:
  /// **'提交失败：{message}'**
  String orderConfirmController_246(Object message);

  /// No description provided for @orderConfirmController_257.
  ///
  /// In zh, this message translates to:
  /// **'支持已提交：{value}'**
  String orderConfirmController_257(Object value);

  /// No description provided for @orderListController_27.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get orderListController_27;

  /// No description provided for @orderListController_31.
  ///
  /// In zh, this message translates to:
  /// **'待评价'**
  String get orderListController_31;

  /// No description provided for @ticketOrder_81.
  ///
  /// In zh, this message translates to:
  /// **'实名支持人数量不能为负'**
  String get ticketOrder_81;

  /// No description provided for @ticketOrder_84.
  ///
  /// In zh, this message translates to:
  /// **'支付时限必须为正'**
  String get ticketOrder_84;

  /// No description provided for @ticketOrder_222.
  ///
  /// In zh, this message translates to:
  /// **'回报档位价格已变化，请重新确认支持'**
  String get ticketOrder_222;

  /// No description provided for @ticketOrder_238.
  ///
  /// In zh, this message translates to:
  /// **'回报档位不存在：{value}'**
  String ticketOrder_238(Object value);

  /// No description provided for @ticketOrder_263.
  ///
  /// In zh, this message translates to:
  /// **'回报档位不存在：{value}'**
  String ticketOrder_263(Object value);

  /// No description provided for @ticketOrder_296.
  ///
  /// In zh, this message translates to:
  /// **'加急服务份数（{units}）不能超过支持份数（{value}）'**
  String ticketOrder_296(Object units, Object value);

  /// No description provided for @ticketOrder_329.
  ///
  /// In zh, this message translates to:
  /// **'同一支持人不能重复选择'**
  String get ticketOrder_329;

  /// No description provided for @ticketOrder_332.
  ///
  /// In zh, this message translates to:
  /// **'本企划无需实名支持人'**
  String get ticketOrder_332;

  /// No description provided for @ticketOrder_337.
  ///
  /// In zh, this message translates to:
  /// **'本单需选择 {requiredVisitorCount} 位支持人，已选 {length} 位'**
  String ticketOrder_337(Object requiredVisitorCount, Object length);

  /// No description provided for @ticketOrder_373.
  ///
  /// In zh, this message translates to:
  /// **'请先选择回报档位'**
  String get ticketOrder_373;

  /// No description provided for @ticketOrder_376.
  ///
  /// In zh, this message translates to:
  /// **'报价与当前支持内容不一致，请重新计算'**
  String get ticketOrder_376;

  /// No description provided for @ticketOrder_391.
  ///
  /// In zh, this message translates to:
  /// **'请先选择回报档位'**
  String get ticketOrder_391;

  /// No description provided for @ticketOrder_396.
  ///
  /// In zh, this message translates to:
  /// **'请阅读并勾选{agreementTitle}'**
  String ticketOrder_396(Object agreementTitle);

  /// No description provided for @ticketOrder_402.
  ///
  /// In zh, this message translates to:
  /// **'支持金额尚未计算'**
  String get ticketOrder_402;

  /// No description provided for @ticketOrder_405.
  ///
  /// In zh, this message translates to:
  /// **'支持内容已变化，请重新确认金额'**
  String get ticketOrder_405;

  /// No description provided for @ticketOrder_410.
  ///
  /// In zh, this message translates to:
  /// **'请选择 {requiredVisitorCount} 位支持人'**
  String ticketOrder_410(Object requiredVisitorCount);

  /// No description provided for @ticketOrder_440.
  ///
  /// In zh, this message translates to:
  /// **'当前状态（{label}）不可支付'**
  String ticketOrder_440(Object label);

  /// No description provided for @ticketOrder_444.
  ///
  /// In zh, this message translates to:
  /// **'支持金额缺失，无法确认支付结果'**
  String get ticketOrder_444;

  /// No description provided for @ticketOrder_486.
  ///
  /// In zh, this message translates to:
  /// **'关闭原因不能为空'**
  String get ticketOrder_486;

  /// No description provided for @ticketOrder_510.
  ///
  /// In zh, this message translates to:
  /// **'未支付的支持不能退款'**
  String get ticketOrder_510;

  /// No description provided for @ticketOrder_534.
  ///
  /// In zh, this message translates to:
  /// **'支付超时，支持已取消'**
  String get ticketOrder_534;

  /// No description provided for @ticketOrder_553.
  ///
  /// In zh, this message translates to:
  /// **'支持已提交，不能再修改'**
  String get ticketOrder_553;

  /// No description provided for @ticketOrder_559.
  ///
  /// In zh, this message translates to:
  /// **'支持状态不允许从「{label}」变为「{label2}」'**
  String ticketOrder_559(Object label, Object label2);

  /// No description provided for @orderLifecycleEvents_22.
  ///
  /// In zh, this message translates to:
  /// **'超时'**
  String get orderLifecycleEvents_22;

  /// No description provided for @orderLifecycleEvents_48.
  ///
  /// In zh, this message translates to:
  /// **'order.shipped({value}, {trackingNumber})'**
  String orderLifecycleEvents_48(Object value, Object trackingNumber);

  /// No description provided for @orderPlaced_42.
  ///
  /// In zh, this message translates to:
  /// **'order.placed({value}, 支持金额 {format})'**
  String orderPlaced_42(Object value, Object format);

  /// No description provided for @purchaseLimitPolicy_30.
  ///
  /// In zh, this message translates to:
  /// **'不限支持'**
  String get purchaseLimitPolicy_30;

  /// No description provided for @purchaseLimitPolicy_32.
  ///
  /// In zh, this message translates to:
  /// **'每单限 {value} 份'**
  String purchaseLimitPolicy_32(Object value);

  /// No description provided for @purchaseLimitPolicy_33.
  ///
  /// In zh, this message translates to:
  /// **'每人限 {value} 份'**
  String purchaseLimitPolicy_33(Object value);

  /// No description provided for @purchaseLimitPolicy_57.
  ///
  /// In zh, this message translates to:
  /// **'每单最多支持 {value} 份'**
  String purchaseLimitPolicy_57(Object value);

  /// No description provided for @purchaseLimitPolicy_81.
  ///
  /// In zh, this message translates to:
  /// **'每人限购 {value} 份，您已支持 {value2} 份'**
  String purchaseLimitPolicy_81(Object value, Object value2);

  /// No description provided for @purchaseLimitPolicy_83.
  ///
  /// In zh, this message translates to:
  /// **'每人限购 {value} 份，您还可支持 {remaining} 份'**
  String purchaseLimitPolicy_83(Object value, Object remaining);

  /// No description provided for @orderQuote_107.
  ///
  /// In zh, this message translates to:
  /// **'支持总额'**
  String get orderQuote_107;

  /// No description provided for @orderQuote_108.
  ///
  /// In zh, this message translates to:
  /// **'运费'**
  String get orderQuote_108;

  /// No description provided for @orderQuote_109.
  ///
  /// In zh, this message translates to:
  /// **'拆单费'**
  String get orderQuote_109;

  /// No description provided for @orderQuote_111.
  ///
  /// In zh, this message translates to:
  /// **'优惠'**
  String get orderQuote_111;

  /// No description provided for @orderQuote_113.
  ///
  /// In zh, this message translates to:
  /// **'礼品卡'**
  String get orderQuote_113;

  /// No description provided for @orderQuote_114.
  ///
  /// In zh, this message translates to:
  /// **'加急服务'**
  String get orderQuote_114;

  /// No description provided for @delivery_78.
  ///
  /// In zh, this message translates to:
  /// **'电子回报凭证'**
  String get delivery_78;

  /// No description provided for @delivery_81.
  ///
  /// In zh, this message translates to:
  /// **'快递配送'**
  String get delivery_81;

  /// No description provided for @delivery_84.
  ///
  /// In zh, this message translates to:
  /// **'现场自取'**
  String get delivery_84;

  /// No description provided for @delivery_136.
  ///
  /// In zh, this message translates to:
  /// **'{method}（{postage}）'**
  String delivery_136(Object method, Object postage);

  /// No description provided for @discount_71.
  ///
  /// In zh, this message translates to:
  /// **'-{percent}%（封顶 {format}）'**
  String discount_71(Object percent, Object format);

  /// No description provided for @discount_122.
  ///
  /// In zh, this message translates to:
  /// **'不使用优惠'**
  String get discount_122;

  /// No description provided for @discount_139.
  ///
  /// In zh, this message translates to:
  /// **'营销活动 {describe}'**
  String discount_139(Object describe);

  /// No description provided for @discount_156.
  ///
  /// In zh, this message translates to:
  /// **'优惠券 {describe}'**
  String discount_156(Object describe);

  /// No description provided for @orderStatus_24.
  ///
  /// In zh, this message translates to:
  /// **'待提交'**
  String get orderStatus_24;

  /// No description provided for @orderStatus_40.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get orderStatus_40;

  /// No description provided for @orderStatus_43.
  ///
  /// In zh, this message translates to:
  /// **'已退款'**
  String get orderStatus_43;

  /// No description provided for @orderStatus_85.
  ///
  /// In zh, this message translates to:
  /// **'未知支持状态编码：{code}'**
  String orderStatus_85(Object code);

  /// No description provided for @orderType_10.
  ///
  /// In zh, this message translates to:
  /// **'普通支持'**
  String get orderType_10;

  /// No description provided for @orderType_13.
  ///
  /// In zh, this message translates to:
  /// **'拼团'**
  String get orderType_13;

  /// No description provided for @orderType_16.
  ///
  /// In zh, this message translates to:
  /// **'限时支持'**
  String get orderType_16;

  /// No description provided for @orderType_19.
  ///
  /// In zh, this message translates to:
  /// **'会员充值'**
  String get orderType_19;

  /// No description provided for @orderType_22.
  ///
  /// In zh, this message translates to:
  /// **'加急服务'**
  String get orderType_22;

  /// No description provided for @orderType_36.
  ///
  /// In zh, this message translates to:
  /// **'未知支持类型：{code}'**
  String orderType_36(Object code);

  /// No description provided for @orderType_49.
  ///
  /// In zh, this message translates to:
  /// **'普通支持'**
  String get orderType_49;

  /// No description provided for @orderType_49_2.
  ///
  /// In zh, this message translates to:
  /// **'《支持服务协议》'**
  String get orderType_49_2;

  /// No description provided for @orderType_52.
  ///
  /// In zh, this message translates to:
  /// **'代支持'**
  String get orderType_52;

  /// No description provided for @orderType_52_2.
  ///
  /// In zh, this message translates to:
  /// **'《代支持服务协议》'**
  String get orderType_52_2;

  /// No description provided for @orderType_69.
  ///
  /// In zh, this message translates to:
  /// **'未知支持方式：{code}'**
  String orderType_69(Object code);

  /// No description provided for @paymentChannel_10.
  ///
  /// In zh, this message translates to:
  /// **'微信支付'**
  String get paymentChannel_10;

  /// No description provided for @paymentChannel_13.
  ///
  /// In zh, this message translates to:
  /// **'支付宝'**
  String get paymentChannel_13;

  /// No description provided for @paymentChannel_16.
  ///
  /// In zh, this message translates to:
  /// **'银行卡'**
  String get paymentChannel_16;

  /// No description provided for @paymentChannel_19.
  ///
  /// In zh, this message translates to:
  /// **'信用付'**
  String get paymentChannel_19;

  /// No description provided for @paymentChannel_22.
  ///
  /// In zh, this message translates to:
  /// **'余额支付'**
  String get paymentChannel_22;

  /// No description provided for @paymentChannel_36.
  ///
  /// In zh, this message translates to:
  /// **'未知支付渠道：{code}'**
  String paymentChannel_36(Object code);

  /// No description provided for @speedPack_61.
  ///
  /// In zh, this message translates to:
  /// **'加急服务 {units} 份（现金 {format} / 余额 {format2}）'**
  String speedPack_61(Object units, Object format, Object format2);

  /// No description provided for @speedPack_85.
  ///
  /// In zh, this message translates to:
  /// **'礼品卡 {value}（余额 {format}）'**
  String speedPack_85(Object value, Object format);

  /// No description provided for @visitor_7.
  ///
  /// In zh, this message translates to:
  /// **'身份证'**
  String get visitor_7;

  /// No description provided for @visitor_8.
  ///
  /// In zh, this message translates to:
  /// **'护照'**
  String get visitor_8;

  /// No description provided for @visitor_9.
  ///
  /// In zh, this message translates to:
  /// **'港澳通行证'**
  String get visitor_9;

  /// No description provided for @visitor_10.
  ///
  /// In zh, this message translates to:
  /// **'台湾通行证'**
  String get visitor_10;

  /// No description provided for @visitor_11.
  ///
  /// In zh, this message translates to:
  /// **'港澳台居住证'**
  String get visitor_11;

  /// No description provided for @orderConfirmPage_48.
  ///
  /// In zh, this message translates to:
  /// **'确认支持'**
  String get orderConfirmPage_48;

  /// No description provided for @orderConfirmPage_59.
  ///
  /// In zh, this message translates to:
  /// **'选择回报档位'**
  String get orderConfirmPage_59;

  /// No description provided for @orderConfirmPage_73.
  ///
  /// In zh, this message translates to:
  /// **'优惠'**
  String get orderConfirmPage_73;

  /// No description provided for @orderConfirmPage_79.
  ///
  /// In zh, this message translates to:
  /// **'不使用优惠'**
  String get orderConfirmPage_79;

  /// No description provided for @orderConfirmPage_99.
  ///
  /// In zh, this message translates to:
  /// **'其他抵扣'**
  String get orderConfirmPage_99;

  /// No description provided for @orderConfirmPage_107.
  ///
  /// In zh, this message translates to:
  /// **'礼品卡（本单不可用）'**
  String get orderConfirmPage_107;

  /// No description provided for @orderConfirmPage_109.
  ///
  /// In zh, this message translates to:
  /// **'礼品卡（余额 {format}）'**
  String orderConfirmPage_109(Object format);

  /// No description provided for @orderConfirmPage_123.
  ///
  /// In zh, this message translates to:
  /// **'加急服务（本企划不提供）'**
  String get orderConfirmPage_123;

  /// No description provided for @orderConfirmPage_125.
  ///
  /// In zh, this message translates to:
  /// **'加急服务（{format}/份）'**
  String orderConfirmPage_125(Object format);

  /// No description provided for @orderConfirmPage_138.
  ///
  /// In zh, this message translates to:
  /// **'实名支持人'**
  String get orderConfirmPage_138;

  /// No description provided for @orderConfirmPage_143.
  ///
  /// In zh, this message translates to:
  /// **'选择支持人（需 {requiredVisitorCount} 位）'**
  String orderConfirmPage_143(Object requiredVisitorCount);

  /// No description provided for @orderConfirmPage_145.
  ///
  /// In zh, this message translates to:
  /// **'已选 {length} 位'**
  String orderConfirmPage_145(Object length);

  /// No description provided for @orderConfirmPage_150.
  ///
  /// In zh, this message translates to:
  /// **'本企划需实名支持人，未选择将无法提交'**
  String get orderConfirmPage_150;

  /// No description provided for @orderConfirmPage_167.
  ///
  /// In zh, this message translates to:
  /// **'费用明细'**
  String get orderConfirmPage_167;

  /// No description provided for @orderConfirmPage_173.
  ///
  /// In zh, this message translates to:
  /// **'支持原价'**
  String get orderConfirmPage_173;

  /// No description provided for @orderConfirmPage_175.
  ///
  /// In zh, this message translates to:
  /// **'应付金额'**
  String get orderConfirmPage_175;

  /// No description provided for @orderConfirmPage_190.
  ///
  /// In zh, this message translates to:
  /// **'我已阅读并同意{agreementTitle}'**
  String orderConfirmPage_190(Object agreementTitle);

  /// No description provided for @orderConfirmPage_196.
  ///
  /// In zh, this message translates to:
  /// **'领域事件：{join}'**
  String orderConfirmPage_196(Object join);

  /// No description provided for @orderConfirmPage_243.
  ///
  /// In zh, this message translates to:
  /// **'{sessionLabel} · 企划 {value}'**
  String orderConfirmPage_243(Object sessionLabel, Object value);

  /// No description provided for @orderConfirmPage_444.
  ///
  /// In zh, this message translates to:
  /// **'应付'**
  String get orderConfirmPage_444;

  /// No description provided for @orderConfirmPage_457.
  ///
  /// In zh, this message translates to:
  /// **'已确认'**
  String get orderConfirmPage_457;

  /// No description provided for @orderConfirmPage_460.
  ///
  /// In zh, this message translates to:
  /// **'确认中…'**
  String get orderConfirmPage_460;

  /// No description provided for @orderConfirmPage_462.
  ///
  /// In zh, this message translates to:
  /// **'确认支持'**
  String get orderConfirmPage_462;

  /// No description provided for @orderDetailPage_52.
  ///
  /// In zh, this message translates to:
  /// **'支持详情'**
  String get orderDetailPage_52;

  /// No description provided for @orderDetailPage_56.
  ///
  /// In zh, this message translates to:
  /// **'支持记录加载失败'**
  String get orderDetailPage_56;

  /// No description provided for @orderDetailPage_65.
  ///
  /// In zh, this message translates to:
  /// **'支持记录不存在'**
  String get orderDetailPage_65;

  /// No description provided for @orderDetailPage_66.
  ///
  /// In zh, this message translates to:
  /// **'支持记录可能已被删除，或链接已过期'**
  String get orderDetailPage_66;

  /// No description provided for @orderDetailPage_68.
  ///
  /// In zh, this message translates to:
  /// **'返回支持列表'**
  String get orderDetailPage_68;

  /// No description provided for @orderDetailPage_101.
  ///
  /// In zh, this message translates to:
  /// **'回报档位'**
  String get orderDetailPage_101;

  /// No description provided for @orderDetailPage_105.
  ///
  /// In zh, this message translates to:
  /// **'{value} 份 · {format}'**
  String orderDetailPage_105(Object value, Object format);

  /// No description provided for @orderDetailPage_108.
  ///
  /// In zh, this message translates to:
  /// **'交付方式'**
  String get orderDetailPage_108;

  /// No description provided for @orderDetailPage_113.
  ///
  /// In zh, this message translates to:
  /// **'支持人'**
  String get orderDetailPage_113;

  /// No description provided for @orderDetailPage_125.
  ///
  /// In zh, this message translates to:
  /// **'金额明细'**
  String get orderDetailPage_125;

  /// No description provided for @orderDetailPage_133.
  ///
  /// In zh, this message translates to:
  /// **'支持金额'**
  String get orderDetailPage_133;

  /// No description provided for @orderDetailPage_139.
  ///
  /// In zh, this message translates to:
  /// **'支持信息'**
  String get orderDetailPage_139;

  /// No description provided for @orderDetailPage_141.
  ///
  /// In zh, this message translates to:
  /// **'支持编号'**
  String get orderDetailPage_141;

  /// No description provided for @orderDetailPage_150.
  ///
  /// In zh, this message translates to:
  /// **'支持编号已复制'**
  String get orderDetailPage_150;

  /// No description provided for @orderDetailPage_163.
  ///
  /// In zh, this message translates to:
  /// **'支持时间'**
  String get orderDetailPage_163;

  /// No description provided for @orderDetailPage_165.
  ///
  /// In zh, this message translates to:
  /// **'支付时间'**
  String get orderDetailPage_165;

  /// No description provided for @orderDetailPage_167.
  ///
  /// In zh, this message translates to:
  /// **'关闭原因'**
  String get orderDetailPage_167;

  /// No description provided for @orderDetailPage_199.
  ///
  /// In zh, this message translates to:
  /// **'支持尚未提交'**
  String get orderDetailPage_199;

  /// No description provided for @orderDetailPage_201.
  ///
  /// In zh, this message translates to:
  /// **'请在 {_deadline} 前完成支付，超时支持将自动关闭'**
  String orderDetailPage_201(Object _deadline);

  /// No description provided for @orderDetailPage_204.
  ///
  /// In zh, this message translates to:
  /// **'已支付，正在为你确认回报'**
  String get orderDetailPage_204;

  /// No description provided for @orderDetailPage_205.
  ///
  /// In zh, this message translates to:
  /// **'回报已寄出，请注意查收'**
  String get orderDetailPage_205;

  /// No description provided for @orderDetailPage_206.
  ///
  /// In zh, this message translates to:
  /// **'支持已完成，欢迎发表支持评价'**
  String get orderDetailPage_206;

  /// No description provided for @orderDetailPage_207.
  ///
  /// In zh, this message translates to:
  /// **'支持已取消，可重新选择企划'**
  String get orderDetailPage_207;

  /// No description provided for @orderDetailPage_208.
  ///
  /// In zh, this message translates to:
  /// **'退款已原路退回'**
  String get orderDetailPage_208;

  /// No description provided for @orderDetailPage_325.
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderDetailPage_325;

  /// No description provided for @orderDetailPage_329.
  ///
  /// In zh, this message translates to:
  /// **'立即支付'**
  String get orderDetailPage_329;

  /// No description provided for @orderDetailPage_335.
  ///
  /// In zh, this message translates to:
  /// **'查看物流'**
  String get orderDetailPage_335;

  /// No description provided for @orderDetailPage_335_2.
  ///
  /// In zh, this message translates to:
  /// **'物流详情待接入快递查询接口'**
  String get orderDetailPage_335_2;

  /// No description provided for @orderDetailPage_337.
  ///
  /// In zh, this message translates to:
  /// **'确认收到回报'**
  String get orderDetailPage_337;

  /// No description provided for @orderDetailPage_342.
  ///
  /// In zh, this message translates to:
  /// **'申请退款'**
  String get orderDetailPage_342;

  /// No description provided for @orderDetailPage_351.
  ///
  /// In zh, this message translates to:
  /// **'去评价'**
  String get orderDetailPage_351;

  /// No description provided for @orderDetailPage_351_2.
  ///
  /// In zh, this message translates to:
  /// **'评价属于独立的评价聚合，本示例未实现'**
  String get orderDetailPage_351_2;

  /// No description provided for @orderDetailPage_353.
  ///
  /// In zh, this message translates to:
  /// **'再次购买'**
  String get orderDetailPage_353;

  /// No description provided for @orderDetailPage_360.
  ///
  /// In zh, this message translates to:
  /// **'继续填写'**
  String get orderDetailPage_360;

  /// No description provided for @orderDetailPage_366.
  ///
  /// In zh, this message translates to:
  /// **'联系客服'**
  String get orderDetailPage_366;

  /// No description provided for @orderDetailPage_366_2.
  ///
  /// In zh, this message translates to:
  /// **'客服会话（演示）'**
  String get orderDetailPage_366_2;

  /// No description provided for @orderDetailPage_367.
  ///
  /// In zh, this message translates to:
  /// **'查看回报凭证'**
  String get orderDetailPage_367;

  /// No description provided for @orderDetailPage_367_2.
  ///
  /// In zh, this message translates to:
  /// **'电子回报凭证面待接入交付接口'**
  String get orderDetailPage_367_2;

  /// No description provided for @orderDetailPage_369.
  ///
  /// In zh, this message translates to:
  /// **'申请退款'**
  String get orderDetailPage_369;

  /// No description provided for @orderDetailPage_379.
  ///
  /// In zh, this message translates to:
  /// **'重新选择企划'**
  String get orderDetailPage_379;

  /// No description provided for @orderDetailPage_437.
  ///
  /// In zh, this message translates to:
  /// **'支付成功，等待交付'**
  String get orderDetailPage_437;

  /// No description provided for @orderDetailPage_444.
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderDetailPage_444;

  /// No description provided for @orderDetailPage_445.
  ///
  /// In zh, this message translates to:
  /// **'取消后需要重新支持，确定继续吗？'**
  String get orderDetailPage_445;

  /// No description provided for @orderDetailPage_449.
  ///
  /// In zh, this message translates to:
  /// **'再想想'**
  String get orderDetailPage_449;

  /// No description provided for @orderDetailPage_453.
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderDetailPage_453;

  /// No description provided for @orderDetailPage_459.
  ///
  /// In zh, this message translates to:
  /// **'用户主动取消'**
  String get orderDetailPage_459;

  /// No description provided for @orderDetailPage_461.
  ///
  /// In zh, this message translates to:
  /// **'支持已取消'**
  String get orderDetailPage_461;

  /// No description provided for @orderDetailPage_470.
  ///
  /// In zh, this message translates to:
  /// **'已确认收到回报'**
  String get orderDetailPage_470;

  /// No description provided for @orderListPage_71.
  ///
  /// In zh, this message translates to:
  /// **'支持记录加载失败'**
  String get orderListPage_71;

  /// No description provided for @orderListPage_85.
  ///
  /// In zh, this message translates to:
  /// **'还没有支持记录'**
  String get orderListPage_85;

  /// No description provided for @orderListPage_87.
  ///
  /// In zh, this message translates to:
  /// **'没有{label}的支持记录'**
  String orderListPage_87(Object label);

  /// No description provided for @orderListPage_88.
  ///
  /// In zh, this message translates to:
  /// **'去首页挑一个企划吧'**
  String get orderListPage_88;

  /// No description provided for @orderListPage_90.
  ///
  /// In zh, this message translates to:
  /// **'去逛逛'**
  String get orderListPage_90;

  /// No description provided for @orderListPage_115.
  ///
  /// In zh, this message translates to:
  /// **'评价属于独立的评价聚合，本示例未实现'**
  String get orderListPage_115;

  /// No description provided for @orderListPage_119.
  ///
  /// In zh, this message translates to:
  /// **'客服会话（演示）'**
  String get orderListPage_119;

  /// No description provided for @orderListPage_130.
  ///
  /// In zh, this message translates to:
  /// **'暂无商品订单'**
  String get orderListPage_130;

  /// No description provided for @orderListPage_131.
  ///
  /// In zh, this message translates to:
  /// **'企划支持链路之外的周边商品暂未接入'**
  String get orderListPage_131;

  /// No description provided for @orderListPage_181.
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderListPage_181;

  /// No description provided for @orderListPage_182.
  ///
  /// In zh, this message translates to:
  /// **'取消后需要重新支持，确定继续吗？'**
  String get orderListPage_182;

  /// No description provided for @orderListPage_186.
  ///
  /// In zh, this message translates to:
  /// **'再想想'**
  String get orderListPage_186;

  /// No description provided for @orderListPage_190.
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderListPage_190;

  /// No description provided for @orderListPage_196.
  ///
  /// In zh, this message translates to:
  /// **'用户主动取消'**
  String get orderListPage_196;

  /// No description provided for @orderCancelTimeout.
  ///
  /// In zh, this message translates to:
  /// **'支付超时，支持已取消'**
  String get orderCancelTimeout;

  /// No description provided for @orderListPage_198.
  ///
  /// In zh, this message translates to:
  /// **'支持已取消'**
  String get orderListPage_198;

  /// No description provided for @orderListPage_208.
  ///
  /// In zh, this message translates to:
  /// **'已确认收到回报'**
  String get orderListPage_208;

  /// No description provided for @orderListPage_229.
  ///
  /// In zh, this message translates to:
  /// **'企划'**
  String get orderListPage_229;

  /// No description provided for @orderListPage_229_2.
  ///
  /// In zh, this message translates to:
  /// **'商品'**
  String get orderListPage_229_2;

  /// No description provided for @paySuccessPage_75.
  ///
  /// In zh, this message translates to:
  /// **'支付成功'**
  String get paySuccessPage_75;

  /// No description provided for @paySuccessPage_84.
  ///
  /// In zh, this message translates to:
  /// **'企划星正在为您确认回报，请耐心等待'**
  String get paySuccessPage_84;

  /// No description provided for @paySuccessPage_115.
  ///
  /// In zh, this message translates to:
  /// **'查看支持记录'**
  String get paySuccessPage_115;

  /// No description provided for @paySuccessPage_138.
  ///
  /// In zh, this message translates to:
  /// **'继续逛逛'**
  String get paySuccessPage_138;

  /// No description provided for @paySuccessPage_182.
  ///
  /// In zh, this message translates to:
  /// **'企划'**
  String get paySuccessPage_182;

  /// No description provided for @paySuccessPage_189.
  ///
  /// In zh, this message translates to:
  /// **'支持编号'**
  String get paySuccessPage_189;

  /// No description provided for @paySuccessPage_198.
  ///
  /// In zh, this message translates to:
  /// **'支付金额'**
  String get paySuccessPage_198;

  /// No description provided for @payInfo_40.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get payInfo_40;

  /// No description provided for @payInfo_55.
  ///
  /// In zh, this message translates to:
  /// **'星币余额支付'**
  String get payInfo_55;

  /// No description provided for @payInfo_60.
  ///
  /// In zh, this message translates to:
  /// **'企划'**
  String get payInfo_60;

  /// No description provided for @payInfo_61.
  ///
  /// In zh, this message translates to:
  /// **'支持编号'**
  String get payInfo_61;

  /// No description provided for @payPage_77.
  ///
  /// In zh, this message translates to:
  /// **'收银台'**
  String get payPage_77;

  /// No description provided for @payPage_133.
  ///
  /// In zh, this message translates to:
  /// **'演示环境：支付不会真实扣款，点击确认后模拟支付流程'**
  String get payPage_133;

  /// No description provided for @payPage_166.
  ///
  /// In zh, this message translates to:
  /// **'支付已取消'**
  String get payPage_166;

  /// No description provided for @payPage_195.
  ///
  /// In zh, this message translates to:
  /// **'请在 {seconds} 内完成支付'**
  String payPage_195(Object seconds);

  /// No description provided for @payPage_259.
  ///
  /// In zh, this message translates to:
  /// **'应付金额'**
  String get payPage_259;

  /// No description provided for @payPage_301.
  ///
  /// In zh, this message translates to:
  /// **'选择支付方式'**
  String get payPage_301;

  /// No description provided for @payPage_436.
  ///
  /// In zh, this message translates to:
  /// **'请求中…'**
  String get payPage_436;

  /// No description provided for @payPage_438.
  ///
  /// In zh, this message translates to:
  /// **'支付中…'**
  String get payPage_438;

  /// No description provided for @payPage_440.
  ///
  /// In zh, this message translates to:
  /// **'确认支付 {format}'**
  String payPage_440(Object format);

  /// No description provided for @payProviders_115.
  ///
  /// In zh, this message translates to:
  /// **'当前状态不可支付'**
  String get payProviders_115;

  /// No description provided for @payProviders_172.
  ///
  /// In zh, this message translates to:
  /// **'支付超时，支持已自动取消'**
  String get payProviders_172;

  /// No description provided for @refundPage_43.
  ///
  /// In zh, this message translates to:
  /// **'退款申请已提交，请等待审核'**
  String get refundPage_43;

  /// No description provided for @refundPage_62.
  ///
  /// In zh, this message translates to:
  /// **'申请退款'**
  String get refundPage_62;

  /// No description provided for @refundPage_97.
  ///
  /// In zh, this message translates to:
  /// **'提交中…'**
  String get refundPage_97;

  /// No description provided for @refundPage_98.
  ///
  /// In zh, this message translates to:
  /// **'已提交'**
  String get refundPage_98;

  /// No description provided for @refundPage_99.
  ///
  /// In zh, this message translates to:
  /// **'提交退款申请'**
  String get refundPage_99;

  /// No description provided for @refundPage_138.
  ///
  /// In zh, this message translates to:
  /// **'退款金额'**
  String get refundPage_138;

  /// No description provided for @refundPage_150.
  ///
  /// In zh, this message translates to:
  /// **'支持金额'**
  String get refundPage_150;

  /// No description provided for @refundPage_164.
  ///
  /// In zh, this message translates to:
  /// **'预计退款'**
  String get refundPage_164;

  /// No description provided for @refundPage_207.
  ///
  /// In zh, this message translates to:
  /// **'退款原因'**
  String get refundPage_207;

  /// No description provided for @refundPage_244.
  ///
  /// In zh, this message translates to:
  /// **'请输入退款原因（选填）'**
  String get refundPage_244;

  /// No description provided for @refundPage_331.
  ///
  /// In zh, this message translates to:
  /// **'退款说明'**
  String get refundPage_331;

  /// No description provided for @refundPage_342.
  ///
  /// In zh, this message translates to:
  /// **'• 众筹中可全额退款\n• 交付中退还支持金额的 80%\n• 已完成支持不支持退款\n• 退款将原路退回至支付账户\n• 退款审核一般需要 1-3 个工作日'**
  String get refundPage_342;

  /// No description provided for @refundPage_382.
  ///
  /// In zh, this message translates to:
  /// **'退款申请已提交'**
  String get refundPage_382;

  /// No description provided for @refundPage_391.
  ///
  /// In zh, this message translates to:
  /// **'退款金额 {format} 将在审核通过后原路退回'**
  String refundPage_391(Object format);

  /// No description provided for @refundPage_404.
  ///
  /// In zh, this message translates to:
  /// **'返回支持列表'**
  String get refundPage_404;

  /// No description provided for @refundState_8.
  ///
  /// In zh, this message translates to:
  /// **'不需要了'**
  String get refundState_8;

  /// No description provided for @refundState_8_2.
  ///
  /// In zh, this message translates to:
  /// **'计划变更，暂时不需要了'**
  String get refundState_8_2;

  /// No description provided for @refundState_11.
  ///
  /// In zh, this message translates to:
  /// **'买错了'**
  String get refundState_11;

  /// No description provided for @refundState_11_2.
  ///
  /// In zh, this message translates to:
  /// **'买错了线下回报场次或回报档位'**
  String get refundState_11_2;

  /// No description provided for @refundState_14.
  ///
  /// In zh, this message translates to:
  /// **'支持金额太高'**
  String get refundState_14;

  /// No description provided for @refundState_14_2.
  ///
  /// In zh, this message translates to:
  /// **'价格超出预算'**
  String get refundState_14_2;

  /// No description provided for @refundState_17.
  ///
  /// In zh, this message translates to:
  /// **'找到更好的企划'**
  String get refundState_17;

  /// No description provided for @refundState_17_2.
  ///
  /// In zh, this message translates to:
  /// **'通过其他渠道购买了'**
  String get refundState_17_2;

  /// No description provided for @refundState_20.
  ///
  /// In zh, this message translates to:
  /// **'其他原因'**
  String get refundState_20;

  /// No description provided for @refundState_20_2.
  ///
  /// In zh, this message translates to:
  /// **'自定义说明'**
  String get refundState_20_2;

  /// No description provided for @orderListCard_52.
  ///
  /// In zh, this message translates to:
  /// **'企划 {value}'**
  String orderListCard_52(Object value);

  /// No description provided for @orderListCard_53.
  ///
  /// In zh, this message translates to:
  /// **'回报信息待确认'**
  String get orderListCard_53;

  /// 订单卡片：企划回报预计交付时间
  ///
  /// In zh, this message translates to:
  /// **'交付：{value}'**
  String orderListCard_delivery(Object value);

  /// No description provided for @orderListCard_78.
  ///
  /// In zh, this message translates to:
  /// **'代支持'**
  String get orderListCard_78;

  /// No description provided for @orderListCard_130.
  ///
  /// In zh, this message translates to:
  /// **'支持人 {join}'**
  String orderListCard_130(Object join);

  /// No description provided for @orderListCard_141.
  ///
  /// In zh, this message translates to:
  /// **'支持编号 {value}'**
  String orderListCard_141(Object value);

  /// No description provided for @orderListCard_184.
  ///
  /// In zh, this message translates to:
  /// **'共 {value} 份  支持金额'**
  String orderListCard_184(Object value);

  /// No description provided for @orderListCard_217.
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderListCard_217;

  /// No description provided for @orderListCard_220.
  ///
  /// In zh, this message translates to:
  /// **'去支付'**
  String get orderListCard_220;

  /// No description provided for @orderListCard_225.
  ///
  /// In zh, this message translates to:
  /// **'联系客服'**
  String get orderListCard_225;

  /// No description provided for @orderListCard_228.
  ///
  /// In zh, this message translates to:
  /// **'申请退款'**
  String get orderListCard_228;

  /// No description provided for @orderListCard_233.
  ///
  /// In zh, this message translates to:
  /// **'查看物流'**
  String get orderListCard_233;

  /// No description provided for @orderListCard_236.
  ///
  /// In zh, this message translates to:
  /// **'确认收到回报'**
  String get orderListCard_236;

  /// No description provided for @orderListCard_241.
  ///
  /// In zh, this message translates to:
  /// **'再次购买'**
  String get orderListCard_241;

  /// No description provided for @orderListCard_244.
  ///
  /// In zh, this message translates to:
  /// **'去评价'**
  String get orderListCard_244;

  /// No description provided for @orderListCard_250.
  ///
  /// In zh, this message translates to:
  /// **'再次购买'**
  String get orderListCard_250;

  /// No description provided for @orderListCard_298.
  ///
  /// In zh, this message translates to:
  /// **'支付已超时，请重新支持'**
  String get orderListCard_298;

  /// No description provided for @orderListCard_305.
  ///
  /// In zh, this message translates to:
  /// **'剩余支付时间 {minutes}:{seconds}'**
  String orderListCard_305(Object minutes, Object seconds);

  /// No description provided for @paymentChannelSheet_52.
  ///
  /// In zh, this message translates to:
  /// **'选择支付方式'**
  String get paymentChannelSheet_52;

  /// 支持详情：企划回报预计交付时间
  ///
  /// In zh, this message translates to:
  /// **'预计交付时间'**
  String get orderDetailPage_expectedDelivery;

  /// 确认支持页：已选座席分组标题
  ///
  /// In zh, this message translates to:
  /// **'已选座席'**
  String get orderConfirmPage_seatsTitle;

  /// 确认支持页：所选座席金额合计
  ///
  /// In zh, this message translates to:
  /// **'座席小计'**
  String get orderConfirmPage_seatsSubtotal;
}

class _OrderLocalizationsDelegate extends LocalizationsDelegate<OrderLocalizations> {
  const _OrderLocalizationsDelegate();

  @override
  Future<OrderLocalizations> load(Locale locale) {
    return SynchronousFuture<OrderLocalizations>(lookupOrderLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_OrderLocalizationsDelegate old) => false;
}

OrderLocalizations lookupOrderLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return OrderLocalizationsEn();
    case 'zh': return OrderLocalizationsZh();
  }

  throw FlutterError(
    'OrderLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
