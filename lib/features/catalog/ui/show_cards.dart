import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../../shared/ui/ps_poster.dart';
import '../../../shared/ui/ps_price.dart';
import '../../../shared/ui/ps_tag.dart';
import '../domain/show_summary.dart';
import '../../../l10n/l10n.dart';
import 'catalog_l10n.dart';

/// 精选卡片（`item_home_choiceness.xml`）。
///
/// 105dp 宽、海报 105×140 圆角 2dp、标题 14sp 粗体 2 行、价格 16sp 粗体 `text_red`。
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
              height: 140,
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
            Text(
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
            const SizedBox(height: 3),
            Row(
              children: <Widget>[
                Expanded(
                  child: show.soldOut
                      ? Text(
                          context.l10n.showCards_72,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textTertiary,
                          ),
                        )
                      : PsPrice(
                          amount: show.priceFrom,
                          size: 16,
                          suffix: context.l10n.showCards_75,
                        ),
                ),
                if (show.tags.isNotEmpty)
                  Flexible(
                    child: PsTag(
                      label: show.tags.first,
                      fontSize: 9,
                      radius: 2,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 3,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 楼层卡片（`item_home_show_list_common.xml`）。
///
/// 76dp 宽、海报 76×101 圆角 8dp（底部压一条 24dp 城市渐变条 + 右上角角标）、
/// 标题 13dp 2 行、价格 12dp 粗体 `#ffff2261`。
class ShowCardFloor extends StatelessWidget {
  const ShowCardFloor({super.key, required this.show, this.onTap});

  final ShowSummary show;
  final VoidCallback? onTap;

  static const double width = 76;

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
                    child: PsPosterCityBar(city: show.city),
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
            if (show.soldOut)
              Text(
                context.l10n.showCards_156,
                style: TextStyle(fontSize: 11, color: colors.textTertiary),
              )
            else
              // 76dp 的窄卡里 `¥1,280` + `9.8折起` 放不下：`PsPrice` 内部的
              // `FittedBox` 只有在拿到**有界**约束时才会缩，而这里是 Row 的
              // 非 flex 子节点（宽度无界），所以它会按自然宽度铺开并把
              // 折扣标签顶出卡片——360dp 屏上实测溢出 19px。
              // 整块等比缩到 76dp 以内，比截断成 `¥1,…` 更接近来源的观感
              // （Android 那边是固定宽度 LinearLayout，超出部分直接裁掉）。
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    PsPrice(amount: show.priceFrom, size: 12),
                    if (discountLabel != null) ...<Widget>[
                      const SizedBox(width: 2),
                      PsDiscountTag(
                        label: context.l10n.showCards_175(discountLabel),
                      ),
                    ],
                  ],
                ),
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
/// 90×120 海报、标题 15dp 粗体、场馆/时间 12dp `text_3`、价格 + 标签。
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
                height: 120,
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
                      show.firstSessionLabelOf(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      show.venueLabel,
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
                        if (show.soldOut)
                          Text(
                            context.l10n.showCards_270,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textTertiary,
                            ),
                          )
                        else
                          PsPrice(
                            amount: show.priceFrom,
                            size: 17,
                            suffix: context.l10n.showCards_277,
                            strikeThroughAmount: show.listPriceFrom,
                          ),
                        const Spacer(),
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
