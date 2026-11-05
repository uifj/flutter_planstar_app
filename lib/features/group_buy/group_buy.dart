import 'package:core_domain/core_domain.dart';

/// 拼团状态。
///
/// 对齐 Android `pinTuanOrderStatus`：
/// - `1` = 拼团中
/// - `2` = 拼团成功
/// - `3` = 拼团失败（未成团）
/// - `4` = 已取消
enum GroupBuyStatus {
  /// 拼团中（Android status=1）。
  grouping,

  /// 拼团成功（Android status=2）。
  success,

  /// 拼团失败（Android status=3）。
  failed,

  /// 已取消（Android status=4）。
  cancelled,
}

/// 拼团成员。
///
/// 对齐 Android：拼团列表中的成员项。
final class GroupBuyMember {
  const GroupBuyMember({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    required this.isLeader,
    required this.joinedAt,
  });

  final int userId;
  final String nickname;
  final String? avatarUrl;

  /// 是否团长。
  final bool isLeader;

  final DateTime joinedAt;
}

/// 拼团信息。
///
/// 对齐 Android `PinTuanInfo.java`（Kotlin data class）。
///
/// ## 与 Android 的差异
///
/// - Android 字段全裸 `double` / `int` / `long`。
/// - 这里用 `Money` 表示价格，`DateTime` 表示时间，
///   `GroupBuyStatus` 枚举表示状态。
final class GroupBuyInfo {
  const GroupBuyInfo({
    required this.id,
    required this.showTitle,
    required this.showPoster,
    required this.venue,
    required this.eventTime,
    required this.lowPrice,
    required this.originalPrice,
    required this.succeedNum,
    required this.currentMembers,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.status,
    required this.slogan,
    required this.members,
    required this.stock,
    this.tag = '超低价拼团',
  });

  /// 拼团活动 ID（Android `id`）。
  final int id;

  /// 演出标题。
  final String showTitle;

  /// 海报 URL。
  final String? showPoster;

  /// 场馆。
  final String venue;

  /// 演出时间。
  final String eventTime;

  /// 拼团价（Android `lowPrice`）。
  final Money lowPrice;

  /// 原价（Android `originPrice`）。
  final Money originalPrice;

  /// 成团人数（Android `succeedNum`）。
  final int succeedNum;

  /// 当前已参团人数。
  final int currentMembers;

  /// 有效期开始（Android `effectiveFrom`）。
  final DateTime effectiveFrom;

  /// 有效期结束（Android `effectiveTo`）。
  final DateTime effectiveTo;

  /// 状态。
  final GroupBuyStatus status;

  /// 标语（Android `slogan`）。
  final String slogan;

  /// 标签（Android `pinTuanTag`）。
  final String tag;

  /// 已参团成员列表。
  final List<GroupBuyMember> members;

  /// 库存（Android `stock`）。
  final int stock;

  /// 还差多少人成团。
  int get remaining => succeedNum - currentMembers;

  /// 是否已满团。
  bool get isFull => currentMembers >= succeedNum;

  /// 进度百分比（0-1）。
  double get progress => succeedNum > 0 ? currentMembers / succeedNum : 0;

  /// 是否已过期。
  bool get isExpired => DateTime.now().isAfter(effectiveTo);

  /// 距到期剩余小时数。
  int get remainingHours =>
      effectiveTo.difference(DateTime.now()).inHours;

  /// 折扣文案（如"5.5折"）。
  String get discountLabel {
    if (originalPrice.minorUnits <= 0) return '';
    final rate = (lowPrice.minorUnits * 10) ~/ originalPrice.minorUnits;
    if (rate >= 10) return '';
    if (rate % 10 == 0) return '${rate ~/ 10}折';
    return '${rate / 10}折';
  }

  /// 节省金额。
  Money get savedAmount => originalPrice - lowPrice;

  /// 状态文案。
  String get statusLabel {
    switch (status) {
      case GroupBuyStatus.grouping:
        return '拼团中';
      case GroupBuyStatus.success:
        return '拼团成功';
      case GroupBuyStatus.failed:
        return '拼团失败';
      case GroupBuyStatus.cancelled:
        return '已取消';
    }
  }
}
