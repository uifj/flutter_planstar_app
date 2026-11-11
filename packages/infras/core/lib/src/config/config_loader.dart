/// 幂等异步加载：并发调用共享一次加载，**失败不会让后来者永久挂起**。
library;

import 'package:core/result.dart';

import 'app_config.dart';
import 'config_source.dart';

/// 配置加载器。
///
/// 这个类存在的唯一理由就是修掉"初始化失败后后来者永久挂起"。
///
/// 反面写法（一次性初始化标记 + 裸 Completer）长这样：
///
/// ```dart
/// if (!_initEndpoint) {
///   _initEndpoint = true;
///   ... await config.getConfig(...) ...   // ← 这里可能抛
///   _initCompleter.complete();            // ← 只有成功才走得到
/// } else {
///   await _initCompleter.future;          // ← 后来者永久挂起
/// }
/// ```
///
/// 一旦第一次初始化抛异常，`_initCompleter` 永远不会 complete，
/// **所有后来者会永远等下去**——不是报错，是静默卡死，最难查。
///
/// 这里的做法：
/// 1. 用 `Future<Result<AppConfig>>` 而不是裸 `Completer`——失败本身就是
///    一个正常的返回值，不存在"该 complete 没 complete"的路径；
/// 2. `finally` 里清空 in-flight，失败后下一次调用会**重新尝试**；
/// 3. 成功结果缓存在 [_cached]，后续调用不再碰数据源。
final class ConfigLoader {
  /// 用数据源创建。
  ConfigLoader(this._source);

  final ConfigSource _source;

  AppConfig? _cached;
  Future<Result<AppConfig>>? _inFlight;

  /// 是否已成功加载过。
  bool get isLoaded => _cached != null;

  /// 已加载的配置（未加载时为 `null`）。
  AppConfig? get cached => _cached;

  /// 加载配置。
  ///
  /// 并发调用**共享同一个 Future**；成功后再调直接返回缓存；
  /// 失败后调用会重新尝试（不会挂起）。
  Future<Result<AppConfig>> load() {
    final cached = _cached;
    if (cached != null) {
      return Future<Result<AppConfig>>.value(Success<AppConfig>(cached));
    }
    final inFlight = _inFlight;
    if (inFlight != null) {
      return inFlight;
    }
    final future = _loadOnce();
    _inFlight = future;
    return future;
  }

  /// 丢弃缓存，强制下次 [load] 重新拉取。
  void invalidate() {
    _cached = null;
    _inFlight = null;
  }

  Future<Result<AppConfig>> _loadOnce() async {
    try {
      final raw = await _source.load();
      final config = AppConfig(raw);
      _cached = config;
      return Success<AppConfig>(config);
    } catch (error) {
      return Fail<AppConfig>(
        Failure(
          code: 'CONFIG_LOAD_FAILED',
          message: '配置加载失败：$error',
          type: FailureType.data,
          cause: error,
        ),
      );
    } finally {
      // 成败都清空：失败后下次调用会重试，而不是拿到一个永远不会完成的
      // future。
      _inFlight = null;
    }
  }
}
