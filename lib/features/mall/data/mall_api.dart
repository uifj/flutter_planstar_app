import 'package:core/domain.dart';
import 'package:core/network.dart';
import 'package:core/result.dart';

import '../../../app/network/api_paths.dart';
import '../model/goods.dart';

/// 星币商城接口。
abstract interface class MallApi {
  /// 商品列表。
  Future<Result<List<Goods>>> fetchGoods();

  /// 商品详情。
  Future<Result<Goods>> fetchGoodsDetail(int id);

  /// 兑换指定规格。
  Future<Result<RedeemResult>> redeem({
    required int goodsId,
    required int skuId,
  });
}

/// 兑换结果（`POST v1/shop/goods/{id}/skus/{skuId}/redeem`）。
final class RedeemResult {
  const RedeemResult({
    required this.orderNo,
    required this.balance,
    required this.stock,
    required this.sold,
  });

  factory RedeemResult.fromJson(Map<String, dynamic> json) {
    return RedeemResult(
      orderNo: json['orderNo']?.toString() ?? '',
      balance: Money.fromMinorUnits(_asInt(json['balance']) ?? 0),
      stock: _asInt(json['stock']) ?? 0,
      sold: _asInt(json['sold']) ?? 0,
    );
  }

  final String orderNo;
  final Money balance;
  final int stock;
  final int sold;
}

/// 企划星商城接口实现。
final class PlanstarMallApi implements MallApi {
  const PlanstarMallApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<Result<List<Goods>>> fetchGoods() {
    return _client.get<List<Goods>>(
      ApiPaths.shopGoods,
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final items = _asMap(data)['items'];
        if (items is! List<dynamic>) return const <Goods>[];
        return items
            .whereType<Map<String, dynamic>>()
            .map(Goods.fromJson)
            .toList(growable: false);
      },
    );
  }

  @override
  Future<Result<Goods>> fetchGoodsDetail(int id) {
    return _client.get<Goods>(
      ApiPaths.shopGoodsDetail(id),
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => Goods.fromJson(_asMap(data)),
    );
  }

  @override
  Future<Result<RedeemResult>> redeem({
    required int goodsId,
    required int skuId,
  }) {
    return _client.post<RedeemResult>(
      ApiPaths.shopGoodsRedeem(goodsId, skuId),
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => RedeemResult.fromJson(_asMap(data)),
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map<Object?, Object?>) {
    return value.map(
      (Object? key, Object? item) => MapEntry<String, dynamic>('$key', item),
    );
  }
  return const <String, dynamic>{};
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
