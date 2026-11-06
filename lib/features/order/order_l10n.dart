import 'package:flutter/widgets.dart';

import '../../l10n/l10n.dart';
import 'application/order_confirm_controller.dart';
import 'application/order_list_controller.dart';
import 'domain/domain.dart';
import 'payment/pay_info.dart';
import 'refund/refund_state.dart';

/// 订单展示文案的本地化映射。
extension OrderStatusL10n on OrderStatus {
  String labelOf(BuildContext context) => switch (this) {
    OrderStatus.draft => context.l10n.orderStatus_24,
    OrderStatus.awaitingPayment => context.l10n.orderStatusPending,
    OrderStatus.awaitingTickets => context.l10n.orderStatusPaid,
    OrderStatus.ticketsInTransit => context.l10n.orderStatusShipped,
    OrderStatus.completed => context.l10n.orderStatusFinished,
    OrderStatus.cancelled => context.l10n.orderStatus_40,
    OrderStatus.refunded => context.l10n.orderStatus_43,
  };
}

extension OrderCancelReasonL10n on OrderCancelReason {
  String labelOf(BuildContext context) => switch (this) {
    OrderCancelReason.userCancelled => context.l10n.orderListPage_196,
    OrderCancelReason.timeout => context.l10n.orderCancelTimeout,
  };
}

extension OrderTypeL10n on OrderType {
  String labelOf(BuildContext context) => switch (this) {
    OrderType.ticket => context.l10n.orderType_10,
    OrderType.pinTuan => context.l10n.orderType_13,
    OrderType.grabTicket => context.l10n.orderType_16,
    OrderType.plusMember => context.l10n.orderType_19,
    OrderType.speedPack => context.l10n.orderType_22,
  };
}

extension BuyTypeL10n on BuyType {
  String labelOf(BuildContext context) => switch (this) {
    BuyType.normal => context.l10n.orderType_49,
    BuyType.proxy => context.l10n.orderType_52,
  };

  /// 需要用户勾选的协议名（书名号由文案自带）。
  String agreementTitleOf(BuildContext context) => switch (this) {
    BuyType.normal => context.l10n.orderType_49_2,
    BuyType.proxy => context.l10n.orderType_52_2,
  };
}

extension IdCardTypeL10n on IdCardType {
  String labelOf(BuildContext context) => switch (this) {
    IdCardType.idCard => context.l10n.visitor_7,
    IdCardType.passport => context.l10n.visitor_8,
    IdCardType.hongKongPass => context.l10n.visitor_9,
    IdCardType.taiwanPass => context.l10n.visitor_10,
    IdCardType.hmtResidencePermit => context.l10n.visitor_11,
  };
}

extension DeliveryMethodL10n on DeliveryMethod {
  String labelOf(BuildContext context) => switch (this) {
    DeliveryMethod.electronic => context.l10n.delivery_78,
    DeliveryMethod.express => context.l10n.delivery_81,
    DeliveryMethod.selfPickup => context.l10n.delivery_84,
  };
}

extension DeliveryInfoL10n on DeliveryInfo {
  /// 展示文案：`快递配送（¥12.00）`。
  String describeOf(BuildContext context) => postage.isZero
      ? method.labelOf(context)
      : context.l10n.delivery_136(method.labelOf(context), postage.format());
}

extension PaymentChannelL10n on PaymentChannel {
  String labelOf(BuildContext context) => switch (this) {
    PaymentChannel.wechat => context.l10n.paymentChannel_10,
    PaymentChannel.alipay => context.l10n.paymentChannel_13,
    PaymentChannel.unionPay => context.l10n.paymentChannel_16,
    PaymentChannel.creditPay => context.l10n.paymentChannel_19,
    PaymentChannel.balance => context.l10n.paymentChannel_22,
  };
}

extension DiscountL10n on Discount {
  /// 抵扣文案：`-¥30` / `-15%` / `-15%（封顶 ¥50）`。
  String describeOf(BuildContext context) => switch (this) {
    AmountDiscount(:final amount) => '-${amount.format()}',
    RateDiscount(:final basisPoints, :final cap) => () {
      final percent = (basisPoints / 100).toStringAsFixed(
        basisPoints % 100 == 0 ? 0 : 2,
      );
      return cap == null
          ? '-$percent%'
          : context.l10n.discount_71(percent, cap.format());
    }(),
  };
}

