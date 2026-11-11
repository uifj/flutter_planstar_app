import 'package:core/domain.dart';

import 'coupon.dart';

/// 优惠券演示数据。
///
/// ## 为什么用演示数据
///
/// 真实券列表来自 `GET v1/coupons`。
/// Flutter 侧该接口尚未接线（只有 `auth` 域走真实网络），
/// 这里生成一份覆盖三种状态、两种抵扣类型的演示数据，
/// 等接口接上时直接替换 [CouponRepository.fetchAll] 的实现即可。
final class DemoCoupons {
  DemoCoupons._();

  /// 生成演示券列表。
  ///
  /// 覆盖：固定金额券 × 2、折扣率券 × 1、已使用 × 1、已过期 × 1。
  static List<Coupon> generate() {
    final now = DateTime.now();

    return <Coupon>[
      // 可使用：满 100 减 30（固定金额）
      Coupon(
        id: 1001,
        title: '新人立减券',
        desc: '全场企划通用',
        discountType: CouponDiscountType.amount,
        discountAmount: Money.fromMinorUnits(3000),
        discountRate: 0,
        requireAmount: Money.fromMinorUnits(10000),
        validFrom: now.subtract(const Duration(days: 30)),
        validTo: now.add(const Duration(days: 5)),
        status: CouponStatus.usable,
        extraCondition: const CouponExtraCondition(),
      ),
      // 可使用：满 200 减 50（固定金额，即将过期）
      Coupon(
        id: 1002,
        title: '企划满减券',
        desc: '音乐企划 / 现场企划专用',
        discountType: CouponDiscountType.amount,
        discountAmount: Money.fromMinorUnits(5000),
        discountRate: 0,
        requireAmount: Money.fromMinorUnits(20000),
        validFrom: now.subtract(const Duration(days: 20)),
        validTo: now.add(const Duration(days: 3)),
        status: CouponStatus.usable,
        extraCondition: const CouponExtraCondition(
          activityCategoryIds: <int>[1, 2],
        ),
      ),
      // 可使用：85 折券（折扣率）
      Coupon(
        id: 1003,
        title: '限时折扣券',
        desc: '全场企划 85 折',
        discountType: CouponDiscountType.rate,
        discountAmount: Money.zero(),
        discountRate: 85,
        requireAmount: Money.fromMinorUnits(5000),
        validFrom: now.subtract(const Duration(days: 10)),
        validTo: now.add(const Duration(days: 45)),
        status: CouponStatus.usable,
        extraCondition: const CouponExtraCondition(),
      ),
      // 可使用：无门槛 15 元券
      Coupon(
        id: 1004,
        title: '无门槛代金券',
        desc: '任意企划可用',
        discountType: CouponDiscountType.amount,
        discountAmount: Money.fromMinorUnits(1500),
        discountRate: 0,
        requireAmount: Money.zero(),
        validFrom: now.subtract(const Duration(days: 5)),
        validTo: now.add(const Duration(days: 60)),
        status: CouponStatus.usable,
        extraCondition: const CouponExtraCondition(),
      ),
      // 已使用
      Coupon(
        id: 2001,
        title: '会员专属券',
        desc: '话剧 / 舞台剧专用',
        discountType: CouponDiscountType.amount,
        discountAmount: Money.fromMinorUnits(8000),
        discountRate: 0,
        requireAmount: Money.fromMinorUnits(30000),
        validFrom: now.subtract(const Duration(days: 60)),
        validTo: now.add(const Duration(days: 30)),
        status: CouponStatus.used,
        extraCondition: const CouponExtraCondition(
          activityCategoryIds: <int>[3],
        ),
      ),
      // 已过期
      Coupon(
        id: 3001,
        title: '周年庆满减券',
        desc: '满 500 减 100',
        discountType: CouponDiscountType.amount,
        discountAmount: Money.fromMinorUnits(10000),
        discountRate: 0,
        requireAmount: Money.fromMinorUnits(50000),
        validFrom: now.subtract(const Duration(days: 90)),
        validTo: now.subtract(const Duration(days: 5)),
        status: CouponStatus.expired,
        extraCondition: const CouponExtraCondition(),
      ),
    ];
  }
}
