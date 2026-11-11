import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

/// 楼层标题。
///
/// 每个楼层都是"标题 +（可选）副标题 +（可选）全部 >"的三段式：
/// - 首页精选楼层：20sp 粗体、左右 14dp
/// - 企划楼层：18dp 粗体 + 12dp 三级灰副标题 + 11dp「全部」+ 10dp 箭头
/// - 热门活动场地楼层：20sp 粗体、左右 14dp
class PsSectionHeader extends StatelessWidget {
  const PsSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.titleSize = 18,
    this.horizontalPadding = 14,
    this.showActionArrow = true,
  });

  final String title;
  final String? subtitle;

  /// 右侧动作文案（企划星固定为「全部」）；`null` 时用默认文案。
  final String? actionLabel;

  /// 为 `null` 时不显示右侧动作。
  final VoidCallback? onAction;

  final double titleSize;
  final double horizontalPadding;
  final bool showActionArrow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          if (subtitle != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    color: colors.textTertiary,
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          if (onAction != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      actionLabel ?? context.l10n.psSectionHeader_16,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.1,
                        color: colors.textTertiary,
                      ),
                    ),
                    if (showActionArrow)
                      Icon(
                        LucideIcons.chevronRight,
                        size: 12,
                        color: colors.textTertiary,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
