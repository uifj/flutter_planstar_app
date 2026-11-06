import 'package:core/domain.dart';

import 'proxy_buy.dart';

/// 代抢演示数据。
///
/// 对齐 Android：代抢信息内嵌于 `ActivityBean.proxyBuyInfo`，
/// 这里用静态演示数据模拟。
class DemoProxyBuy {
  DemoProxyBuy._();

  /// 演示代抢信息。
  static ProxyBuyInfo get info => ProxyBuyInfo(
    proxyBuyFee: Money.fromYuan(30),
    ruleDesc:
        '代抢服务由企划星合作渠道提供，开抢时由专业抢手为您抢单。\n'
        '• 抢票成功后不支持退换\n'
        '• 抢票失败自动退款\n'
        '• 请确保填写的观演人信息准确\n'
        '• 代抢服务费不退（无论成功与否）',
    deadlines: <ProxyBuyDeadline>[
      const ProxyBuyDeadline(endValue: 1, desc: '开抢即抢'),
      const ProxyBuyDeadline(endValue: 10, desc: '开抢后10分钟内'),
      const ProxyBuyDeadline(endValue: 30, desc: '开抢后30分钟内'),
    ],
    turn: const ProxyBuyTurn(title: '第一场', timeStr: '2026-12-25 19:30'),
    compensationEnabled: true,
  );

  /// 演示代抢订单列表。
  static final List<ProxyBuyOrder> orders = <ProxyBuyOrder>[
    ProxyBuyOrder(
      id: 1,
      showTitle: '周杰伦嘉年华世界巡回演唱会',
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
      showTitle: '五月天回到那一天巡回演唱会',
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
      showTitle: '林俊杰JJ20世界巡回演唱会',
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
      showTitle: '薛之谦天外来物巡回演唱会',
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
