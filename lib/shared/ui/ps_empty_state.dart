import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

/// 空态。
///
/// 企划星有 `icon_empty` / `icon_search_empty` / `icon_actor_site_goods_empty` /
/// `icon_empty_toys` 四张空态图，分别对应"通用空 / 搜索无结果 / 演出无票 / 商品空"。
/// 这里用一张图 + 文案参数化，避免每处各写一套布局。
class PsEmptyState extends StatelessWidget {
  const PsEmptyState({
    super.key,
    this.title = '暂无内容',
    this.description,
    this.actionLabel,
    this.onAction,
    this.icon = LucideIcons.inbox,
    this.compact = false,
  });

  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  /// 紧凑模式（嵌在卡片里时用，减少上下留白）。
  final bool compact;

  /// 搜索无结果。
  factory PsEmptyState.search({VoidCallback? onAction}) => PsEmptyState(
        title: '没有找到相关演出',
        description: '换个关键词或城市试试',
        icon: LucideIcons.searchX,
        actionLabel: onAction == null ? null : '重新搜索',
        onAction: onAction,
      );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: compact ? 24 : 64,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: compact ? 40 : 64, color: colors.skeleton),
            SizedBox(height: compact ? 8 : 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 13 : 15,
                color: colors.textTertiary,
              ),
            ),
            if (description != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: colors.textDisabled),
              ),
            ],
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.brand,
                  side: BorderSide(color: colors.brand, width: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Text(actionLabel!, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
