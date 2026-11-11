import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

import '../../../shared/ui/ps_shortcut_grid.dart';
import '../../catalog/domain/show_category.dart';

/// 分类 → 图标。
///
/// 图标统一用 Lucide 矢量图标，按 `categoryId` 映射；未命中时回落到默认图标。
/// 复核点：现有字形与分类语义不匹配，需按 10 个真实分类逐个重挑。
const Map<int, IconData> _categoryIcons = <int, IconData>{
  1: LucideIcons.mic, // 游戏企划
  2: LucideIcons.drama, // 小说企划
  3: LucideIcons.music, // 同人企划
  4: LucideIcons.baby, // 面经企划
  5: LucideIcons.landmark, // 桌游企划
  6: LucideIcons.activity, // 画集设定集
  7: LucideIcons.mic, // 音乐影像
  8: LucideIcons.trophy, // 校园与活动
  10: LucideIcons.video, // 自媒体企划
};

/// 把分类目录转成快捷入口。
///
/// 每页 5 列 × 2 行 = 10 个入口，分类超过 10 个时自动分页。
List<PsShortcut> buildCategoryShortcuts({
  required List<ShowCategory> categories,
  required void Function(ShowCategory category) onTap,
}) {
  return <PsShortcut>[
    for (final category in categories)
      PsShortcut(
        label: category.name,
        icon: _categoryIcons[category.id] ?? LucideIcons.ticket,
        onTap: () => onTap(category),
      ),
  ];
}
