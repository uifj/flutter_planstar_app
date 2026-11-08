import 'package:flutter/foundation.dart';

/// 「企划创意」埋点事件名（与 Spec §4.12 一一对应）。
abstract final class ProjectIdeaEvents {
  /// 卡片曝光（`ideaId` / `position` / `tab`）。
  static const String ideaCardImpression = 'idea_card_impression';

  /// 支持入口点击。
  static const String ideaSupportClick = 'idea_support_click';

  /// 支持提交（`ideaId` / `tier`）。
  static const String ideaSupportSubmit = 'idea_support_submit';

  /// 不支持入口点击。
  static const String ideaOpposeClick = 'idea_oppose_click';

  /// 不支持提交（`ideaId` / `reasonCode`）。
  static const String ideaOpposeSubmit = 'idea_oppose_submit';

  /// 详情页浏览（`ideaId` / `from`）。
  static const String ideaDetailView = 'idea_detail_view';

  /// 叠卡流空态（`reason`）。
  static const String ideaFeedEmpty = 'idea_feed_empty';
}

/// 记录一条企划创意埋点。
///
/// 项目暂未接入分析 SDK，先统一走 [debugPrint]，等接入后只改这一处。
void trackProjectIdeaEvent(
  String name, [
  Map<String, Object?> params = const <String, Object?>{},
]) {
  debugPrint('[track] $name $params');
}
