/// 选票页 → 确认页的**用户选择快照**。
///
/// 历史缺陷（P0-08）：`choose_ticket_page.dart` 把 `tier/qty/session` 拼进
/// `/order/confirm` 的 query，但路由 builder 只取了 `showId`，确认页固定用
/// `seed.tiers.first` + 1 张建草稿，导致用户选的高价档 / 多份 / 指定场次全部
/// 失效，实付金额与意愿不符。
///
/// 现在把选择作为不可变值对象并入 [OrderConfirmArgs]，作为控制器与种子
/// provider 的 family 参数：无全局可变状态、无 Riverpod 作用域覆盖，
/// 同一个 showId 的不同选择也各自独立缓存，天然支持多页面并存。
///
/// 所有字段都是「索引」而非金额：金额一律由服务端票档数据重新计算。
final class OrderConfirmSelection {
  const OrderConfirmSelection({
    this.tierIndex,
    this.quantity,
    this.sessionIndex,
  });

  /// `show.tiers` 的下标；越界或为 null 时回退首个票档。
  final int? tierIndex;

  /// 购买张数；小于 1 或超过限购时由控制器按限购规则收敛。
  final int? quantity;

  /// `show.sessions` 的下标；越界或为 null 时回退首个场次。
  final int? sessionIndex;

  bool get isEmpty =>
      tierIndex == null && quantity == null && sessionIndex == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderConfirmSelection &&
          other.tierIndex == tierIndex &&
          other.quantity == quantity &&
          other.sessionIndex == sessionIndex;

  @override
  int get hashCode => Object.hash(tierIndex, quantity, sessionIndex);
}

/// 确认订单页的 family 参数（Riverpod 用 `==` / [hashCode] 做缓存键）。
final class OrderConfirmArgs {
  const OrderConfirmArgs({
    required this.showId,
    this.selection = const OrderConfirmSelection(),
  });

  final String showId;
  final OrderConfirmSelection selection;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderConfirmArgs &&
          other.showId == showId &&
          other.selection == selection;

  @override
  int get hashCode => Object.hash(showId, selection);
}
