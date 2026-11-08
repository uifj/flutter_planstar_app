// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'order_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class OrderLocalizationsEn extends OrderLocalizations {
  OrderLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get orderListTitle => 'My supports';

  @override
  String get orderListPlaceholder => 'Support history (sign-in required)';

  @override
  String get orderGoConfirm => 'Review support';

  @override
  String get orderStatusPending => 'Awaiting payment';

  @override
  String get orderStatusPaid => 'Crowdfunding';

  @override
  String get orderStatusShipped => 'Delivering';

  @override
  String get orderStatusFinished => 'Completed';

  @override
  String get orderStatusRefund => 'Refunded';

  @override
  String get orderConfirmController_117 => 'Reward tier does not exist';

  @override
  String get orderConfirmController_145 => 'No promotions available for this order';

  @override
  String get orderConfirmController_156 => 'No coupons available for this order';

  @override
  String get orderConfirmController_169 => 'No gift cards available for this order';

  @override
  String get orderConfirmController_183 => 'This project does not offer express service';

  @override
  String get orderConfirmController_220 => 'supporter(s)';

  @override
  String orderConfirmController_246(Object message) {
    return 'Submission failed: $message';
  }

  @override
  String orderConfirmController_257(Object value) {
    return 'Support submitted: $value';
  }

  @override
  String get orderListController_27 => 'All';

  @override
  String get orderListController_31 => 'To review';

  @override
  String get ticketOrder_81 => 'The number of real-name supporters cannot be negative';

  @override
  String get ticketOrder_84 => 'The payment deadline must be positive';

  @override
  String get ticketOrder_222 => 'The reward tier price has changed. Please re-confirm your support';

  @override
  String ticketOrder_238(Object value) {
    return 'Reward tier does not exist: $value';
  }

  @override
  String ticketOrder_263(Object value) {
    return 'Reward tier does not exist: $value';
  }

  @override
  String ticketOrder_296(Object units, Object value) {
    return 'Express service units ($units) cannot exceed support units ($value)';
  }

  @override
  String get ticketOrder_329 => 'The same supporter cannot be selected more than once';

  @override
  String get ticketOrder_332 => 'This project does not require real-name supporters';

  @override
  String ticketOrder_337(Object requiredVisitorCount, Object length) {
    return 'This order requires $requiredVisitorCount supporters, $length selected';
  }

  @override
  String get ticketOrder_373 => 'Please select a reward tier first';

  @override
  String get ticketOrder_376 => 'The quote does not match the current support details. Please recalculate';

  @override
  String get ticketOrder_391 => 'Please select a reward tier first';

  @override
  String ticketOrder_396(Object agreementTitle) {
    return 'Please read and check $agreementTitle';
  }

  @override
  String get ticketOrder_402 => 'The support amount has not been calculated yet';

  @override
  String get ticketOrder_405 => 'Support details have changed. Please re-confirm the amount';

  @override
  String ticketOrder_410(Object requiredVisitorCount) {
    return 'Please select $requiredVisitorCount supporter(s)';
  }

  @override
  String ticketOrder_440(Object label) {
    return 'Cannot pay in the current status ($label)';
  }

  @override
  String get ticketOrder_444 => 'Support amount is missing; cannot confirm the payment result';

  @override
  String get ticketOrder_486 => 'Close reason cannot be empty';

  @override
  String get ticketOrder_510 => 'Unpaid support cannot be refunded';

  @override
  String get ticketOrder_534 => 'Payment timed out; support has been cancelled';

  @override
  String get ticketOrder_553 => 'Support has been submitted and cannot be modified';

  @override
  String ticketOrder_559(Object label, Object label2) {
    return 'Support status cannot change from $label to $label2';
  }

  @override
  String get orderLifecycleEvents_22 => 'Timeout';

  @override
  String orderLifecycleEvents_48(Object value, Object trackingNumber) {
    return 'order.shipped($value, $trackingNumber)';
  }

  @override
  String orderPlaced_42(Object value, Object format) {
    return 'order.placed($value, support amount $format)';
  }

  @override
  String get purchaseLimitPolicy_30 => 'Unlimited support';

  @override
  String purchaseLimitPolicy_32(Object value) {
    return 'Limit of $value per order';
  }

  @override
  String purchaseLimitPolicy_33(Object value) {
    return 'Limit of $value per person';
  }

  @override
  String purchaseLimitPolicy_57(Object value) {
    return 'Up to $value per order';
  }

  @override
  String purchaseLimitPolicy_81(Object value, Object value2) {
    return 'Limit of $value per person; you have supported $value2';
  }

  @override
  String purchaseLimitPolicy_83(Object value, Object remaining) {
    return 'Limit of $value per person; you can still support $remaining';
  }

  @override
  String get orderQuote_107 => 'Support total';

  @override
  String get orderQuote_108 => 'Shipping fee';

  @override
  String get orderQuote_109 => 'Split fee';

  @override
  String get orderQuote_111 => 'Discount';

  @override
  String get orderQuote_113 => 'Gift card';

  @override
  String get orderQuote_114 => 'Express service';

  @override
  String get delivery_78 => 'Electronic reward voucher';

  @override
  String get delivery_81 => 'Express delivery';

  @override
  String get delivery_84 => 'On-site pickup';

  @override
  String delivery_136(Object method, Object postage) {
    return '$method ($postage)';
  }

  @override
  String discount_71(Object percent, Object format) {
    return '-$percent% (capped at $format)';
  }

  @override
  String get discount_122 => 'No discount';

  @override
  String discount_139(Object describe) {
    return 'Promotion $describe';
  }

  @override
  String discount_156(Object describe) {
    return 'Coupon $describe';
  }

  @override
  String get orderStatus_24 => 'Pending submission';

  @override
  String get orderStatus_40 => 'Cancelled';

  @override
  String get orderStatus_43 => 'Refunded';

  @override
  String orderStatus_85(Object code) {
    return 'Unknown support status code: $code';
  }

  @override
  String get orderType_10 => 'Regular support';

  @override
  String get orderType_13 => 'Group purchase';

  @override
  String get orderType_16 => 'Limited-time support';

  @override
  String get orderType_19 => 'Membership recharge';

  @override
  String get orderType_22 => 'Express service';

  @override
  String orderType_36(Object code) {
    return 'Unknown support type: $code';
  }

  @override
  String get orderType_49 => 'Regular support';

  @override
  String get orderType_49_2 => 'Support Service Agreement';

  @override
  String get orderType_52 => 'Proxy support';

  @override
  String get orderType_52_2 => 'Proxy Support Service Agreement';

  @override
  String orderType_69(Object code) {
    return 'Unknown support method: $code';
  }

  @override
  String get paymentChannel_10 => 'WeChat Pay';

  @override
  String get paymentChannel_13 => 'Alipay';

  @override
  String get paymentChannel_16 => 'Bank card';

  @override
  String get paymentChannel_19 => 'Credit pay';

  @override
  String get paymentChannel_22 => 'Balance payment';

  @override
  String paymentChannel_36(Object code) {
    return 'Unknown payment channel: $code';
  }

  @override
  String speedPack_61(Object units, Object format, Object format2) {
    return 'Express service $units units ($format cash / $format2 balance)';
  }

  @override
  String speedPack_85(Object value, Object format) {
    return 'Gift card $value (balance $format)';
  }

  @override
  String get visitor_7 => 'ID card';

  @override
  String get visitor_8 => 'Passport';

  @override
  String get visitor_9 => 'HK/Macau Travel Permit';

  @override
  String get visitor_10 => 'Taiwan Travel Permit';

  @override
  String get visitor_11 => 'HK/Macau/Taiwan Residence Permit';

  @override
  String get orderConfirmPage_48 => 'Confirm support';

  @override
  String get orderConfirmPage_59 => 'Select a reward tier';

  @override
  String get orderConfirmPage_73 => 'Discount';

  @override
  String get orderConfirmPage_79 => 'No discount';

  @override
  String get orderConfirmPage_99 => 'Other deductions';

  @override
  String get orderConfirmPage_107 => 'Gift card (not available for this order)';

  @override
  String orderConfirmPage_109(Object format) {
    return 'Gift card (balance $format)';
  }

  @override
  String get orderConfirmPage_123 => 'Express service (not provided by this project)';

  @override
  String orderConfirmPage_125(Object format) {
    return 'Express service ($format/unit)';
  }

  @override
  String get orderConfirmPage_138 => 'Real-name supporter';

  @override
  String orderConfirmPage_143(Object requiredVisitorCount) {
    return 'Select supporters ($requiredVisitorCount required)';
  }

  @override
  String orderConfirmPage_145(Object length) {
    return '$length selected';
  }

  @override
  String get orderConfirmPage_150 => 'This project requires real-name supporters. You cannot submit without selecting them';

  @override
  String get orderConfirmPage_167 => 'Cost details';

  @override
  String get orderConfirmPage_173 => 'Original support price';

  @override
  String get orderConfirmPage_175 => 'Amount payable';

  @override
  String orderConfirmPage_190(Object agreementTitle) {
    return 'I have read and agree to $agreementTitle';
  }

  @override
  String orderConfirmPage_196(Object join) {
    return 'Domain events: $join';
  }

  @override
  String orderConfirmPage_243(Object sessionLabel, Object value) {
    return '$sessionLabel · Project $value';
  }

  @override
  String get orderConfirmPage_444 => 'Payable';

  @override
  String get orderConfirmPage_457 => 'Confirmed';

  @override
  String get orderConfirmPage_460 => 'Confirming…';

  @override
  String get orderConfirmPage_462 => 'Confirm support';

  @override
  String get orderDetailPage_52 => 'Support details';

  @override
  String get orderDetailPage_56 => 'Failed to load support record';

  @override
  String get orderDetailPage_65 => 'Support record not found';

  @override
  String get orderDetailPage_66 => 'The support record may have been deleted, or the link has expired';

  @override
  String get orderDetailPage_68 => 'Back to support list';

  @override
  String get orderDetailPage_101 => 'Reward tier';

  @override
  String orderDetailPage_105(Object value, Object format) {
    return '$value units · $format';
  }

  @override
  String get orderDetailPage_108 => 'Delivery method';

  @override
  String get orderDetailPage_113 => 'Supporter';

  @override
  String get orderDetailPage_125 => 'Amount details';

  @override
  String get orderDetailPage_133 => 'Support amount';

  @override
  String get orderDetailPage_139 => 'Support information';

  @override
  String get orderDetailPage_141 => 'Support number';

  @override
  String get orderDetailPage_150 => 'Support number copied';

  @override
  String get orderDetailPage_163 => 'Support time';

  @override
  String get orderDetailPage_165 => 'Payment time';

  @override
  String get orderDetailPage_167 => 'Close reason';

  @override
  String get orderDetailPage_199 => 'Support has not been submitted yet';

  @override
  String orderDetailPage_201(Object _deadline) {
    return 'Please complete payment before $_deadline. Support will be cancelled automatically on timeout';
  }

  @override
  String get orderDetailPage_204 => 'Payment received. Confirming your reward';

  @override
  String get orderDetailPage_205 => 'Your reward has been shipped. Please check your delivery';

  @override
  String get orderDetailPage_206 => 'Support completed. Feel free to leave a review';

  @override
  String get orderDetailPage_207 => 'Support cancelled. You can choose a new project';

  @override
  String get orderDetailPage_208 => 'Refund returned to your original payment method';

  @override
  String get orderDetailPage_325 => 'Cancel support';

  @override
  String get orderDetailPage_329 => 'Pay now';

  @override
  String get orderDetailPage_335 => 'Track delivery';

  @override
  String get orderDetailPage_335_2 => 'Delivery tracking details are not available yet';

  @override
  String get orderDetailPage_337 => 'Confirm reward received';

  @override
  String get orderDetailPage_342 => 'Request refund';

  @override
  String get orderDetailPage_351 => 'Leave a review';

  @override
  String get orderDetailPage_351_2 => 'Reviews belong to a separate review module, which is not implemented in this demo';

  @override
  String get orderDetailPage_353 => 'Support again';

  @override
  String get orderDetailPage_360 => 'Continue';

  @override
  String get orderDetailPage_366 => 'Contact customer service';

  @override
  String get orderDetailPage_366_2 => 'Customer service chat (demo)';

  @override
  String get orderDetailPage_367 => 'View reward voucher';

  @override
  String get orderDetailPage_367_2 => 'Reward voucher details are not available yet';

  @override
  String get orderDetailPage_369 => 'Request refund';

  @override
  String get orderDetailPage_379 => 'Choose another project';

  @override
  String get orderDetailPage_437 => 'Payment successful. Awaiting delivery';

  @override
  String get orderDetailPage_444 => 'Cancel support';

  @override
  String get orderDetailPage_445 => 'You\'ll need to support again after cancelling. Continue?';

  @override
  String get orderDetailPage_449 => 'Not now';

  @override
  String get orderDetailPage_453 => 'Cancel support';

  @override
  String get orderDetailPage_459 => 'Cancelled by user';

  @override
  String get orderDetailPage_461 => 'Support cancelled';

  @override
  String get orderDetailPage_470 => 'Reward confirmed as received';

  @override
  String get orderListPage_71 => 'Failed to load support records';

  @override
  String get orderListPage_85 => 'No support records yet';

  @override
  String orderListPage_87(Object label) {
    return 'No $label support records';
  }

  @override
  String get orderListPage_88 => 'Browse the home page to find a project';

  @override
  String get orderListPage_90 => 'Browse';

  @override
  String get orderListPage_115 => 'Reviews belong to a separate review module, which is not implemented in this demo';

  @override
  String get orderListPage_119 => 'Customer service chat (demo)';

  @override
  String get orderListPage_130 => 'No merchandise orders';

  @override
  String get orderListPage_131 => 'Merchandise outside the project support flow is not available yet';

  @override
  String get orderListPage_181 => 'Cancel support';

  @override
  String get orderListPage_182 => 'You\'ll need to support again after cancelling. Continue?';

  @override
  String get orderListPage_186 => 'Not now';

  @override
  String get orderListPage_190 => 'Cancel support';

  @override
  String get orderListPage_196 => 'Cancelled by user';

  @override
  String get orderCancelTimeout => 'Payment timed out; support has been cancelled';

  @override
  String get orderListPage_198 => 'Support cancelled';

  @override
  String get orderListPage_208 => 'Reward confirmed as received';

  @override
  String get orderListPage_229 => 'Projects';

  @override
  String get orderListPage_229_2 => 'Merchandise';

  @override
  String get paySuccessPage_75 => 'Payment successful';

  @override
  String get paySuccessPage_84 => 'Planstar is confirming your reward. Please wait';

  @override
  String get paySuccessPage_115 => 'View support records';

  @override
  String get paySuccessPage_138 => 'Keep browsing';

  @override
  String get paySuccessPage_182 => 'Project';

  @override
  String get paySuccessPage_189 => 'Support number';

  @override
  String get paySuccessPage_198 => 'Payment amount';

  @override
  String get payInfo_40 => 'Recommended';

  @override
  String get payInfo_55 => 'Star coin balance';

  @override
  String get payInfo_60 => 'Project';

  @override
  String get payInfo_61 => 'Support number';

  @override
  String get payPage_77 => 'Checkout';

  @override
  String get payPage_133 => 'Demo environment: no real payment is charged; confirming will simulate the payment flow';

  @override
  String get payPage_166 => 'Payment cancelled';

  @override
  String payPage_195(Object seconds) {
    return 'Please complete payment within $seconds';
  }

  @override
  String get payPage_259 => 'Amount payable';

  @override
  String get payPage_301 => 'Select payment method';

  @override
  String get payPage_436 => 'Requesting…';

  @override
  String get payPage_438 => 'Paying…';

  @override
  String payPage_440(Object format) {
    return 'Confirm payment $format';
  }

  @override
  String get payProviders_115 => 'Cannot pay in the current status';

  @override
  String get payProviders_172 => 'Payment timed out; support has been cancelled automatically';

  @override
  String get refundPage_43 => 'Refund request submitted. Please wait for review';

  @override
  String get refundPage_62 => 'Request refund';

  @override
  String get refundPage_97 => 'Submitting…';

  @override
  String get refundPage_98 => 'Submitted';

  @override
  String get refundPage_99 => 'Submit refund request';

  @override
  String get refundPage_138 => 'Refund amount';

  @override
  String get refundPage_150 => 'Support amount';

  @override
  String get refundPage_164 => 'Estimated refund';

  @override
  String get refundPage_207 => 'Refund reason';

  @override
  String get refundPage_244 => 'Enter a refund reason (optional)';

  @override
  String get refundPage_331 => 'Refund notes';

  @override
  String get refundPage_342 => '• Full refund during crowdfunding\n• 80% of the support amount refunded during delivery\n• No refund after support is completed\n• Refunds are returned to your original payment account\n• Refund review usually takes 1-3 business days';

  @override
  String get refundPage_382 => 'Refund request submitted';

  @override
  String refundPage_391(Object format) {
    return 'The refund of $format will be returned to your original payment method after approval';
  }

  @override
  String get refundPage_404 => 'Back to support list';

  @override
  String get refundState_8 => 'No longer needed';

  @override
  String get refundState_8_2 => 'Plans changed; no longer needed';

  @override
  String get refundState_11 => 'Ordered by mistake';

  @override
  String get refundState_11_2 => 'Selected the wrong offline reward session or reward tier';

  @override
  String get refundState_14 => 'Support amount too high';

  @override
  String get refundState_14_2 => 'Price exceeds my budget';

  @override
  String get refundState_17 => 'Found a better project';

  @override
  String get refundState_17_2 => 'Supported through another channel';

  @override
  String get refundState_20 => 'Other reasons';

  @override
  String get refundState_20_2 => 'Custom note';

  @override
  String orderListCard_52(Object value) {
    return 'Project $value';
  }

  @override
  String get orderListCard_53 => 'Reward info pending confirmation';

  @override
  String orderListCard_delivery(Object value) {
    return 'Delivery: $value';
  }

  @override
  String get orderListCard_78 => 'Proxy support';

  @override
  String orderListCard_130(Object join) {
    return 'Supporters $join';
  }

  @override
  String orderListCard_141(Object value) {
    return 'Support number $value';
  }

  @override
  String orderListCard_184(Object value) {
    return '$value units  support amount';
  }

  @override
  String get orderListCard_217 => 'Cancel support';

  @override
  String get orderListCard_220 => 'Go to pay';

  @override
  String get orderListCard_225 => 'Contact customer service';

  @override
  String get orderListCard_228 => 'Request refund';

  @override
  String get orderListCard_233 => 'Track delivery';

  @override
  String get orderListCard_236 => 'Confirm reward received';

  @override
  String get orderListCard_241 => 'Support again';

  @override
  String get orderListCard_244 => 'Leave a review';

  @override
  String get orderListCard_250 => 'Support again';

  @override
  String get orderListCard_298 => 'Payment timed out. Please support again';

  @override
  String orderListCard_305(Object minutes, Object seconds) {
    return 'Time left to pay $minutes:$seconds';
  }

  @override
  String get paymentChannelSheet_52 => 'Select payment method';

  @override
  String get orderDetailPage_expectedDelivery => 'Estimated delivery';

  @override
  String get orderConfirmPage_seatsTitle => 'Selected seats';

  @override
  String get orderConfirmPage_seatsSubtotal => 'Seat subtotal';
}
