/// 本地锁座服务。
///
/// 只维护「座位 ID → 锁定截止时间」的内存锁表，不访问服务端。
/// 服务端座位库存尚未接入，因此这把锁只在当前进程内有效：
/// 换设备 / 重启 App / 其他用户都感知不到它。
class SeatLockService {
  SeatLockService({
    this.defaultTtl = defaultSeatLockTtl,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// 默认锁定时长（10 分钟，与选座倒计时窗口一致）。
  static const Duration defaultSeatLockTtl = Duration(minutes: 10);

  /// 默认 TTL；可在构造时注入短时长便于测试。
  final Duration defaultTtl;

  /// 可注入时钟（测试用）。
  final DateTime Function() _clock;

  final Map<int, DateTime> _expiresAt = <int, DateTime>{};

  /// 锁定座位。
  ///
  /// 已有未过期锁时返回 `false`（不覆盖别人的到期时间）；
  /// 写入成功返回 `true`。[ttl] 为空时使用 [defaultTtl]。
  bool lock(int seatId, {Duration? ttl}) {
    final effectiveTtl = ttl ?? defaultTtl;
    if (effectiveTtl <= Duration.zero) return false;

    releaseExpired();
    if (_expiresAt.containsKey(seatId)) return false;

    _expiresAt[seatId] = _clock().add(effectiveTtl);
    return true;
  }

  /// 释放单个座位的锁。
  void unlock(int seatId) {
    _expiresAt.remove(seatId);
  }

  /// 释放全部锁。
  void unlockAll() {
    _expiresAt.clear();
  }

  /// 座位是否仍处于锁定状态（过期锁会被顺带清理）。
  bool isLocked(int seatId) {
    releaseExpired();
    return _expiresAt.containsKey(seatId);
  }

  /// 清理所有已到期的锁。
  void releaseExpired() {
    final now = _clock();
    _expiresAt.removeWhere((_, expiresAt) => !expiresAt.isAfter(now));
  }
}
