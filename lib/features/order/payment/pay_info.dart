import 'package:core/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/domain.dart';

part 'pay_info.freezed.dart';

/// 支付页面信息（对齐企划星 `GET v1/unifiedPay/payDetail` 的 `PayInfo`）。
///
/// 企划星的 `PayActivity` 在 onCreate 里拉一次 `payDetail`，拿到：
/// - `payAmount`：应付金额
/// - `leftTime`：倒计时秒数（订单超时前剩余时间）
/// - `channels[]`：可用支付渠道列表
/// - `detailInfo[]`：订单摘要行（演出名 / 票档 / 数量等）
/// - `payReturnPage`：成功 / 失败页配置
///
/// 页面壳由 [PayInfo.forOrder] 按路由参数构造；真实支付金额与状态
/// 由 `PaymentOrder`（`/v1/unifiedPay/pay`）驱动。
@freezed
abstract class PayInfo with _$PayInfo {
  const factory PayInfo({
    required String orderNumber,
    required Money payAmount,
    required int leftSeconds,
    required List<PayChannelOption> channels,
    required List<PayDetailLine> detailLines,
    required String showTitle,
  }) = _PayInfo;

  /// 按订单参数构造支付页信息（渠道为客户端能力声明）。
  factory PayInfo.forOrder({
    required String orderNumber,
    required Money payAmount,
    required String showTitle,
  }) {
    return PayInfo(
      orderNumber: orderNumber,
      payAmount: payAmount,
      leftSeconds: 900, // 15 分钟
      showTitle: showTitle,
      channels: <PayChannelOption>[
        const PayChannelOption(
          channel: PaymentChannel.wechat,
          tip: PayChannelTip.recommended,
          available: true,
        ),
        const PayChannelOption(
          channel: PaymentChannel.alipay,
          tip: PayChannelTip.none,
          available: true,
        ),
        const PayChannelOption(
          channel: PaymentChannel.unionPay,
          tip: PayChannelTip.none,
          available: true,
        ),
        const PayChannelOption(
          channel: PaymentChannel.balance,
          tip: PayChannelTip.balance,
          available: false,
        ),
      ],
      detailLines: <PayDetailLine>[
        PayDetailLine(kind: PayDetailKind.show, value: showTitle),
        PayDetailLine(kind: PayDetailKind.orderNumber, value: orderNumber),
      ],
    );
  }
}

/// 支付渠道下方的提示类型。
enum PayChannelTip {
  /// 无提示。
  none,

  /// 推荐。
  recommended,

  /// 余额支付提示。
  balance,
}

/// 一个支付渠道选项（对齐 `PayInfo.channels[]`）。
@freezed
abstract class PayChannelOption with _$PayChannelOption {
  const factory PayChannelOption({
    /// 渠道。
    required PaymentChannel channel,

    /// 提示类型（展示文案由 UI 层按 l10n 解析）。
    required PayChannelTip tip,

    /// 是否可选。余额不足 / 未绑卡时为 false。
    required bool available,
  }) = _PayChannelOption;
}

/// 订单摘要行类型。
enum PayDetailKind { show, orderNumber }

/// 订单摘要行（对齐 `PayInfo.detailInfo[]`）。
@freezed
abstract class PayDetailLine with _$PayDetailLine {
  const factory PayDetailLine({
    required PayDetailKind kind,
    required String value,
  }) = _PayDetailLine;
}

/// 支付结果（对齐 `POST v1/unifiedPay/pay` 的响应 + SDK 回调）。
sealed class PayResult {
  const PayResult();
}

/// 支付成功。
class PaySuccess extends PayResult {
  const PaySuccess();
}

/// 支付失败。
class PayFailure extends PayResult {
  const PayFailure(this.message);

  final String message;
}

/// 用户取消支付（从支付 SDK 返回 / 关闭面板）。
class PayCancelled extends PayResult {
  const PayCancelled();
}

/// 支付状态枚举（UI 状态机用）。
enum PayStatus {
  /// 待选择渠道 / 待确认。
  idle,

  /// 正在请求支付参数（调 `POST v1/unifiedPay/pay`）。
  requesting,

  /// 正在调起第三方 SDK。
  paying,

  /// 支付成功。
  success,

  /// 支付失败。
  failure,

  /// 用户取消。
  cancelled,
}
