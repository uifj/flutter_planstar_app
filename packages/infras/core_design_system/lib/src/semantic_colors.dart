/// L1 语义槽：组件**只准引用这一层**。
///
/// 语义槽映射自 TUIKit（`base_component/theme/color_scheme.dart`）的
/// `SemanticColorScheme`，按本应用实际用到的 24 个槽收敛。多出来的
/// TRTC 专属槽（气泡、通话按钮、标签色阶等）不搬。
library;

import 'package:flutter/material.dart';

import 'palette.dart';

/// 语义色方案，以 [ThemeExtension] 形式挂在 `ThemeData.extensions` 上。
///
/// 为什么是 `ThemeExtension` 而不是来源的 `InheritedNotifier<ThemeState>`：
///
/// 1. 来源的 `ComponentTheme` 在构造函数里 `themeState = themeState ?? ThemeState()`，
///    而它是 `StatelessWidget`，父级每次 rebuild 都会 new 一个 `ThemeState`，
///    主题会被重置为默认。
/// 2. 来源的 `ThemeConfig.operator==` 只比 `primaryColor`、忽略 `type`，
///    切换亮/暗时缓存判断会失效。[AppColors] 是 `@immutable` 值对象，
///    全部字段参与比较，不会出现这个问题。
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

  /// 次级背景（输入框、分组底）。
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

  /// 警告（文字/图标）。
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

  /// 亮色方案（TUIKit `LightSemanticScheme` 的子集）。
  static const AppColors light = AppColors(
    textPrimary: BasePalette.black2,
    textSecondary: BasePalette.black4,
    textTertiary: BasePalette.black5,
    textDisabled: BasePalette.black6,
    bgPage: BasePalette.grayLight1,
    bgCard: BasePalette.white1,
    bgSubtle: BasePalette.grayLight2,
    bgOverlay: BasePalette.black4,
    divider: BasePalette.grayLight2,
    border: BasePalette.grayLight3,
    brand: BasePalette.themeLight6,
    brandPressed: BasePalette.themeLight7,
    brandDisabled: BasePalette.themeLight2,
    brandSubtle: BasePalette.themeLight1,
    onBrand: BasePalette.white1,
    price: BasePalette.redLight6,
    success: BasePalette.greenLight6,
    warning: BasePalette.orangeLight6,
    warningBg: BasePalette.orangeLight1,
    error: BasePalette.redLight6,
    info: BasePalette.themeLight5,
    skeleton: BasePalette.grayLight2,
    tabActive: BasePalette.themeLight6,
    tabInactive: BasePalette.black4,
  );

  /// 暗色方案（TUIKit `DarkSemanticScheme` 的子集）。
  static const AppColors dark = AppColors(
    textPrimary: BasePalette.white2,
    textSecondary: BasePalette.white4,
    textTertiary: BasePalette.white6,
    textDisabled: BasePalette.white7,
    bgPage: BasePalette.grayDark1,
    bgCard: BasePalette.grayDark2,
    bgSubtle: BasePalette.grayDark3,
    bgOverlay: BasePalette.black4,
    divider: BasePalette.grayDark3,
    border: BasePalette.grayDark4,
    brand: BasePalette.themeDark6,
    brandPressed: BasePalette.themeDark7,
    brandDisabled: BasePalette.themeDark2,
    brandSubtle: BasePalette.themeDark2,
    onBrand: BasePalette.white1,
    price: BasePalette.redDark6,
    success: BasePalette.greenDark6,
    warning: BasePalette.orangeDark6,
    warningBg: BasePalette.orangeDark2,
    error: BasePalette.redDark6,
    info: BasePalette.themeDark6,
    skeleton: BasePalette.grayDark3,
    tabActive: BasePalette.themeDark6,
    tabInactive: BasePalette.white4,
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
  /// 新增字段时编译器不会提醒你补这里——字段与 [hashCode] 必须成对维护。
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
