import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../../shared/ui/ps_section_header.dart';
import '../../catalog/domain/show_summary.dart';
import '../../catalog/ui/show_cards.dart';

/// 首页「演出楼层」（`view_home_show_floor.xml`）。
///
/// 白底 + 12dp 圆角 + 左右 12dp 外边距；标题 18dp 粗体（上边距 12、左 10）、
/// 副标题 12dp `text_3`、右侧「全部」11dp + 10dp 箭头；
/// 卡片区是一个 `HorizontalScrollView`（左右 padding 10/4、上边距 12）。
///
/// 企划星首页有**多个**这样的楼层（热门演出 / 演唱会 / 话剧歌剧 / 儿童亲子 …），
/// 每个楼层的标题与副标题都来自服务端 `HomeFloorBean`。这里用同一个组件重复渲染。
class HomeShowFloor extends StatelessWidget {
  const HomeShowFloor({
    super.key,
    required this.title,
    required this.shows,
    required this.onTapShow,
    this.description,
    this.onTapMore,
  });

  final String title;

  /// 副标题（企划星 `tv_home_show_list_desc`，如「本周热销」）。
  final String? description;

  final List<ShowSummary> shows;
  final void Function(ShowSummary show) onTapShow;
  final VoidCallback? onTapMore;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    if (shows.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8, left: 12, right: 12),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 12),
          PsSectionHeader(
            title: title,
            subtitle: description,
            onAction: onTapMore,
            horizontalPadding: 10,
          ),
          const SizedBox(height: 12),
          ShowCardFloorStrip(shows: shows, onTapShow: onTapShow, height: 172),
        ],
      ),
    );
  }
}
