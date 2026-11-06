import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../../shared/ui/ps_section_header.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/show_summary.dart';
import '../../catalog/ui/show_cards.dart';
import '../../../l10n/home_localizations.dart';

/// 首页「精选推荐」楼层（`view_home_choiceness.xml`）。
///
/// 结构：20sp 粗体标题（上边距 16、左右 14）→ 42dp 可横滑 tab
/// （选中 16sp 粗体 `text_0`、未选中 14sp 常规 `text_2`、2dp 品牌色下划线）
/// → 105dp 宽的横滑卡片（`item_home_choiceness.xml`）。
///
/// tab 的选中态样式来自 `HomeChoicenessView.onTabSelected/onTabUnselected`，
/// 不是 layout 里写的（layout 里只有 `tabIndicator`），所以这里必须按 Java 侧取值。
class HomeChoicenessFloor extends StatefulWidget {
  const HomeChoicenessFloor({
    super.key,
    required this.groups,
    required this.onTapShow,
  });

  final List<ChoicenessGroup> groups;
  final void Function(ShowSummary show) onTapShow;

  @override
  State<HomeChoicenessFloor> createState() => _HomeChoicenessFloorState();
}

class _HomeChoicenessFloorState extends State<HomeChoicenessFloor> {
  final ScrollController _tabController = ScrollController();
  final List<GlobalKey> _tabKeys = <GlobalKey>[];
  int _selected = 0;

  @override
  void didUpdateWidget(covariant HomeChoicenessFloor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selected >= widget.groups.length) _selected = 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _selected) return;
    setState(() => _selected = index);
    // 选中的 tab 可能滑出屏幕（企划星 `TabLayout` 会自动滚），这里手动居中。
    if (index < _tabKeys.length) {
      final target = _tabKeys[index].currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          alignment: 0.5,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    if (widget.groups.isEmpty) return const SizedBox.shrink();

    while (_tabKeys.length < widget.groups.length) {
      _tabKeys.add(GlobalKey());
    }
    final group = widget.groups[_selected.clamp(0, widget.groups.length - 1)];

    return Container(
      margin: const EdgeInsets.only(top: 12),
      color: colors.bgCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 16),
          // 企划星的精选楼层只有标题，**没有**「全部」——不要凭印象加。
          PsSectionHeader(title: HomeLocalizations.of(context).homeChoicenessFloor_83, titleSize: 20),
          const SizedBox(height: 6),
          SizedBox(
            height: 42,
            child: ListView.builder(
              controller: _tabController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 5),
              itemCount: widget.groups.length,
              itemBuilder: (context, index) {
                final item = widget.groups[index];
                final selected = index == _selected;
                return GestureDetector(
                  key: _tabKeys[index],
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _select(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: Text(
                              item.categoryName,
                              style: TextStyle(
                                fontSize: selected ? 16 : 14,
                                height: 1.2,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                color: selected ? colors.textPrimary : colors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                        // drawable_tab_indicator：2dp 品牌色，宽度跟随文字。
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 2,
                          width: selected ? 24 : 0,
                          decoration: BoxDecoration(
                            color: colors.brand,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 17, right: 12),
              itemCount: group.shows.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final show = group.shows[index];
                return ShowCardChoiceness(
                  show: show,
                  onTap: () => widget.onTapShow(show),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
