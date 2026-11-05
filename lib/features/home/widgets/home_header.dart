import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../../shared/ui/ps_search_bar.dart';

/// 首页顶部（`view_home_header.xml` + `view_home_toolbar.xml`）。
///
/// ## 行为
///
/// 企划星的首页头部有两态：展开时是"logo + 服务承诺 + 搜索栏"，上滑后
/// logo 行淡出、只剩搜索栏贴在状态栏下方（`HomeToolbarAnimateHelper` 驱动）。
/// 这里用 `SliverPersistentHeader` 复刻同一个效果：
///
/// - 展开高度：`topPadding + 78`（logo 22 + 间距 10 + 搜索栏 36 + 底部 6）
/// - 收起高度：`topPadding + 42`（搜索栏 36 + 上下 3）
/// - 搜索栏随滚动从 `top + 36` 上移到 `top + 3`，logo 行同步淡出并上移
///
/// 背景是 `bg_home_header_gradient`（`#ffffe9ef` → 白色，从上到下）。
class HomeHeader extends SliverPersistentHeaderDelegate {
  HomeHeader({
    required this.topPadding,
    required this.city,
    required this.hints,
    required this.onTapCity,
    required this.onTapSearch,
    required this.onTapField,
  });

  final double topPadding;
  final String city;
  final List<String> hints;
  final VoidCallback onTapCity;
  final VoidCallback onTapSearch;
  final VoidCallback onTapField;

  static const double _logoRowHeight = 22;
  static const double _logoRowTop = 4;
  static const double _searchGap = 10;
  static const double _searchHeight = 36;
  static const double _horizontal = 12;

  double get _expandedSearchTop => topPadding + _logoRowTop + _logoRowHeight + _searchGap;
  double get _collapsedSearchTop => topPadding + 3;

  @override
  double get maxExtent => _expandedSearchTop + _searchHeight + 6;

  @override
  double get minExtent => _collapsedSearchTop + _searchHeight + 3;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final range = maxExtent - minExtent;
    final t = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);

    final searchTop = _expandedSearchTop + (_collapsedSearchTop - _expandedSearchTop) * t;

    return SizedBox(
      height: maxExtent,
      child: Stack(
        children: <Widget>[
          // 渐变背景：收起后收敛成纯白，避免滚动时颜色断层。
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color.lerp(const Color(0xFFFFE9EF), colors.bgCard, t)!,
                    colors.bgCard,
                  ],
                ),
              ),
            ),
          ),
          // logo 行（`iv_logo` 22dp 高 + 右侧 `iv_service`）。
          Positioned(
            left: _horizontal,
            right: _horizontal,
            top: topPadding + _logoRowTop - _logoRowHeight * t,
            height: _logoRowHeight,
            child: Opacity(
              opacity: (1 - t * 1.6).clamp(0.0, 1.0),
              child: Row(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(LucideIcons.sparkles, size: 18, color: colors.brand),
                      const SizedBox(width: 4),
                      Text(
                        '企划星',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.brand,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(LucideIcons.shieldCheck, size: 14, color: colors.textTertiary),
                  const SizedBox(width: 2),
                  Text(
                    '100%真票 · 无票赔付',
                    style: TextStyle(fontSize: 11, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: _horizontal,
            right: _horizontal,
            top: searchTop,
            height: _searchHeight,
            child: PsSearchBar(
              city: city,
              hints: hints,
              onTapCity: onTapCity,
              onTapSearch: onTapSearch,
              onTapField: onTapField,
            ),
          ),
          // 收起后补一条 1dp 分隔线，替代阴影（企划星 `view_divider` 的做法）。
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: t,
              child: Container(height: 1, color: colors.divider),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeHeader oldDelegate) {
    return oldDelegate.city != city ||
        oldDelegate.topPadding != topPadding ||
        oldDelegate.hints.length != hints.length;
  }
}
