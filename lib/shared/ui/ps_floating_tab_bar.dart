import 'dart:ui';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

/// 悬浮胶囊底栏，对齐 iOS 26 悬浮 tab bar 的视觉。
///
/// ## 为什么要自己画
///
/// `AdaptiveScaffold` 的 Android 分支在没给自定义 bar 时会回落成 Material
/// `NavigationBar`：贴边、整条不透明、选中态是图标背后一枚小药丸，和 iOS 那条
/// 悬浮胶囊完全不是一回事。这里把它换成：整条收成胶囊、左右+底部留白浮在页面上、
/// 半透明 + 背景模糊 + 投影，选中项自己再套一枚高亮胶囊。
///
/// ## 只在 Android 生效
///
/// 本组件通过 `AdaptiveBottomNavigationBar.bottomNavigationBar` 注入，该字段
/// 在 iOS 上被忽略：iOS 26+ 走原生悬浮 tab bar（`useNativeBottomBar` 默认开），
/// iOS <26 由 `items` 生成 `CupertinoTabBar`。也就是说 iOS 侧拿到的就是真·系统
/// 悬浮 bar，Android 侧用这个组件对齐它，不存在两套手写的悬浮样式。
///
/// ## 布局占位
///
/// `RootShell` 开了 `extendBody`：body 铺满整屏、从胶囊底下滚过去，胶囊外层那圈
/// 留白透出的是页面内容而不是背景色（iOS 就是这个效果）。相应地，每个 tab 页的
/// 滚动容器要给底部补 [bottomClearance]，否则滚到底时最后一屏内容会永久压在胶囊下。
class PsFloatingTabBar extends StatelessWidget {
  const PsFloatingTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  /// 与 `AdaptiveBottomNavigationBar.items` 同一份列表：iOS 原生路径和这里
  /// 共用数据，避免两处各写五个 tab 而漏改一边。
  final List<AdaptiveNavigationDestination> items;

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const double _barHeight = 58;
  static const double _sideMargin = 12;
  static const double _topGap = 6;
  static const double _bottomGap = 8;
  static const double _radius = 29;
  static const double _itemRadius = 22;

  /// 悬浮 bar 在屏幕底部占掉的净空（顶部留白 + 胶囊高度 + 底部留白），
  /// 不含系统安全区。
  static const double contentClearance = _topGap + _barHeight + _bottomGap;

  /// 页面滚动内容底部要预留的 padding：胶囊净空 + 系统底部安全区。
  ///
  /// `RootShell` 开了 `extendBody`，body 会铺到胶囊底下（内容从玻璃底下滚过去，
  /// 和 iOS 一致）。代价是页面得把最后一屏内容抬到胶囊之上，否则底部内容会被
  /// 永久盖住——五个 tab 页滚动容器的底部 padding 统一取这个值。
  static double bottomClearance(BuildContext context) =>
      contentClearance + MediaQuery.viewPaddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 系统导航条/手势条的高度：胶囊要浮在它上面，不能被压到屏幕边。
    // 用 viewPadding 而不是 padding：键盘弹出时 padding.bottom 会变成键盘高度，
    // 而 Scaffold 已经把整条 bottomNavigationBar 抬到键盘上方了，两者叠加会把
    // bar 顶到屏幕中间去。viewPadding 是原始系统 inset，不随键盘变。
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _sideMargin,
        _topGap,
        _sideMargin,
        _bottomGap + bottomInset,
      ),
      child: Container(
        height: _barHeight,
        // 投影放在裁剪层外面：ClipRRect 会把子树画出的阴影一起裁掉。
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? colors.bgCard.withValues(alpha: 0.72)
                    : Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(_radius),
                // 描边是玻璃边缘的主要线索——底下没有可模糊的内容时，
                // 全靠它把胶囊从页面背景里抬出来。
                border: Border.all(
                  color: colors.border.withValues(alpha: isDark ? 0.6 : 0.35),
                ),
              ),
              child: Row(
                children: <Widget>[
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _PsFloatingTab(
                        item: items[i],
                        selected: i == selectedIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 单个 tab：图标 + 文案，选中时外面套一枚高亮胶囊。
class _PsFloatingTab extends StatelessWidget {
  const _PsFloatingTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AdaptiveNavigationDestination item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = selected ? colors.tabActive : colors.tabInactive;

    // icon 是 dynamic（iOS 原生路径允许传 SF Symbol 名），这里固定
    // 是 root_shell 传进来的 Lucide IconData。
    Widget icon = Icon(item.icon as IconData, size: 21, color: foreground);
    // badge 必须先用 hasBadge 兜一层再包：AdaptiveBadge 断言 count/label 至少
    // 给一个，无 badge 的 destination 直接 wrapWithBadge 会当场抛
    // （包里生成 NavigationBar 时也是同样的 if (dest.hasBadge) 判断）。
    if (item.hasBadge) {
      icon = item.wrapWithBadge(icon);
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: onTap,
        borderRadius: BorderRadius.circular(PsFloatingTabBar._itemRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? colors.tabActive.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(PsFloatingTabBar._itemRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
              const SizedBox(height: 1),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.1,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
