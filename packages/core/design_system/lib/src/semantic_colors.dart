/// L1 语义槽：组件**只准引用这一层**。
library;

import 'package:flutter/material.dart';

import 'palette.dart';

/// 语义色方案，以 [ThemeExtension] 形式挂在 `ThemeData.extensions` 上。
///
/// 为什么是 `ThemeExtension` 而不是来源的 `InheritedNotifier<ThemeState>`：
///
/// 1. 来源的 `ComponentTheme`（`theme_state.dart:699`）在构造函数初始化列表里
///    写 `themeState = themeState ?? ThemeState()`，而它是 `StatelessWidget`，
///    **父级每次 rebuild 都会 new 一个 `ThemeState`**，主题被重置为默认（30-09）。
///    `ThemeExtension` 由 `ThemeData` 持有，不存在这个问题。
/// 2. 来源的 `ThemeConfig.operator==` 只比 `primaryColor`、忽略 `type`（30-10）。
///    [AppColors] 是 `@immutable` 值对象，由 Flutter 框架用 `==` 比较，
///    字段全参与比较，不会有"缓存命中判断失效"。
/// 3. 与 Riverpod 天然配合：主题由 `Notifier<ThemeMode>` 决定，
///    `MaterialApp.theme` 消费它，`AppColors` 通过 `Theme.of(context)` 下发。
///
/// 取用：
/// ```dart
/// final colors = Theme.of(context).extension<AppColors>()!;
/// Text('¥880', style: TextStyle(color: colors.price));
/// ```
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  /// 创建语义色方案。
  const AppColors({
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.bgPage,
    required this.bgCard,
    required this.bgSubtle,
    required this.bgOverlay,
    required this.divider,
    required this.border,
    required this.brand,
    required this.brandPressed,
    required this.brandDisabled,
    required this.brandSubtle,
    required this.onBrand,
    required this.price,
    required this.success,
    required this.warning,
    required this.warningBg,
    required this.error,
    required this.info,
    required this.skeleton,
    required this.tabActive,
    required this.tabInactive,
  });

  /// 一级文字（标题）。
  final Color textPrimary;

  /// 二级文字（正文）。
  final Color textSecondary;

  /// 三级文字（次要说明）。
  final Color textTertiary;

  /// 禁用/占位文字。
  final Color textDisabled;

  /// 页面背景。
  final Color bgPage;

  /// 卡片/容器背景。
  final Color bgCard;

  /// 次级背景。
  final Color bgSubtle;

  /// 遮罩。
  final Color bgOverlay;

  /// 分隔线。
  final Color divider;

  /// 描边。
  final Color border;

  /// 品牌主色。
  final Color brand;

  /// 品牌色按下态。
  final Color brandPressed;

  /// 品牌色禁用态。
  final Color brandDisabled;

  /// 品牌色淡背景（标签、选中底）。
  final Color brandSubtle;

  /// 品牌色之上的文字/图标色。
  final Color onBrand;

  /// 价格色。
  final Color price;

  /// 成功。
  final Color success;

  /// 警告。
  final Color warning;

  /// 警告背景。
  final Color warningBg;

  /// 错误。
  final Color error;

  /// 信息。
  final Color info;

  /// 骨架屏。
  final Color skeleton;

  /// 选中态 Tab。
  final Color tabActive;

  /// 未选中 Tab。
  final Color tabInactive;

  /// 亮色方案。数值全部来自企划星 Android 资源。
  static const AppColors light = AppColors(
    textPrimary: NeutralPalette.text0,
    textSecondary: NeutralPalette.text1,
    textTertiary: NeutralPalette.text2,
    textDisabled: NeutralPalette.text3,
    bgPage: NeutralPalette.bgPage,
    bgCard: NeutralPalette.surface,
    bgSubtle: NeutralPalette.bgSubtle,
    bgOverlay: NeutralPalette.overlay,
    divider: NeutralPalette.divider,
    border: NeutralPalette.dividerList,
    brand: BrandPalette.primary,
    brandPressed: BrandPalette.primaryPressed,
    brandDisabled: BrandPalette.primaryDisabled,
    brandSubtle: BrandPalette.primaryAlpha20,
    onBrand: NeutralPalette.surface,
    price: FunctionalPalette.price,
    success: FunctionalPalette.success,
    warning: FunctionalPalette.warningBg,
    warningBg: FunctionalPalette.warningBg,
    error: FunctionalPalette.error,
    info: FunctionalPalette.info,
    skeleton: FunctionalPalette.skeleton,
    tabActive: BrandPalette.primary,
    tabInactive: NeutralPalette.text2,
  );

  /// 暗色方案。
  ///
  /// `⚠` **这是自建的，不是从企划星 Android 抄的。** 企划星 `values-night/colors.xml`
  /// 里并没有覆盖 `ps_theme_color` / `text_0..4` / `divider` 这些槽位，
  /// 也就是说 Android 侧根本没有暗色语义体系。这里的取值按同一套槽位推导，
  /// **上线前需要设计确认**，不要当成既有设计。
  static const AppColors dark = AppColors(
    textPrimary: Color(0xFFE6E6E6),
    textSecondary: Color(0xFFCCCCCC),
    textTertiary: Color(0xFF999999),
    textDisabled: Color(0xFF666666),
    bgPage: Color(0xFF121212),
    bgCard: Color(0xFF1E1E1E),
    bgSubtle: Color(0xFF181818),
    bgOverlay: Color(0x99000000),
    divider: Color(0xFF232323),
    border: Color(0xFF2E2E2E),
    brand: BrandPalette.primary,
    brandPressed: BrandPalette.primaryDark,
    brandDisabled: BrandPalette.primaryDisabled,
    brandSubtle: BrandPalette.primaryAlpha20,
    onBrand: Color(0xFFFFFFFF),
    price: Color(0xFFFF4E7E),
    success: Color(0xFF7BD383),
    warning: Color(0xFF4A3A12),
    warningBg: Color(0xFF4A3A12),
    error: Color(0xFFE96A6A),
    info: Color(0xFF7BA9FF),
    skeleton: Color(0xFF2A2A2A),
    tabActive: BrandPalette.primary,
    tabInactive: Color(0xFF999999),
  );

  @override
  AppColors copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? bgPage,
    Color? bgCard,
    Color? bgSubtle,
    Color? bgOverlay,
    Color? divider,
    Color? border,
    Color? brand,
    Color? brandPressed,
    Color? brandDisabled,
    Color? brandSubtle,
    Color? onBrand,
    Color? price,
    Color? success,
    Color? warning,
    Color? warningBg,
    Color? error,
    Color? info,
    Color? skeleton,
    Color? tabActive,
    Color? tabInactive,
  }) {
    return AppColors(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      bgPage: bgPage ?? this.bgPage,
      bgCard: bgCard ?? this.bgCard,
      bgSubtle: bgSubtle ?? this.bgSubtle,
      bgOverlay: bgOverlay ?? this.bgOverlay,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      brand: brand ?? this.brand,
      brandPressed: brandPressed ?? this.brandPressed,
      brandDisabled: brandDisabled ?? this.brandDisabled,
      brandSubtle: brandSubtle ?? this.brandSubtle,
      onBrand: onBrand ?? this.onBrand,
      price: price ?? this.price,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      error: error ?? this.error,
      info: info ?? this.info,
      skeleton: skeleton ?? this.skeleton,
      tabActive: tabActive ?? this.tabActive,
      tabInactive: tabInactive ?? this.tabInactive,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      textDisabled: mix(textDisabled, other.textDisabled),
      bgPage: mix(bgPage, other.bgPage),
      bgCard: mix(bgCard, other.bgCard),
      bgSubtle: mix(bgSubtle, other.bgSubtle),
      bgOverlay: mix(bgOverlay, other.bgOverlay),
      divider: mix(divider, other.divider),
      border: mix(border, other.border),
      brand: mix(brand, other.brand),
      brandPressed: mix(brandPressed, other.brandPressed),
      brandDisabled: mix(brandDisabled, other.brandDisabled),
      brandSubtle: mix(brandSubtle, other.brandSubtle),
      onBrand: mix(onBrand, other.onBrand),
      price: mix(price, other.price),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      warningBg: mix(warningBg, other.warningBg),
      error: mix(error, other.error),
      info: mix(info, other.info),
      skeleton: mix(skeleton, other.skeleton),
      tabActive: mix(tabActive, other.tabActive),
      tabInactive: mix(tabInactive, other.tabInactive),
    );
  }

  /// **全部 24 个字段**参与比较。
  ///
  /// 这一条直接对应 30-10：来源的 `ThemeConfig.operator==` 只比较
  /// `primaryColor`、忽略 `type`，于是"亮色/暗色切换"时缓存命中判断失效。
  /// 这里用全字段比较，且新增字段时**编译器不会提醒你补**——所以字段与
  /// [hashCode] 必须成对维护，任何新增槽位都要同时加进这两处。
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AppColors &&
        other.textPrimary == textPrimary &&
        other.textSecondary == textSecondary &&
        other.textTertiary == textTertiary &&
        other.textDisabled == textDisabled &&
        other.bgPage == bgPage &&
        other.bgCard == bgCard &&
        other.bgSubtle == bgSubtle &&
        other.bgOverlay == bgOverlay &&
        other.divider == divider &&
        other.border == border &&
        other.brand == brand &&
        other.brandPressed == brandPressed &&
        other.brandDisabled == brandDisabled &&
        other.brandSubtle == brandSubtle &&
        other.onBrand == onBrand &&
        other.price == price &&
        other.success == success &&
        other.warning == warning &&
        other.warningBg == warningBg &&
        other.error == error &&
        other.info == info &&
        other.skeleton == skeleton &&
        other.tabActive == tabActive &&
        other.tabInactive == tabInactive;
  }

  @override
  int get hashCode => Object.hashAll(<Object>[
        textPrimary,
        textSecondary,
        textTertiary,
        textDisabled,
        bgPage,
        bgCard,
        bgSubtle,
        bgOverlay,
        divider,
        border,
        brand,
        brandPressed,
        brandDisabled,
        brandSubtle,
        onBrand,
        price,
        success,
        warning,
        warningBg,
        error,
        info,
        skeleton,
        tabActive,
        tabInactive,
      ]);
}

/// 便捷取用：`context.appColors.price`。
extension AppColorsContext on BuildContext {
  /// 当前主题的语义色。
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
