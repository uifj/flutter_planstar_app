import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 应用壳的主题入口。
///
/// 直接复用 `core_design_system` 的三层令牌装配（L0 色板 → L1 语义槽 →
/// L2 ThemeData）。视觉风格来自 TUIKit（`atomic-x`）：品牌蓝 #1C66E5、
/// 中性灰阶、药丸主按钮、8/12/16/20 圆角。
export 'package:core_design_system/core_design_system.dart'
    show AppColors, AppRadius, AppSpacing, AppTheme, AppTypography, BasePalette;

/// 主题模式控制器。`system` / `light` / `dark` 三态，默认跟随系统。
///
/// 持久化留给后续接入 `package:core/storage.dart`：把 [set] 里的赋值改成
/// `appStore.preferences.writeInt('themeMode', mode.index)`，
/// [build] 里读回来即可，**不要**在 Notifier 里直接调单例。
final class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  /// 显式设置。
  void set(ThemeMode mode) => state = mode;

  /// 在亮/暗之间切换（当前为 `system` 时切到与系统相反的一侧）。
  void toggle(Brightness platformBrightness) {
    state = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system =>
        platformBrightness == Brightness.dark
            ? ThemeMode.light
            : ThemeMode.dark,
    };
  }
}

/// 全局主题模式。
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