extension DiscountSelectionL10n on DiscountSelection {
  String describeOf(BuildContext context) => switch (this) {
    NoDiscount() => context.l10n.discount_122,
    CampaignSelection(:final discount) => context.l10n.discount_139(
      discount.describeOf(context),
    ),
    CouponSelection(:final discount) => context.l10n.discount_156(
      discount.describeOf(context),
    ),
  };
}

extension QuoteLineL10n on QuoteLine {
  String labelOf(BuildContext context) => switch (kind) {
    QuoteLineKind.goodsTotal => context.l10n.orderQuote_107,
    QuoteLineKind.postage => context.l10n.orderQuote_108,
    QuoteLineKind.splitFee => context.l10n.orderQuote_109,
    QuoteLineKind.discount => context.l10n.orderQuote_111,
    QuoteLineKind.giftCard => context.l10n.orderQuote_113,
    QuoteLineKind.speedPack => context.l10n.orderQuote_114,
  };
}

extension RefundReasonL10n on RefundReason {
  String labelOf(BuildContext context) => switch (this) {
    RefundReason.notNeeded => context.l10n.refundState_8,
    RefundReason.boughtWrong => context.l10n.refundState_11,
    RefundReason.tooExpensive => context.l10n.refundState_14,
    RefundReason.foundBetter => context.l10n.refundState_17,
    RefundReason.other => context.l10n.refundState_20,
  };

  String descriptionOf(BuildContext context) => switch (this) {
    RefundReason.notNeeded => context.l10n.refundState_8_2,
    RefundReason.boughtWrong => context.l10n.refundState_11_2,
    RefundReason.tooExpensive => context.l10n.refundState_14_2,
    RefundReason.foundBetter => context.l10n.refundState_17_2,
    RefundReason.other => context.l10n.refundState_20_2,
  };
}

extension RefundStateL10n on RefundState {
  /// 原因文案：自定义原因优先。
  String reasonTextOf(BuildContext context) {
    if (reason == RefundReason.other && customReason.isNotEmpty) {
      return customReason;
    }
    return reason.labelOf(context);
  }
}

extension OrderListFilterL10n on OrderListFilter {
  String labelOf(BuildContext context) => switch (this) {
    OrderListFilter.all => context.l10n.orderListController_27,
    OrderListFilter.awaitingPayment => context.l10n.orderStatusPending,
    OrderListFilter.awaitingTickets => context.l10n.orderStatusPaid,
    OrderListFilter.ticketsInTransit => context.l10n.orderStatusShipped,
    OrderListFilter.awaitingReview => context.l10n.orderListController_31,
  };
}

extension PayChannelOptionL10n on PayChannelOption {
  /// 渠道下方的提示文案；无提示返回 `null`。
  String? tipOf(BuildContext context) => switch (tip) {
    PayChannelTip.none => null,
    PayChannelTip.recommended => context.l10n.payInfo_40,
    PayChannelTip.balance => context.l10n.payInfo_55,
  };
}

extension PayDetailLineL10n on PayDetailLine {
  String labelOf(BuildContext context) => switch (kind) {
    PayDetailKind.show => context.l10n.payInfo_60,
    PayDetailKind.orderNumber => context.l10n.payInfo_61,
  };
}

extension OrderNoticeL10n on OrderNotice {
  String messageOf(BuildContext context) {
    final detail = this.detail;
    return switch (code) {
      OrderNoticeCode.ticketTierMissing =>
        context.l10n.orderConfirmController_117,
      OrderNoticeCode.noCampaign => context.l10n.orderConfirmController_145,
      OrderNoticeCode.noCoupon => context.l10n.orderConfirmController_156,
      OrderNoticeCode.noGiftCard => context.l10n.orderConfirmController_169,
      OrderNoticeCode.noSpeedPack => context.l10n.orderConfirmController_183,
      OrderNoticeCode.failure => detail ?? '',
      OrderNoticeCode.saveFailed => context.l10n.orderConfirmController_246(
        detail ?? '',
      ),
      OrderNoticeCode.submitted => context.l10n.orderConfirmController_257(
        detail ?? '',
      ),
    };
  }
}
