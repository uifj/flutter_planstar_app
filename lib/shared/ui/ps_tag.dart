import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

/// 标签外观。
enum PsTagTone {
  /// 描边（`item_home_choiceness.xml` 的 `tv_tag`：0.5dp 描边 + 9sp 灰字）。
  outline,

  /// 实心（`item_home_show_list_common.xml` 的 `tv_discount`：品牌红底白字）。
  solid,

  /// 淡底（订单类型、服务标签这类需要"存在感但不抢眼"的场合）。
  soft,
}

/// 小标签。企划星里这类标签有十几种写法（`SuperTextView` 配不同的
/// `corner` / `solid` / `stroke_color`），这里收敛成 [PsTagTone] 三档。
class PsTag extends StatelessWidget {
  const PsTag({
    super.key,
    required this.label,
    this.tone = PsTagTone.outline,
    this.color,
    this.fontSize = 9,
    this.radius = 2,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  });

  final String label;
  final PsTagTone tone;

  /// 主色。默认 `outline` 用 `text_3`、`solid` 用品牌色、`soft` 用品牌色。
  final Color? color;

  final double fontSize;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final accent =
        color ??
        (tone == PsTagTone.outline ? colors.textTertiary : colors.brand);

    final (Color background, Color border, Color foreground) = switch (tone) {
      PsTagTone.outline => (
        Colors.transparent,
        accent.withValues(alpha: 0.5),
        accent,
      ),
      PsTagTone.solid => (accent, accent, Colors.white),
      PsTagTone.soft => (
        accent.withValues(alpha: 0.1),
        Colors.transparent,
        accent,
      ),
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: border == Colors.transparent
            ? null
            : Border.all(color: border, width: 0.5),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

/// 折扣标签（`9.8折起`）。企划星用 8sp 白字 + `#ffff2261` 实心 + 3dp 圆角。
class PsDiscountTag extends StatelessWidget {
  const PsDiscountTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return PsTag(
      label: label,
      tone: PsTagTone.solid,
      color: colors.price,
      fontSize: 8,
      radius: 3,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
    );
  }
}
