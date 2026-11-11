import 'package:flutter/widgets.dart';

import '../../../l10n/l10n.dart';
import '../domain/show_category.dart';
import '../domain/show_summary.dart';

/// 企划展示文案的本地化映射。
///
/// Domain 层只保留纯数据，所有面向用户的文案在这里按 `BuildContext` 解析。
extension ShowSummaryL10n on ShowSummary {
  /// `9.8折` 角标文案；无折扣返回 `null`。
  String? discountLabelOf(BuildContext context) {
    final permille = discountPermille;
    if (permille == null || permille <= 0 || permille >= 1000) return null;
    final tenth = permille / 100;
    final text = tenth == tenth.roundToDouble()
        ? tenth.toStringAsFixed(0)
        : tenth.toStringAsFixed(1);
    return context.l10n.showSummary_165(text);
  }

  /// 首个线下回报场次时间：`11月8日 周日 19:30`。
  String firstSessionLabelOf(BuildContext context) =>
      formatSessionLabelL10n(context, firstSessionAt);

  /// 支持状态文案（支持中 / 名额已满）。
  String saleStatusLabelOf(BuildContext context) =>
      soldOut ? context.l10n.showSummary_178 : context.l10n.showSummary_178_2;
}

extension VenueSummaryL10n on VenueSummary {
  /// 副标题：`浦东新区 · 12 个企划`。
  String subtitleOf(BuildContext context) =>
      context.l10n.showCategory_95(address, showCount);
}

/// 线下回报场次时间格式：`11月8日 周日 19:30`。
String formatSessionLabelL10n(BuildContext context, DateTime time) {
  final l10n = context.l10n;
  final weekday = switch (time.weekday) {
    DateTime.monday => l10n.showSummary_263,
    DateTime.tuesday => l10n.showSummary_263_2,
    DateTime.wednesday => l10n.showSummary_263_3,
    DateTime.thursday => l10n.showSummary_263_4,
    DateTime.friday => l10n.showSummary_263_5,
    DateTime.saturday => l10n.showSummary_263_6,
    _ => l10n.showSummary_263_7,
  };
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return l10n.showSummary_266(time.month, time.day, weekday, hour, minute);
}
