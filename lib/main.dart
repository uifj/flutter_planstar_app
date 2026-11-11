import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/network/app_bootstrap.dart';
import 'app/network/network_providers.dart';

/// 应用装配根：`main() → 启动装配 → ProviderScope → MaterialApp.router`。
///
/// 对应架构图中 `main() → ProviderScope → MaterialApp.router` 链条，中间多了一步
/// [loadAppBootstrap]——它把"读配置 / 打开存储 / 灌 dvid 与 psSession"这三件必须在
/// 首个请求之前完成的事**一次性做完**，然后 override 进 Riverpod。
///
/// 为什么不把这些放进 provider 里懒加载：`dioProvider` 的拦截器是同步的，
/// 它读 `PsRequestContext` 时 `dvid`/`psSession` 必须已经在内存里；懒加载只能靠
/// "第一次请求前 await"，那等于把初始化顺序又变回隐式约定（全局单例
/// 懒初始化的老毛病）。宁可启动时多 await 一次。
///
/// `⚠` 测试不跑 `main()`，因此拿到的是 `AppBootstrap.memory`（内存存储），
/// 不会碰任何平台通道。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppBootstrap bootstrap = await loadAppBootstrap();
  runApp(
    ProviderScope(
      overrides: <Override>[appBootstrapProvider.overrideWithValue(bootstrap)],
      child: const PlanstarApp(),
    ),
  );
}
