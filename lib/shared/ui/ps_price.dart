import 'package:core_design_system/core_design_system.dart';
import 'package:core/domain.dart';
import 'package:flutter/material.dart';

/// 价格排版。
///
/// 企划星的价格不是一个 `Text("星币 880")`，而是"小符号 + 大数字 + 小后缀"的三段式：
/// `星币` 与 `起` 比主数字小一档，主数字用系统字体 + 等宽数字特性避免跳动。
///
/// 尺寸与颜色按使用场景分四档：
/// - 首页精选卡片：16sp 粗体、价格红
/// - 普通列表卡片：12sp 粗体 `#ffff2261`
/// - 热门列表卡片：18dp 粗体 + `星币` 14dp + `起` 10dp 三级文本灰
/// - 企划详情头图：18dp、价格红
///
/// 金额本身一律走 [Money]（整数分），这里只做排版，不做任何算术。
class PsPrice extends StatelessWidget {
  const PsPrice({
    super.key,
    required this.amount,
    this.size = 16,
    this.color,
    this.suffix,
    this.prefix,
    this.showSymbol = true,
    this.strikeThroughAmount,
    this.weight = FontWeight.w700,
  });

  /// 主金额。
  final Money amount;

  /// 主数字字号；符号与小数按 0.62 缩放。
  final double size;

  /// 默认取语义槽 `price`（`#ffff2661`）。
  final Color? color;

  /// 主数字后的后缀（如 `起`）。10sp、三级文本灰。
  final String? suffix;

  /// 主数字前的说明（如 `服务费：`）。
  final String? prefix;

  final bool showSymbol;

  /// 划线原价（有值时显示在右侧）。
  final Money? strikeThroughAmount;

  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final priceColor = color ?? colors.price;
    final minorSize = size * 0.62;

    final absolute = amount.minorUnits.abs();
    final yuan = absolute ~/ 100;
    final cents = absolute % 100;

    final numberStyle = AppTypography.numeric(
      size: size,
      color: priceColor,
      weight: weight,
    );

    // `FittedBox(scaleDown)` 在这里是**防御性的，不是装饰**。
    //
    // 下面这个 Row 是 `mainAxisSize: min` 且没有任何 flex 子节点，一旦父级
    // 给的是紧约束，子节点就无法收缩：`ShowCardChoiceness` 是固定 105dp 的
    // 卡片，底部那行把剩余空间按 flex 均分给 `Expanded(价格)` 和
    // `Flexible(角标)`，价格只拿到 52.5dp，而 `星币 880起` 在 16sp 下要约 71dp
    // —— 直接 `RenderFlex overflowed by 19 pixels`。
    //
    // 这不是测试环境的假象：卡片宽度是写死的 105dp，真机 390pt 屏上分到的
    // 同样是 52.5dp，也就是**每个带角标的精选卡片都会溢出**。
    //
    // 为什么缩整块而不是给某个 Text 加 ellipsis：价格的「符号 + 数字 + 后缀」
    // 是一套比例排版（符号 0.62 倍），单独截断会变成 `星币 8…` 这种没有意义的
    // 残文；整块等比缩小才既保住可读性又不丢信息。
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          if (prefix != null)
            Text(
              prefix!,
              style: TextStyle(
                fontSize: minorSize,
                height: 1.1,
                color: colors.textTertiary,
              ),
            ),
          if (showSymbol)
            Text(
              amount.isNegative ? '-星币' : '星币',
              style: AppTypography.numeric(
                size: minorSize,
                color: priceColor,
                weight: weight,
              ),
            ),
          Text('$yuan', style: numberStyle),
          // 整数星币不显示 `.00`——企划星列表里的起价都是整数。
          if (cents != 0)
            Text(
              '.${cents.toString().padLeft(2, '0')}',
              style: AppTypography.numeric(
                size: minorSize,
                color: priceColor,
                weight: weight,
              ),
            ),
          if (suffix != null)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                suffix!,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.1,
                  color: colors.textTertiary,
                ),
              ),
            ),
          if (strikeThroughAmount != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                strikeThroughAmount!.format(),
                style: TextStyle(
                  fontSize: minorSize,
                  height: 1.1,
                  color: colors.textDisabled,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: colors.textDisabled,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
