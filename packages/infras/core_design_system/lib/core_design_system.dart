/// 三层设计令牌：L0 原始色板 → L1 语义槽 → L2 组件。
///
/// 设计来源：`appunits_core` 的 `base_component/theme/`
/// （`colors.dart` 46+ 常量 · `color_scheme.dart` 80 个语义槽 · `font.dart` 36 槽
/// · `radius.dart` 6 槽 · `spacing.dart` 10 槽 · `theme_state.dart` 1,000+ 行）
/// （见 `wiki_zh/30-flutter-adoptable-designs.md` §3.3）。
///
/// 相对来源的**刻意改动**：
/// 1. **配色全换**。来源是 TRTC 的中性灰阶 + 蓝绿红橙四组品牌色，与企划星视觉
///    无关。这里 [BrandPalette] / [NeutralPalette] / [FunctionalPalette]
///    的每个值都注明取自企划星 `resources/res/values/colors.xml` 的哪个资源名。
/// 2. **`InheritedNotifier<ThemeState>` → `ThemeExtension<AppColors>`**。
///    顺带修掉 30-09（`ComponentTheme` 每次 rebuild 重置主题）与
///    30-10（`ThemeConfig.operator==` 忽略 `type`）。
/// 3. **不做 `ThemeColorGenerator`（HSL 调色）**。来源那套是为白标/多品牌
///    换肤准备的；企划星只有一套品牌色，抄过来只是多 300 行需要维护的代码。
/// 4. 语义槽从 80 个收到 24 个。来源的 80 个槽里有大量 TRTC 专属
///    （`bgColorAudioRoom` 之类），企划星用不上。
library;

export 'src/app_theme.dart';
export 'src/palette.dart';
export 'src/semantic_colors.dart';
export 'src/typography.dart';
