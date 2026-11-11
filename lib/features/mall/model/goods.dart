import 'package:core/domain.dart';

/// 商城商品（`GET v1/shop/goods`）。
final class Goods {
  const Goods({
    required this.goodsId,
    required this.name,
    required this.brief,
    required this.description,
    required this.cover,
    required this.skus,
  });

  factory Goods.fromJson(Map<String, dynamic> json) {
    final items = json['skus'];
    return Goods(
      goodsId: _asInt(json['goodsId']) ?? 0,
      name: json['name']?.toString() ?? '',
      brief: json['brief']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      skus: items is List<dynamic>
          ? items
                .whereType<Map<String, dynamic>>()
                .map(GoodsSku.fromJson)
                .toList(growable: false)
          : const <GoodsSku>[],
    );
  }

  final int goodsId;
  final String name;
  final String brief;
  final String description;
  final String cover;
  final List<GoodsSku> skus;
}

/// 商品规格。
final class GoodsSku {
  const GoodsSku({
    required this.skuId,
    required this.name,
    required this.priceCoins,
    required this.stock,
    required this.sold,
  });

  factory GoodsSku.fromJson(Map<String, dynamic> json) {
    return GoodsSku(
      skuId: _asInt(json['skuId']) ?? 0,
      name: json['name']?.toString() ?? '',
      priceCoins: _asInt(json['priceCoins']) ?? 0,
      stock: _asInt(json['stock']) ?? 0,
      sold: _asInt(json['sold']) ?? 0,
    );
  }

  final int skuId;
  final String name;

  /// 价格（星币个数）。
  ///
  /// 接口示例 `priceCoins=1000` 在 UI 上显示为「星币 1,000」，因此展示时
  /// 转成 [Money] 的最小单位（×100），而不是当成「分」直接除。
  final int priceCoins;

  /// 剩余库存。
  final int stock;

  /// 已兑数量。
  final int sold;

  /// 限量（初始库存）。
  int get totalStock => stock + sold;

  /// 是否名额已满（库存为 0）。
  bool get soldOut => stock <= 0;

  /// 展示价格。
  Money get price => Money.fromMinorUnits(priceCoins * 100);
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
