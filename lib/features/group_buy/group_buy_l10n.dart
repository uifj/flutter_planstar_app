import 'package:flutter/widgets.dart';

import '../../l10n/l10n.dart';
import 'group_buy.dart';

/// 拼团展示文案的本地化映射。
extension GroupBuyInfoL10n on GroupBuyInfo {
  /// 标语标签：未配置时回落到默认「超低价拼团」。
  String tagLabelOf(BuildContext context) =>
      tag.isEmpty ? context.l10n.groupBuy_72 : tag;

  /// 折扣文案（如 `5.5折`）；无折扣返回空字符串。
  String discountLabelOf(BuildContext context) {
    if (originalPrice.minorUnits <= 0) return '';
    final rate = (lowPrice.minorUnits * 10) ~/ originalPrice.minorUnits;
    if (rate >= 10) return '';
    if (rate % 10 == 0) {
      return context.l10n.groupBuy_144(rate ~/ 10);
    }
    return context.l10n.groupBuy_145(rate / 10);
  }

  /// 状态文案。
  String statusLabelOf(BuildContext context) => switch (status) {
    GroupBuyStatus.grouping => context.l10n.groupBuy_155,
    GroupBuyStatus.success => context.l10n.groupBuy_157,
    GroupBuyStatus.failed => context.l10n.groupBuy_159,
    GroupBuyStatus.cancelled => context.l10n.groupBuy_161,
  };
}
