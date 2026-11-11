import 'package:core/domain.dart';

/// 优惠券状态。
///
/// 用枚举三态，而不是 int 状态码 + bool 禁用位两个标记位：
/// - 两个标记位会交叉出第四种"既可用又不可用"的矛盾状态；
/// - 列表页按三态分 Tab（可用 / 已使用 / 已过期），不需要再做二次归并。
enum CouponStatus {
  /// 可使用（未禁用且未过期）。
  usable,

  /// 已使用。
  used,

  /// 已过期。
  expired,
}

/// 抵扣类型。
///
/// 抵扣类型的接口取值（见 `wireCode`）：
/// - `1` = 固定金额（现金券）
/// - 其他 = 折扣率（例如 8.5 = 85 折）
enum CouponDiscountType {
  /// 固定金额（减 N 元）。
  amount(1),

  /// 折扣率（X 折）。
  rate(2);

  const CouponDiscountType(this.wireCode);

  final int wireCode;
}

/// 优惠券领域模型。
///
/// ## 刻意不做的事
///
/// - 不用裸 `double` / `int` / `long` 字段让页面直接读：
///   这里用 `final class` + 语义化 getter，金额用 [Money]（整数分），
///   到期时间用 [DateTime]（不是 ms 时间戳），
///   抵扣类型用枚举 [CouponDiscountType] 而不是 `int`。
/// - `ExtraCondition` 保留为可选字段——下单选券时用来判断适用范围。
final class Coupon {
  const Coupon({
    required this.id,
    required this.title,
    required this.desc,
    required this.discountType,
    required this.discountAmount,
    required this.discountRate,
    required this.requireAmount,
    required this.validFrom,
    required this.validTo,
    required this.status,
    this.extraCondition,
  });

  /// 优惠券 ID。
  final int id;

  /// 券名称。
  final String title;

  /// 描述文案。
  final String desc;

  /// 抵扣类型。
  final CouponDiscountType discountType;

  /// 固定金额抵扣（`discountType == amount` 时有效）。
  final Money discountAmount;

  /// 折扣率（`discountType == rate` 时有效，`85` = 85 折）。
  final int discountRate;

  /// 最低消费门槛（满 N 元可用）。
  final Money requireAmount;

  /// 有效期开始。
  final DateTime validFrom;

  /// 有效期结束（到期时间）。
  final DateTime validTo;

  /// 状态。
  final CouponStatus status;

  /// 使用限制条件。
  final CouponExtraCondition? extraCondition;

  /// 是否在有效期内。
  bool get isValid =>
      DateTime.now().isAfter(validFrom) && DateTime.now().isBefore(validTo);

  /// 距离到期还有多少天（负数表示已过期）。
  int get daysUntilExpiry => validTo.difference(DateTime.now()).inDays;

  /// 是否即将过期（7 天内）。
  bool get isExpiringSoon =>
      status == CouponStatus.usable &&
      daysUntilExpiry >= 0 &&
      daysUntilExpiry <= 7;

  /// 在给定金额上算抵扣额。
  ///
  /// - 固定金额：返回 `discountAmount`（但不超过 `base`）。
  /// - 折扣率：返回 `base * discountRate / 1000`（向下取整到分）。
  Money discountOn(Money base) {
    if (discountType == CouponDiscountType.amount) {
      return discountAmount.min(base);
    }
    // discountRate 是"折"（85 = 85 折），万分比 = (1000 - rate * 10)
    // 抵扣额 = base * (1000 - rate * 10) / 10000
    final bps = 10000 - discountRate * 100;
    return base.percentage(bps);
  }
}

/// 优惠券使用限制。
///
/// 服务端下发的使用限制：
/// - `activityCategoryIds`：限定分类
/// - `activityIds`：限定企划
/// - `shopIds`：限定店铺
final class CouponExtraCondition {
  const CouponExtraCondition({
    this.activityCategoryIds = const <int>[],
    this.activityIds = const <int>[],
    this.shopIds = const <int>[],
  });

  final List<int> activityCategoryIds;
  final List<int> activityIds;
  final List<int> shopIds;

  /// 是否有限定分类。
  bool get hasCategoryRestriction => activityCategoryIds.isNotEmpty;

  /// 是否有限定企划。
  bool get hasActivityRestriction => activityIds.isNotEmpty;

  /// 是否有限定店铺。
  bool get hasShopRestriction => shopIds.isNotEmpty;
}
