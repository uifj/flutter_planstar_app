import 'package:core_domain/core_domain.dart';

import '../domain/domain.dart';

/// 支付页面信息（对齐企划星 `GET v1/unifiedPay/payDetail` 的 `PayInfo`）。
///
/// 企划星的 `PayActivity` 在 onCreate 里拉一次 `payDetail`，拿到：
/// - `payAmount`：应付金额
/// - `leftTime`：倒计时秒数（订单超时前剩余时间）
/// - `channels[]`：可用支付渠道列表
/// - `detailInfo[]`：订单摘要行（演出名 / 票档 / 数量等）
/// - `payReturnPage`：成功 / 失败页配置
///
/// 本演示模式里用 [PayInfo.demo] 生成；接真实接口时由 repository 从
/// `v1/unifiedPay/payDetail` 拉取并映射到这里。
class PayInfo {
  const PayInfo({
    required this.orderNumber,
    required this.payAmount,
    required this.leftSeconds,
    required this.channels,
    required this.detailLines,
    required this.showTitle,
  });

  /// 演示数据。
  factory PayInfo.demo({
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
          tip: '推荐',
          available: true,
        ),
        const PayChannelOption(
          channel: PaymentChannel.alipay,
          tip: '',
          available: true,
        ),
        const PayChannelOption(
          channel: PaymentChannel.unionPay,
          tip: '',
          available: true,
        ),
        const PayChannelOption(
          channel: PaymentChannel.balance,
          tip: '余额 ¥0.00',
          available: false,
        ),
      ],
      detailLines: <PayDetailLine>[
        PayDetailLine(label: '演出', value: showTitle),
        PayDetailLine(label: '订单号', value: orderNumber),
      ],
    );
  }

  /// 订单号。
  final String orderNumber;

  /// 应付金额。
  final Money payAmount;

  /// 剩余支付时间（秒）。超时后订单自动取消。
  final int leftSeconds;

  /// 可用支付渠道。
  final List<PayChannelOption> channels;

  /// 订单摘要行。
  final List<PayDetailLine> detailLines;

  /// 演出名（用于成功页展示）。
  final String showTitle;
}

/// 一个支付渠道选项（对齐 `PayInfo.channels[]`）。
class PayChannelOption {
  const PayChannelOption({
    required this.channel,
    required this.tip,
    required this.available,
  });

  /// 渠道。
  final PaymentChannel channel;

  /// 提示文案（如"推荐""余额 ¥128.00"）。
  final String tip;

  /// 是否可选。余额不足 / 未绑卡时为 false。
  final bool available;
}

/// 订单摘要行（对齐 `PayInfo.detailInfo[]`）。
class PayDetailLine {
  const PayDetailLine({required this.label, required this.value});

  final String label;
  final String value;
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
