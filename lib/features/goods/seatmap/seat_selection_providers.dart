import 'dart:async';

import 'package:core/domain.dart';
import 'package:core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../../catalog/application/catalog_providers.dart';
import 'demo_seat_map.dart';
import 'domain/seat_continuity_policy.dart';
import 'seat_lock_service.dart';
import 'seat_map.dart';

/// 座位图数据 Provider（按演出 id 分族）。
///
/// 企划星的 `SelectTicketSeatMapActivity` 调 `GET v5/ticketCategories` 拿座位图。
/// 本演示模式用 [DemoSeatMap.generate] 生成座位布局；
/// 真实模式下座位价格统一取后端权威单价（`priceFrom`），
/// 与服务端「在售票档最低价 × 数量」的结算口径保持一致。
final seatMapDataProvider = Provider.family<SeatMapData, String>((ref, showId) {
  final policy = ref.watch(dataSourcePolicyProvider);
  final show = ref.watch(showFullProvider(showId));
  final unitPrice = policy.isDemo || show == null ? null : show.priceFrom;
  return DemoSeatMap.generate(
    unitPrice: unitPrice != null && unitPrice.minorUnits > 0 ? unitPrice : null,
  );
});

/// 本地锁座服务 Provider（按演出 id 分族，避免不同演出的座位 ID 互相干扰）。
///
/// **注意：这是本地锁，服务端座位库存未接入**——锁只在当前 App 进程内有效，
/// 其他用户 / 其他设备看不到，也不会在服务端占座。
final seatLockServiceProvider = Provider.family<SeatLockService, String>(
  (ref, showId) => SeatLockService(),
);

/// 选座会话时长（与默认锁座 TTL 一致）。
const Duration seatSelectionWindow = SeatLockService.defaultSeatLockTtl;

/// 选座倒计时时长 Provider；测试可注入很短的时长。
final seatSelectionDurationProvider = Provider<Duration>(
  (ref) => seatSelectionWindow,
);

/// 选座状态。
class SeatSelectionState {
  const SeatSelectionState({
    required this.mapData,
    this.selectedSeatIds = const <int>{},
    this.leftSeconds = 600,
    this.timedOut = false,
  });

  final SeatMapData mapData;

  /// 选中座位 ID 集合。
  final Set<int> selectedSeatIds;

  /// 倒计时剩余秒数（默认 10 分钟）。
  final int leftSeconds;

  /// 倒计时是否已归零（页面据此提示「选座已超时」）。
  final bool timedOut;

  /// 选中的座位列表。
  List<Seat> get selectedSeats {
    final result = <Seat>[];
    for (final area in mapData.areas) {
      for (final row in area.rows) {
        for (final seat in row.seats) {
          if (selectedSeatIds.contains(seat.id)) {
            result.add(seat);
          }
        }
      }
    }
    return result;
  }

  /// 总价。
  Money get totalPrice {
    if (selectedSeats.isEmpty) return Money.zero();
    var sum = 0;
    for (final seat in selectedSeats) {
      sum += seat.price?.minorUnits ?? 0;
    }
    return Money.fromMinorUnits(sum);
  }

  /// 选中数量。
  int get count => selectedSeatIds.length;

  /// 是否达到最大选择数。
  bool get atMax => count >= maxSeats;

  /// 最大可选数量（企划星默认 6，可通过 `buyCount` 参数控制）。
  static const int maxSeats = 6;

  SeatSelectionState copyWith({
    Set<int>? selectedSeatIds,
    int? leftSeconds,
    bool? timedOut,
  }) {
    return SeatSelectionState(
      mapData: mapData,
      selectedSeatIds: selectedSeatIds ?? this.selectedSeatIds,
      leftSeconds: leftSeconds ?? this.leftSeconds,
      timedOut: timedOut ?? this.timedOut,
    );
  }
}

