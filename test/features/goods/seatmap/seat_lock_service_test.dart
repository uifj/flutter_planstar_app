import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/goods/seatmap/seat_lock_service.dart';

void main() {
  group('SeatLockService', () {
    late DateTime now;

    SeatLockService createService({Duration ttl = const Duration(seconds: 2)}) {
      return SeatLockService(defaultTtl: ttl, clock: () => now);
    }

    setUp(() {
      now = DateTime(2026, 11, 7, 12);
    });

    test('TTL 过期后自动释放，并可重新锁定', () {
      final locks = createService();

      expect(locks.lock(1001), isTrue);
      expect(locks.isLocked(1001), isTrue);

      now = now.add(const Duration(seconds: 1));
      expect(locks.isLocked(1001), isTrue);

      // 恰好到达截止时间即视为过期。
      now = now.add(const Duration(seconds: 1));
      expect(locks.isLocked(1001), isFalse);
      expect(locks.lock(1001), isTrue, reason: '过期锁不应阻止重新锁定');
    });

    test('重复锁定返回 false，unlock / unlockAll 生效', () {
      final locks = createService(ttl: const Duration(minutes: 10));

      expect(locks.lock(1), isTrue);
      expect(locks.lock(1), isFalse, reason: '已有未过期锁时不覆盖');
      expect(locks.lock(2), isTrue);

      locks.unlock(1);
      expect(locks.isLocked(1), isFalse);
      expect(locks.isLocked(2), isTrue);

      locks.unlockAll();
      expect(locks.isLocked(2), isFalse);
    });

    test('构造默认 TTL 可被单次调用覆盖', () {
      final locks = createService(ttl: const Duration(minutes: 10));

      expect(locks.lock(1, ttl: const Duration(seconds: 1)), isTrue);
      now = now.add(const Duration(seconds: 2));
      expect(locks.isLocked(1), isFalse);
    });
  });
}
