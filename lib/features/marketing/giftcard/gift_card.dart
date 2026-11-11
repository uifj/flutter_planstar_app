import 'package:core/domain.dart';

/// 礼品卡状态。
///
/// 用枚举三态表达是否可用，而不是 int 状态码 + bool 禁用位两个标记位。
enum GiftCardStatus {
  /// 可用（未禁用且 `balance > 0`）。
  active,

  /// 已用完（`balance <= 0`）。
  depleted,

  /// 已禁用。
  disabled,
}

/// 礼品卡领域模型。
///
/// ## 设计取舍
///
/// - 用 `final class` 而不是裸 `double` / `int` / `long` 字段让页面直接读：
///   金额用 [Money]（整数分），时间用 [DateTime]，
///   状态用枚举 [GiftCardStatus] 而不是 `int` + `bool`。
/// - `denomination`（面值）和 `balance`（余额）分开存：
///   面值是卡片的初始金额（决定卡片颜色），余额是当前可用金额。
final class GiftCard {
  const GiftCard({
    required this.id,
    required this.title,
    required this.desc,
    required this.denomination,
    required this.balance,
    required this.status,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.addTime,
    this.serialNumber,
    this.canRevoke = false,
  });

  /// 礼品卡 ID。
  final int id;

  /// 卡名称。
  final String title;

  /// 描述文案。
  final String desc;

  /// 面值（初始金额）。决定卡片颜色分级：
  /// ≤100 绿、≤200 蓝、≤500 黄、≤1000 红、>1000 黑。
  final Money denomination;

  /// 当前余额。
  final Money balance;

  /// 状态。
  final GiftCardStatus status;

  /// 有效期开始。
  final DateTime effectiveFrom;

  /// 有效期结束。
  final DateTime effectiveTo;

  /// 绑定时间。
  final DateTime addTime;

  /// 卡号（用户绑定时输入的序列号）。
  final String? serialNumber;

  /// 是否可以解绑。
  final bool canRevoke;

  /// 是否在有效期内。
  bool get isValid =>
      DateTime.now().isAfter(effectiveFrom) &&
      DateTime.now().isBefore(effectiveTo);

  /// 距离到期还有多少天。
  int get daysUntilExpiry => effectiveTo.difference(DateTime.now()).inDays;

  /// 是否即将过期（7 天内）。
  bool get isExpiringSoon =>
      status == GiftCardStatus.active &&
      daysUntilExpiry >= 0 &&
      daysUntilExpiry <= 7;
}
