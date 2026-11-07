import 'package:core/domain.dart';
import 'package:core/result.dart';

import '../domain/proxy_buy.dart';
import '../domain/repositories/proxy_buy_repository.dart';
import 'demo_proxy_buy.dart';
import 'proxy_buy_defaults.dart';

/// 演示仓储：规则用默认配置，订单用内存数据，提交只生成订单号。
final class DemoProxyBuyRepository implements ProxyBuyRepository {
  @override
  Future<Result<ProxyBuyInfo>> fetchInfo() async =>
      Success<ProxyBuyInfo>(ProxyBuyDefaults.info);

  @override
  Future<Result<List<ProxyBuyOrder>>> fetchOrders() async =>
      Success<List<ProxyBuyOrder>>(
        List<ProxyBuyOrder>.unmodifiable(DemoProxyBuy.orders),
      );

  @override
  Future<Result<String>> submit({
    required ProxyBuyInfo info,
    required Money ticketPrice,
    required int quantity,
    required ProxyBuyDeadline deadline,
  }) async {
    // 演示模式下模拟一次网络往返，保持提交中的加载态可见。
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final String orderNumber =
        'PB${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    return Success<String>(orderNumber);
  }
}
