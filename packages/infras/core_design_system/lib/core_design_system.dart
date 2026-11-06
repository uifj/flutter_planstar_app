/// 三层设计令牌：L0 原始色板 → L1 语义槽 → L2 组件。
///
/// 设计来源：TUIKit `atomic-x/lib/base_component/theme/`
/// （`colors.dart` 基础色阶 · `color_scheme.dart` 语义槽 · `font.dart` 字号阶梯
/// · `radius.dart` 圆角 · `spacing.dart` 间距）。
///
/// 相对来源的**刻意改动**：
/// 1. **保留来源配色**：品牌蓝 `themeLight6 (#1C66E5)` 为亮色主色，
///    暗色用 `themeDark6 (#4086FF)`；中性灰阶、绿/红/橙功能色全部沿用。
/// 2. **`InheritedNotifier<ThemeState>` → `ThemeExtension<AppColors>`**。
///    顺带修掉来源的两个缺陷（`ComponentTheme` 每次 rebuild 重置主题、
///    `ThemeConfig.operator==` 忽略 `type`）。
/// 3. **不做 `ThemeColorGenerator`（HSL 调色换肤）**：本应用只有一套品牌色，
///    暂不需要白标多主题；需要时再按 `AppColors.copyWith` 注入。
/// 4. 语义槽按本应用实际用到的 24 个收敛，TRTC 专属槽（通话气泡、标签色阶
///    等）不搬。
library;

export 'src/app_theme.dart';
export 'src/palette.dart';
export 'src/semantic_colors.dart';
export 'src/typography.dart';
