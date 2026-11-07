import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:core/result.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

/// 把错误转成可读文案：优先用 [Failure.message]，不展示堆栈。
String psErrorMessage(Object error) {
  if (error is Failure) return error.message;
  return '加载失败，请检查网络后重试';
}

/// 空态。
///
/// 企划星有 `icon_empty` / `icon_search_empty` / `icon_actor_site_goods_empty` /
/// `icon_empty_toys` 四张空态图，分别对应"通用空 / 搜索无结果 / 演出无票 / 商品空"。
/// 这里用一张图 + 文案参数化，避免每处各写一套布局。
class PsEmptyState extends StatelessWidget {
  const PsEmptyState({
    super.key,
    this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.icon = LucideIcons.inbox,
    this.compact = false,
    this.isSearch = false,
  });

  /// 标题；`null` 时按 [isSearch] 取默认文案。
  final String? title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  /// 搜索无结果的默认文案标记（由 [PsEmptyState.search] 设置）。
  final bool isSearch;

  /// 紧凑模式（嵌在卡片里时用，减少上下留白）。
  final bool compact;

  /// 搜索无结果。
  factory PsEmptyState.search({VoidCallback? onAction}) => PsEmptyState(
    icon: LucideIcons.searchX,
    isSearch: true,
    onAction: onAction,
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = context.l10n;
    final effectiveTitle =
        title ?? (isSearch ? l10n.psEmptyState_32 : l10n.stateEmpty);
    final effectiveDescription =
        description ?? (isSearch ? l10n.psEmptyState_33 : null);
    final effectiveActionLabel =
        actionLabel ??
        (isSearch && onAction != null ? l10n.psEmptyState_35 : null);
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
              effectiveTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 13 : 15,
                color: colors.textTertiary,
              ),
            ),
            if (effectiveDescription != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                effectiveDescription,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: colors.textDisabled),
              ),
            ],
            if (effectiveActionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.brand,
                  side: BorderSide(color: colors.brand, width: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  effectiveActionLabel,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
