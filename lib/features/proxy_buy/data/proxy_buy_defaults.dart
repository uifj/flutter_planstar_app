import 'package:core/domain.dart';

import '../domain/proxy_buy.dart';

/// 代抢默认规则配置。
///
/// 代抢规则内嵌在活动详情（`ActivityBean.proxyBuyInfo`）里；本页没有活动
/// 上下文，因此使用这份默认配置。真实模式下只有订单列表走接口，规则不变。
abstract final class ProxyBuyDefaults {
  static ProxyBuyInfo get info => ProxyBuyInfo(
    proxyBuyFee: Money.fromYuan(30),
    ruleDesc:
        '代购服务由企划星合作渠道提供，开放支持时由专业代购为您下单。\n'
        '• 代购成功后不支持退换\n'
        '• 代购失败自动退款\n'
        '• 请确保填写的支持人信息准确\n'
        '• 代购服务费不退（无论成功与否）',
    deadlines: <ProxyBuyDeadline>[
      const ProxyBuyDeadline(endValue: 1, desc: '开放即代购'),
      const ProxyBuyDeadline(endValue: 10, desc: '开放支持后10分钟内'),
      const ProxyBuyDeadline(endValue: 30, desc: '开放支持后30分钟内'),
    ],
    turn: const ProxyBuyTurn(title: '第一场', timeStr: '2026-12-25 19:30'),
    compensationEnabled: true,
  );
}
