/// 强类型 ID。
///
/// 用 `extension type`（零运行时开销的包装）而不是裸 `String`/`int`：
/// `ShowId` 与 `TicketOrderId` 在编译期就不可互换。
///
/// 这条直接对应企划星的一个真实缺陷：`wiki_zh/27` §10 —— 94 个模型的 id 都是裸 `int`，
/// `id` 和 `activityId` 是两个独立字段，服务端有时只填一个；把 `activityId`
/// 传进 `orderId` 参数编译得过去，运行时才炸。
library;

/// 演出（活动）id。
extension type const ShowId(String value) {
  static ShowId? tryParse(String? raw) {
    final trimmed = raw?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : ShowId(trimmed);
  }
}

/// 场次 id。
extension type const SessionId(String value) {
  static SessionId? tryParse(String? raw) {
    final trimmed = raw?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : SessionId(trimmed);
  }
}

/// 票档 id（原 App 的 `TicketGroup` / `Goods` 身份）。
extension type const TicketTierId(String value) {}

/// 订单 id。
extension type const TicketOrderId(String value) {
  static TicketOrderId? tryParse(String? raw) {
    final trimmed = raw?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : TicketOrderId(trimmed);
  }
}

/// 营销活动 id。
extension type const CampaignId(String value) {}

/// 优惠券 id。
extension type const CouponId(String value) {}

/// 礼品卡 id。
extension type const GiftCardId(String value) {}

/// 观演人 id。
extension type const VisitorId(String value) {}
