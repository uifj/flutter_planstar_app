import 'package:flutter/widgets.dart';

import '../../../l10n/l10n.dart';
import '../application/group_buy_controller.dart';
import '../domain/group_buy.dart';

/// 拼团展示文案的本地化映射。
extension GroupBuyViewL10n on GroupBuyView {
  /// 标语标签：未配置时回落到默认「超低价拼团」。
  String tagLabelOf(BuildContext context) =>
      info.tag.isEmpty ? context.l10n.groupBuy_72 : info.tag;

  /// 折扣文案（如 `5.5折`）；无折扣返回空字符串。
  String discountLabelOf(BuildContext context) {
    final int? rate = discountRate;
    if (rate == null) return '';
    if (rate % 10 == 0) {
      return context.l10n.groupBuy_144(rate ~/ 10);
    }
    return context.l10n.groupBuy_145(rate / 10);
  }

  /// 状态文案。
  String statusLabelOf(BuildContext context) => switch (info.status) {
    GroupBuyStatus.grouping => context.l10n.groupBuy_155,
    GroupBuyStatus.success => context.l10n.groupBuy_157,
    GroupBuyStatus.failed => context.l10n.groupBuy_159,
    GroupBuyStatus.cancelled => context.l10n.groupBuy_161,
  };
}
