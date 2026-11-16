import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/ui/ps_shortcut_grid.dart';

/// 首页固定快捷入口：分类 / 排行 / 精品 / 新企划 / 已达成。
///
/// 五个入口对应五个独立落地页，不再按分类目录动态生成；
/// 每个入口只占一行，避免原先 5×2 宫格把首屏压得过密。
List<PsShortcut> buildHomeShortcuts({
  required BuildContext context,
  required void Function(String location) onTap,
}) {
  final l10n = context.l10n;
  return <PsShortcut>[
    PsShortcut(
      label: l10n.homeShortcutCategory,
      icon: LucideIcons.layoutGrid,
      onTap: () => onTap('/categories'),
    ),
    PsShortcut(
      label: l10n.homeShortcutRanking,
      icon: LucideIcons.trophy,
      onTap: () => onTap('/ranking'),
    ),
    PsShortcut(
      label: l10n.homeShortcutFeatured,
      icon: LucideIcons.gem,
      onTap: () => onTap('/featured'),
    ),
    PsShortcut(
      label: l10n.homeShortcutNew,
      icon: LucideIcons.sparkles,
      onTap: () => onTap('/new-projects'),
    ),
    PsShortcut(
      label: l10n.homeShortcutAchieved,
      icon: LucideIcons.badgeCheck,
      onTap: () => onTap('/achieved'),
    ),
  ];
}
