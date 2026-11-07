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

  /// 来源：lib/features/order/application/order_confirm_controller.dart:117；原文：'回报档位不存在'
  ///
  /// In zh, this message translates to:
  /// **'回报档位不存在'**
  String get orderConfirmController_117;

  /// 来源：lib/features/order/application/order_confirm_controller.dart:145；原文：'本单没有可用营销活动'
  ///
  /// In zh, this message translates to:
  /// **'本单没有可用营销活动'**
  String get orderConfirmController_145;

  /// 来源：lib/features/order/application/order_confirm_controller.dart:156；原文：'本单没有可用优惠券'
  ///
  /// In zh, this message translates to:
  /// **'本单没有可用优惠券'**
  String get orderConfirmController_156;

  /// 来源：lib/features/order/application/order_confirm_controller.dart:169；原文：'本单没有可用礼品卡'
  ///
  /// In zh, this message translates to:
  /// **'本单没有可用礼品卡'**
  String get orderConfirmController_169;

  /// 来源：lib/features/order/application/order_confirm_controller.dart:183；原文：'本企划不提供加急服务'
  ///
  /// In zh, this message translates to:
  /// **'本企划不提供加急服务'**
  String get orderConfirmController_183;

  /// 来源：lib/features/order/application/order_confirm_controller.dart:220；原文：'张支持人'
  ///
  /// In zh, this message translates to:
  /// **'张支持人'**
  String get orderConfirmController_220;

  /// 来源：lib/features/order/application/order_confirm_controller.dart:246；原文：'提交失败：${saved.failure!.message}'
  ///
  /// In zh, this message translates to:
  /// **'提交失败：{message}'**
  String orderConfirmController_246(Object message);

  /// 来源：lib/features/order/application/order_confirm_controller.dart:257；原文：'支持已提交：${order.number.value}'
  ///
  /// In zh, this message translates to:
  /// **'支持已提交：{value}'**
  String orderConfirmController_257(Object value);

  /// 来源：lib/features/order/application/order_list_controller.dart:27；原文：'全部'
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get orderListController_27;

  /// 来源：lib/features/order/application/order_list_controller.dart:31；原文：'待评价'
  ///
  /// In zh, this message translates to:
  /// **'待评价'**
  String get orderListController_31;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:81；原文：'实名支持人数量不能为负'
  ///
  /// In zh, this message translates to:
  /// **'实名支持人数量不能为负'**
  String get ticketOrder_81;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:84；原文：'支付时限必须为正'
  ///
  /// In zh, this message translates to:
  /// **'支付时限必须为正'**
  String get ticketOrder_84;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:222；原文：'回报档位价格已变化，请重新确认支持'
  ///
  /// In zh, this message translates to:
  /// **'回报档位价格已变化，请重新确认支持'**
  String get ticketOrder_222;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:238；原文：'回报档位不存在：${tierId.value}'
  ///
  /// In zh, this message translates to:
  /// **'回报档位不存在：{value}'**
  String ticketOrder_238(Object value);

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:263；原文：'回报档位不存在：${tierId.value}'
  ///
  /// In zh, this message translates to:
  /// **'回报档位不存在：{value}'**
  String ticketOrder_263(Object value);

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:296；原文：'加急服务份数（${pack.units}）不能超过支持份数（${totalTickets.value}）'
  ///
  /// In zh, this message translates to:
  /// **'加急服务份数（{units}）不能超过支持份数（{value}）'**
  String ticketOrder_296(Object units, Object value);

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:329；原文：'同一支持人不能重复选择'
  ///
  /// In zh, this message translates to:
  /// **'同一支持人不能重复选择'**
  String get ticketOrder_329;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:332；原文：'本企划无需实名支持人'
  ///
  /// In zh, this message translates to:
  /// **'本企划无需实名支持人'**
  String get ticketOrder_332;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:337；原文：'本单需选择 $requiredVisitorCount 位支持人，已选 ${unique.length} 位'
  ///
  /// In zh, this message translates to:
  /// **'本单需选择 {requiredVisitorCount} 位支持人，已选 {length} 位'**
  String ticketOrder_337(Object requiredVisitorCount, Object length);

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:373；原文：'请先选择回报档位'
  ///
  /// In zh, this message translates to:
  /// **'请先选择回报档位'**
  String get ticketOrder_373;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:376；原文：'报价与当前支持内容不一致，请重新计算'
  ///
  /// In zh, this message translates to:
  /// **'报价与当前支持内容不一致，请重新计算'**
  String get ticketOrder_376;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:391；原文：'请先选择回报档位'
  ///
  /// In zh, this message translates to:
  /// **'请先选择回报档位'**
  String get ticketOrder_391;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:396；原文：'请阅读并勾选${buyType.agreementTitle}'
  ///
  /// In zh, this message translates to:
  /// **'请阅读并勾选{agreementTitle}'**
  String ticketOrder_396(Object agreementTitle);

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:402；原文：'支持金额尚未计算'
  ///
  /// In zh, this message translates to:
  /// **'支持金额尚未计算'**
  String get ticketOrder_402;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:405；原文：'支持内容已变化，请重新确认金额'
  ///
  /// In zh, this message translates to:
  /// **'支持内容已变化，请重新确认金额'**
  String get ticketOrder_405;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:410；原文：'请选择 $requiredVisitorCount 位支持人'
  ///
  /// In zh, this message translates to:
  /// **'请选择 {requiredVisitorCount} 位支持人'**
  String ticketOrder_410(Object requiredVisitorCount);

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:440；原文：'当前状态（${_status.label}）不可支付'
  ///
  /// In zh, this message translates to:
  /// **'当前状态（{label}）不可支付'**
  String ticketOrder_440(Object label);

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:444；原文：'支持金额缺失，无法确认支付结果'
  ///
  /// In zh, this message translates to:
  /// **'支持金额缺失，无法确认支付结果'**
  String get ticketOrder_444;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:486；原文：'关闭原因不能为空'
  ///
  /// In zh, this message translates to:
  /// **'关闭原因不能为空'**
  String get ticketOrder_486;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:510；原文：'未支付的支持不能退款'
  ///
  /// In zh, this message translates to:
  /// **'未支付的支持不能退款'**
  String get ticketOrder_510;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:534；原文：'支付超时，支持已取消'
  ///
  /// In zh, this message translates to:
  /// **'支付超时，支持已取消'**
  String get ticketOrder_534;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:553；原文：'支持已提交，不能再修改'
  ///
  /// In zh, this message translates to:
  /// **'支持已提交，不能再修改'**
  String get ticketOrder_553;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:559；原文：'支持状态不允许从「${_status.label}」变为「${next.label}」'
  ///
  /// In zh, this message translates to:
  /// **'支持状态不允许从「{label}」变为「{label2}」'**
  String ticketOrder_559(Object label, Object label2);

  /// 来源：lib/features/order/domain/events/order_lifecycle_events.dart:22；原文：'超时'
  ///
  /// In zh, this message translates to:
  /// **'超时'**
  String get orderLifecycleEvents_22;

  /// 来源：lib/features/order/domain/events/order_lifecycle_events.dart:48；原文：'order.shipped(${orderId.value}, ${trackingNumber ?? '无单号'})'
  ///
  /// In zh, this message translates to:
  /// **'order.shipped({value}, {trackingNumber})'**
  String orderLifecycleEvents_48(Object value, Object trackingNumber);

  /// 来源：lib/features/order/domain/events/order_placed.dart:42；原文：'order.placed(${orderNumber.value}, 支持金额 ${paymentAmount.format()})'
  ///
  /// In zh, this message translates to:
  /// **'order.placed({value}, 支持金额 {format})'**
  String orderPlaced_42(Object value, Object format);

  /// 来源：lib/features/order/domain/policies/purchase_limit_policy.dart:30；原文：'不限支持'
  ///
  /// In zh, this message translates to:
  /// **'不限支持'**
  String get purchaseLimitPolicy_30;

  /// 来源：lib/features/order/domain/policies/purchase_limit_policy.dart:32；原文：'每单限 ${maxPerOrder!.value} 份'
  ///
  /// In zh, this message translates to:
  /// **'每单限 {value} 份'**
  String purchaseLimitPolicy_32(Object value);

  /// 来源：lib/features/order/domain/policies/purchase_limit_policy.dart:33；原文：'每人限 ${maxPerUser!.value} 份'
  ///
  /// In zh, this message translates to:
  /// **'每人限 {value} 份'**
  String purchaseLimitPolicy_33(Object value);

  /// 来源：lib/features/order/domain/policies/purchase_limit_policy.dart:57；原文：'每单最多支持 ${max.value} 份'
  ///
  /// In zh, this message translates to:
  /// **'每单最多支持 {value} 份'**
  String purchaseLimitPolicy_57(Object value);

  /// 来源：lib/features/order/domain/policies/purchase_limit_policy.dart:81；原文：'每人限购 ${max.value} 份，您已支持 ${alreadyPurchased.value} 份'
  ///
  /// In zh, this message translates to:
  /// **'每人限购 {value} 份，您已支持 {value2} 份'**
  String purchaseLimitPolicy_81(Object value, Object value2);

  /// 来源：lib/features/order/domain/policies/purchase_limit_policy.dart:83；原文：'每人限购 ${max.value} 份，您还可支持 $remaining 份'
  ///
  /// In zh, this message translates to:
  /// **'每人限购 {value} 份，您还可支持 {remaining} 份'**
  String purchaseLimitPolicy_83(Object value, Object remaining);

  /// 来源：lib/features/order/domain/services/order_quote.dart:107；原文：'支持总额'
  ///
  /// In zh, this message translates to:
  /// **'支持总额'**
  String get orderQuote_107;

  /// 来源：lib/features/order/domain/services/order_quote.dart:108；原文：'运费'
  ///
  /// In zh, this message translates to:
  /// **'运费'**
  String get orderQuote_108;

  /// 来源：lib/features/order/domain/services/order_quote.dart:109；原文：'拆单费'
  ///
  /// In zh, this message translates to:
  /// **'拆单费'**
  String get orderQuote_109;

  /// 来源：lib/features/order/domain/services/order_quote.dart:111；原文：'优惠'
  ///
  /// In zh, this message translates to:
  /// **'优惠'**
  String get orderQuote_111;

  /// 来源：lib/features/order/domain/services/order_quote.dart:113；原文：'礼品卡'
  ///
  /// In zh, this message translates to:
  /// **'礼品卡'**
  String get orderQuote_113;

  /// 来源：lib/features/order/domain/services/order_quote.dart:114；原文：'加急服务'
  ///
  /// In zh, this message translates to:
  /// **'加急服务'**
  String get orderQuote_114;

  /// 来源：lib/features/order/domain/value_objects/delivery.dart:78；原文：'电子回报凭证'
  ///
  /// In zh, this message translates to:
  /// **'电子回报凭证'**
  String get delivery_78;

  /// 来源：lib/features/order/domain/value_objects/delivery.dart:81；原文：'快递配送'
  ///
  /// In zh, this message translates to:
  /// **'快递配送'**
  String get delivery_81;

  /// 来源：lib/features/order/domain/value_objects/delivery.dart:84；原文：'现场自取'
  ///
  /// In zh, this message translates to:
  /// **'现场自取'**
  String get delivery_84;

  /// 来源：lib/features/order/order_l10n.dart:68；原文：'${method.labelOf(context)}（${postage.format()}）'
  ///
  /// In zh, this message translates to:
  /// **'{method}（{postage}）'**
  String delivery_136(Object method, Object postage);

  /// 来源：lib/features/order/domain/value_objects/discount.dart:71；原文：'-$percent%（封顶 ${ceiling.format()}）'
  ///
  /// In zh, this message translates to:
  /// **'-{percent}%（封顶 {format}）'**
  String discount_71(Object percent, Object format);

  /// 来源：lib/features/order/domain/value_objects/discount.dart:122；原文：'不使用优惠'
  ///
  /// In zh, this message translates to:
  /// **'不使用优惠'**
  String get discount_122;

  /// 来源：lib/features/order/domain/value_objects/discount.dart:139；原文：'营销活动 ${discount.describe()}'
  ///
  /// In zh, this message translates to:
  /// **'营销活动 {describe}'**
  String discount_139(Object describe);

  /// 来源：lib/features/order/domain/value_objects/discount.dart:156；原文：'优惠券 ${discount.describe()}'
  ///
  /// In zh, this message translates to:
  /// **'优惠券 {describe}'**
  String discount_156(Object describe);

  /// 来源：lib/features/order/domain/value_objects/order_status.dart:24；原文：'待提交'
  ///
  /// In zh, this message translates to:
  /// **'待提交'**
  String get orderStatus_24;

  /// 来源：lib/features/order/domain/value_objects/order_status.dart:40；原文：'已取消'
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get orderStatus_40;

  /// 来源：lib/features/order/domain/value_objects/order_status.dart:43；原文：'已退款'
  ///
  /// In zh, this message translates to:
  /// **'已退款'**
  String get orderStatus_43;

  /// 来源：lib/features/order/domain/value_objects/order_status.dart:85；原文：'未知支持状态编码：$code'
  ///
  /// In zh, this message translates to:
  /// **'未知支持状态编码：{code}'**
  String orderStatus_85(Object code);

  /// 来源：lib/features/order/domain/value_objects/order_type.dart:10；原文：'普通支持'
  ///
  /// In zh, this message translates to:
  /// **'普通支持'**
  String get orderType_10;

  /// 来源：lib/features/order/domain/value_objects/order_type.dart:13；原文：'拼团'
  ///
  /// In zh, this message translates to:
  /// **'拼团'**
  String get orderType_13;

  /// 来源：lib/features/order/domain/value_objects/order_type.dart:16；原文：'限时支持'
  ///
  /// In zh, this message translates to:
  /// **'限时支持'**
  String get orderType_16;

  /// 来源：lib/features/order/domain/value_objects/order_type.dart:19；原文：'会员充值'
  ///
  /// In zh, this message translates to:
  /// **'会员充值'**
  String get orderType_19;

  /// 来源：lib/features/order/domain/value_objects/order_type.dart:22；原文：'加急服务'
  ///
  /// In zh, this message translates to:
  /// **'加急服务'**
  String get orderType_22;

  /// 来源：lib/features/order/domain/value_objects/order_type.dart:36；原文：'未知支持类型：$code'
  ///
  /// In zh, this message translates to:
  /// **'未知支持类型：{code}'**
  String orderType_36(Object code);

  /// 来源：lib/features/order/domain/value_objects/order_type.dart:49；原文：'普通支持'
  ///
  /// In zh, this message translates to:
  /// **'普通支持'**
  String get orderType_49;

  /// 来源：lib/features/order/domain/value_objects/order_type.dart:49；原文：'《支持服务协议》'
  ///
  /// In zh, this message translates to:
  /// **'《支持服务协议》'**
  String get orderType_49_2;

  /// 来源：lib/features/order/domain/value_objects/order_type.dart:52；原文：'代支持'
  ///
  /// In zh, this message translates to:
  /// **'代支持'**
  String get orderType_52;

  /// 来源：lib/features/order/domain/value_objects/order_type.dart:52；原文：'《代支持服务协议》'
  ///
  /// In zh, this message translates to:
  /// **'《代支持服务协议》'**
  String get orderType_52_2;

  /// 来源：lib/features/order/domain/value_objects/order_type.dart:69；原文：'未知支持方式：$code'
  ///
  /// In zh, this message translates to:
  /// **'未知支持方式：{code}'**
  String orderType_69(Object code);

  /// 来源：lib/features/order/domain/value_objects/payment_channel.dart:10；原文：'微信支付'
  ///
  /// In zh, this message translates to:
  /// **'微信支付'**
  String get paymentChannel_10;

  /// 来源：lib/features/order/domain/value_objects/payment_channel.dart:13；原文：'支付宝'
  ///
  /// In zh, this message translates to:
  /// **'支付宝'**
  String get paymentChannel_13;

  /// 来源：lib/features/order/domain/value_objects/payment_channel.dart:16；原文：'银行卡'
  ///
  /// In zh, this message translates to:
  /// **'银行卡'**
  String get paymentChannel_16;

  /// 来源：lib/features/order/domain/value_objects/payment_channel.dart:19；原文：'信用付'
  ///
  /// In zh, this message translates to:
  /// **'信用付'**
  String get paymentChannel_19;

  /// 来源：lib/features/order/domain/value_objects/payment_channel.dart:22；原文：'余额支付'
  ///
  /// In zh, this message translates to:
  /// **'余额支付'**
  String get paymentChannel_22;

  /// 来源：lib/features/order/domain/value_objects/payment_channel.dart:36；原文：'未知支付渠道：$code'
  ///
  /// In zh, this message translates to:
  /// **'未知支付渠道：{code}'**
  String paymentChannel_36(Object code);

  /// 来源：lib/features/order/domain/value_objects/speed_pack.dart:61；原文：'加急服务 $units 份（现金 ${cashPortion.format()} / 余额 ${balancePortion.format()}）'
  ///
  /// In zh, this message translates to:
  /// **'加急服务 {units} 份（现金 {format} / 余额 {format2}）'**
  String speedPack_61(Object units, Object format, Object format2);

  /// 来源：lib/features/order/domain/value_objects/speed_pack.dart:85；原文：'礼品卡 ${id.value}（余额 ${balance.format()}）'
  ///
  /// In zh, this message translates to:
  /// **'礼品卡 {value}（余额 {format}）'**
  String speedPack_85(Object value, Object format);

  /// 来源：lib/features/order/domain/value_objects/visitor.dart:7；原文：'身份证'
  ///
  /// In zh, this message translates to:
  /// **'身份证'**
  String get visitor_7;

  /// 来源：lib/features/order/domain/value_objects/visitor.dart:8；原文：'护照'
  ///
  /// In zh, this message translates to:
  /// **'护照'**
  String get visitor_8;

  /// 来源：lib/features/order/domain/value_objects/visitor.dart:9；原文：'港澳通行证'
  ///
  /// In zh, this message translates to:
  /// **'港澳通行证'**
  String get visitor_9;

  /// 来源：lib/features/order/domain/value_objects/visitor.dart:10；原文：'台湾通行证'
  ///
  /// In zh, this message translates to:
  /// **'台湾通行证'**
  String get visitor_10;

  /// 来源：lib/features/order/domain/value_objects/visitor.dart:11；原文：'港澳台居住证'
  ///
  /// In zh, this message translates to:
  /// **'港澳台居住证'**
  String get visitor_11;

  /// 来源：lib/features/order/order_confirm_page.dart:48；原文：'确认支持'
  ///
  /// In zh, this message translates to:
  /// **'确认支持'**
  String get orderConfirmPage_48;

  /// 来源：lib/features/order/order_confirm_page.dart:59；原文：'选择档位'
  ///
  /// In zh, this message translates to:
  /// **'选择回报档位'**
  String get orderConfirmPage_59;

  /// 来源：lib/features/order/order_confirm_page.dart:73；原文：'优惠'
  ///
  /// In zh, this message translates to:
  /// **'优惠'**
  String get orderConfirmPage_73;

  /// 来源：lib/features/order/order_confirm_page.dart:79；原文：'不使用优惠'
  ///
  /// In zh, this message translates to:
  /// **'不使用优惠'**
  String get orderConfirmPage_79;

  /// 来源：lib/features/order/order_confirm_page.dart:99；原文：'其他抵扣'
  ///
  /// In zh, this message translates to:
  /// **'其他抵扣'**
  String get orderConfirmPage_99;

  /// 来源：lib/features/order/order_confirm_page.dart:107；原文：'礼品卡（本单不可用）'
  ///
  /// In zh, this message translates to:
  /// **'礼品卡（本单不可用）'**
  String get orderConfirmPage_107;

  /// 来源：lib/features/order/order_confirm_page.dart:109；原文：'礼品卡（余额 ${seed.giftCard!.balance.format()}）'
  ///
  /// In zh, this message translates to:
  /// **'礼品卡（余额 {format}）'**
  String orderConfirmPage_109(Object format);

  /// 来源：lib/features/order/order_confirm_page.dart:123；原文：'加急服务（本企划不提供）'
  ///
  /// In zh, this message translates to:
  /// **'加急服务（本企划不提供）'**
  String get orderConfirmPage_123;

  /// 来源：lib/features/order/order_confirm_page.dart:125；原文：'加急服务（${seed.speedPackUnitPrice!.format()}/份）'
  ///
  /// In zh, this message translates to:
  /// **'加急服务（{format}/份）'**
  String orderConfirmPage_125(Object format);

  /// 来源：lib/features/order/order_confirm_page.dart:138；原文：'实名支持人'
  ///
  /// In zh, this message translates to:
  /// **'实名支持人'**
  String get orderConfirmPage_138;

  /// 来源：lib/features/order/order_confirm_page.dart:143；原文：'选择支持人（需 ${state.order.requiredVisitorCount} 位）'
  ///
  /// In zh, this message translates to:
  /// **'选择支持人（需 {requiredVisitorCount} 位）'**
  String orderConfirmPage_143(Object requiredVisitorCount);

  /// 来源：lib/features/order/order_confirm_page.dart:145；原文：'已选 ${state.order.visitors.length} 位'
  ///
  /// In zh, this message translates to:
  /// **'已选 {length} 位'**
  String orderConfirmPage_145(Object length);

  /// 来源：lib/features/order/order_confirm_page.dart:150；原文：'本企划需实名支持人，未选择将无法提交'
  ///
  /// In zh, this message translates to:
  /// **'本企划需实名支持人，未选择将无法提交'**
  String get orderConfirmPage_150;

  /// 来源：lib/features/order/order_confirm_page.dart:167；原文：'费用明细'
  ///
  /// In zh, this message translates to:
  /// **'费用明细'**
  String get orderConfirmPage_167;

  /// 来源：lib/features/order/order_confirm_page.dart:173；原文：'支持原价'
  ///
  /// In zh, this message translates to:
  /// **'支持原价'**
  String get orderConfirmPage_173;

  /// 来源：lib/features/order/order_confirm_page.dart:175；原文：'应付金额'
  ///
  /// In zh, this message translates to:
  /// **'应付金额'**
  String get orderConfirmPage_175;

  /// 来源：lib/features/order/order_confirm_page.dart:190；原文：'我已阅读并同意${state.order.buyType.agreementTitle}'
  ///
  /// In zh, this message translates to:
  /// **'我已阅读并同意{agreementTitle}'**
  String orderConfirmPage_190(Object agreementTitle);

  /// 来源：lib/features/order/order_confirm_page.dart:196；原文：'领域事件：${state.recentEvents.join(' → ')}'
  ///
  /// In zh, this message translates to:
  /// **'领域事件：{join}'**
  String orderConfirmPage_196(Object join);

  /// 来源：lib/features/order/order_confirm_page.dart:243；原文：'${seed.sessionLabel} · 企划 ${seed.showId.value}'
  ///
  /// In zh, this message translates to:
  /// **'{sessionLabel} · 企划 {value}'**
  String orderConfirmPage_243(Object sessionLabel, Object value);

  /// 来源：lib/features/order/order_confirm_page.dart:444；原文：'应付'
  ///
  /// In zh, this message translates to:
  /// **'应付'**
  String get orderConfirmPage_444;

  /// 来源：lib/features/order/order_confirm_page.dart:457；原文：'已确认'
  ///
  /// In zh, this message translates to:
  /// **'已确认'**
  String get orderConfirmPage_457;

  /// 来源：lib/features/order/order_confirm_page.dart:460；原文：'确认中…'
  ///
  /// In zh, this message translates to:
  /// **'确认中…'**
  String get orderConfirmPage_460;

  /// 来源：lib/features/order/order_confirm_page.dart:462；原文：'确认支持'
  ///
  /// In zh, this message translates to:
  /// **'确认支持'**
  String get orderConfirmPage_462;

  /// 来源：lib/features/order/order_detail_page.dart:52；原文：'支持详情'
  ///
  /// In zh, this message translates to:
  /// **'支持详情'**
  String get orderDetailPage_52;

  /// 来源：lib/features/order/order_detail_page.dart:56；原文：'订单加载失败'
  ///
  /// In zh, this message translates to:
  /// **'支持记录加载失败'**
  String get orderDetailPage_56;

  /// 来源：lib/features/order/order_detail_page.dart:65；原文：'订单不存在'
  ///
  /// In zh, this message translates to:
  /// **'支持记录不存在'**
  String get orderDetailPage_65;

  /// 来源：lib/features/order/order_detail_page.dart:66；原文：'订单可能已被删除，或链接已过期'
  ///
  /// In zh, this message translates to:
  /// **'支持记录可能已被删除，或链接已过期'**
  String get orderDetailPage_66;

  /// 来源：lib/features/order/order_detail_page.dart:68；原文：'返回支持列表'
  ///
  /// In zh, this message translates to:
  /// **'返回支持列表'**
  String get orderDetailPage_68;

  /// 来源：lib/features/order/order_detail_page.dart:101；原文：'回报档位'
  ///
  /// In zh, this message translates to:
  /// **'回报档位'**
  String get orderDetailPage_101;

  /// 来源：lib/features/order/order_detail_page.dart:105；原文：'${line.quantity.value} 份 · ${line.subtotal.format()}'
  ///
  /// In zh, this message translates to:
  /// **'{value} 份 · {format}'**
  String orderDetailPage_105(Object value, Object format);

  /// 来源：lib/features/order/order_detail_page.dart:108；原文：'交付方式'
  ///
  /// In zh, this message translates to:
  /// **'交付方式'**
  String get orderDetailPage_108;

  /// 来源：lib/features/order/order_detail_page.dart:113；原文：'支持人'
  ///
  /// In zh, this message translates to:
  /// **'支持人'**
  String get orderDetailPage_113;

  /// 来源：lib/features/order/order_detail_page.dart:125；原文：'金额明细'
  ///
  /// In zh, this message translates to:
  /// **'金额明细'**
  String get orderDetailPage_125;

  /// 来源：lib/features/order/order_detail_page.dart:133；原文：'支持金额'
  ///
  /// In zh, this message translates to:
  /// **'支持金额'**
  String get orderDetailPage_133;

  /// 来源：lib/features/order/order_detail_page.dart:139；原文：'支持信息'
  ///
  /// In zh, this message translates to:
  /// **'支持信息'**
  String get orderDetailPage_139;

  /// 来源：lib/features/order/order_detail_page.dart:141；原文：'支持编号'
  ///
  /// In zh, this message translates to:
  /// **'支持编号'**
  String get orderDetailPage_141;

  /// 来源：lib/features/order/order_detail_page.dart:150；原文：'支持编号已复制'
  ///
  /// In zh, this message translates to:
  /// **'支持编号已复制'**
  String get orderDetailPage_150;

  /// 来源：lib/features/order/order_detail_page.dart:163；原文：'支持时间'
  ///
  /// In zh, this message translates to:
  /// **'支持时间'**
  String get orderDetailPage_163;

  /// 来源：lib/features/order/order_detail_page.dart:165；原文：'支付时间'
  ///
  /// In zh, this message translates to:
  /// **'支付时间'**
  String get orderDetailPage_165;

  /// 来源：lib/features/order/order_detail_page.dart:167；原文：'关闭原因'
  ///
  /// In zh, this message translates to:
  /// **'关闭原因'**
  String get orderDetailPage_167;

  /// 来源：lib/features/order/order_detail_page.dart:199；原文：'支持尚未提交'
  ///
  /// In zh, this message translates to:
  /// **'支持尚未提交'**
  String get orderDetailPage_199;

  /// 来源：lib/features/order/order_detail_page.dart:201；原文：'请在 $_deadline 前完成支付，超时支持将自动关闭'
  ///
  /// In zh, this message translates to:
  /// **'请在 {_deadline} 前完成支付，超时支持将自动关闭'**
  String orderDetailPage_201(Object _deadline);

  /// 来源：lib/features/order/order_detail_page.dart:204；原文：'已支付，正在为你确认回报'
  ///
  /// In zh, this message translates to:
  /// **'已支付，正在为你确认回报'**
  String get orderDetailPage_204;

  /// 来源：lib/features/order/order_detail_page.dart:205；原文：'回报已寄出，请注意查收'
  ///
  /// In zh, this message translates to:
  /// **'回报已寄出，请注意查收'**
  String get orderDetailPage_205;

  /// 来源：lib/features/order/order_detail_page.dart:206；原文：'支持已完成，欢迎发表支持评价'
  ///
  /// In zh, this message translates to:
  /// **'支持已完成，欢迎发表支持评价'**
  String get orderDetailPage_206;

  /// 来源：lib/features/order/order_detail_page.dart:207；原文：'支持已取消，可重新选择企划'
  ///
  /// In zh, this message translates to:
  /// **'支持已取消，可重新选择企划'**
  String get orderDetailPage_207;

  /// 来源：lib/features/order/order_detail_page.dart:208；原文：'退款已原路退回'
  ///
  /// In zh, this message translates to:
  /// **'退款已原路退回'**
  String get orderDetailPage_208;

  /// 来源：lib/features/order/order_detail_page.dart:325；原文：'取消支持'
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderDetailPage_325;

  /// 来源：lib/features/order/order_detail_page.dart:329；原文：'立即支付'
  ///
  /// In zh, this message translates to:
  /// **'立即支付'**
  String get orderDetailPage_329;

  /// 来源：lib/features/order/order_detail_page.dart:335；原文：'查看物流'
  ///
  /// In zh, this message translates to:
  /// **'查看物流'**
  String get orderDetailPage_335;

  /// 来源：lib/features/order/order_detail_page.dart:335；原文：'物流详情待接入快递查询接口'
  ///
  /// In zh, this message translates to:
  /// **'物流详情待接入快递查询接口'**
  String get orderDetailPage_335_2;

  /// 来源：lib/features/order/order_detail_page.dart:337；原文：'确认收到回报'
  ///
  /// In zh, this message translates to:
  /// **'确认收到回报'**
  String get orderDetailPage_337;

  /// 来源：lib/features/order/order_detail_page.dart:342；原文：'申请退款'
  ///
  /// In zh, this message translates to:
  /// **'申请退款'**
  String get orderDetailPage_342;

  /// 来源：lib/features/order/order_detail_page.dart:351；原文：'去评价'
  ///
  /// In zh, this message translates to:
  /// **'去评价'**
  String get orderDetailPage_351;

  /// 来源：lib/features/order/order_detail_page.dart:351；原文：'评价属于独立的评价聚合，本示例未实现'
  ///
  /// In zh, this message translates to:
  /// **'评价属于独立的评价聚合，本示例未实现'**
  String get orderDetailPage_351_2;

  /// 来源：lib/features/order/order_detail_page.dart:353；原文：'再次购买'
  ///
  /// In zh, this message translates to:
  /// **'再次购买'**
  String get orderDetailPage_353;

  /// 来源：lib/features/order/order_detail_page.dart:360；原文：'继续填写'
  ///
  /// In zh, this message translates to:
  /// **'继续填写'**
  String get orderDetailPage_360;

  /// 来源：lib/features/order/order_detail_page.dart:366；原文：'联系客服'
  ///
  /// In zh, this message translates to:
  /// **'联系客服'**
  String get orderDetailPage_366;

  /// 来源：lib/features/order/order_detail_page.dart:366；原文：'客服会话（演示）'
  ///
  /// In zh, this message translates to:
  /// **'客服会话（演示）'**
  String get orderDetailPage_366_2;

  /// 来源：lib/features/order/order_detail_page.dart:367；原文：'查看回报凭证'
  ///
  /// In zh, this message translates to:
  /// **'查看回报凭证'**
  String get orderDetailPage_367;

  /// 来源：lib/features/order/order_detail_page.dart:367；原文：'电子回报凭证面待接入交付接口'
  ///
  /// In zh, this message translates to:
  /// **'电子回报凭证面待接入交付接口'**
  String get orderDetailPage_367_2;

  /// 来源：lib/features/order/order_detail_page.dart:369；原文：'申请退款'
  ///
  /// In zh, this message translates to:
  /// **'申请退款'**
  String get orderDetailPage_369;

  /// 来源：lib/features/order/order_detail_page.dart:379；原文：'重新选择企划'
  ///
  /// In zh, this message translates to:
  /// **'重新选择企划'**
  String get orderDetailPage_379;

  /// 来源：lib/features/order/order_detail_page.dart:437；原文：'支付成功，等待交付'
  ///
  /// In zh, this message translates to:
  /// **'支付成功，等待交付'**
  String get orderDetailPage_437;

  /// 来源：lib/features/order/order_detail_page.dart:444；原文：'取消支持'
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderDetailPage_444;

  /// 来源：lib/features/order/order_detail_page.dart:445；原文：'取消后需要重新支持，确定继续吗？'
  ///
  /// In zh, this message translates to:
  /// **'取消后需要重新支持，确定继续吗？'**
  String get orderDetailPage_445;

  /// 来源：lib/features/order/order_detail_page.dart:449；原文：'再想想'
  ///
  /// In zh, this message translates to:
  /// **'再想想'**
  String get orderDetailPage_449;

  /// 来源：lib/features/order/order_detail_page.dart:453；原文：'取消支持'
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderDetailPage_453;

  /// 来源：lib/features/order/order_detail_page.dart:459；原文：'用户主动取消'
  ///
  /// In zh, this message translates to:
  /// **'用户主动取消'**
  String get orderDetailPage_459;

  /// 来源：lib/features/order/order_detail_page.dart:461；原文：'支持已取消'
  ///
  /// In zh, this message translates to:
  /// **'支持已取消'**
  String get orderDetailPage_461;

  /// 来源：lib/features/order/order_detail_page.dart:470；原文：'已确认收到回报'
  ///
  /// In zh, this message translates to:
  /// **'已确认收到回报'**
  String get orderDetailPage_470;

  /// 来源：lib/features/order/order_list_page.dart:71；原文：'订单加载失败'
  ///
  /// In zh, this message translates to:
  /// **'支持记录加载失败'**
  String get orderListPage_71;

  /// 来源：lib/features/order/order_list_page.dart:85；原文：'还没有订单'
  ///
  /// In zh, this message translates to:
  /// **'还没有支持记录'**
  String get orderListPage_85;

  /// 来源：lib/features/order/order_list_page.dart:87；原文：'没有${filter.label}的订单'
  ///
  /// In zh, this message translates to:
  /// **'没有{label}的支持记录'**
  String orderListPage_87(Object label);

  /// 来源：lib/features/order/order_list_page.dart:88；原文：'去首页挑一个企划吧'
  ///
  /// In zh, this message translates to:
  /// **'去首页挑一个企划吧'**
  String get orderListPage_88;

  /// 来源：lib/features/order/order_list_page.dart:90；原文：'去逛逛'
  ///
  /// In zh, this message translates to:
  /// **'去逛逛'**
  String get orderListPage_90;

  /// 来源：lib/features/order/order_list_page.dart:115；原文：'评价属于独立的评价聚合，本示例未实现'
  ///
  /// In zh, this message translates to:
  /// **'评价属于独立的评价聚合，本示例未实现'**
  String get orderListPage_115;

  /// 来源：lib/features/order/order_list_page.dart:119；原文：'客服会话（演示）'
  ///
  /// In zh, this message translates to:
  /// **'客服会话（演示）'**
  String get orderListPage_119;

  /// 来源：lib/features/order/order_list_page.dart:130；原文：'暂无商品订单'
  ///
  /// In zh, this message translates to:
  /// **'暂无商品订单'**
  String get orderListPage_130;

  /// 来源：lib/features/order/order_list_page.dart:131；原文：'企划支持链路之外的周边商品暂未接入'
  ///
  /// In zh, this message translates to:
  /// **'企划支持链路之外的周边商品暂未接入'**
  String get orderListPage_131;

  /// 来源：lib/features/order/order_list_page.dart:181；原文：'取消支持'
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderListPage_181;

  /// 来源：lib/features/order/order_list_page.dart:182；原文：'取消后需要重新支持，确定继续吗？'
  ///
  /// In zh, this message translates to:
  /// **'取消后需要重新支持，确定继续吗？'**
  String get orderListPage_182;

  /// 来源：lib/features/order/order_list_page.dart:186；原文：'再想想'
  ///
  /// In zh, this message translates to:
  /// **'再想想'**
  String get orderListPage_186;

  /// 来源：lib/features/order/order_list_page.dart:190；原文：'取消支持'
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderListPage_190;

  /// 来源：lib/features/order/order_list_page.dart:196；原文：'用户主动取消'
  ///
  /// In zh, this message translates to:
  /// **'用户主动取消'**
  String get orderListPage_196;

  /// 来源：lib/features/order/domain/aggregates/ticket_order.dart:534；原文：'支付超时，支持已取消'
  ///
  /// In zh, this message translates to:
  /// **'支付超时，支持已取消'**
  String get orderCancelTimeout;

  /// 来源：lib/features/order/order_list_page.dart:198；原文：'支持已取消'
  ///
  /// In zh, this message translates to:
  /// **'支持已取消'**
  String get orderListPage_198;

  /// 来源：lib/features/order/order_list_page.dart:208；原文：'已确认收到回报'
  ///
  /// In zh, this message translates to:
  /// **'已确认收到回报'**
  String get orderListPage_208;

  /// 来源：lib/features/order/order_list_page.dart:229；原文：'企划'
  ///
  /// In zh, this message translates to:
  /// **'企划'**
  String get orderListPage_229;

  /// 来源：lib/features/order/order_list_page.dart:229；原文：'商品'
  ///
  /// In zh, this message translates to:
  /// **'商品'**
  String get orderListPage_229_2;

  /// 来源：lib/features/order/pay_success_page.dart:75；原文：'支付成功'
  ///
  /// In zh, this message translates to:
  /// **'支付成功'**
  String get paySuccessPage_75;

  /// 来源：lib/features/order/pay_success_page.dart:84；原文：'企划星正在为您确认回报，请耐心等待'
  ///
  /// In zh, this message translates to:
  /// **'企划星正在为您确认回报，请耐心等待'**
  String get paySuccessPage_84;

  /// 来源：lib/features/order/pay_success_page.dart:115；原文：'查看订单'
  ///
  /// In zh, this message translates to:
  /// **'查看支持记录'**
  String get paySuccessPage_115;

  /// 来源：lib/features/order/pay_success_page.dart:138；原文：'继续逛逛'
  ///
  /// In zh, this message translates to:
  /// **'继续逛逛'**
  String get paySuccessPage_138;

  /// 来源：lib/features/order/pay_success_page.dart:182；原文：'企划'
  ///
  /// In zh, this message translates to:
  /// **'企划'**
  String get paySuccessPage_182;

  /// 来源：lib/features/order/pay_success_page.dart:189；原文：'支持编号'
  ///
  /// In zh, this message translates to:
  /// **'支持编号'**
  String get paySuccessPage_189;

  /// 来源：lib/features/order/pay_success_page.dart:198；原文：'支付金额'
  ///
  /// In zh, this message translates to:
  /// **'支付金额'**
  String get paySuccessPage_198;

  /// 来源：lib/features/order/payment/pay_info.dart:40；原文：'推荐'
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get payInfo_40;

  /// 来源：lib/features/order/payment/pay_info.dart:55；原文：'星币余额支付'
  ///
  /// In zh, this message translates to:
  /// **'星币余额支付'**
  String get payInfo_55;

  /// 来源：lib/features/order/payment/pay_info.dart:60；原文：'企划'
  ///
  /// In zh, this message translates to:
  /// **'企划'**
  String get payInfo_60;

  /// 来源：lib/features/order/payment/pay_info.dart:61；原文：'支持编号'
  ///
  /// In zh, this message translates to:
  /// **'支持编号'**
  String get payInfo_61;

  /// 来源：lib/features/order/payment/pay_page.dart:77；原文：'收银台'
  ///
  /// In zh, this message translates to:
  /// **'收银台'**
  String get payPage_77;

  /// 来源：lib/features/order/payment/pay_page.dart:133；原文：'演示环境：支付不会真实扣款，点击确认后模拟支付流程'
  ///
  /// In zh, this message translates to:
  /// **'演示环境：支付不会真实扣款，点击确认后模拟支付流程'**
  String get payPage_133;

  /// 来源：lib/features/order/payment/pay_page.dart:166；原文：'支付已取消'
  ///
  /// In zh, this message translates to:
  /// **'支付已取消'**
  String get payPage_166;

  /// 来源：lib/features/order/payment/pay_page.dart:195；原文：'请在 ${PayController.formatCountdown(seconds)} 内完成支付'
  ///
  /// In zh, this message translates to:
  /// **'请在 {seconds} 内完成支付'**
  String payPage_195(Object seconds);

  /// 来源：lib/features/order/payment/pay_page.dart:259；原文：'应付金额'
  ///
  /// In zh, this message translates to:
  /// **'应付金额'**
  String get payPage_259;

  /// 来源：lib/features/order/payment/pay_page.dart:301；原文：'选择支付方式'
  ///
  /// In zh, this message translates to:
  /// **'选择支付方式'**
  String get payPage_301;

  /// 来源：lib/features/order/payment/pay_page.dart:436；原文：'请求中…'
  ///
  /// In zh, this message translates to:
  /// **'请求中…'**
  String get payPage_436;

  /// 来源：lib/features/order/payment/pay_page.dart:438；原文：'支付中…'
  ///
  /// In zh, this message translates to:
  /// **'支付中…'**
  String get payPage_438;

  /// 来源：lib/features/order/payment/pay_page.dart:440；原文：'确认支付 ${state.info.payAmount.format()}'
  ///
  /// In zh, this message translates to:
  /// **'确认支付 {format}'**
  String payPage_440(Object format);

  /// 来源：lib/features/order/payment/pay_providers.dart:115；原文：'当前状态不可支付'
  ///
  /// In zh, this message translates to:
  /// **'当前状态不可支付'**
  String get payProviders_115;

  /// 来源：lib/features/order/payment/pay_providers.dart:172；原文：'支付超时，支持已自动取消'
  ///
  /// In zh, this message translates to:
  /// **'支付超时，支持已自动取消'**
  String get payProviders_172;

  /// 来源：lib/features/order/refund/refund_page.dart:43；原文：'退款申请已提交，请等待审核'
  ///
  /// In zh, this message translates to:
  /// **'退款申请已提交，请等待审核'**
  String get refundPage_43;

  /// 来源：lib/features/order/refund/refund_page.dart:62；原文：'申请退款'
  ///
  /// In zh, this message translates to:
  /// **'申请退款'**
  String get refundPage_62;

  /// 来源：lib/features/order/refund/refund_page.dart:97；原文：'提交中…'
  ///
  /// In zh, this message translates to:
  /// **'提交中…'**
  String get refundPage_97;

  /// 来源：lib/features/order/refund/refund_page.dart:98；原文：'已提交'
  ///
  /// In zh, this message translates to:
  /// **'已提交'**
  String get refundPage_98;

  /// 来源：lib/features/order/refund/refund_page.dart:99；原文：'提交退款申请'
  ///
  /// In zh, this message translates to:
  /// **'提交退款申请'**
  String get refundPage_99;

  /// 来源：lib/features/order/refund/refund_page.dart:138；原文：'退款金额'
  ///
  /// In zh, this message translates to:
  /// **'退款金额'**
  String get refundPage_138;

  /// 来源：lib/features/order/refund/refund_page.dart:150；原文：'支持金额'
  ///
  /// In zh, this message translates to:
  /// **'支持金额'**
  String get refundPage_150;

  /// 来源：lib/features/order/refund/refund_page.dart:164；原文：'预计退款'
  ///
  /// In zh, this message translates to:
  /// **'预计退款'**
  String get refundPage_164;

  /// 来源：lib/features/order/refund/refund_page.dart:207；原文：'退款原因'
  ///
  /// In zh, this message translates to:
  /// **'退款原因'**
  String get refundPage_207;

  /// 来源：lib/features/order/refund/refund_page.dart:244；原文：'请输入退款原因（选填）'
  ///
  /// In zh, this message translates to:
  /// **'请输入退款原因（选填）'**
  String get refundPage_244;

  /// 来源：lib/features/order/refund/refund_page.dart:331；原文：'退款说明'
  ///
  /// In zh, this message translates to:
  /// **'退款说明'**
  String get refundPage_331;

  /// 来源：lib/features/order/refund/refund_page.dart:342；原文：'• 众筹中状态下可全额退款\n'
  ///             '• 交付中状态下退还支持金额的 80%\n'
  ///             '• 已完成支持不支持退款\n'
  ///             '• 退款将原路退回至支付账户\n'
  ///             '• 退款审核一般需要 1-3 个工作日'
  ///
  /// In zh, this message translates to:
  /// **'• 众筹中可全额退款\n• 交付中退还支持金额的 80%\n• 已完成支持不支持退款\n• 退款将原路退回至支付账户\n• 退款审核一般需要 1-3 个工作日'**
  String get refundPage_342;

  /// 来源：lib/features/order/refund/refund_page.dart:382；原文：'退款申请已提交'
  ///
  /// In zh, this message translates to:
  /// **'退款申请已提交'**
  String get refundPage_382;

  /// 来源：lib/features/order/refund/refund_page.dart:391；原文：'退款金额 ${amount.format()} 将在审核通过后原路退回'
  ///
  /// In zh, this message translates to:
  /// **'退款金额 {format} 将在审核通过后原路退回'**
  String refundPage_391(Object format);

  /// 来源：lib/features/order/refund/refund_page.dart:404；原文：'返回支持列表'
  ///
  /// In zh, this message translates to:
  /// **'返回支持列表'**
  String get refundPage_404;

  /// 来源：lib/features/order/refund/refund_state.dart:8；原文：'不需要了'
  ///
  /// In zh, this message translates to:
  /// **'不需要了'**
  String get refundState_8;

  /// 来源：lib/features/order/refund/refund_state.dart:8；原文：'计划变更，暂时不需要了'
  ///
  /// In zh, this message translates to:
  /// **'计划变更，暂时不需要了'**
  String get refundState_8_2;

  /// 来源：lib/features/order/refund/refund_state.dart:11；原文：'买错了'
  ///
  /// In zh, this message translates to:
  /// **'买错了'**
  String get refundState_11;

  /// 来源：lib/features/order/refund/refund_state.dart:11；原文：'买错了场次或回报档位'
  ///
  /// In zh, this message translates to:
  /// **'买错了线下回报场次或回报档位'**
  String get refundState_11_2;

  /// 来源：lib/features/order/refund/refund_state.dart:14；原文：'支持金额太高'
  ///
  /// In zh, this message translates to:
  /// **'支持金额太高'**
  String get refundState_14;

  /// 来源：lib/features/order/refund/refund_state.dart:14；原文：'价格超出预算'
  ///
  /// In zh, this message translates to:
  /// **'价格超出预算'**
  String get refundState_14_2;

  /// 来源：lib/features/order/refund/refund_state.dart:17；原文：'找到更好的企划'
  ///
  /// In zh, this message translates to:
  /// **'找到更好的企划'**
  String get refundState_17;

  /// 来源：lib/features/order/refund/refund_state.dart:17；原文：'通过其他渠道购买了'
  ///
  /// In zh, this message translates to:
  /// **'通过其他渠道购买了'**
  String get refundState_17_2;

  /// 来源：lib/features/order/refund/refund_state.dart:20；原文：'其他原因'
  ///
  /// In zh, this message translates to:
  /// **'其他原因'**
  String get refundState_20;

  /// 来源：lib/features/order/refund/refund_state.dart:20；原文：'自定义说明'
  ///
  /// In zh, this message translates to:
  /// **'自定义说明'**
  String get refundState_20_2;

  /// 来源：lib/features/order/widgets/order_list_card.dart:52；原文：'企划 ${order.showId.value}'
  ///
  /// In zh, this message translates to:
  /// **'企划 {value}'**
  String orderListCard_52(Object value);

  /// 来源：lib/features/order/widgets/order_list_card.dart:53；原文：'回报信息待确认'
  ///
  /// In zh, this message translates to:
  /// **'回报信息待确认'**
  String get orderListCard_53;

  /// 订单卡片：企划回报预计交付时间
  ///
  /// In zh, this message translates to:
  /// **'交付：{value}'**
  String orderListCard_delivery(Object value);

  /// 来源：lib/features/order/widgets/order_list_card.dart:78；原文：'代支持'
  ///
  /// In zh, this message translates to:
  /// **'代支持'**
  String get orderListCard_78;

  /// 来源：lib/features/order/widgets/order_list_card.dart:130；原文：'支持人 ${order.visitors.map((v) => v.name).join('、')}'
  ///
  /// In zh, this message translates to:
  /// **'支持人 {join}'**
  String orderListCard_130(Object join);

  /// 来源：lib/features/order/widgets/order_list_card.dart:141；原文：'支持编号 ${order.number.value}'
  ///
  /// In zh, this message translates to:
  /// **'支持编号 {value}'**
  String orderListCard_141(Object value);

  /// 来源：lib/features/order/widgets/order_list_card.dart:184；原文：'共 ${order.totalTickets.value} 份  支持金额'
  ///
  /// In zh, this message translates to:
  /// **'共 {value} 份  支持金额'**
  String orderListCard_184(Object value);

  /// 来源：lib/features/order/widgets/order_list_card.dart:217；原文：'取消支持'
  ///
  /// In zh, this message translates to:
  /// **'取消支持'**
  String get orderListCard_217;

  /// 来源：lib/features/order/widgets/order_list_card.dart:220；原文：'去支付'
  ///
  /// In zh, this message translates to:
  /// **'去支付'**
  String get orderListCard_220;

  /// 来源：lib/features/order/widgets/order_list_card.dart:225；原文：'联系客服'
  ///
  /// In zh, this message translates to:
  /// **'联系客服'**
  String get orderListCard_225;

  /// 来源：lib/features/order/widgets/order_list_card.dart:228；原文：'申请退款'
  ///
  /// In zh, this message translates to:
  /// **'申请退款'**
  String get orderListCard_228;

  /// 来源：lib/features/order/widgets/order_list_card.dart:233；原文：'查看物流'
  ///
  /// In zh, this message translates to:
  /// **'查看物流'**
  String get orderListCard_233;

  /// 来源：lib/features/order/widgets/order_list_card.dart:236；原文：'确认收到回报'
  ///
  /// In zh, this message translates to:
  /// **'确认收到回报'**
  String get orderListCard_236;

  /// 来源：lib/features/order/widgets/order_list_card.dart:241；原文：'再次购买'
  ///
  /// In zh, this message translates to:
  /// **'再次购买'**
  String get orderListCard_241;

  /// 来源：lib/features/order/widgets/order_list_card.dart:244；原文：'去评价'
  ///
  /// In zh, this message translates to:
  /// **'去评价'**
  String get orderListCard_244;

  /// 来源：lib/features/order/widgets/order_list_card.dart:250；原文：'再次购买'
  ///
  /// In zh, this message translates to:
  /// **'再次购买'**
  String get orderListCard_250;

  /// 来源：lib/features/order/widgets/order_list_card.dart:298；原文：'支付已超时，请重新支持'
  ///
  /// In zh, this message translates to:
  /// **'支付已超时，请重新支持'**
  String get orderListCard_298;

  /// 来源：lib/features/order/widgets/order_list_card.dart:305；原文：'剩余支付时间 $minutes:$seconds'
  ///
  /// In zh, this message translates to:
  /// **'剩余支付时间 {minutes}:{seconds}'**
  String orderListCard_305(Object minutes, Object seconds);

  /// 来源：lib/features/order/widgets/payment_channel_sheet.dart:52；原文：'选择支付方式'
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
