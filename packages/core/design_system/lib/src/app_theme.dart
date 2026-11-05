/// L2 装配：把 L0 色板与 L1 语义槽组装成 `ThemeData`。
library;

import 'package:flutter/material.dart';

import 'semantic_colors.dart';
import 'typography.dart';

/// 主题装配器。
///
/// 用法（应用壳里由 Riverpod 的 `Notifier<ThemeMode>` 驱动）：
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light(),
///   darkTheme: AppTheme.dark(),
///   themeMode: ref.watch(themeModeProvider),
/// )
/// ```
abstract final class AppTheme {
  /// 亮色主题。
  static ThemeData light() => _build(AppColors.light, Brightness.light);

  /// 暗色主题。
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    // 刻意**不用** `ColorScheme.fromSeed`：它会把品牌色变成一整套 Material
    // 派生的色调（primary 会被调成更"协调"的值），企划星的品牌红就会失真。
    // 这里显式给出 ColorScheme，只让 Material 组件拿到必要的槽位。
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.brand,
      onPrimary: colors.onBrand,
      secondary: colors.brandPressed,
      onSecondary: colors.onBrand,
      error: colors.error,
      onError: const Color(0xFFFFFFFF),
      surface: colors.bgCard,
      onSurface: colors.textPrimary,
    );

    final textTheme = _textTheme(colors);

    return ThemeData(
      colorScheme: scheme,
      // 语义槽通过 extensions 下发，组件用 `context.appColors` 取。
      extensions: <ThemeExtension<dynamic>>[colors],
      scaffoldBackgroundColor: colors.bgPage,
      canvasColor: colors.bgCard,
      dividerColor: colors.divider,
      fontFamily: null, // 全量使用系统字体（品牌字体 DIN 已移除）
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgCard,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppTypography.subtitle,
          fontWeight: AppTypography.medium,
          color: colors.textPrimary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 0.5,
        space: 0.5,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.bgCard,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) => TextStyle(
            fontSize: AppTypography.micro,
            fontWeight: states.contains(WidgetState.selected)
                ? AppTypography.medium
                : AppTypography.regular,
            color: states.contains(WidgetState.selected)
                ? colors.tabActive
                : colors.tabInactive,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? colors.tabActive
                : colors.tabInactive,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.brand,
          foregroundColor: colors.onBrand,
          disabledBackgroundColor: colors.brandDisabled,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: TextStyle(
            fontSize: AppTypography.body,
            fontWeight: AppTypography.medium,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.bgOverlay,
        contentTextStyle: TextStyle(
          fontSize: AppTypography.body,
          color: colors.onBrand,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static TextTheme _textTheme(AppColors colors) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: AppTypography.display,
        fontWeight: AppTypography.bold,
        color: colors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: AppTypography.title,
        fontWeight: AppTypography.bold,
        color: colors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: AppTypography.subtitle,
        fontWeight: AppTypography.medium,
        color: colors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: AppTypography.body,
        fontWeight: AppTypography.regular,
        color: colors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: AppTypography.caption,
        fontWeight: AppTypography.regular,
        color: colors.textTertiary,
      ),
      labelSmall: TextStyle(
        fontSize: AppTypography.label,
        fontWeight: AppTypography.regular,
        color: colors.textDisabled,
      ),
    );
  }
}
