import 'package:flutter/widgets.dart';

import '../../l10n/l10n.dart';
import 'domain/search_models.dart';

/// 搜索展示文案的本地化映射。
extension SearchScopeL10n on SearchScope {
  String labelOf(BuildContext context) => switch (this) {
    SearchScope.all => context.l10n.searchModels_14,
    SearchScope.shows => context.l10n.searchModels_15,
    SearchScope.feeds => context.l10n.searchModels_16,
  };
}

extension HotKeywordL10n on HotKeyword {
  /// 热度文案：`3.2万` / `9600`。
  String hitLabelOf(BuildContext context) {
    if (hitCount >= 10000) {
      return context.l10n.searchModels_43(
        (hitCount / 10000).toStringAsFixed(1),
      );
    }
    return '$hitCount';
  }
}
