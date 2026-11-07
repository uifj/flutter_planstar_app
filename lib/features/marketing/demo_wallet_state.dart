import 'package:flutter_riverpod/flutter_riverpod.dart';

/// demo 模式下的星币账户状态。
///
/// 钱包页与「我的」页签到卡共用同一份状态，保证本地演示时
/// 「签到 +100 → 钱包余额 +100」的表现与真实接口一致。
final class DemoWalletState {
  const DemoWalletState({this.signedOn, this.balanceMinorUnits = 30000});

  /// 最近一次签到的自然日。
  final DateTime? signedOn;

  /// 当前星币余额（最小单位：分）。
  final int balanceMinorUnits;

  /// 今天是否已签到。
  bool get signedToday {
    final DateTime? day = signedOn;
    if (day == null) return false;
    final DateTime now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }
}

/// demo 模式签到控制器：内存中维护「今天是否已签到 + 星币余额」。
class DemoWalletController extends Notifier<DemoWalletState> {
  /// 每次签到奖励 100 星币（10000 分）。
  static const int signInRewardMinorUnits = 10000;

  @override
  DemoWalletState build() => const DemoWalletState();

  /// 本地签到；返回本次是否真正入账（当天重复签到返回 false）。
  bool signIn() {
    if (state.signedToday) return false;
    state = DemoWalletState(
      signedOn: DateTime.now(),
      balanceMinorUnits: state.balanceMinorUnits + signInRewardMinorUnits,
    );
    return true;
  }
}

final demoWalletStateProvider =
    NotifierProvider<DemoWalletController, DemoWalletState>(
      DemoWalletController.new,
    );
