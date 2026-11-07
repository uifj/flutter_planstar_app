import 'package:core/domain.dart';
import 'package:core/network.dart';
import 'package:core/result.dart';

import '../domain/proxy_buy.dart';
import '../domain/repositories/proxy_buy_repository.dart';
import 'proxy_buy_api.dart';
import 'proxy_buy_defaults.dart';

/// 真实数据仓储：订单走 `v1/proxyBuyOrder/myOrders`。
///
/// 代抢规则与提交接口后端尚未提供，分别使用默认规则和明确的失败结果，
/// 不静默伪造成功。
final class RemoteProxyBuyRepository implements ProxyBuyRepository {
  RemoteProxyBuyRepository({required ApiClient client})
    : _api = ProxyBuyApi(client: client);

  final ProxyBuyApi _api;

  @override
  Future<Result<ProxyBuyInfo>> fetchInfo() async =>
      Success<ProxyBuyInfo>(ProxyBuyDefaults.info);

  @override
  Future<Result<List<ProxyBuyOrder>>> fetchOrders() => _api.fetchOrders();

  @override
  Future<Result<String>> submit({
    required ProxyBuyInfo info,
    required Money ticketPrice,
    required int quantity,
    required ProxyBuyDeadline deadline,
  }) async {
    return const Result<String>.failure(
      Failure.input(message: '当前版本暂不支持在线提交代购订单'),
    );
  }
}
