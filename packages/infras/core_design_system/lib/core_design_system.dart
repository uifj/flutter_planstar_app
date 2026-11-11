/// 三层设计令牌：L0 原始色板 → L1 语义槽 → L2 组件。
///
/// **刻意改动**：
/// 1. **配色**：品牌蓝 `themeLight6 (#1C66E5)` 为亮色主色，
///    暗色用 `themeDark6 (#4086FF)`；中性灰阶与绿/红/橙功能色成套提供。
/// 2. **用 `ThemeExtension<AppColors>`，不用 `InheritedNotifier`**。
///    顺带修掉两个缺陷（主题容器每次 rebuild 重置主题、
///    主题配置的 `operator==` 忽略 `type`）。
/// 3. **不做 HSL 调色换肤**：本应用只有一套品牌色，
///    暂不需要白标多主题；需要时再按 `AppColors.copyWith` 注入。
/// 4. 语义槽按本应用实际用到的 24 个收敛，音视频通话专属槽（通话气泡、标签色阶
///    等）不引入。
library;

export 'src/app_theme.dart';
export 'src/palette.dart';
export 'src/semantic_colors.dart';
export 'src/typography.dart';
