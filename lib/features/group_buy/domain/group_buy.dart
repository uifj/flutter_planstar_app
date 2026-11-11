import 'package:core/domain.dart';

/// 组队支持状态。
///
/// 服务端状态码取值：
/// - `1` = 组队中
/// - `2` = 组队成功
/// - `3` = 组队失败（人数未达标）
/// - `4` = 已取消
enum GroupBuyStatus {
  /// 组队中（状态码 1）。
  grouping,

  /// 组队成功（状态码 2）。
  success,

  /// 组队失败（状态码 3）。
  failed,

  /// 已取消（状态码 4）。
  cancelled,
}

/// 组队支持成员。
///
/// 组队列表中的成员项。
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

  /// 是否发起人。
  final bool isLeader;

  final DateTime joinedAt;
}

/// 组队支持信息。
///
/// 组队支持：保留社交裂变、去掉票务心智（POSITIONING.md §10）。
///
/// 这里只保留数据；组队进度、剩余时间、过期与库存判定见
/// `domain/services/group_buy_progress.dart`，价格见
/// `domain/services/group_buy_pricing.dart`。
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
    this.tag = '',
  });

  /// 组队支持活动 ID。
  final int id;

  /// 企划标题。
  final String showTitle;

  /// 海报 URL。
  final String? showPoster;

  /// 活动场地。
  final String venue;

  /// 线下回报场次时间。
  final String eventTime;

  /// 组队支持价。
  final Money lowPrice;

  /// 原价。
  final Money originalPrice;

  /// 组队成功所需人数。
  final int succeedNum;

  /// 当前已参与人数。
  final int currentMembers;

  /// 有效期开始。
  final DateTime effectiveFrom;

  /// 有效期结束。
  final DateTime effectiveTo;

  /// 状态。
  final GroupBuyStatus status;

  /// 标语。
  final String slogan;

  /// 标签。
  final String tag;

  /// 已参与成员列表。
  final List<GroupBuyMember> members;

  /// 库存。
  final int stock;
}
