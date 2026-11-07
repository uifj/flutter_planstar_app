import '../domain/shipping_address.dart';

/// 演示收货地址。
///
/// 企划星从 `v1/address/list` 读。这里造两条，覆盖"默认 / 非默认"两种状态——
/// 只有一条时看不出"设为默认"这个动作到底改了什么。
List<ShippingAddress> buildDemoAddresses() {
  return const <ShippingAddress>[
    ShippingAddress(
      id: 'addr-1',
      name: '张伟',
      mobile: '13800138000',
      region: '上海市 浦东新区',
      detail: '世博大道 1200 号 梅赛德斯-奔驰文化中心 东门回报领取处',
      isDefault: true,
    ),
    ShippingAddress(
      id: 'addr-2',
      name: '李静',
      mobile: '13900139000',
      region: '上海市 黄浦区',
      detail: '人民大道 300 号 上海文化中心 1 号门',
    ),
  ];
}
