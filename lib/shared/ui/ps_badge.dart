import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

/// 未读角标（`item_system_message_header.xml` / `item_user_message.xml` 的
/// `tv_notice_int`）。
///
/// 最小 18×18、圆角 9dp、`#ffff2661` 实心、1dp 白描边、12dp 白字。
/// 白描边不是装饰——它是让角标在头像/图标上"浮起来"的必要条件，
/// 去掉就会和深色图标糊在一起。
class PsBadge extends StatelessWidget {
  const PsBadge({super.key, required this.count, this.dot = false});

  /// 未读数。`> 99` 显示 `99+`。
  final int count;

  /// 纯红点（`red_dot`：10×10 无数字）。
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    if (dot) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: colors.price,
          shape: BoxShape.circle,
          border: Border.all(color: colors.bgCard, width: 1),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.price,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: colors.bgCard, width: 1),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          fontSize: 12,
          height: 1.0,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 把角标挂在右上角（带企划星的固定偏移：头像 +9/-9，图标 -14/-4）。
class PsBadgeAnchor extends StatelessWidget {
  const PsBadgeAnchor({
    super.key,
    required this.child,
    required this.count,
    this.offset = const Offset(9, -9),
    this.dot = false,
  });

  final Widget child;
  final int count;
  final Offset offset;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        Positioned(
          right: -offset.dx,
          top: offset.dy,
          child: PsBadge(count: count, dot: dot),
        ),
      ],
    );
  }
}
