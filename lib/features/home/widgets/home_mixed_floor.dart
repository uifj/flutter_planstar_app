import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/ui/ps_floating_tab_bar.dart';
import '../../../shared/ui/ps_section_header.dart';
import '../../catalog/domain/show_summary.dart';
import '../../catalog/ui/show_cards.dart';

/// 首页「全部企划」楼层（页面最后一个模块）。
///
/// 一行一个的「左图右文」列表（复用 [ShowCardRow]），行间用 1dp 分隔线；
/// 数据由 [HomePage] 触底分页，本组件只负责渲染已加载的数据，
/// 并在末尾展示「加载中 / 没有更多」状态。
class HomeMixedFloor extends StatelessWidget {
  const HomeMixedFloor({
    super.key,
    required this.title,
    required this.shows,
    required this.onTapShow,
    this.description,
    this.onTapMore,
    this.loadingMore = false,
    this.exhausted = false,
  });

  final String title;

  /// 副标题（如「游戏 · 小说 · 同人」）。
  final String? description;

  final List<ShowSummary> shows;
  final void Function(ShowSummary show) onTapShow;
  final VoidCallback? onTapMore;

  /// 正在加载下一页。
  final bool loadingMore;

  /// 没有更多数据了。
  final bool exhausted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    if (shows.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: PsSectionHeader(
              title: title,
              subtitle: description,
              onAction: onTapMore,
              horizontalPadding: 12,
            ),
          ),
        ),
        SliverList.separated(
          itemCount: shows.length,
          separatorBuilder: (_, _) =>
              Divider(height: 1, thickness: 1, color: colors.divider),
          itemBuilder: (BuildContext context, int index) {
            final show = shows[index];
            return ShowCardRow(show: show, onTap: () => onTapShow(show));
          },
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              top: 12,
              bottom: 8 + PsFloatingTabBar.bottomClearance(context),
            ),
            child: Center(
              child: loadingMore
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.brand,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.homeFeedLoading,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    )
                  : exhausted
                  ? Text(
                      context.l10n.homeFeedEnd,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    )
                  : const SizedBox(height: 20),
            ),
          ),
        ),
      ],
    );
  }
}
