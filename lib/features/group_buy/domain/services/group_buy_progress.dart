import '../group_buy.dart';

/// 参团被拒绝的原因。
enum GroupBuyJoinBlock {
  /// 可以参团。
  none,

  /// 活动不在「拼团中」状态。
  notGrouping,

  /// 已满团。
  full,

  /// 已过有效期。
  expired,

  /// 库存不足。
  outOfStock,
}

/// 拼团进度快照。
final class GroupBuyProgress {
  const GroupBuyProgress({
    required this.remainingSlots,
    required this.isFull,
    required this.progress,
    required this.isExpired,
    required this.remainingHours,
    required this.hasStock,
    required this.block,
  });

  /// 还差多少人成团（不会为负）。
  final int remainingSlots;

  /// 是否已满团。
  final bool isFull;

  /// 进度百分比（0–1）。
  final double progress;

  /// 是否已过期。
  final bool isExpired;

  /// 距到期剩余小时数（已过期或不足一小时为 0）。
  final int remainingHours;

  /// 库存是否充足。
  final bool hasStock;

  /// 参团拦截原因；[GroupBuyJoinBlock.none] 表示可以参团。
  final GroupBuyJoinBlock block;

  /// 是否可以参团。
  bool get canJoin => block == GroupBuyJoinBlock.none;
}

/// 拼团进度策略（纯函数）。
///
/// [now] 显式注入，便于测试过期与剩余时间；不依赖 `DateTime.now()`。
final class GroupBuyProgressPolicy {
  const GroupBuyProgressPolicy();

  GroupBuyProgress evaluate(GroupBuyInfo info, {required DateTime now}) {
    final bool isFull = info.currentMembers >= info.succeedNum;
    final int remainingSlots = info.succeedNum > info.currentMembers
        ? info.succeedNum - info.currentMembers
        : 0;
    final double rawProgress = info.succeedNum > 0
        ? info.currentMembers / info.succeedNum
        : 0;
    final bool isExpired = now.isAfter(info.effectiveTo);
    final Duration untilExpiry = info.effectiveTo.difference(now);
    final int remainingHours = untilExpiry.isNegative ? 0 : untilExpiry.inHours;
    final bool hasStock = info.stock > 0;

    return GroupBuyProgress(
      remainingSlots: remainingSlots,
      isFull: isFull,
      progress: rawProgress.clamp(0.0, 1.0).toDouble(),
      isExpired: isExpired,
      remainingHours: remainingHours,
      hasStock: hasStock,
      block: blockOf(
        info,
        now: now,
        isFull: isFull,
        isExpired: isExpired,
        hasStock: hasStock,
      ),
    );
  }

  /// 判断能否参团（加入 / 下单）。
  ///
  /// 顺序：状态 → 过期 → 满团 → 库存。库存不足单独暴露为
  /// [GroupBuyJoinBlock.outOfStock]，供应用层给出明确提示。
  GroupBuyJoinBlock blockOf(
    GroupBuyInfo info, {
    required DateTime now,
    bool? isFull,
    bool? isExpired,
    bool? hasStock,
  }) {
    if (info.status != GroupBuyStatus.grouping) {
      return GroupBuyJoinBlock.notGrouping;
    }
    if (isExpired ?? now.isAfter(info.effectiveTo)) {
      return GroupBuyJoinBlock.expired;
    }
    if (isFull ?? info.currentMembers >= info.succeedNum) {
      return GroupBuyJoinBlock.full;
    }
    if (!(hasStock ?? info.stock > 0)) {
      return GroupBuyJoinBlock.outOfStock;
    }
    return GroupBuyJoinBlock.none;
  }

  /// 便捷判定：能否参团。
  bool canJoin(GroupBuyInfo info, {required DateTime now}) =>
      blockOf(info, now: now) == GroupBuyJoinBlock.none;
}
