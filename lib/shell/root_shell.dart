import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import '../shared/ui/ps_floating_tab_bar.dart';

/// StatefulShellRoute 的外壳：唯一的自适配底栏 + 当前分支（IndexedStack）。
/// 底栏的 selectedIndex / onTap 直接映射到 navigationShell，切 Tab 保留各分支栈。
///
/// 底栏文案走 l10n，不再硬编码中文——硬编码会让 `supportedLocales` 里的
/// `en` 变成"只有 Material 组件是英文、自家文案还是中文"的半吊子状态。
///
/// ## 图标：全量 Lucide
///
/// 五个 tab 统一用 Lucide 线性图标，选中/未选中只差颜色和 iOS 那条高亮
/// 胶囊（见 [PsFloatingTabBar]）。本地 Lottie 动画资源已随 assets/ 一并移除。
///
/// ## 底栏形态
///
/// 交给 `AdaptiveScaffold` + [AdaptiveBottomNavigationBar]：iOS 26+ 用原生悬浮
/// tab bar，Android 用 [PsFloatingTabBar] 对齐同一套悬浮胶囊视觉。`items` 一份
/// 数据两条路径共用，加 tab 只改 [_tabs]。开了 `extendBody`，页面内容从胶囊
/// 底下滚过；各 tab 页底部净空取 `PsFloatingTabBar.bottomClearance`。
class RootShell extends ConsumerWidget {
  const RootShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// (图标, l10n key)。图标用 Lucide：`house`/`compass`/`messageCircle`/
  /// `receiptText`/`user`，与 iOS tab bar 的 SF Symbols 同为线性风格。
  static const List<(IconData, String)> _tabs = <(IconData, String)>[
    (LucideIcons.house, 'tabHome'),
    (LucideIcons.compass, 'tabDiscover'),
    (LucideIcons.messageCircle, 'tabMessage'),
    (LucideIcons.receiptText, 'tabOrder'),
    (LucideIcons.user, 'tabProfile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentIndex = navigationShell.currentIndex;

    final items = <AdaptiveNavigationDestination>[
      for (var i = 0; i < _tabs.length; i++)
        AdaptiveNavigationDestination(
          icon: _tabs[i].$1,
          label: _resolveLabel(l10n, _tabs[i].$2),
        ),
    ];

    void goBranch(int index) => navigationShell.goBranch(index);

    return AdaptiveScaffold(
      body: navigationShell,
      // 内容铺到悬浮胶囊底下（iOS 悬浮 tab bar 的效果）：胶囊外层那圈留白透出的
      // 是页面内容，不是一条背景色带。配套要求：每个 tab 页的滚动容器底部要补
      // `PsFloatingTabBar.bottomClearance`，否则滚到底时最后一屏会被胶囊盖住。
      extendBody: true,
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        items: items,
        selectedIndex: currentIndex,
        onTap: goBranch,
        // Android 用悬浮胶囊 bar。iOS 上这个字段被忽略：iOS 26+ 走原生悬浮
        // tab bar（useNativeBottomBar 默认 true），iOS <26 由 items 生成
        // CupertinoTabBar。
        bottomNavigationBar: PsFloatingTabBar(
          items: items,
          selectedIndex: currentIndex,
          onTap: goBranch,
        ),
      ),
    );
  }

  String _resolveLabel(AppLocalizations l10n, String key) => switch (key) {
    'tabHome' => l10n.tabHome,
    'tabDiscover' => l10n.tabDiscover,
    'tabMessage' => l10n.tabMessage,
    'tabOrder' => l10n.tabOrder,
    'tabProfile' => l10n.tabProfile,
    _ => key,
  };
}
