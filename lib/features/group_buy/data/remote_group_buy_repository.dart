import 'package:core/network.dart';
import 'package:core/result.dart';

import '../domain/group_buy.dart';
import '../domain/repositories/group_buy_repository.dart';
import 'group_buy_api.dart';

/// 真实数据仓储。
final class RemoteGroupBuyRepository implements GroupBuyRepository {
  RemoteGroupBuyRepository({required ApiClient client})
    : _api = GroupBuyApi(client: client);

  final GroupBuyApi _api;

  @override
  Future<Result<List<GroupBuyInfo>>> fetchCampaigns() => _api.fetchCampaigns();

  @override
  Future<Result<GroupBuyInfo?>> fetchCampaign(int id) => _api.fetchCampaign(id);

  @override
  Future<Result<void>> join(int id) => _api.join(id);
}
