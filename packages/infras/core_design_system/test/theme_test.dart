import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors 是值对象（修 30-09 / 30-10）', () {
    test('相同内容相等', () {
      expect(AppColors.light, AppColors.light);
      expect(AppColors.light, isNot(equals(AppColors.dark)));
    });

    test('copyWith 只改传入字段', () {
      final changed = AppColors.light.copyWith(brand: const Color(0xFF00FF00));
      expect(changed.brand, const Color(0xFF00FF00));
      expect(changed.textPrimary, AppColors.light.textPrimary);
    });

    test('copyWith 不传参数时与原值相等', () {
      expect(AppColors.light.copyWith(), AppColors.light);
    });

    test('lerp 到自身不变', () {
      final same = AppColors.light.lerp(AppColors.light, 0.5);
      expect(same, AppColors.light);
    });

    test('lerp 到另一端取端点值', () {
      final result = AppColors.light.lerp(AppColors.dark, 1);
      expect(result.brand, AppColors.dark.brand);
      expect(result.textPrimary, AppColors.dark.textPrimary);
    });
  });

  group('AppTheme 装配', () {
    test('亮色主题带 AppColors 扩展', () {
      final theme = AppTheme.light();
      expect(theme.extension<AppColors>(), AppColors.light);
      expect(theme.scaffoldBackgroundColor, AppColors.light.bgPage);
    });

    test('暗色主题带暗色扩展', () {
      final theme = AppTheme.dark();
      expect(theme.extension<AppColors>(), AppColors.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('品牌色直接进 ColorScheme，不被 fromSeed 派生掉', () {
      final theme = AppTheme.light();
      expect(theme.colorScheme.primary, BrandPalette.primary);
      expect(theme.colorScheme.primary, const Color(0xFFFF317B));
    });

    test('分隔线是 0.5 逻辑像素（企划星的细线风格）', () {
      expect(AppTheme.light().dividerTheme.thickness, 0.5);
    });
  });

  group('令牌取值', () {
    test('品牌色与企划星 Android 资源一致', () {
      // ps_theme_color = #ffff317b
      expect(BrandPalette.primary, const Color(0xFFFF317B));
      // text_0 = #ff262626
      expect(NeutralPalette.text0, const Color(0xFF262626));
      // divider = #fff2f2f2
      expect(NeutralPalette.divider, const Color(0xFFF2F2F2));
    });

    test('数字样式带 tabularFigures（避免价格左右跳动）', () {
      final style = AppTypography.numeric(
        size: AppTypography.display,
        color: BrandPalette.primary,
      );
      expect(style.fontFamily, AppTypography.numericFontFamily);
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    });
  });

  testWidgets('context.appColors 能取到语义槽', (WidgetTester tester) async {
    late AppColors resolved;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (BuildContext context) {
            resolved = context.appColors;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(resolved.price, FunctionalPalette.price);
  });
}
