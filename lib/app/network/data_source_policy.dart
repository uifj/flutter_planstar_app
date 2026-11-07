import 'api_config.dart';

/// 数据源策略：全局唯一的"走 demo 还是走真实接口"判断入口。
///
/// 业务层**不应**直接读 `useDemoProvider`（`lib/app/network` 内部实现细节），
/// 统一通过 `dataSourcePolicyProvider` 拿到本对象，再按语义分支：
///
/// ```dart
/// final policy = ref.watch(dataSourcePolicyProvider);
/// if (policy.isDemo) return buildDemoData();
/// ```
///
/// 之所以收敛成一个对象，是为了让"数据源"这件事只有一处定义，
/// 不在几十个 provider 里各自 `!ref.read(useDemoProvider)`。
final class DataSourcePolicy {
  const DataSourcePolicy({required this.isDemo});

  /// 从 API 配置派生。[ApiConfig.useDemo] 是唯一真相源。
  factory DataSourcePolicy.fromApiConfig(ApiConfig config) =>
      DataSourcePolicy(isDemo: config.useDemo);

  /// 是否使用本地演示数据。
  final bool isDemo;

  /// 是否走真实远端数据。
  bool get isRemote => !isDemo;

  /// 按数据源二选一。
  ///
  /// 用于需要"取某个值"或"执行某个副作用"的场景，避免每个调用点都写
  /// `if (isDemo) … else …`。
  T pick<T>({required T Function() demo, required T Function() remote}) =>
      isDemo ? demo() : remote();
}
