/// 异步信号量：取消时用**返回值**表达，而不是抛异常。
library;

import 'dart:async';
import 'dart:collection';

/// 限制并发数的异步信号量。
///
/// 自带实现而非引第三方包：只有几十行，且属内部实现细节，
/// 不值得为它增加一个依赖与一层版本约束。
///
/// 唯一但关键的取舍：**取消时 [acquire] 返回 `false`，而不是 `completeError`。**
///
/// 为什么重要：若用异常表达取消，每个 `await semaphore.acquire()` 都得包
/// try/catch，而且异常会被 Sentry 记成错误——一次正常取消污染整个错误率。
/// 用返回值表达后，等待者醒来拿到 `false`，自然走"没拿到许可"分支，
/// 上层代码零 try/catch。这个小决定决定了取消路径的全部代码量。
final class AsyncSemaphore {
  /// 用初始许可数创建。
  AsyncSemaphore(this._permits)
      : assert(_permits > 0, '许可数必须为正');

  int _permits;
  bool _cancelled = false;
  final Queue<Completer<bool>> _waiters = Queue<Completer<bool>>();

  /// 当前可用许可数（不含等待者）。
  int get available => _permits;

  /// 是否已取消。
  bool get isCancelled => _cancelled;

  /// 等待一个许可。
  ///
  /// 返回 `true` 表示拿到；`false` 表示**已被取消**（调用方应直接放弃，
  /// 不要重试、不要当失败上报）。
  Future<bool> acquire() {
    if (_cancelled) {
      return Future<bool>.value(false);
    }
    if (_permits > 0) {
      _permits--;
      return Future<bool>.value(true);
    }
    final completer = Completer<bool>();
    _waiters.add(completer);
    return completer.future;
  }

  /// 归还一个许可。
  ///
  /// 已取消时**什么都不做**：否则会把许可还回一个已经关闭的信号量，
  /// 让新来的等待者以为还能继续。
  void release() {
    if (_cancelled) {
      return;
    }
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete(true);
      return;
    }
    _permits++;
  }

  /// 取消全部等待者：它们立刻拿到 `false`。
  void cancelAll() {
    _cancelled = true;
    while (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete(false);
    }
    _permits = 0;
  }
}
