import 'package:core_domain/core_domain.dart';
import 'package:core_result/core_result.dart';

/// 限购规则。
///
/// 企划星 `ActivityBean` 有 4 个相关字段（`numMax` / `numMin` / `orderLimit` /
/// `orderNumLimit`，`wiki_zh/27` §10）语义重叠，服务端填哪个不固定。
/// 这里只保留两个**真正影响下单**的维度：
/// - [maxPerOrder]：单笔最多买几张（"每单限购 6 张"）
/// - [maxPerUser]：每个账号累计最多买几张（"每人限购 2 张"）
final class PurchaseLimit extends ValueObject {
  const PurchaseLimit({this.maxPerOrder, this.maxPerUser});

  /// 无限制。
  const PurchaseLimit.unlimited() : maxPerOrder = null, maxPerUser = null;

  /// 单笔上限。
  final Quantity? maxPerOrder;

  /// 账号累计上限。
  final Quantity? maxPerUser;

  bool get isUnlimited => maxPerOrder == null && maxPerUser == null;

  @override
  List<Object?> get props => <Object?>[maxPerOrder, maxPerUser];

  @override
  String toString() {
    if (isUnlimited) return '不限购';
    final parts = <String>[
      if (maxPerOrder != null) '每单限 ${maxPerOrder!.value} 张',
      if (maxPerUser != null) '每人限 ${maxPerUser!.value} 张',
    ];
    return parts.join('，');
  }
}

/// 限购策略 —— **无状态领域服务**。
///
/// 单独抽出来的理由：限购要在"加票档"（本地）和"下单前"（服务端返回已购数）两处
/// 用同一套判断。企划星侧是 `ChooseTicketHelper` 里一段共享计算 + 服务端兜底，
/// 前端那套没有任何测试。
final class PurchaseLimitPolicy {
  const PurchaseLimitPolicy();

  /// 单笔数量校验。
  Result<void> checkOrderQuantity({
    required Quantity requested,
    required PurchaseLimit limit,
  }) {
    final max = limit.maxPerOrder;
    if (max != null && requested.exceeds(max)) {
      return Fail<void>(
        Failure(
          code: 'ORDER_LIMIT_PER_ORDER',
          message: '每单最多购买 ${max.value} 张',
          type: FailureType.validation,
        ),
      );
    }
    return const Success<void>(null);
  }

  /// 账号累计配额校验。
  Result<void> checkUserQuota({
    required Quantity requested,
    required Quantity alreadyPurchased,
    required PurchaseLimit limit,
  }) {
    final max = limit.maxPerUser;
    if (max == null) return const Success<void>(null);

    final total = alreadyPurchased + requested;
    if (total.exceeds(max)) {
      final remaining = max.value - alreadyPurchased.value;
      return Fail<void>(
        Failure(
          code: 'ORDER_LIMIT_PER_USER',
          message: remaining <= 0
              ? '每人限购 ${max.value} 张，您已购买 ${alreadyPurchased.value} 张'
              : '每人限购 ${max.value} 张，您还可购买 $remaining 张',
          type: FailureType.validation,
        ),
      );
    }
    return const Success<void>(null);
  }
}
