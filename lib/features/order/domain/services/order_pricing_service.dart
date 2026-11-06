import 'package:core/domain.dart';

import '../value_objects/discount.dart';
import '../value_objects/speed_pack.dart';
import 'order_quote.dart';

/// 订单金额计算 —— **领域服务**。
///
/// ## 为什么不是聚合的方法
///
/// 这段逻辑需要知道"优惠/礼品卡/加速包"这些**不属于订单聚合**的概念（券和卡是别的聚合），
/// 又要被确认页、支付页、费用明细弹窗、服务端对账同时用。放在聚合里会让订单
/// 依赖券/卡聚合；放在 UI 里就是企划星现在的样子——`updatePrice()` 长在 2,633 行的
/// Activity 里，改一个优惠规则要动页面。
///
/// 领域服务正好：**无状态、纯函数、只吃值对象、返回值对象**。
///
/// ## 公式（逐行对齐企划星 `OrderConfirmActivity.updatePrice`）
///
/// ```
/// totalAmount    = goodsTotal + postage + splitFee
/// discount       = 三选一（营销活动 / 优惠券 / 都不用）
/// payable        = max(totalAmount − discount, 0)          ← 原实现 Utils.round 后钳 0
/// giftCardApplied= min(giftCard.balance, payable)
/// paymentAmount  = payable − giftCardApplied + speedPackCash
/// ```
///
/// 与原实现的三处**刻意差异**：
/// 1. 原实现用 `double` 元 + `ArithmeticUtils`（BigDecimal 包装）+ `Utils.round`，
///    但礼品卡/加速包两处手写 `-` 没包；这里全程整数分，不需要"记得包一层"。
/// 2. 原实现的优惠额可以超过总额（靠事后钳 0）；这里 [Discount.discountOn]
///    在源头就钳到 `≤ base`。
/// 3. 原实现把结果写回 7 个成员变量；这里返回不可变的 [OrderQuote]，
///    构造时自校验"拆解项之和 = 实付"。
final class OrderPricingService {
  const OrderPricingService();

  /// 报价。
  ///
  /// [goodsTotal] 由聚合从订单行汇总后传入（服务不碰实体，只算钱）。
  OrderQuote quote({
    required Money goodsTotal,
    required Money postage,
    required Money splitFee,
    DiscountSelection discount = DiscountSelection.none,
    GiftCardTender? giftCard,
    SpeedPack? speedPack,
  }) {
    final totalAmount = goodsTotal + postage + splitFee;
    final discountApplied = discount.discountOn(totalAmount);
    final payable = (totalAmount - discountApplied).atLeastZero();

    final giftCardApplied = giftCard == null
        ? Money.zero(totalAmount.currency)
        : giftCard.balance.min(payable);

    final speedPackCash =
        speedPack?.cashPortion ?? Money.zero(totalAmount.currency);
    final speedPackBalance =
        speedPack?.balancePortion ?? Money.zero(totalAmount.currency);

    final paymentAmount = payable - giftCardApplied + speedPackCash;

    return OrderQuote(
      goodsTotal: goodsTotal,
      postage: postage,
      splitFee: splitFee,
      discountApplied: discountApplied,
      totalAmount: totalAmount,
      giftCardApplied: giftCardApplied,
      speedPackCash: speedPackCash,
      speedPackBalance: speedPackBalance,
      paymentAmount: paymentAmount,
    );
  }
}
