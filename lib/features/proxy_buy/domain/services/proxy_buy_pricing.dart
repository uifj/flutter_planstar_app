import 'package:core/domain.dart';

import '../proxy_buy.dart';

/// 服务费档位。
///
/// 按**单份价格**分档：单价达到 [minTicketPrice] 时使用该档的 [fee]。
/// 档位可乱序传入，构造时会按门槛从高到低排序。
final class ProxyBuyFeeTier {
  const ProxyBuyFeeTier({required this.minTicketPrice, required this.fee});

  /// 该档适用的最低单份价格（含）。
  final Money minTicketPrice;

  /// 该档每份的服务费。
  final Money fee;
}

/// 一次报价。
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

  /// 每份的服务费。
  final Money unitServiceFee;

  /// 单价小计。
  final Money ticketAmount;

  /// 服务费小计。
  final Money serviceFee;

  /// 合计（单价小计 + 服务费）。
  final Money totalAmount;
}

/// 代抢定价服务（纯函数，无状态）。
///
/// 总价 = `(单价 × 数量) + (服务费 × 数量)`。
/// 服务费可以按单价分档，`ProxyBuyPricing.flat` /
/// `ProxyBuyPricing.fromInfo` 则退化为单一费率。
final class ProxyBuyPricing {
  ProxyBuyPricing(Iterable<ProxyBuyFeeTier> tiers) : _tiers = _sorted(tiers);

  /// 单一费率（等价于 `ProxyBuyInfo.proxyBuyFee * count`）。
  factory ProxyBuyPricing.flat(Money fee) => ProxyBuyPricing(<ProxyBuyFeeTier>[
    ProxyBuyFeeTier(minTicketPrice: const Money.zero(), fee: fee),
  ]);

  /// 从规则信息构造：当前接口只给单一费率。
  factory ProxyBuyPricing.fromInfo(ProxyBuyInfo info) =>
      ProxyBuyPricing.flat(info.proxyBuyFee);

  /// 按门槛从高到低排列的档位。
  final List<ProxyBuyFeeTier> _tiers;

  List<ProxyBuyFeeTier> get tiers => _tiers;

  /// 取单份对应的服务费。
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

  /// 计算总费用（[quote] 的便捷入口）。
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
