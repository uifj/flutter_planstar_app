/// L2 装配：把 L0 色板与 L1 语义槽组装成 `ThemeData`。
///
/// 组件样式向 TUIKit（`atomic-x`）靠拢：直角卡片、8/20 圆角按钮、
/// 无阴影、灰底输入框、细描边。
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
    // 刻意**不用** `ColorScheme.fromSeed`：它会把品牌色派生成一套
    // "更协调"的色调，TUIKit 的蓝会失真。这里显式给出 ColorScheme。
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.brand,
      onPrimary: colors.onBrand,
      secondary: colors.info,
      onSecondary: colors.onBrand,
      error: colors.error,
      onError: colors.onBrand,
      surface: colors.bgCard,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.bgSubtle,
      outline: colors.border,
      outlineVariant: colors.divider,
    );

    final textTheme = _textTheme(colors);

    return ThemeData(
      colorScheme: scheme,
      // 语义槽通过 extensions 下发，组件用 `context.appColors` 取。
      extensions: <ThemeExtension<dynamic>>[colors],
      scaffoldBackgroundColor: colors.bgPage,
      canvasColor: colors.bgCard,
      dividerColor: colors.divider,
      fontFamily: null, // 系统字体
      textTheme: textTheme,
      iconTheme: IconThemeData(color: colors.textPrimary),
      primaryIconTheme: IconThemeData(color: colors.onBrand),
      disabledColor: colors.textDisabled,
      hintColor: colors.textTertiary,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        // TUIKit 顶栏与页面同底，靠分隔线分层。
        backgroundColor: colors.bgPage,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
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
            fontSize: AppTypography.label,
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
          disabledForegroundColor: colors.textDisabled,
          minimumSize: const Size.fromHeight(44),
          // TUIKit 主按钮是药丸（superLargeRadius = 20）。
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          textStyle: TextStyle(
            fontSize: AppTypography.body,
            fontWeight: AppTypography.medium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.brand,
          disabledForegroundColor: colors.textDisabled,
          minimumSize: const Size.fromHeight(44),
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: TextStyle(
            fontSize: AppTypography.body,
            fontWeight: AppTypography.medium,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.brand,
          disabledForegroundColor: colors.textDisabled,
          textStyle: TextStyle(
            fontSize: AppTypography.body,
            fontWeight: AppTypography.medium,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bgSubtle,
        hintStyle: TextStyle(
          fontSize: AppTypography.body,
          color: colors.textTertiary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: colors.brand),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: colors.error),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.bgCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.bgCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        titleTextStyle: TextStyle(
          fontSize: AppTypography.subtitle,
          fontWeight: AppTypography.medium,
          color: colors.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontSize: AppTypography.body,
          color: colors.textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.bgCard,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.bgCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.bgCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: TextStyle(
          fontSize: AppTypography.body,
          color: colors.textPrimary,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? colors.brand
              : colors.bgSubtle,
        ),
        checkColor: WidgetStatePropertyAll<Color>(colors.onBrand),
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? colors.onBrand
              : colors.bgCard,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? colors.brand
              : colors.border,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.brand,
        inactiveTrackColor: colors.border,
        thumbColor: colors.onBrand,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colors.tabActive,
        unselectedLabelColor: colors.tabInactive,
        indicatorColor: colors.brand,
        dividerColor: colors.divider,
        labelStyle: TextStyle(
          fontSize: AppTypography.body,
          fontWeight: AppTypography.medium,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppTypography.body,
          fontWeight: AppTypography.regular,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.brand,
        linearTrackColor: colors.border,
        circularTrackColor: colors.border,
      ),
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
