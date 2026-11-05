import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

/// 城市格子（`item_city.xml` 的简化版）。
///
/// 从 [CityPickerSheet] 的私有 `_CityChip` 提升而来：城市选择面板
/// （首页顶部）和城市列表页（`/cities`）都要渲染同一套"选中 / 可选 /
/// 暂无数据"三态，两处各写一份必然漂移——例如面板里灰显是
/// `textDisabled`，列表页改成别的灰，用户会以为两处的"不可选"含义不同。
///
/// 三态的含义：
/// - [selected]：当前城市，品牌色描边 + 淡底 + 粗体；
/// - [available] 为真：可选，`textPrimary`；
/// - [available] 为假：**可选但无数据**（`textDisabled`）。仍然可点——
///   企划星允许切到没有演出的城市，进去看空态。做成不可点会让用户
///   以为"这个城市不存在"。
class CityTile extends StatelessWidget {
  const CityTile({
    super.key,
    required this.city,
    required this.selected,
    required this.available,
    required this.onTap,
    this.width = 72,
    this.height = 34,
  });

  final String city;
  final bool selected;

  /// 该城市是否有演出数据。
  final bool available;

  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final Color foreground = selected
        ? colors.brand
        : available
        ? colors.textPrimary
        : colors.textDisabled;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.brandSubtle : colors.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: selected ? Border.all(color: colors.brand, width: 0.5) : null,
        ),
        child: Text(
          city,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
