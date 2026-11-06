import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/domain.dart';

/// 一个可选票档（展示 + 下单用）。
final class TicketTierOffer {
  const TicketTierOffer({required this.id, required this.name, required this.price});

  final TicketTierId id;
  final String name;
  final Money price;
}

/// 确认页的"服务端数据"。
///
/// 对应企划星 `GET v1/unifiedOrder/confirm` 的响应（`OrderConfirmInfo`）：
/// 票档、限购、实名要求、可用券/活动/礼品卡都在这里。
///
/// ⚠ 现在是一份**写死的演示数据**（`orderDraftSeedProvider`）。
/// 接真实接口时，只需要换掉这个 provider 的实现——聚合、报价、事件都不用动。
/// 这也是把"领域"和"数据来源"分开的直接收益。
final class OrderDraftSeed {
  const OrderDraftSeed({
    required this.showId,
    required this.showTitle,
    required this.sessionLabel,
    required this.tiers,
    required this.requiredVisitorCount,
    required this.purchaseLimit,
    required this.availableCoupon,
    required this.availableCampaign,
    required this.giftCard,
    required this.speedPackUnitPrice,
    required this.speedPackBalance,
  });

  final ShowId showId;
  final String showTitle;
  final String sessionLabel;
  final List<TicketTierOffer> tiers;

  /// 需要几位实名观演人（0 = 不需要）。
  final int requiredVisitorCount;

  /// 限购规则。
  final PurchaseLimit purchaseLimit;

  /// 可用优惠券（没有则为 `null`）。
  final CouponSelection? availableCoupon;

  /// 可用营销活动（没有则为 `null`）。
  final CampaignSelection? availableCampaign;

  /// 可用礼品卡（没有则为 `null`）。
  final GiftCardTender? giftCard;

  /// 加速包单价（`null` = 本场不提供）。
  final Money? speedPackUnitPrice;

  /// 账户加速包余额。
  final Money speedPackBalance;
}

/// 演示数据：一个 11 月 8 日晚场的演出。
///
/// 金额刻意选得能暴露精度问题（`680.00` / `580.00` / `380.00`），
/// 优惠选得能覆盖两条分支（券 = 减固定额、活动 = 按比例 + 封顶）。
final orderDraftSeedProvider = Provider.family<OrderDraftSeed, String>((ref, showId) {
  return OrderDraftSeed(
    showId: ShowId(showId),
    showTitle: '《剧院魅影》中文版',
    sessionLabel: '2026-11-08（周日）19:30',
    tiers: <TicketTierOffer>[
      TicketTierOffer(
        id: const TicketTierId('tier-1'),
        name: '内场 A 区',
        price: Money.fromYuan(680),
      ),
      TicketTierOffer(
        id: const TicketTierId('tier-2'),
        name: '内场 B 区',
        price: Money.fromYuan(580),
      ),
      TicketTierOffer(
        id: const TicketTierId('tier-3'),
        name: '二层看台',
        price: Money.fromYuan(380),
      ),
    ],
    requiredVisitorCount: 1,
    purchaseLimit: PurchaseLimit(
      maxPerOrder: Quantity(6),
      maxPerUser: Quantity(4),
    ),
    availableCoupon: CouponSelection(
      const CouponId('CP-2026-50'),
      AmountDiscount(Money.fromYuan(50)),
    ),
    availableCampaign: CampaignSelection(
      const CampaignId('CM-9ZHE'),
      RateDiscount(1000, cap: Money.fromYuan(100)),
    ),
    giftCard: GiftCardTender(
      id: const GiftCardId('GC-8888'),
      balance: Money.fromYuan(200),
    ),
    speedPackUnitPrice: Money.fromYuan(30),
    speedPackBalance: Money.fromYuan(30),
  );
});
