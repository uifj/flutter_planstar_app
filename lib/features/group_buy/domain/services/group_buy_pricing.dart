import 'package:core/domain.dart';

import '../group_buy.dart';

/// 组队支持价格策略（纯函数）。
///
/// 折扣文案的分档（`5.5 折` / `6 折`）是展示格式，放在 UI 的 l10n 扩展里；
/// 这里只给出**折扣档位数值**与金额，不在页面里做除法。
final class GroupBuyPricing {
  const GroupBuyPricing();

  /// 是否有折扣（原价高于组队支持价）。
  bool hasDiscount(GroupBuyInfo info) =>
      info.originalPrice.minorUnits > info.lowPrice.minorUnits;

  /// 节省金额。
  Money savedAmount(GroupBuyInfo info) => info.originalPrice - info.lowPrice;

  /// 折扣档位。
  ///
  /// 计算口径：`组队价(分) * 10 ~/ 原价(分)`，取值 0–9，由 UI 的 l10n
  /// 扩展决定展示成 `{rate}折` 或 `{rate / 10}折`。
  /// 无原价或没有折扣时返回 `null`。
  int? discountRate(GroupBuyInfo info) {
    if (info.originalPrice.minorUnits <= 0) return null;
    final int rate =
        (info.lowPrice.minorUnits * 10) ~/ info.originalPrice.minorUnits;
    if (rate >= 10) return null;
    return rate < 0 ? 0 : rate;
  }
}
