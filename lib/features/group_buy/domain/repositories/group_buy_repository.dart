import 'package:core/result.dart';

import '../group_buy.dart';

/// 组队支持数据端口。
///
/// 演示 / 真实实现的切换由应用层的 `DataSourcePolicy` 决定。
abstract interface class GroupBuyRepository {
  /// 我的组队支持列表。
  Future<Result<List<GroupBuyInfo>>> fetchCampaigns();

  /// 组队支持详情；不存在返回成功且值为 `null`。
  Future<Result<GroupBuyInfo?>> fetchCampaign(int id);

  /// 参与组队（库存与状态校验在应用层用领域策略完成）。
  Future<Result<void>> join(int id);
}
