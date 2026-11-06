import 'package:core/domain.dart';

/// 代抢截止时间选项。
///
/// 对齐 Android `ProxyBuyTimeInfo`：
/// - `endValue`（int）：截止阈值
/// - `endValueDesc`（String）：展示文案
final class ProxyBuyDeadline {
  const ProxyBuyDeadline({
    required this.endValue,
    required this.desc,
  });

  /// 截止阈值（Android `endValue`）。
  final int endValue;

  /// 展示文案（Android `endValueDesc`）。
  final String desc;
}

/// 代抢场次信息。
///
/// 对齐 Android `ProxyBuyTurnInfo`：
/// - `title`：场次标题
/// - `timeStr`：时间描述
final class ProxyBuyTurn {
  const ProxyBuyTurn({
    required this.title,
    required this.timeStr,
  });

  final String title;
  final String timeStr;
}

/// 代抢规则信息。
///
/// 对齐 Android `ProxyBuyInfo`（内嵌于 `ActivityBean`）。
///
/// ## 与 Android 的差异
///
/// - Android 的 `ProxyBuyInfo` 是 Kotlin data class，
///   费用用裸 `double`，时间列表用 `List<ProxyBuyTimeInfo>`。
/// - 这里用 `Money` 表示费用，`DateTime` 表示时间，
///   `List<ProxyBuyDeadline>` 表示截止选项。
final class ProxyBuyInfo {
  const ProxyBuyInfo({
    required this.proxyBuyFee,
    required this.ruleDesc,
    required this.deadlines,
    required this.turn,
    this.compensationEnabled = false,
  });

  /// 每张票的代抢服务费（Android `proxyBuyFee`）。
  final Money proxyBuyFee;

  /// 规则说明文案（Android `proxyBuyRuleDesc`）。
  final String ruleDesc;

  /// 截止时间选项列表（Android `proxyBuyTimeInfo`）。
  final List<ProxyBuyDeadline> deadlines;

  /// 场次信息（Android `proxyBuyTurnInfo`）。
  final ProxyBuyTurn turn;

  /// 是否开启赔付（Android `proxyBuyCompensationInfo.open`）。
  final bool compensationEnabled;

  /// 计算总费用。
  /// 对齐 Android `ProxyBuyHelper.calculateTotalPrice`：
  /// `(salePrice * count) + (proxyBuyFee * count)`
  Money calculateTotal(Money salePrice, int count) =>
      (salePrice * count) + (proxyBuyFee * count);
}

/// 代抢订单状态。
enum ProxyBuyStatus {
  /// 待抢票（已提交，等待开抢）。
  pending,

  /// 抢票中（开抢时间已到，正在抢）。
  inProgress,

  /// 抢票成功。
  success,

  /// 抢票失败。
  failed,

  /// 已取消。
  cancelled,
}

/// 代抢订单。
final class ProxyBuyOrder {
  const ProxyBuyOrder({
    required this.id,
    required this.showTitle,
    required this.showPoster,
    required this.venue,
    required this.eventTime,
    required this.turn,
    required this.deadline,
    required this.ticketPrice,
    required this.quantity,
    required this.proxyBuyFee,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.compensationEnabled = false,
  });

  final int id;
  final String showTitle;
  final String? showPoster;
  final String venue;
  final String eventTime;
  final ProxyBuyTurn turn;
  final ProxyBuyDeadline deadline;

  /// 单张票价。
  final Money ticketPrice;
  final int quantity;

  /// 代抢服务费（每张）。
  final Money proxyBuyFee;

  /// 总金额（票价 + 服务费）。
  final Money totalAmount;

  final ProxyBuyStatus status;
  final DateTime createdAt;

  /// 是否开启赔付。
  final bool compensationEnabled;

  /// 状态文案。
  String get statusLabel {
    switch (status) {
      case ProxyBuyStatus.pending:
        return '待抢票';
      case ProxyBuyStatus.inProgress:
        return '抢票中';
      case ProxyBuyStatus.success:
        return '抢票成功';
      case ProxyBuyStatus.failed:
        return '抢票失败';
      case ProxyBuyStatus.cancelled:
        return '已取消';
    }
  }
}
