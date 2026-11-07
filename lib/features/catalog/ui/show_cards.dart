import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../../shared/ui/ps_poster.dart';
import '../domain/show_summary.dart';
import '../../../l10n/l10n.dart';
import 'catalog_l10n.dart';

/// 精选卡片（`item_home_choiceness.xml`）。
///
/// 105dp 宽、海报 105×112 圆角 2dp、标题 14sp 粗体 2 行，
/// 下方固定展示达成率进度条、达成率、目标金额、支持人数与剩余天数。
/// 卡片之间靠 10dp 的 `marginStart` 留白——企划星用 margin 而不是 `spacing`，
/// 所以横向列表的最后一项要补一个尾部 padding。
class ShowCardChoiceness extends StatelessWidget {
  const ShowCardChoiceness({
    super.key,
    required this.show,
    this.onTap,
    this.width = 105,
  });

  final ShowSummary show;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final discountLabel = show.discountLabelOf(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PsPoster(
              seed: show.title,
              width: width,
              height: 112,
              radius: 2,
              dimmed: show.soldOut,
              overlay: discountLabel == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 6, top: 3),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: PsDiscountCorner(text: discountLabel),
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              // 固定两行标题高度，单行标题顶部对齐，下方信息不会上下跳动。
              height: MediaQuery.textScalerOf(context).scale(14) * 1.25 * 2,
              child: Text(
                show.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            _ProjectProgressBar(show: show, height: 4),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  context.l10n.projectCardAchievement(
                    (show.achievementPermille / 10).round(),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: show.achievementPermille >= 1000
                        ? colors.price
                        : colors.brand,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    show.achievementPermille >= 1000
                        ? context.l10n.projectCardAchieved
                        : context.l10n.projectAchievement,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: colors.textTertiary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.projectCardGoal(show.goalAmount?.format() ?? '—'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: colors.textTertiary),
            ),
            const SizedBox(height: 1),
            Text(
              '${context.l10n.projectCardSupporters(show.supporterCount)} · '
              '${_remainingLabel(context, show)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 达成率进度条（企划卡通用）。
class _ProjectProgressBar extends StatelessWidget {
  const _ProjectProgressBar({required this.show, this.height = 4});

  final ShowSummary show;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final value = (show.achievementPermille / 1000).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        backgroundColor: colors.bgSubtle,
        valueColor: AlwaysStoppedAnimation<Color>(
          show.achievementPermille >= 1000 ? colors.price : colors.brand,
        ),
      ),
    );
  }
}

/// 卡片底部剩余时间 / 已结束文案。
String _remainingLabel(BuildContext context, ShowSummary show) {
  if (show.fundingStatusValue == 'failed' ||
      show.fundingStatusValue == 'delivered') {
    return context.l10n.projectCardEnded;
  }
  final days = show.remainingDays;
  return days <= 0
      ? context.l10n.projectCardEnded
      : context.l10n.projectCardDays(days);
}

/// 楼层卡片（`item_home_show_list_common.xml`）。
///
/// 76dp 宽、海报 76×101 圆角 8dp（底部压一条 24dp 品类渐变条 + 右上角角标）、
/// 标题 13dp 2 行、达成率 12dp 粗体。
class ShowCardFloor extends StatelessWidget {
  const ShowCardFloor({super.key, required this.show, this.onTap});

  final ShowSummary show;
  final VoidCallback? onTap;

  static const double width = 76;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PsPoster(
              seed: show.title,
              width: width,
              height: 101,
              radius: 8,
              dimmed: show.soldOut,
              overlay: Stack(
                children: <Widget>[
                  if (show.tags.isNotEmpty)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: PsPosterTag(label: show.tags.first),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: PsPosterCityBar(city: show.categoryName),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              show.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            _ProjectProgressBar(show: show, height: 3),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    context.l10n.projectCardAchievement(
                      (show.achievementPermille / 10).round(),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: show.achievementPermille >= 1000
                          ? colors.price
                          : colors.brand,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    context.l10n.projectCardAchieved,
                    style: TextStyle(fontSize: 10, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _remainingLabel(context, show),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 横向列表卡片（发现流 / 搜索结果 / 相似推荐）。
///
/// 结构对应企划星的 `item_feed_detail_relate_show.xml` 一类"左图右文"卡片：
/// 90×120 海报、标题 15dp 粗体、创作者 / 品类 / 支持人数 12dp `text_3`、
/// 底部达成率与剩余天数。
class ShowCardRow extends StatelessWidget {
  const ShowCardRow({super.key, required this.show, this.onTap, this.trailing});

  final ShowSummary show;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final discountLabel = show.discountLabelOf(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PsPoster(
              seed: show.title,
              width: 90,
              height: 120,
              radius: 4,
              dimmed: show.soldOut,
              overlay: discountLabel == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: PsDiscountCorner(text: discountLabel),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                // 海报高度 120 是视觉基线；文案多一行「达成率 + 剩余天数」，
                // 给到 126 以避免 360dp 宽下底部行溢出。
                height: 126,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      show.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      show.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      show.categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.projectCardSupporters(show.supporterCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          context.l10n.projectCardAchievement(
                            (show.achievementPermille / 10).round(),
                          ),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: show.achievementPermille >= 1000
                                ? colors.price
                                : colors.brand,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _remainingLabel(context, show),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                        if (trailing != null) ?trailing,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 横向滚动的一排楼层卡片（`ll_home_show_list` + `HorizontalScrollView`）。
///
/// 企划星给每张卡 10dp 的左边距、容器右 padding 4dp；这里用 `ListView.separated`
/// 显式表达间距，最后一项之外不再多留白。
class ShowCardFloorStrip extends StatelessWidget {
  const ShowCardFloorStrip({
    super.key,
    required this.shows,
    required this.onTapShow,
    this.height = 190,
  });

  final List<ShowSummary> shows;
  final void Function(ShowSummary show) onTapShow;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 10, right: 10),
        itemCount: shows.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final show = shows[index];
          return ShowCardFloor(show: show, onTap: () => onTapShow(show));
        },
      ),
    );
  }
}
