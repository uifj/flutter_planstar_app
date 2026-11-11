/// 强类型 ID。
///
/// 用 `extension type`（零运行时开销的包装）而不是裸 `String`/`int`：
/// `ShowId` 与 `TicketOrderId` 在编译期就不可互换。
///
/// 这条是为了避免一类真实缺陷：模型 id 全是裸 `int` 时，
/// 企划 id 和订单 id 是两个独立字段，服务端有时只填一个；把企划 id
/// 传进订单 id 参数编译得过去，运行时才炸。
library;

/// 企划 id。
extension type const ShowId(String value) {
  static ShowId? tryParse(String? raw) {
    final trimmed = raw?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : ShowId(trimmed);
  }
}

/// 线下回报场次 id。
extension type const SessionId(String value) {
  static SessionId? tryParse(String? raw) {
    final trimmed = raw?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : SessionId(trimmed);
  }
}

/// 回报档位 id。
extension type const TicketTierId(String value) {}

/// 支持单 id。
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

/// 实名支持者 id。
extension type const VisitorId(String value) {}
