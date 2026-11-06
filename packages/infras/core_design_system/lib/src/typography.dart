/// 字号与字重令牌 + 数字字体。
///
/// 阶梯对齐 TUIKit（`base_component/theme/font.dart`）：
/// 标题 32/20、小标题 16、正文 14、说明 12、角标 10；字重只保留
/// bold / medium / regular 三档。
library;

import 'package:flutter/material.dart';

/// 字号与字重。
abstract final class AppTypography {
  /// 数字/价格字体族。使用系统字体，等宽效果由
  /// [FontFeature.tabularFigures] 保证。
  static const String? numericFontFamily = null;

  /// 超大号：详情页主价格、大数字。
  static const double display = 32;

  /// 标题：页面标题。
  static const double title = 20;

  /// 小标题：卡片标题、分组头。
  static const double subtitle = 16;

  /// 正文：列表项主文案。
  static const double body = 14;

  /// 辅助：次要说明。
  static const double caption = 12;

  /// 标签：角标、徽标。
  static const double label = 10;

  /// 最小：极小角标。
  static const double micro = 10;

  /// 常规字重。
  static const FontWeight regular = FontWeight.normal;

  /// 中等字重（强调）。
  static const FontWeight medium = FontWeight.w500;

  /// 粗体（价格、标题）。
  static const FontWeight bold = FontWeight.bold;

  /// 数字展示样式（系统字体 + 粗体 + 紧行高）。
  ///
  /// 价格用 `fontFeatures: tabularFigures` 让数字等宽，
  /// 避免"¥88"与"¥188"在列表中左右跳动。
  static TextStyle numeric({
    required double size,
    required Color color,
    FontWeight weight = bold,
  }) {
    return TextStyle(
      fontFamily: numericFontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.1,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
  }
}

/// 圆角令牌。
///
/// 对齐 TUIKit（`radius.dart`）：4 / 8 / 12 / 16 / 20 / 999。
abstract final class AppRadius {
  /// 4：提示条、小标签（TUIKit `tipsRadius`）。
  static const double xs = 4;

  /// 8：输入框、小按钮（TUIKit `smallRadius`）。
  static const double sm = 8;

  /// 12：弹窗、卡片（TUIKit `alertRadius`）。
  static const double md = 12;

  /// 16：大卡片、面板（TUIKit `largeRadius`）。
  static const double lg = 16;

  /// 20：底部面板、药丸按钮（TUIKit `superLargeRadius`）。
  static const double xl = 20;

  /// 20：与 [xl] 同值，保留旧名以兼容既有调用。
  static const double xxl = 20;

  /// 全圆（头像、药丸）。
  static const double full = 999;
}

/// 间距令牌。
///
/// 对齐 TUIKit（`spacing.dart`）的 4 基准阶梯：
/// 4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 56 / 72。
abstract final class AppSpacing {
  /// 4：图标与文字。
  static const double xxs = 4;

  /// 8：小间距。
  static const double xs = 8;

  /// 12：图标之间。
  static const double sm = 12;

  /// 16：模块内部。
  static const double md = 16;

  /// 20：内容区。
  static const double lg = 20;

  /// 24：常规布局。
  static const double xl = 24;

  /// 32：标题区。
  static const double xxl = 32;

  /// 40：卡片区。
  static const double section = 40;

  /// 56：大区块。
  static const double huge = 56;

  /// 页面水平内边距。
  static const double pageHorizontal = 16;
}
