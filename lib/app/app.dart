import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/auth_localizations.dart';
import '../l10n/catalog_localizations.dart';
import '../l10n/discover_localizations.dart';
import '../l10n/goods_localizations.dart';
import '../l10n/group_buy_localizations.dart';
import '../l10n/home_localizations.dart';
import '../l10n/marketing_localizations.dart';
import '../l10n/message_localizations.dart';
import '../l10n/order_localizations.dart';
import '../l10n/proxy_buy_localizations.dart';
import '../l10n/search_localizations.dart';
import '../l10n/user_localizations.dart';
import 'router.dart';
import 'sdk/sdk_bootstrap.dart';
import 'theme.dart';

/// 全部 l10n delegate：应用级 + 7 个 feature + Material/Cupertino 内置。
///
/// 抽成常量而不是写在 `MaterialApp` 的参数里，有两个原因：
/// 1. **可测**——`test/l10n_wiring_test.dart` 直接断言这份列表，不必渲染
///    任何页面（渲染页面会把 l10n 测试和页面改版绑死）。
/// 2. **单一来源**——新增 feature 时只改这里，不会出现"某个页面单独拼了
///    一份 delegate 列表"的分叉。
const List<LocalizationsDelegate<Object>> appLocalizationsDelegates =
    <LocalizationsDelegate<Object>>[
      // 应用级（跨 feature 共用文案）
      AppLocalizations.delegate,
      // 各 feature 自带
      AuthLocalizations.delegate,
      CatalogLocalizations.delegate,
      DiscoverLocalizations.delegate,
      GoodsLocalizations.delegate,
      GroupBuyLocalizations.delegate,
      HomeLocalizations.delegate,
      MarketingLocalizations.delegate,
      MessageLocalizations.delegate,
      OrderLocalizations.delegate,
      ProxyBuyLocalizations.delegate,
      SearchLocalizations.delegate,
      UserLocalizations.delegate,
      // Material / Cupertino 内置组件文案
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

/// 装配链的第二环：把 Riverpod 里的 [routerProvider] 交给 MaterialApp.router，
/// 并挂上 adaptive_platform_ui 的固定工具栏宿主（iOS 26 生效、Android 无副作用）
/// 与本地化 delegates。
///
/// 主题来自 [AppTheme]（`core_design_system` 的三层令牌），主题模式来自
/// [themeModeProvider]——**不再是写死的 `ThemeMode.system`**，
/// 后续接设置页只需要 `ref.read(themeModeProvider.notifier).set(...)`。
///
/// ## l10n 是「一 feature 一套 ARB」
///
/// 每个 feature 有自己的 ARB 与生成类，**源文件统一放在 `lib/l10n`**
/// （`lib/l10n/features/<name>/<name>_zh.arb`），这里只是把它们的 delegate
/// 汇总挂上（见 [appLocalizationsDelegates]）。**不要把 feature 文案搬进
/// 应用级 ARB**——那正是 §3.4 要治的病（一个几千行的巨型 ARB，
/// 谁都不敢删任何一个 key）。
///
/// 应用级 [AppLocalizations] 只保留跨 feature 共用的部分：应用名、底栏 Tab、
/// 通用动作（重试/取消/确定）、通用状态（加载/空/网络错误/超时/登录失效）。
///
/// `⚠` 新增 feature 时**两处都要改**：这里加 delegate，且
/// `tool/gen_l10n.dart` 的 `targets` 加一行（否则 ARB 不会生成）。
/// 忘了第一处的症状是运行时 `Null check operator` 或文案回落成 key；
/// 忘了第二处的症状是编译期找不到生成的类。
class PlanstarApp extends ConsumerWidget {
  const PlanstarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    // 触发第三方 SDK 初始化骨架：同意隐私前不动作，同意后自动 init
    // （百度地图合规 / JPush setup+init / fluwx registerApi）。见 sdk_bootstrap.dart。
    ref.watch(sdkBootstrapProvider);
    return MaterialApp.router(
      // 用 onGenerateTitle 而不是 title：title 拿不到 BuildContext，
      // 无法读取本地化文案。
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => AdaptiveToolbarHost(child: child!),
      localizationsDelegates: appLocalizationsDelegates,
      // 各套 ARB 支持的语种必须一致，取应用级为准（见 l10n_wiring_test.dart）。
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
