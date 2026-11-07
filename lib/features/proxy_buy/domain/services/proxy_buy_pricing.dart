import 'package:core/domain.dart';

import '../proxy_buy.dart';

/// 代抢服务费档位。
///
/// 按**单张票价**分档：票价达到 [minTicketPrice] 时使用该档的 [fee]。
/// 档位可乱序传入，构造时会按门槛从高到低排序。
final class ProxyBuyFeeTier {
  const ProxyBuyFeeTier({required this.minTicketPrice, required this.fee});

  /// 该档适用的最低单张票价（含）。
  final Money minTicketPrice;

  /// 该档每张票的服务费。
  final Money fee;
}

/// 一次代抢报价。
final class ProxyBuyQuote {
  const ProxyBuyQuote({
    required this.ticketPrice,
    required this.quantity,
    required this.unitServiceFee,
    required this.ticketAmount,
    required this.serviceFee,
    required this.totalAmount,
  });

  final Money ticketPrice;
  final int quantity;

  /// 每张票的服务费。
  final Money unitServiceFee;

  /// 票价小计。
  final Money ticketAmount;

  /// 服务费小计。
  final Money serviceFee;

  /// 合计（票价 + 服务费）。
  final Money totalAmount;
}

/// 代抢定价服务（纯函数，无状态）。
///
/// 对齐 Android `ProxyBuyHelper.calculateTotalPrice`：
/// `(salePrice * count) + (proxyBuyFee * count)`。
/// 与 Android 的差异：服务费可以按票价分档，`ProxyBuyPricing.flat` /
/// `ProxyBuyPricing.fromInfo` 则退化为原来的单一费率。
final class ProxyBuyPricing {
  ProxyBuyPricing(Iterable<ProxyBuyFeeTier> tiers) : _tiers = _sorted(tiers);

  /// 单一费率（等价于原 `ProxyBuyInfo.proxyBuyFee * count`）。
  factory ProxyBuyPricing.flat(Money fee) => ProxyBuyPricing(<ProxyBuyFeeTier>[
    ProxyBuyFeeTier(minTicketPrice: const Money.zero(), fee: fee),
  ]);

  /// 从规则信息构造：当前接口只给单一费率。
  factory ProxyBuyPricing.fromInfo(ProxyBuyInfo info) =>
      ProxyBuyPricing.flat(info.proxyBuyFee);

  /// 按门槛从高到低排列的档位。
  final List<ProxyBuyFeeTier> _tiers;

  List<ProxyBuyFeeTier> get tiers => _tiers;

  /// 取单张票对应的服务费。
  Money feeFor(Money ticketPrice) {
    for (final ProxyBuyFeeTier tier in _tiers) {
      if (ticketPrice.minorUnits >= tier.minTicketPrice.minorUnits) {
        return tier.fee;
      }
    }
    // `_sorted` 保证最低门槛档兜底；正常不会走到这里。
    return _tiers.last.fee;
  }

  /// 生成报价。数量必须为正数。
  ProxyBuyQuote quote({required Money ticketPrice, required int quantity}) {
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', '代购份数必须为正数');
    }
    final Money unitServiceFee = feeFor(ticketPrice);
    final Money ticketAmount = ticketPrice * quantity;
    final Money serviceFee = unitServiceFee * quantity;
    return ProxyBuyQuote(
      ticketPrice: ticketPrice,
      quantity: quantity,
      unitServiceFee: unitServiceFee,
      ticketAmount: ticketAmount,
      serviceFee: serviceFee,
      totalAmount: ticketAmount + serviceFee,
    );
  }

  /// 计算总费用（原 `ProxyBuyInfo.calculateTotal` 的替代入口）。
  Money total({required Money ticketPrice, required int quantity}) =>
      quote(ticketPrice: ticketPrice, quantity: quantity).totalAmount;

  static List<ProxyBuyFeeTier> _sorted(Iterable<ProxyBuyFeeTier> tiers) {
    final List<ProxyBuyFeeTier> sorted = tiers.toList(growable: false)
      ..sort(
        (ProxyBuyFeeTier a, ProxyBuyFeeTier b) =>
            b.minTicketPrice.minorUnits.compareTo(a.minTicketPrice.minorUnits),
      );
    if (sorted.isEmpty) {
      throw ArgumentError.value(tiers, 'tiers', '至少需要一个服务费档位');
    }
    return List<ProxyBuyFeeTier>.unmodifiable(sorted);
  }
}
