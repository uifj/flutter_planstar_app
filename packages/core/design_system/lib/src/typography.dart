/// 字号与字重令牌 + 数字字体。
library;

import 'package:flutter/material.dart';

/// 字号与字重。
///
/// 企划星 Android 侧字号散落在各 layout 的 `sp` 值里，没有集中定义；这里是
/// 按现有页面的实际使用归纳出的七级阶梯，**不是**从资源文件抄来的。
abstract final class AppTypography {
  /// 数字/价格字体族。本地品牌字体 DIN 已随 `assets/` 一并移除，
  /// 改为 `null`（系统字体），等宽效果由 `FontFeature.tabularFigures` 保证。
  static const String? numericFontFamily = null;

  /// 超大号：详情页主价格、倒计时。
  static const double display = 28;

  /// 标题：页面标题。
  static const double title = 20;

  /// 小标题：卡片标题、分组头。
  static const double subtitle = 16;

  /// 正文：列表项主文案。
  static const double body = 14;

  /// 辅助：次要说明。
  static const double caption = 12;

  /// 标签：角标、徽标。
  static const double label = 11;

  /// 最小：极小角标。
  static const double micro = 10;

  /// 常规字重。
  static const FontWeight regular = FontWeight.w400;

  /// 中等字重（强调）。
  static const FontWeight medium = FontWeight.w500;

  /// 粗体（价格、标题）。
  static const FontWeight bold = FontWeight.w700;

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
abstract final class AppRadius {
  /// 2：极小元素（标签内边距）。
  static const double xs = 2;

  /// 4：输入框、按钮。
  static const double sm = 4;

  /// 6：卡片内的图片。
  static const double md = 6;

  /// 8：卡片。
  static const double lg = 8;

  /// 12：弹窗、底部面板。
  static const double xl = 12;

  /// 16：大面板。
  static const double xxl = 16;

  /// 全圆（药丸按钮、头像）。
  static const double full = 999;
}

/// 间距令牌。以 4 为基准的八级阶梯。
abstract final class AppSpacing {
  /// 2。
  static const double xxs = 2;

  /// 4。
  static const double xs = 4;

  /// 6。
  static const double sm = 6;

  /// 8。
  static const double md = 8;

  /// 12。
  static const double lg = 12;

  /// 16：页面左右边距。
  static const double xl = 16;

  /// 20。
  static const double xxl = 20;

  /// 24：区块间距。
  static const double section = 24;

  /// 32：大区块间距。
  static const double huge = 32;

  /// 页面水平内边距（列表页统一 12）。
  static const double pageHorizontal = 12;
}
