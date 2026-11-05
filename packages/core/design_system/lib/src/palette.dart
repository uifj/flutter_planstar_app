/// L0 原始色板。**只有这一层写死十六进制**。
library;

import 'dart:ui';

/// 品牌色板。
///
/// 全部取自企划星 Android `resources/res/values/colors.xml`，括号内是资源名。
/// 这些是**唯一**允许出现字面量的地方——上层只准引用语义槽。
abstract final class BrandPalette {
  /// 主品牌色（`ps_theme_color` = `#ffff317b`）。
  ///
  /// `⚠` 应用壳 `lib/app/theme.dart` 里当前写的是 `0xFFFF4F1F`（橙色），
  /// 与真实品牌色不符，应改为本值。
  static const Color primary = Color(0xFFFF317B);

  /// 品牌色按下态（`gradient_red_darker` = `#ffff2661`）。
  static const Color primaryPressed = Color(0xFFFF2661);

  /// 品牌浅色（`gradient_red_light` = `#ffff6ab9`）。
  static const Color primaryLight = Color(0xFFFF6AB9);

  /// 品牌更浅（`gradient_red_lighter` = `#ffff4e9a`）。
  static const Color primaryLighter = Color(0xFFFF4E9A);

  /// 品牌深色（`gradient_red_dark` = `#fffe3870`）。
  static const Color primaryDark = Color(0xFFFE3870);

  /// 禁用态品牌色（`disabled_red` = `#66ff2661`，40% 透明）。
  static const Color primaryDisabled = Color(0x66FF2661);

  /// 品牌色 20% 透明（`gradient_red_dark_alpha20` = `#33ff366d`）。
  static const Color primaryAlpha20 = Color(0x33FF366D);
}

/// 中性色板（文字与背景）。
///
/// 企划星用 `text_0..text_4` 五级文字色 + `divider*` 四级分隔线，是典型的
/// "五级文字 + 四级描边"体系，比 Material 的 onSurface 单槽更实用。
abstract final class NeutralPalette {
  /// 一级文字，标题（`text_0` = `#ff262626`）。
  static const Color text0 = Color(0xFF262626);

  /// 二级文字，正文（`text_1` = `#ff333333`）。
  static const Color text1 = Color(0xFF333333);

  /// 三级文字，次要说明（`text_2` = `#ff666666`）。
  static const Color text2 = Color(0xFF666666);

  /// 四级文字，辅助信息（`text_3` = `#ff999999`）。
  static const Color text3 = Color(0xFF999999);

  /// 五级文字，占位/禁用（`text_4` = `#ffd8d8d8`）。
  static const Color text4 = Color(0xFFD8D8D8);

  /// 页面背景（`bg_gray` = `#fff5f5f5`）。
  static const Color bgPage = Color(0xFFF5F5F5);

  /// 更浅的背景（`bg_gray1` = `#fff8f8fa`）。
  static const Color bgSubtle = Color(0xFFF8F8FA);

  /// 容器背景（`bg_color` = `#ffededed`）。
  static const Color bgContainer = Color(0xFFEDEDED);

  /// 卡片/白色（`white`）。
  static const Color surface = Color(0xFFFFFFFF);

  /// 标准分隔线（`divider` = `#fff2f2f2`）。
  static const Color divider = Color(0xFFF2F2F2);

  /// 更浅分隔线（`divider_light` = `#fff5f5f5`）。
  static const Color dividerLight = Color(0xFFF5F5F5);

  /// 更浅（`divider_lighter` = `#ffeaeaea`）。
  static const Color dividerLighter = Color(0xFFEAEAEA);

  /// 列表分隔线（`divider_list` = `#ffd4d4d4`）。
  static const Color dividerList = Color(0xFFD4D4D4);

  /// 遮罩（`bgColor_overlay` = `#60000000`）。
  static const Color overlay = Color(0x60000000);

  /// 半透明黑 80%（`black_alpha_80`）。
  static const Color blackAlpha80 = Color(0xCC000000);

  /// 半透明黑 50%（`black_alpha_50`）。
  static const Color blackAlpha50 = Color(0x80000000);
}

/// 功能色板（涨跌 / 成功 / 警告 / 提示）。
abstract final class FunctionalPalette {
  /// 价格红（`text_red_1` 系列，企划星用品牌红做价格）。
  static const Color price = Color(0xFFFF2661);

  /// 成功绿（`btn_green_noraml` = `#ff68c270`）。
  static const Color success = Color(0xFF68C270);

  /// 警告黄背景（`bg_yellow` = `#fffff2d8`）。
  static const Color warningBg = Color(0xFFFFF2D8);

  /// 信息蓝（`blue_text` = `#ff5a91f8`）。
  static const Color info = Color(0xFF5A91F8);

  /// 错误红（`btn_logout_normal` = `#ffd33f3f`）。
  static const Color error = Color(0xFFD33F3F);

  /// 骨架屏/占位灰。
  static const Color skeleton = Color(0xFFEDEDED);
}
