import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

import '../../../shared/ui/ps_shortcut_grid.dart';
import '../../catalog/domain/show_category.dart';

/// 分类 → 图标。
///
/// 企划星的分类图标是 `drawable/ic_category_*` 位图（`HomeIconView` 里按
/// `categoryId` 映射），图标统一改用 Lucide 矢量图标。
/// 这里按分类语义挑 Material 图标，形状尽量贴近原图标。
const Map<int, IconData> _categoryIcons = <int, IconData>{
  1: LucideIcons.mic, // 演唱会
  2: LucideIcons.drama, // 话剧歌剧
  3: LucideIcons.music, // 音乐会
  4: LucideIcons.baby, // 儿童亲子
  5: LucideIcons.landmark, // 休闲展览
  6: LucideIcons.activity, // 舞蹈芭蕾
  7: LucideIcons.mic, // 戏曲综艺
  8: LucideIcons.trophy, // 体育赛事
};

/// 把分类目录转成快捷入口。
///
/// 分类超过 10 个（5 列 × 2 行）时自动分页，与企划星 `HomeIconView` 的
/// `ViewPager + RecyclerView` 行为一致。
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
