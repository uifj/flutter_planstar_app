import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 应用壳的主题入口。
///
/// 这里**不再自己定义 `AppTheme`**，而是直接复用 `core_design_system` 的
/// 三层令牌装配（L0 色板 → L1 语义槽 → L2 ThemeData）。
///
/// `⚠` 旧版本这里写的是 `brand = Color(0xFFFF4F1F)`（橙色）+ `ColorScheme.fromSeed`。
/// 两处都不对：
/// 1. 企划星的真实品牌色是 `ps_theme_color = #FFFF317B`（洋红），不是橙色；
/// 2. `fromSeed` 会把品牌色派生成一套"更协调"的色调，品牌红会失真。
/// 现已由 [BrandPalette.primary] 与 [AppTheme] 的显式 `ColorScheme` 取代。
export 'package:core_design_system/core_design_system.dart'
    show
        AppColors,
        AppRadius,
        AppSpacing,
        AppTheme,
        AppTypography,
        BrandPalette,
        FunctionalPalette,
        NeutralPalette;

/// 主题模式控制器。`system` / `light` / `dark` 三态，默认跟随系统。
///
/// 持久化留给后续接入 `core_storage`：把 [set] 里的赋值改成
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
      ThemeMode.system => platformBrightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark,
    };
  }
}

/// 全局主题模式。
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
