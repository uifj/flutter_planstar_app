import 'package:flutter/widgets.dart';

import '../../l10n/l10n.dart';
import 'proxy_buy.dart';

/// 代抢展示文案的本地化映射。
extension ProxyBuyOrderL10n on ProxyBuyOrder {
  /// 状态文案。
  String statusLabelOf(BuildContext context) => switch (status) {
    ProxyBuyStatus.pending => context.l10n.proxyBuy_142,
    ProxyBuyStatus.inProgress => context.l10n.proxyBuy_144,
    ProxyBuyStatus.success => context.l10n.proxyBuy_146,
    ProxyBuyStatus.failed => context.l10n.proxyBuy_148,
    ProxyBuyStatus.cancelled => context.l10n.proxyBuy_150,
  };
}
