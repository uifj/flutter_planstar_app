import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../../marketing/wallet_providers.dart';
import '../../user/application/profile_providers.dart';
import '../data/mall_api.dart';
import '../model/goods.dart';

/// 商城接口客户端。
final mallApiProvider = Provider<MallApi>(
  (ref) => PlanstarMallApi(client: ref.watch(apiClientProvider)),
);

/// 商城商品列表。
///
/// 真实模式请求 `GET v1/shop/goods`；demo 模式返回本地演示商品。
final mallGoodsProvider = FutureProvider<List<Goods>>((ref) async {
  if (ref.watch(dataSourcePolicyProvider).isDemo) {
    return DemoMall.all;
  }
  final result = await ref.watch(mallApiProvider).fetchGoods();
  return result.fold(
    onSuccess: (List<Goods> goods) => goods,
    onFailure: (failure) => throw failure,
  );
});

/// demo 商城数据。
final class DemoMall {
  DemoMall._();

  static const Goods goods = Goods(
    goodsId: 1,
    name: '企划星UP主的祝福视频',
    brief: '为你定制一段专属祝福视频',
    description: '由企划星UP主录制的专属祝福视频，下单后 7 个工作日内完成。',
    cover: '',
    skus: <GoodsSku>[
      GoodsSku(skuId: 1, name: '30秒祝福视频', priceCoins: 50, stock: 500, sold: 0),
      GoodsSku(skuId: 2, name: '60秒祝福视频', priceCoins: 100, stock: 0, sold: 500),
    ],
  );

  static const List<Goods> all = <Goods>[goods];
}

/// 兑换提交控制器；`state` 表示是否正在兑换。
class MallController extends Notifier<bool> {
  @override
  bool build() => false;

  /// 成功返回 `null`，失败返回接口 message。
  Future<String?> redeem(Goods goods, GoodsSku sku) async {
    if (state) return '兑换处理中，请稍候';
    state = true;
    try {
      if (ref.read(dataSourcePolicyProvider).isDemo) {
        ref.invalidate(mallGoodsProvider);
        ref.invalidate(walletProvider);
        ref.invalidate(userProfileProvider);
        return null;
      }

      final result = await ref
          .read(mallApiProvider)
          .redeem(goodsId: goods.goodsId, skuId: sku.skuId);
      if (result.isFailure) {
        return result.failure!.message;
      }

      ref.invalidate(mallGoodsProvider);
      ref.invalidate(walletProvider);
      ref.invalidate(userProfileProvider);
      return null;
    } finally {
      state = false;
    }
  }
}

final mallControllerProvider = NotifierProvider<MallController, bool>(
  MallController.new,
);
