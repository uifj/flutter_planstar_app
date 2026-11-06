// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'order_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class OrderLocalizationsEn extends OrderLocalizations {
  OrderLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get orderListTitle => 'My orders';

  @override
  String get orderListPlaceholder => 'Order list (sign-in required)';

  @override
  String get orderGoConfirm => 'Go to confirm';

  @override
  String get orderStatusPending => 'Unpaid';

  @override
  String get orderStatusPaid => 'To ship';

  @override
  String get orderStatusShipped => 'To receive';

  @override
  String get orderStatusFinished => 'Completed';

  @override
  String get orderStatusRefund => 'Refunding';

  @override
  String get orderConfirmController_117 => '票档不存在';

  @override
  String get orderConfirmController_145 => '本单没有可用营销活动';

  @override
  String get orderConfirmController_156 => '本单没有可用优惠券';

  @override
  String get orderConfirmController_169 => '本单没有可用礼品卡';

  @override
  String get orderConfirmController_183 => '本场不提供加速包';

  @override
  String get orderConfirmController_220 => '张票友';

  @override
  String orderConfirmController_246(Object message) {
    return '提交失败：$message';
  }

  @override
  String orderConfirmController_257(Object value) {
    return '订单已提交：$value';
  }

  @override
  String get orderListController_27 => '全部';

  @override
  String get orderListController_31 => '待评论';

  @override
  String get ticketOrder_81 => '实名观演人数量不能为负';

  @override
  String get ticketOrder_84 => '支付时限必须为正';

  @override
  String get ticketOrder_222 => '票档价格已变化，请重新确认订单';

  @override
  String ticketOrder_238(Object value) {
    return '票档不存在：$value';
  }

  @override
  String ticketOrder_263(Object value) {
    return '票档不存在：$value';
  }

  @override
  String ticketOrder_296(Object units, Object value) {
    return '加速包份数（$units）不能超过票数（$value）';
  }

  @override
  String get ticketOrder_329 => '同一观演人不能重复选择';

  @override
  String get ticketOrder_332 => '本场次无需实名观演人';

  @override
  String ticketOrder_337(Object requiredVisitorCount, Object length) {
    return '本单需选择 $requiredVisitorCount 位观演人，已选 $length 位';
  }

  @override
  String get ticketOrder_373 => '请先选择票档';

  @override
  String get ticketOrder_376 => '报价与当前订单内容不一致，请重新计算';

  @override
  String get ticketOrder_391 => '请先选择票档';

  @override
  String ticketOrder_396(Object agreementTitle) {
    return '请阅读并勾选$agreementTitle';
  }

  @override
  String get ticketOrder_402 => '订单金额尚未计算';

  @override
  String get ticketOrder_405 => '订单内容已变化，请重新确认金额';

  @override
  String ticketOrder_410(Object requiredVisitorCount) {
    return '请选择 $requiredVisitorCount 位观演人';
  }

  @override
  String ticketOrder_440(Object label) {
    return '当前状态（$label）不可支付';
  }

  @override
  String get ticketOrder_444 => '订单金额缺失，无法确认支付结果';

  @override
  String get ticketOrder_486 => '关闭原因不能为空';

  @override
  String get ticketOrder_510 => '未支付的订单不能退款';

  @override
  String get ticketOrder_534 => '支付超时，订单已关闭';

  @override
  String get ticketOrder_553 => '订单已提交，不能再修改';

  @override
  String ticketOrder_559(Object label, Object label2) {
    return '订单状态不允许从「$label」变为「$label2」';
  }

  @override
  String get orderLifecycleEvents_22 => '超时';

  @override
  String orderLifecycleEvents_48(Object value, Object trackingNumber) {
    return 'order.shipped($value, $trackingNumber)';
  }

  @override
  String orderPlaced_42(Object value, Object format) {
    return 'order.placed($value, 实付 $format)';
  }

  @override
  String get purchaseLimitPolicy_30 => '不限购';

  @override
  String purchaseLimitPolicy_32(Object value) {
    return '每单限 $value 张';
  }

  @override
  String purchaseLimitPolicy_33(Object value) {
    return '每人限 $value 张';
  }

  @override
  String purchaseLimitPolicy_57(Object value) {
    return '每单最多购买 $value 张';
  }

  @override
  String purchaseLimitPolicy_81(Object value, Object value2) {
    return '每人限购 $value 张，您已购买 $value2 张';
  }

  @override
  String purchaseLimitPolicy_83(Object value, Object remaining) {
    return '每人限购 $value 张，您还可购买 $remaining 张';
  }

  @override
  String get orderQuote_107 => '商品总额';

  @override
  String get orderQuote_108 => '运费';

  @override
  String get orderQuote_109 => '拆单费';

  @override
  String get orderQuote_111 => '优惠';

  @override
  String get orderQuote_113 => '礼品卡';

  @override
  String get orderQuote_114 => '加速包';

  @override
  String get delivery_78 => '电子票';

  @override
  String get delivery_81 => '快递配送';

  @override
  String get delivery_84 => '现场自取';

  @override
  String delivery_136(Object method, Object postage) {
    return '$method（$postage）';
  }

  @override
  String discount_71(Object percent, Object format) {
    return '-$percent%（封顶 $format）';
  }

  @override
  String get discount_122 => '不使用优惠';

  @override
  String discount_139(Object describe) {
    return '营销活动 $describe';
  }

  @override
  String discount_156(Object describe) {
    return '优惠券 $describe';
  }

  @override
  String get orderStatus_24 => '待提交';

  @override
  String get orderStatus_40 => '已关闭';

  @override
  String get orderStatus_43 => '已退款';

  @override
  String orderStatus_85(Object code) {
    return '未知订单状态编码：$code';
  }

  @override
  String get orderType_10 => '普通票';

  @override
  String get orderType_13 => '拼团';

  @override
  String get orderType_16 => '抢票';

  @override
  String get orderType_19 => '会员充值';

  @override
  String get orderType_22 => '加速包';

  @override
  String orderType_36(Object code) {
    return '未知下单类型：$code';
  }

  @override
  String get orderType_49 => '普通购票';

  @override
  String get orderType_49_2 => '《票务服务协议》';

  @override
  String get orderType_52 => '代购';

  @override
  String get orderType_52_2 => '《代购服务协议》';

  @override
  String orderType_69(Object code) {
    return '未知购买方式：$code';
  }

  @override
  String get paymentChannel_10 => '微信支付';

  @override
  String get paymentChannel_13 => '支付宝';

  @override
  String get paymentChannel_16 => '银行卡';

  @override
  String get paymentChannel_19 => '信用付';

  @override
  String get paymentChannel_22 => '余额支付';

  @override
  String paymentChannel_36(Object code) {
    return '未知支付渠道：$code';
  }

  @override
  String speedPack_61(Object units, Object format, Object format2) {
    return '加速包 $units 份（现金 $format / 余额 $format2）';
  }

  @override
  String speedPack_85(Object value, Object format) {
    return '礼品卡 $value（余额 $format）';
  }

  @override
  String get visitor_7 => '身份证';

  @override
  String get visitor_8 => '护照';

  @override
  String get visitor_9 => '港澳通行证';

  @override
  String get visitor_10 => '台湾通行证';

  @override
  String get visitor_11 => '港澳台居住证';

  @override
  String get orderConfirmPage_48 => '确认订单';

  @override
  String get orderConfirmPage_59 => '选择票档';

  @override
  String get orderConfirmPage_73 => '优惠';

  @override
  String get orderConfirmPage_79 => '不使用优惠';

  @override
  String get orderConfirmPage_99 => '其他抵扣';

  @override
  String get orderConfirmPage_107 => '礼品卡（本单不可用）';

  @override
  String orderConfirmPage_109(Object format) {
    return '礼品卡（余额 $format）';
  }

  @override
  String get orderConfirmPage_123 => '加速包（本场不提供）';

  @override
  String orderConfirmPage_125(Object format) {
    return '加速包（$format/张）';
  }

  @override
  String get orderConfirmPage_138 => '实名观演人';

  @override
  String orderConfirmPage_143(Object requiredVisitorCount) {
    return '选择观演人（需 $requiredVisitorCount 位）';
  }

  @override
  String orderConfirmPage_145(Object length) {
    return '已选 $length 位';
  }

  @override
  String get orderConfirmPage_150 => '本场次需实名观演人，未选择将无法提交';

  @override
  String get orderConfirmPage_167 => '费用明细';

  @override
  String get orderConfirmPage_173 => '订单原价';

  @override
  String get orderConfirmPage_175 => '应付';

  @override
  String orderConfirmPage_190(Object agreementTitle) {
    return '我已阅读并同意$agreementTitle';
  }

  @override
  String orderConfirmPage_196(Object join) {
    return '领域事件：$join';
  }

  @override
  String orderConfirmPage_243(Object sessionLabel, Object value) {
    return '$sessionLabel · 演出 $value';
  }

  @override
  String get orderConfirmPage_444 => '应付';

  @override
  String get orderConfirmPage_457 => '已提交';

  @override
  String get orderConfirmPage_460 => '提交中…';

  @override
  String get orderConfirmPage_462 => '提交订单';

  @override
  String get orderDetailPage_52 => '订单详情';

  @override
  String get orderDetailPage_56 => '订单加载失败';

  @override
  String get orderDetailPage_65 => '订单不存在';

  @override
  String get orderDetailPage_66 => '订单可能已被删除，或链接已过期';

  @override
  String get orderDetailPage_68 => '返回订单列表';

  @override
  String get orderDetailPage_101 => '票档';

  @override
  String orderDetailPage_105(Object value, Object format) {
    return '$value 张 · $format';
  }

  @override
  String get orderDetailPage_108 => '取票方式';

  @override
  String get orderDetailPage_113 => '观演人';

  @override
  String get orderDetailPage_125 => '金额明细';

  @override
  String get orderDetailPage_133 => '实付';

  @override
  String get orderDetailPage_139 => '订单信息';

  @override
  String get orderDetailPage_141 => '订单号';

  @override
  String get orderDetailPage_150 => '订单号已复制';

  @override
  String get orderDetailPage_163 => '下单时间';

  @override
  String get orderDetailPage_165 => '支付时间';

  @override
  String get orderDetailPage_167 => '关闭原因';

  @override
  String get orderDetailPage_199 => '订单尚未提交';

  @override
  String orderDetailPage_201(Object _deadline) {
    return '请在 $_deadline 前完成支付，超时订单将自动关闭';
  }

  @override
  String get orderDetailPage_204 => '已支付，正在为你出票';

  @override
  String get orderDetailPage_205 => '门票已寄出，请注意查收';

  @override
  String get orderDetailPage_206 => '订单已完成，欢迎发表观演评价';

  @override
  String get orderDetailPage_207 => '订单已关闭，可重新选购';

  @override
  String get orderDetailPage_208 => '退款已原路退回';

  @override
  String get orderDetailPage_325 => '取消订单';

  @override
  String get orderDetailPage_329 => '立即支付';

  @override
  String get orderDetailPage_335 => '查看物流';

  @override
  String get orderDetailPage_335_2 => '物流详情待接入快递查询接口';

  @override
  String get orderDetailPage_337 => '确认收货';

  @override
  String get orderDetailPage_342 => '申请退款';

  @override
  String get orderDetailPage_351 => '去评价';

  @override
  String get orderDetailPage_351_2 => '评价属于独立的评价聚合，本示例未实现';

  @override
  String get orderDetailPage_353 => '再次购买';

  @override
  String get orderDetailPage_360 => '继续填写';

  @override
  String get orderDetailPage_366 => '联系客服';

  @override
  String get orderDetailPage_366_2 => '客服会话（演示）';

  @override
  String get orderDetailPage_367 => '查看票夹';

  @override
  String get orderDetailPage_367_2 => '电子票面待接入出票接口';

  @override
  String get orderDetailPage_369 => '申请退款';

  @override
  String get orderDetailPage_379 => '重新选购';

  @override
  String get orderDetailPage_437 => '支付成功，等待出票';

  @override
  String get orderDetailPage_444 => '取消订单';

  @override
  String get orderDetailPage_445 => '取消后需要重新下单，确定继续吗？';

  @override
  String get orderDetailPage_449 => '再想想';

  @override
  String get orderDetailPage_453 => '取消订单';

  @override
  String get orderDetailPage_459 => '用户主动取消';

  @override
  String get orderDetailPage_461 => '订单已取消';

  @override
  String get orderDetailPage_470 => '已确认收货';

  @override
  String get orderListPage_71 => '订单加载失败';

  @override
  String get orderListPage_85 => '还没有订单';

  @override
  String orderListPage_87(Object label) {
    return '没有$label的订单';
  }

  @override
  String get orderListPage_88 => '去首页挑一场演出吧';

  @override
  String get orderListPage_90 => '去逛逛';

  @override
  String get orderListPage_115 => '评价属于独立的评价聚合，本示例未实现';

  @override
  String get orderListPage_119 => '客服会话（演示）';

  @override
  String get orderListPage_130 => '暂无商品订单';

  @override
  String get orderListPage_131 => '本项目只迁移了演出票链路，周边商品未包含';

  @override
  String get orderListPage_181 => '取消订单';

  @override
  String get orderListPage_182 => '取消后需要重新下单，确定继续吗？';

  @override
  String get orderListPage_186 => '再想想';

  @override
  String get orderListPage_190 => '取消订单';

  @override
  String get orderListPage_196 => '用户主动取消';

  @override
  String get orderCancelTimeout => '支付超时，订单已关闭';

  @override
  String get orderListPage_198 => '订单已取消';

  @override
  String get orderListPage_208 => '已确认收货';

  @override
  String get orderListPage_229 => '演出';

  @override
  String get orderListPage_229_2 => '商品';

  @override
  String get paySuccessPage_75 => '支付成功';

  @override
  String get paySuccessPage_84 => '企划星正在为您出票，请耐心等待';

  @override
  String get paySuccessPage_115 => '查看订单';

  @override
  String get paySuccessPage_138 => '继续逛逛';

  @override
  String get paySuccessPage_182 => '演出';

  @override
  String get paySuccessPage_189 => '订单号';

  @override
  String get paySuccessPage_198 => '支付金额';

  @override
  String get payInfo_40 => '推荐';

  @override
  String get payInfo_55 => '余额 ¥0.00';

  @override
  String get payInfo_60 => '演出';

  @override
  String get payInfo_61 => '订单号';

  @override
  String get payPage_77 => '收银台';

  @override
  String get payPage_133 => '演示环境：支付不会真实扣款，点击确认后模拟支付流程';

  @override
  String get payPage_166 => '支付已取消';

  @override
  String payPage_195(Object seconds) {
    return '请在 $seconds 内完成支付';
  }

  @override
  String get payPage_259 => '应付金额';

  @override
  String get payPage_301 => '选择支付方式';

  @override
  String get payPage_436 => '请求中…';

  @override
  String get payPage_438 => '支付中…';

  @override
  String payPage_440(Object format) {
    return '确认支付 $format';
  }

  @override
  String get payProviders_115 => '当前状态不可支付';

  @override
  String get payProviders_172 => '支付超时，订单已自动取消';

  @override
  String get refundPage_43 => '退款申请已提交，请等待审核';

  @override
  String get refundPage_62 => '申请退款';

  @override
  String get refundPage_97 => '提交中…';

  @override
  String get refundPage_98 => '已提交';

  @override
  String get refundPage_99 => '提交退款申请';

  @override
  String get refundPage_138 => '退款金额';

  @override
  String get refundPage_150 => '订单金额';

  @override
  String get refundPage_164 => '预计退款';

  @override
  String get refundPage_207 => '退款原因';

  @override
  String get refundPage_244 => '请输入退款原因（选填）';

  @override
  String get refundPage_331 => '退款说明';

  @override
  String get refundPage_342 => '• 待发货状态下可全额退款\n• 待收货状态下退票款金额的 80%\n• 已完成订单不支持退款\n• 退款将原路退回至支付账户\n• 退款审核一般需要 1-3 个工作日';

  @override
  String get refundPage_382 => '退款申请已提交';

  @override
  String refundPage_391(Object format) {
    return '退款金额 $format 将在审核通过后原路退回';
  }

  @override
  String get refundPage_404 => '返回订单列表';

  @override
  String get refundState_8 => '不需要了';

  @override
  String get refundState_8_2 => '计划变更，暂时不需要了';

  @override
  String get refundState_11 => '买错了';

  @override
  String get refundState_11_2 => '买错了场次或票档';

  @override
  String get refundState_14 => '票价太贵';

  @override
  String get refundState_14_2 => '价格超出预算';

  @override
  String get refundState_17 => '找到更好的票源';

  @override
  String get refundState_17_2 => '通过其他渠道购买了';

  @override
  String get refundState_20 => '其他原因';

  @override
  String get refundState_20_2 => '自定义说明';

  @override
  String orderListCard_52(Object value) {
    return '演出 $value';
  }

  @override
  String get orderListCard_53 => '场次待确认';

  @override
  String get orderListCard_78 => '代购';

  @override
  String orderListCard_130(Object join) {
    return '观演人 $join';
  }

  @override
  String orderListCard_141(Object value) {
    return '订单号 $value';
  }

  @override
  String orderListCard_184(Object value) {
    return '共 $value 张  实付';
  }

  @override
  String get orderListCard_217 => '取消订单';

  @override
  String get orderListCard_220 => '去支付';

  @override
  String get orderListCard_225 => '联系客服';

  @override
  String get orderListCard_228 => '申请退款';

  @override
  String get orderListCard_233 => '查看物流';

  @override
  String get orderListCard_236 => '确认收货';

  @override
  String get orderListCard_241 => '再次购买';

  @override
  String get orderListCard_244 => '去评价';

  @override
  String get orderListCard_250 => '再次购买';

  @override
  String get orderListCard_298 => '支付已超时，请重新下单';

  @override
  String orderListCard_305(Object minutes, Object seconds) {
    return '剩余支付时间 $minutes:$seconds';
  }

  @override
  String get paymentChannelSheet_52 => '选择支付方式';
}
