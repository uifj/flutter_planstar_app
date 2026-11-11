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
/// 依赖券/卡聚合；放在 UI 里就会让重算逻辑长在几千行的页面组件里，
/// 改一个优惠规则要动页面。
///
/// 领域服务正好：**无状态、纯函数、只吃值对象、返回值对象**。
///
/// ## 公式
///
/// ```
/// totalAmount    = goodsTotal + postage + splitFee
/// discount       = 三选一（营销活动 / 优惠券 / 都不用）
/// payable        = max(totalAmount − discount, 0)          ← 钳到 0，不允许负应付
/// giftCardApplied= min(giftCard.balance, payable)
/// paymentAmount  = payable − giftCardApplied + speedPackCash
/// ```
///
/// 三处**刻意的设计选择**：
/// 1. 不用 `double` 元 + 四舍五入包装（那样礼品卡/加速包两处手写 `-` 很容易漏包）；
///    这里全程整数分，不需要"记得包一层"。
/// 2. 不让优惠额超过总额再靠事后钳 0；这里 [Discount.discountOn]
///    在源头就钳到 `≤ base`。
/// 3. 不把结果写回 7 个成员变量；这里返回不可变的 [OrderQuote]，
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
