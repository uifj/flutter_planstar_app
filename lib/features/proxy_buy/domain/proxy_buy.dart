import 'package:core/domain.dart';

/// 遗留票务能力：与「企划支持平台」定位冲突，按 POSITIONING.md §10 待下线。
///
/// 代抢截止时间选项。
///
/// 服务端下发字段：
/// - `endValue`（int）：截止阈值
/// - `endValueDesc`（String）：展示文案
final class ProxyBuyDeadline {
  const ProxyBuyDeadline({required this.endValue, required this.desc});

  /// 截止阈值。
  final int endValue;

  /// 展示文案。
  final String desc;
}

/// 代抢的线下回报场次信息。
///
/// 服务端下发字段：
/// - `title`：线下回报场次标题
/// - `timeStr`：时间描述
final class ProxyBuyTurn {
  const ProxyBuyTurn({required this.title, required this.timeStr});

  final String title;
  final String timeStr;
}

/// 代抢规则信息。
///
/// 规则内嵌于企划详情，没有独立端点。
///
/// 这里只保留数据；总价计算见
/// `domain/services/proxy_buy_pricing.dart` 的 `ProxyBuyPricing`。
final class ProxyBuyInfo {
  const ProxyBuyInfo({
    required this.proxyBuyFee,
    required this.ruleDesc,
    required this.deadlines,
    required this.turn,
    this.compensationEnabled = false,
  });

  /// 每份的服务费。
  final Money proxyBuyFee;

  /// 规则说明文案。
  final String ruleDesc;

  /// 截止时间选项列表。
  final List<ProxyBuyDeadline> deadlines;

  /// 线下回报场次信息。
  final ProxyBuyTurn turn;

  /// 是否开启赔付。
  final bool compensationEnabled;
}

/// 代抢订单状态。
enum ProxyBuyStatus {
  /// 待处理（已提交，等待开始）。
  pending,

  /// 进行中（已到开始时间，正在处理）。
  inProgress,

  /// 处理成功。
  success,

  /// 处理失败。
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

  /// 单份价格。
  final Money ticketPrice;
  final int quantity;

  /// 服务费（每份）。
  final Money proxyBuyFee;

  /// 总金额（单价小计 + 服务费）。
  final Money totalAmount;

  final ProxyBuyStatus status;
  final DateTime createdAt;

  /// 是否开启赔付。
  final bool compensationEnabled;
}
