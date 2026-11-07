import 'package:core/result.dart';

import '../domain/group_buy.dart';
import '../domain/repositories/group_buy_repository.dart';
import 'demo_group_buy.dart';

/// 演示仓储：内存拼团数据，参团只模拟一次网络往返。
final class DemoGroupBuyRepository implements GroupBuyRepository {
  @override
  Future<Result<List<GroupBuyInfo>>> fetchCampaigns() async =>
      Success<List<GroupBuyInfo>>(
        List<GroupBuyInfo>.unmodifiable(DemoGroupBuy.campaigns),
      );

  @override
  Future<Result<GroupBuyInfo?>> fetchCampaign(int id) async =>
      Success<GroupBuyInfo?>(
        DemoGroupBuy.campaigns
            .where((GroupBuyInfo group) => group.id == id)
            .firstOrNull,
      );

  @override
  Future<Result<void>> join(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return const Success<void>(null);
  }
}
