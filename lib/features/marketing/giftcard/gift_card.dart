import 'package:core/domain.dart';

/// 礼品卡状态。
///
/// 对齐 Android `GiftCard.status` + `isDisable`：
/// - Android 用 `status`（int）+ `isDisable`（bool）判断是否可用。
/// - 这里用枚举三态。
enum GiftCardStatus {
  /// 可用（`isDisable=false` 且 `balance > 0`）。
  active,

  /// 已用完（`balance <= 0`）。
  depleted,

  /// 已禁用（`isDisable=true`）。
  disabled,
}

/// 礼品卡领域模型。
///
/// 对齐 Android `GiftCard.java`（`Serializable` Kotlin data class）。
///
/// ## 与 Android 的差异
///
/// - Android 字段全是裸 `double` / `int` / `long`，页面直接读字段。
/// - 这里用 `final class`：金额用 [Money]（整数分），时间用 [DateTime]，
///   状态用枚举 [GiftCardStatus] 而不是 `int` + `bool`。
/// - Android 用 `denomination`（面值）和 `balance`（余额）两个字段；
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

  /// 卡名称（Android 默认 "礼品卡"）。
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

  /// 是否可以解绑（Android `isCanRevoke`）。
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

  /// 到期文案。
  String get expiryLabel {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${effectiveTo.year}-${two(effectiveTo.month)}-${two(effectiveTo.day)}到期';
  }

  /// 面值文案。
  String get denominationLabel => '面值 ${denomination.format()}';

  /// 余额文案。
  String get balanceLabel => '余额 ${balance.format()}';
}
