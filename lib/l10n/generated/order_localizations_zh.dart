// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'order_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class OrderLocalizationsZh extends OrderLocalizations {
  OrderLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get orderListTitle => '我的支持';

  @override
  String get orderListPlaceholder => '支持列表（需登录）';

  @override
  String get orderGoConfirm => '去确认支持';

  @override
  String get orderStatusPending => '待支付';

  @override
  String get orderStatusPaid => '众筹中';

  @override
  String get orderStatusShipped => '交付中';

  @override
  String get orderStatusFinished => '已完成';

  @override
  String get orderStatusRefund => '已退款';

  @override
  String get orderConfirmController_117 => '回报档位不存在';

  @override
  String get orderConfirmController_145 => '本单没有可用营销活动';

  @override
  String get orderConfirmController_156 => '本单没有可用优惠券';

  @override
  String get orderConfirmController_169 => '本单没有可用礼品卡';

  @override
  String get orderConfirmController_183 => '本企划不提供加急服务';

  @override
  String get orderConfirmController_220 => '张支持人';

  @override
  String orderConfirmController_246(Object message) {
    return '提交失败：$message';
  }

  @override
  String orderConfirmController_257(Object value) {
    return '支持已提交：$value';
  }

  @override
  String get orderListController_27 => '全部';

  @override
  String get orderListController_31 => '待评价';

  @override
  String get ticketOrder_81 => '实名支持人数量不能为负';

  @override
  String get ticketOrder_84 => '支付时限必须为正';

  @override
  String get ticketOrder_222 => '回报档位价格已变化，请重新确认支持';

  @override
  String ticketOrder_238(Object value) {
    return '回报档位不存在：$value';
  }

  @override
  String ticketOrder_263(Object value) {
    return '回报档位不存在：$value';
  }

  @override
  String ticketOrder_296(Object units, Object value) {
    return '加急服务份数（$units）不能超过支持份数（$value）';
  }

  @override
  String get ticketOrder_329 => '同一支持人不能重复选择';

  @override
  String get ticketOrder_332 => '本企划无需实名支持人';

  @override
  String ticketOrder_337(Object requiredVisitorCount, Object length) {
    return '本单需选择 $requiredVisitorCount 位支持人，已选 $length 位';
  }

  @override
  String get ticketOrder_373 => '请先选择回报档位';

  @override
  String get ticketOrder_376 => '报价与当前支持内容不一致，请重新计算';

  @override
  String get ticketOrder_391 => '请先选择回报档位';

  @override
  String ticketOrder_396(Object agreementTitle) {
    return '请阅读并勾选$agreementTitle';
  }

  @override
  String get ticketOrder_402 => '支持金额尚未计算';

  @override
  String get ticketOrder_405 => '支持内容已变化，请重新确认金额';

  @override
  String ticketOrder_410(Object requiredVisitorCount) {
    return '请选择 $requiredVisitorCount 位支持人';
  }

  @override
  String ticketOrder_440(Object label) {
    return '当前状态（$label）不可支付';
  }

  @override
  String get ticketOrder_444 => '支持金额缺失，无法确认支付结果';

  @override
  String get ticketOrder_486 => '关闭原因不能为空';

  @override
  String get ticketOrder_510 => '未支付的支持不能退款';

  @override
  String get ticketOrder_534 => '支付超时，支持已取消';

  @override
  String get ticketOrder_553 => '支持已提交，不能再修改';

  @override
  String ticketOrder_559(Object label, Object label2) {
    return '支持状态不允许从「$label」变为「$label2」';
  }

  @override
  String get orderLifecycleEvents_22 => '超时';

  @override
  String orderLifecycleEvents_48(Object value, Object trackingNumber) {
    return 'order.shipped($value, $trackingNumber)';
  }

  @override
  String orderPlaced_42(Object value, Object format) {
    return 'order.placed($value, 支持金额 $format)';
  }

  @override
  String get purchaseLimitPolicy_30 => '不限支持';

  @override
  String purchaseLimitPolicy_32(Object value) {
    return '每单限 $value 份';
  }

  @override
  String purchaseLimitPolicy_33(Object value) {
    return '每人限 $value 份';
  }

  @override
  String purchaseLimitPolicy_57(Object value) {
    return '每单最多支持 $value 份';
  }

  @override
  String purchaseLimitPolicy_81(Object value, Object value2) {
    return '每人限购 $value 份，您已支持 $value2 份';
  }

  @override
  String purchaseLimitPolicy_83(Object value, Object remaining) {
    return '每人限购 $value 份，您还可支持 $remaining 份';
  }

  @override
  String get orderQuote_107 => '支持总额';

  @override
  String get orderQuote_108 => '运费';

  @override
  String get orderQuote_109 => '拆单费';

  @override
  String get orderQuote_111 => '优惠';

  @override
  String get orderQuote_113 => '礼品卡';

  @override
  String get orderQuote_114 => '加急服务';

  @override
  String get delivery_78 => '电子回报凭证';

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
  String get orderStatus_40 => '已取消';

  @override
  String get orderStatus_43 => '已退款';

  @override
  String orderStatus_85(Object code) {
    return '未知支持状态编码：$code';
  }

  @override
  String get orderType_10 => '普通支持';

  @override
  String get orderType_13 => '拼团';

  @override
  String get orderType_16 => '限时支持';

  @override
  String get orderType_19 => '会员充值';

  @override
  String get orderType_22 => '加急服务';

  @override
  String orderType_36(Object code) {
    return '未知支持类型：$code';
  }

  @override
  String get orderType_49 => '普通支持';

  @override
  String get orderType_49_2 => '《支持服务协议》';

  @override
  String get orderType_52 => '代支持';

  @override
  String get orderType_52_2 => '《代支持服务协议》';

  @override
  String orderType_69(Object code) {
    return '未知支持方式：$code';
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
    return '加急服务 $units 份（现金 $format / 余额 $format2）';
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
  String get orderConfirmPage_48 => '确认支持';

  @override
  String get orderConfirmPage_59 => '选择回报档位';

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
  String get orderConfirmPage_123 => '加急服务（本企划不提供）';

  @override
  String orderConfirmPage_125(Object format) {
    return '加急服务（$format/份）';
  }

  @override
  String get orderConfirmPage_138 => '实名支持人';

  @override
  String orderConfirmPage_143(Object requiredVisitorCount) {
    return '选择支持人（需 $requiredVisitorCount 位）';
  }

  @override
  String orderConfirmPage_145(Object length) {
    return '已选 $length 位';
  }

  @override
  String get orderConfirmPage_150 => '本企划需实名支持人，未选择将无法提交';

  @override
  String get orderConfirmPage_167 => '费用明细';

  @override
  String get orderConfirmPage_173 => '支持原价';

  @override
  String get orderConfirmPage_175 => '应付金额';

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
    return '$sessionLabel · 企划 $value';
  }

  @override
  String get orderConfirmPage_444 => '应付';

  @override
  String get orderConfirmPage_457 => '已确认';

  @override
  String get orderConfirmPage_460 => '确认中…';

  @override
  String get orderConfirmPage_462 => '确认支持';

  @override
  String get orderDetailPage_52 => '支持详情';

  @override
  String get orderDetailPage_56 => '支持记录加载失败';

  @override
  String get orderDetailPage_65 => '支持记录不存在';

  @override
  String get orderDetailPage_66 => '支持记录可能已被删除，或链接已过期';

  @override
  String get orderDetailPage_68 => '返回支持列表';

  @override
  String get orderDetailPage_101 => '回报档位';

  @override
  String orderDetailPage_105(Object value, Object format) {
    return '$value 份 · $format';
  }

  @override
  String get orderDetailPage_108 => '交付方式';

  @override
  String get orderDetailPage_113 => '支持人';

  @override
  String get orderDetailPage_125 => '金额明细';

  @override
  String get orderDetailPage_133 => '支持金额';

  @override
  String get orderDetailPage_139 => '支持信息';

  @override
  String get orderDetailPage_141 => '支持编号';

  @override
  String get orderDetailPage_150 => '支持编号已复制';

  @override
  String get orderDetailPage_163 => '支持时间';

  @override
  String get orderDetailPage_165 => '支付时间';

  @override
  String get orderDetailPage_167 => '关闭原因';

  @override
  String get orderDetailPage_199 => '支持尚未提交';

  @override
  String orderDetailPage_201(Object _deadline) {
    return '请在 $_deadline 前完成支付，超时支持将自动关闭';
  }

  @override
  String get orderDetailPage_204 => '已支付，正在为你确认回报';

  @override
  String get orderDetailPage_205 => '回报已寄出，请注意查收';

  @override
  String get orderDetailPage_206 => '支持已完成，欢迎发表支持评价';

  @override
  String get orderDetailPage_207 => '支持已取消，可重新选择企划';

  @override
  String get orderDetailPage_208 => '退款已原路退回';

  @override
  String get orderDetailPage_325 => '取消支持';

  @override
  String get orderDetailPage_329 => '立即支付';

  @override
  String get orderDetailPage_335 => '查看物流';

  @override
  String get orderDetailPage_335_2 => '物流详情待接入快递查询接口';

  @override
  String get orderDetailPage_337 => '确认收到回报';

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
  String get orderDetailPage_367 => '查看回报凭证';

  @override
  String get orderDetailPage_367_2 => '电子回报凭证面待接入交付接口';

  @override
  String get orderDetailPage_369 => '申请退款';

  @override
  String get orderDetailPage_379 => '重新选择企划';

  @override
  String get orderDetailPage_437 => '支付成功，等待交付';

  @override
  String get orderDetailPage_444 => '取消支持';

  @override
  String get orderDetailPage_445 => '取消后需要重新支持，确定继续吗？';

  @override
  String get orderDetailPage_449 => '再想想';

  @override
  String get orderDetailPage_453 => '取消支持';

  @override
  String get orderDetailPage_459 => '用户主动取消';

  @override
  String get orderDetailPage_461 => '支持已取消';

  @override
  String get orderDetailPage_470 => '已确认收到回报';

  @override
  String get orderListPage_71 => '支持记录加载失败';

  @override
  String get orderListPage_85 => '还没有支持记录';

  @override
  String orderListPage_87(Object label) {
    return '没有$label的支持记录';
  }

  @override
  String get orderListPage_88 => '去首页挑一个企划吧';

  @override
  String get orderListPage_90 => '去逛逛';

  @override
  String get orderListPage_115 => '评价属于独立的评价聚合，本示例未实现';

  @override
  String get orderListPage_119 => '客服会话（演示）';

  @override
  String get orderListPage_130 => '暂无商品订单';

  @override
  String get orderListPage_131 => '企划支持链路之外的周边商品暂未接入';

  @override
  String get orderListPage_181 => '取消支持';

  @override
  String get orderListPage_182 => '取消后需要重新支持，确定继续吗？';

  @override
  String get orderListPage_186 => '再想想';

  @override
  String get orderListPage_190 => '取消支持';

  @override
  String get orderListPage_196 => '用户主动取消';

  @override
  String get orderCancelTimeout => '支付超时，支持已取消';

  @override
  String get orderListPage_198 => '支持已取消';

  @override
  String get orderListPage_208 => '已确认收到回报';

  @override
  String get orderListPage_229 => '企划';

  @override
  String get orderListPage_229_2 => '商品';

  @override
  String get paySuccessPage_75 => '支付成功';

  @override
  String get paySuccessPage_84 => '企划星正在为您确认回报，请耐心等待';

  @override
  String get paySuccessPage_115 => '查看支持记录';

  @override
  String get paySuccessPage_138 => '继续逛逛';

  @override
  String get paySuccessPage_182 => '企划';

  @override
  String get paySuccessPage_189 => '支持编号';

  @override
  String get paySuccessPage_198 => '支付金额';

  @override
  String get payInfo_40 => '推荐';

  @override
  String get payInfo_55 => '余额 ¥0.00';

  @override
  String get payInfo_60 => '企划';

  @override
  String get payInfo_61 => '支持编号';

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
  String get payProviders_172 => '支付超时，支持已自动取消';

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
  String get refundPage_150 => '支持金额';

  @override
  String get refundPage_164 => '预计退款';

  @override
  String get refundPage_207 => '退款原因';

  @override
  String get refundPage_244 => '请输入退款原因（选填）';

  @override
  String get refundPage_331 => '退款说明';

  @override
  String get refundPage_342 => '• 众筹中可全额退款\n• 交付中退还支持金额的 80%\n• 已完成支持不支持退款\n• 退款将原路退回至支付账户\n• 退款审核一般需要 1-3 个工作日';

  @override
  String get refundPage_382 => '退款申请已提交';

  @override
  String refundPage_391(Object format) {
    return '退款金额 $format 将在审核通过后原路退回';
  }

  @override
  String get refundPage_404 => '返回支持列表';

  @override
  String get refundState_8 => '不需要了';

  @override
  String get refundState_8_2 => '计划变更，暂时不需要了';

  @override
  String get refundState_11 => '买错了';

  @override
  String get refundState_11_2 => '买错了线下回报场次或回报档位';

  @override
  String get refundState_14 => '支持金额太高';

  @override
  String get refundState_14_2 => '价格超出预算';

  @override
  String get refundState_17 => '找到更好的企划';

  @override
  String get refundState_17_2 => '通过其他渠道购买了';

  @override
  String get refundState_20 => '其他原因';

  @override
  String get refundState_20_2 => '自定义说明';

  @override
  String orderListCard_52(Object value) {
    return '企划 $value';
  }

  @override
  String get orderListCard_53 => '回报信息待确认';

  @override
  String orderListCard_delivery(Object value) {
    return '交付：$value';
  }

  @override
  String get orderListCard_78 => '代支持';

  @override
  String orderListCard_130(Object join) {
    return '支持人 $join';
  }

  @override
  String orderListCard_141(Object value) {
    return '支持编号 $value';
  }

  @override
  String orderListCard_184(Object value) {
    return '共 $value 份  支持金额';
  }

  @override
  String get orderListCard_217 => '取消支持';

  @override
  String get orderListCard_220 => '去支付';

  @override
  String get orderListCard_225 => '联系客服';

  @override
  String get orderListCard_228 => '申请退款';

  @override
  String get orderListCard_233 => '查看物流';

  @override
  String get orderListCard_236 => '确认收到回报';

  @override
  String get orderListCard_241 => '再次购买';

  @override
  String get orderListCard_244 => '去评价';

  @override
  String get orderListCard_250 => '再次购买';

  @override
  String get orderListCard_298 => '支付已超时，请重新支持';

  @override
  String orderListCard_305(Object minutes, Object seconds) {
    return '剩余支付时间 $minutes:$seconds';
  }

  @override
  String get paymentChannelSheet_52 => '选择支付方式';

  @override
  String get orderDetailPage_expectedDelivery => '预计交付时间';

  @override
  String get orderConfirmPage_seatsTitle => '已选座席';

  @override
  String get orderConfirmPage_seatsSubtotal => '座席小计';
}
