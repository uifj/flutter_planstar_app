import 'package:core/domain.dart';

import '../domain/proxy_buy.dart';

/// 代抢演示数据。
///
/// 代抢规则内嵌于企划详情、没有独立端点，
/// 这里用静态演示数据模拟。
abstract final class DemoProxyBuy {
  /// 演示代抢订单列表。
  static final List<ProxyBuyOrder> orders = <ProxyBuyOrder>[
    ProxyBuyOrder(
      id: 1,
      showTitle: '周杰伦「嘉年华」音乐影像企划',
      showPoster: null,
      venue: '国家体育场（鸟巢）',
      eventTime: '2026-12-25 19:30',
      turn: const ProxyBuyTurn(title: '第一场', timeStr: '2026-12-25 19:30'),
      deadline: const ProxyBuyDeadline(endValue: 10, desc: '开抢后10分钟内'),
      ticketPrice: Money.fromYuan(880),
      quantity: 2,
      proxyBuyFee: Money.fromYuan(30),
      totalAmount: Money.fromYuan(1820),
      status: ProxyBuyStatus.success,
      createdAt: DateTime(2026, 11, 20, 10, 30),
    ),
    ProxyBuyOrder(
      id: 2,
      showTitle: '五月天「回到那一天」音乐影像企划',
      showPoster: null,
      venue: '上海体育场',
      eventTime: '2026-11-30 19:30',
      turn: const ProxyBuyTurn(title: '第一场', timeStr: '2026-11-30 19:30'),
      deadline: const ProxyBuyDeadline(endValue: 1, desc: '开抢即抢'),
      ticketPrice: Money.fromYuan(680),
      quantity: 1,
      proxyBuyFee: Money.fromYuan(30),
      totalAmount: Money.fromYuan(710),
      status: ProxyBuyStatus.inProgress,
      createdAt: DateTime(2026, 11, 25, 9, 0),
    ),
    ProxyBuyOrder(
      id: 3,
      showTitle: '林俊杰「JJ20」音乐影像企划',
      showPoster: null,
      venue: '广州奥体中心',
      eventTime: '2026-12-15 19:30',
      turn: const ProxyBuyTurn(title: '第二场', timeStr: '2026-12-15 19:30'),
      deadline: const ProxyBuyDeadline(endValue: 30, desc: '开抢后30分钟内'),
      ticketPrice: Money.fromYuan(580),
      quantity: 3,
      proxyBuyFee: Money.fromYuan(30),
      totalAmount: Money.fromYuan(1830),
      status: ProxyBuyStatus.failed,
      createdAt: DateTime(2026, 11, 18, 14, 0),
    ),
    ProxyBuyOrder(
      id: 4,
      showTitle: '薛之谦「天外来物」音乐影像企划',
      showPoster: null,
      venue: '深圳湾体育中心',
      eventTime: '2027-01-08 19:30',
      turn: const ProxyBuyTurn(title: '第一场', timeStr: '2027-01-08 19:30'),
      deadline: const ProxyBuyDeadline(endValue: 1, desc: '开抢即抢'),
      ticketPrice: Money.fromYuan(480),
      quantity: 2,
      proxyBuyFee: Money.fromYuan(30),
      totalAmount: Money.fromYuan(1020),
      status: ProxyBuyStatus.pending,
      createdAt: DateTime(2026, 11, 28, 16, 0),
    ),
  ];
}
