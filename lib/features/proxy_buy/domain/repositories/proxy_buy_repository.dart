import 'package:core/domain.dart';
import 'package:core/result.dart';

import '../proxy_buy.dart';

/// 代抢数据端口。
///
/// 演示 / 真实实现的切换由应用层的 `DataSourcePolicy` 决定，
/// 领域层不关心数据从哪来。
abstract interface class ProxyBuyRepository {
  /// 代抢规则（内嵌于企划详情；页面单独展示时使用默认规则）。
  Future<Result<ProxyBuyInfo>> fetchInfo();

  /// 我的代抢订单。
  Future<Result<List<ProxyBuyOrder>>> fetchOrders();

  /// 提交代抢订单，返回订单号。
  Future<Result<String>> submit({
    required ProxyBuyInfo info,
    required Money ticketPrice,
    required int quantity,
    required ProxyBuyDeadline deadline,
  });
}