/// 选座控制器。
///
/// ## 与 Android 的差异
///
/// - **锁座是本地锁**：选中即写入 [SeatLockService] 的内存锁表（默认 10 分钟），
///   取消选择 / 清空 / 超时 / 页面销毁时释放。服务端座位库存未接入，
///   因此这把锁不跨进程、不跨用户，仅用于本页内的选座冲突防护。
/// - **连座**：进入确认页前用 [SeatContinuityPolicy] 校验「同一区域 + 同一排 +
///   列号连续」，不通过时由页面提示并阻止跳转。
/// - **倒计时**：默认 10 分钟，归零后清空选择并释放全部本地锁；
///   超时后重新选座会重新开始一轮倒计时。
class SeatSelectionController
    extends FamilyNotifier<SeatSelectionState, String> {
  Timer? _countdownTimer;

  SeatLockService get _locks => ref.read(seatLockServiceProvider(arg));

  @override
  SeatSelectionState build(arg) {
    final mapData = ref.read(seatMapDataProvider(arg));
    final window = ref.read(seatSelectionDurationProvider);
    _startCountdown(window);
    ref.onDispose(() {
      _countdownTimer?.cancel();
      _countdownTimer = null;
    });
    return SeatSelectionState(mapData: mapData, leftSeconds: window.inSeconds);
  }

  /// 切换座位选择状态。
  ///
  /// 可选座位 → 选中 / 取消选中。
  /// 不可选或已被本地锁占用（且非本人选中）→ 忽略。
  /// 已达上限 → 再选新的不生效（先取消一个才能选新的）。
  void toggleSeat(Seat seat) {
    if (!seat.isSelectable) return;

    final ids = Set<int>.of(state.selectedSeatIds);
    if (ids.contains(seat.id)) {
      ids.remove(seat.id);
      _locks.unlock(seat.id);
    } else {
      if (state.atMax) return;
      _locks.releaseExpired();
      if (_locks.isLocked(seat.id)) return;
      if (!_locks.lock(seat.id)) return;
      ids.add(seat.id);
      _restartIfExpired();
    }
    state = state.copyWith(selectedSeatIds: ids);
  }

  /// 用 WebView 回传的整份选中集合覆盖当前状态。
  ///
  /// WebView 只是渲染层，这里仍按座位图数据做一次校验：
  /// 只接受真实存在、可选且未被本地锁占用的座位，并强制不超过
  /// [SeatSelectionState.maxSeats]。与当前选中集合做差异后加锁 / 解锁。
  void setSelection(Iterable<int> seatIds) {
    final next = <int>{};
    for (final id in seatIds) {
      if (next.length >= SeatSelectionState.maxSeats) break;
      final seat = state.mapData.seatById(id);
      if (seat == null || !seat.isSelectable) continue;

      final alreadySelected = state.selectedSeatIds.contains(id);
      if (!alreadySelected) {
        _locks.releaseExpired();
        if (_locks.isLocked(id)) continue;
        if (!_locks.lock(id)) continue;
      }
      next.add(id);
    }

    for (final id in state.selectedSeatIds) {
      if (!next.contains(id)) _locks.unlock(id);
    }
    if (next.isNotEmpty) _restartIfExpired();

    state = state.copyWith(selectedSeatIds: next);
  }

  /// 清空选择并释放全部本地锁。
  void clear() {
    _locks.unlockAll();
    state = state.copyWith(selectedSeatIds: <int>{});
  }

  /// 校验当前选中座位是否连座（进入确认页前调用）。
  Result<void> validateContinuity() {
    return const SeatContinuityPolicy().validate(state.selectedSeats);
  }

  /// 格式化倒计时为 mm:ss（与 `PayController.formatCountdown` 口径一致）。
  static String formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startCountdown(Duration window) {
    _countdownTimer?.cancel();
    if (window <= Duration.zero) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.leftSeconds - 1;
      if (remaining <= 0) {
        timer.cancel();
        _countdownTimer = null;
        _locks.unlockAll();
        state = state.copyWith(
          selectedSeatIds: const <int>{},
          leftSeconds: 0,
          timedOut: true,
        );
      } else {
        state = state.copyWith(leftSeconds: remaining);
      }
    });
  }

  /// 超时后用户重新选座：重置倒计时并重新开始计时。
  void _restartIfExpired() {
    if (state.leftSeconds > 0) return;
    final window = ref.read(seatSelectionDurationProvider);
    state = state.copyWith(leftSeconds: window.inSeconds, timedOut: false);
    _startCountdown(window);
  }
}

/// 选座控制器 Provider。
final seatSelectionProvider =
    NotifierProvider.family<
      SeatSelectionController,
      SeatSelectionState,
      String
    >(SeatSelectionController.new);
