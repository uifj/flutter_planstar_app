import 'package:core/result.dart';

import '../group_buy.dart';

/// 拼团数据端口。
///
/// 演示 / 真实实现的切换由应用层的 `DataSourcePolicy` 决定。
abstract interface class GroupBuyRepository {
  /// 我的拼团列表。
  Future<Result<List<GroupBuyInfo>>> fetchCampaigns();

  /// 拼团详情；不存在返回成功且值为 `null`。
  Future<Result<GroupBuyInfo?>> fetchCampaign(int id);

  /// 参团（库存与状态校验在应用层用领域策略完成）。
  Future<Result<void>> join(int id);
}
