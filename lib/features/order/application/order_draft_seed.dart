import 'package:core/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../../catalog/application/catalog_providers.dart';
import '../domain/domain.dart';

/// 一个可选票档（展示 + 下单用）。
final class TicketTierOffer {
  const TicketTierOffer({
    required this.id,
    required this.name,
    required this.price,
  });

  final TicketTierId id;
  final String name;
  final Money price;
}

/// 确认页的"服务端数据"。
///
/// 对应企划星 `GET v1/unifiedOrder/confirm` 的响应（`OrderConfirmInfo`）：
/// 票档、限购、实名要求、可用券/活动/礼品卡都在这里。
///
/// demo 模式用固定数据；真实模式从已加载的演出详情映射票档/场次。
final class OrderDraftSeed {
  const OrderDraftSeed({
    required this.showId,
    required this.sessionId,
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
  final SessionId sessionId;
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

/// 确认页种子数据。
///
/// demo 模式保留原演示场次；真实模式从已加载的演出映射票档和首个场次，
/// 详情尚未返回时给一个空票档种子，由 UI 展示不可提交状态。
final orderDraftSeedProvider = Provider.family<OrderDraftSeed, String>((
  ref,
  showId,
) {
  if (ref.watch(useDemoProvider)) return _demoSeed(showId);

  final show = ref.watch(showFullProvider(showId));
  if (show == null) return _emptySeed(showId);

  final tiers = <TicketTierOffer>[
    for (var i = 0; i < show.tiers.length; i++)
      TicketTierOffer(
        id: TicketTierId('tier-$i'),
        name: show.tiers[i].name,
        price: show.tiers[i].price,
      ),
  ];
  final session = show.sessions.isEmpty ? null : show.sessions.first;
  return OrderDraftSeed(
    showId: ShowId(showId),
    sessionId: SessionId('${show.id}-0'),
    showTitle: show.title,
    sessionLabel: session == null
        ? show.firstSessionAt.toString()
        : session.startsAt.toString(),
    tiers: tiers,
    // 真实下单接口当前不要求客户端选集观演人。
    requiredVisitorCount: 0,
    purchaseLimit: const PurchaseLimit.unlimited(),
    availableCoupon: null,
    availableCampaign: null,
    giftCard: null,
    speedPackUnitPrice: null,
    speedPackBalance: Money.zero(),
  );
});

OrderDraftSeed _emptySeed(String showId) {
  return OrderDraftSeed(
    showId: ShowId(showId),
    sessionId: const SessionId(''),
    showTitle: '演出详情加载中',
    sessionLabel: '',
    tiers: const <TicketTierOffer>[],
    requiredVisitorCount: 0,
    purchaseLimit: const PurchaseLimit.unlimited(),
    availableCoupon: null,
    availableCampaign: null,
    giftCard: null,
    speedPackUnitPrice: null,
    speedPackBalance: Money.zero(),
  );
}

/// 演示数据：一个 11 月 8 日晚场的演出。
OrderDraftSeed _demoSeed(String showId) {
  return OrderDraftSeed(
    showId: ShowId(showId),
    sessionId: const SessionId('S-20261108-1930'),
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
}
