import 'package:core/domain.dart';

import 'gift_card.dart';

/// 礼品卡演示数据。
///
/// 对齐 Android `GiftCardService.fetchGiftCards()` → `GiftCardInfo`：
/// - Android 返回 `enableGiftCards` + `disableGiftCards` 两个列表。
/// - 这里直接生成混合列表，由 `GiftCardStatus` 区分。
class DemoGiftCards {
  DemoGiftCards._();

  static final List<GiftCard> _all = <GiftCard>[
    GiftCard(
      id: 1,
      title: '企划星礼品卡',
      desc: '企划星官网购买礼品卡',
      denomination: Money.fromYuan(100),
      balance: Money.fromYuan(100),
      status: GiftCardStatus.active,
      effectiveFrom: DateTime(2026, 9, 1),
      effectiveTo: DateTime(2027, 3, 1),
      addTime: DateTime(2026, 9, 15),
      serialNumber: 'PN2026GC001',
      canRevoke: true,
    ),
    GiftCard(
      id: 2,
      title: '演出补贴卡',
      desc: '会员日赠送',
      denomination: Money.fromYuan(200),
      balance: Money.fromYuan(150),
      status: GiftCardStatus.active,
      effectiveFrom: DateTime(2026, 8, 1),
      effectiveTo: DateTime(2026, 12, 31),
      addTime: DateTime(2026, 8, 10),
      serialNumber: 'PN2026GC002',
      canRevoke: false,
    ),
    GiftCard(
      id: 3,
      title: '企划星礼品卡',
      desc: '企划星官网购买礼品卡',
      denomination: Money.fromYuan(500),
      balance: Money.fromYuan(500),
      status: GiftCardStatus.active,
      effectiveFrom: DateTime(2026, 10, 1),
      effectiveTo: DateTime(2027, 10, 1),
      addTime: DateTime(2026, 10, 5),
      serialNumber: 'PN2026GC003',
      canRevoke: true,
    ),
    GiftCard(
      id: 4,
      title: '新人礼包卡',
      desc: '注册赠送',
      denomination: Money.fromYuan(50),
      balance: Money.zero(),
      status: GiftCardStatus.depleted,
      effectiveFrom: DateTime(2025, 6, 1),
      effectiveTo: DateTime(2026, 6, 1),
      addTime: DateTime(2025, 6, 1),
      serialNumber: 'PN2025GC004',
      canRevoke: false,
    ),
    GiftCard(
      id: 5,
      title: '活动赠卡',
      desc: '春节活动赠送',
      denomination: Money.fromYuan(300),
      balance: Money.fromYuan(300),
      status: GiftCardStatus.disabled,
      effectiveFrom: DateTime(2026, 1, 20),
      effectiveTo: DateTime(2026, 3, 20),
      addTime: DateTime(2026, 1, 20),
      serialNumber: 'PN2026GC005',
      canRevoke: false,
    ),
  ];

  /// 所有礼品卡（含可用 / 已用完 / 已禁用）。
  static List<GiftCard> get all => List<GiftCard>.unmodifiable(_all);

  /// 可用礼品卡。
  static List<GiftCard> get active =>
      _all.where((GiftCard c) => c.status == GiftCardStatus.active).toList();

  /// 不可用礼品卡（已用完 + 已禁用）。
  static List<GiftCard> get inactive =>
      _all.where((GiftCard c) => c.status != GiftCardStatus.active).toList();

  /// 可用礼品卡数量。
  static int get activeCount => active.length;

  /// 礼品卡总余额。
  static Money get totalBalance =>
      active.fold(Money.zero(), (Money sum, GiftCard c) => sum + c.balance);
}
