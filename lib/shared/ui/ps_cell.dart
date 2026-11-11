import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

/// 菜单行。
///
/// 58dp 高、左右 18dp、16sp 主文本色、右侧 8×14 灰色箭头、行间 1dp `divider`。
/// 这个菜单**没有图标**——只有文字 + 箭头。加图标会偏离既定视觉，
/// 所以 [leading] 只在确实需要时传（例如「我的订单」里的状态入口另有实现）。
class PsCell extends StatelessWidget {
  const PsCell({
    super.key,
    required this.label,
    this.value,
    this.leading,
    this.onTap,
    this.height = 58,
    this.showDivider = true,
    this.horizontalPadding = 18,
    this.trailing,
  });

  final String label;

  /// 右侧次要文案（`已绑定` / `3 个`）。
  final String? value;

  final Widget? leading;
  final VoidCallback? onTap;
  final double height;
  final bool showDivider;
  final double horizontalPadding;

  /// 自定义右侧内容（覆盖默认箭头）。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: height,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: <Widget>[
                    if (leading != null) ...<Widget>[
                      leading!,
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.2,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (value != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          value!,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                    trailing ??
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: colors.textDisabled,
                        ),
                  ],
                ),
              ),
            ),
            if (showDivider)
              Padding(
                padding: EdgeInsets.only(left: horizontalPadding),
                child: Divider(height: 1, thickness: 1, color: colors.divider),
              ),
          ],
        ),
      ),
    );
  }
}
