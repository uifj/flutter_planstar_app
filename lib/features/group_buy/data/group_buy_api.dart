import 'package:core/domain.dart';
import 'package:core/network.dart';
import 'package:core/result.dart';

import '../../../app/network/api_paths.dart';
import '../domain/group_buy.dart';

/// 组队支持 API 适配。
///
/// | 用途 | 方法 | 路径 |
/// |---|---|---|
/// | 我的组队 | GET | `v1/pinTuanOrder/myOrders` |
/// | 组队详情 | GET | `v1/pinTuanCampaign/{id}` |
/// | 参与组队 | POST | `v1/pinTuanOrder/make` |
final class GroupBuyApi {
  GroupBuyApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  /// 我的组队支持列表。
  Future<Result<List<GroupBuyInfo>>> fetchCampaigns() {
    return _client.get<List<GroupBuyInfo>>(
      ApiPaths.groupBuyOrders,
      queryParameters: <String, dynamic>{'pageIndex': 1, 'pageSize': 50},
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final List<dynamic> raw = _unwrapList(data);
        return raw
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> item) => _parseCampaign(_unwrapItem(item)),
            )
            .toList(growable: false);
      },
    );
  }

  /// 组队支持详情（不存在返回 `null`）。
  Future<Result<GroupBuyInfo?>> fetchCampaign(int id) {
    return _client.get<GroupBuyInfo?>(
      ApiPaths.groupBuyCampaign(id),
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final Map<String, dynamic>? json = _unwrapMap(data);
        return json == null ? null : _parseCampaign(_unwrapItem(json));
      },
    );
  }

  /// 参与组队。
  Future<Result<void>> join(int id) {
    return _client.post<void>(
      ApiPaths.groupBuyJoin,
      data: <String, dynamic>{'pinTuanId': id},
      envelope: const PassthroughEnvelope(),
      parser: (_) {},
    );
  }

  static List<dynamic> _unwrapList(Object? data) {
    Object? raw = data;
    if (raw is Map<String, dynamic>) {
      raw = raw['data'] ?? raw['list'] ?? raw['records'];
      if (raw is Map<String, dynamic>) {
        raw = raw['list'] ?? raw['records'] ?? raw['items'];
      }
    }
    return raw is List ? raw : const <dynamic>[];
  }

  static Map<String, dynamic>? _unwrapMap(Object? data) {
    if (data is! Map<String, dynamic>) return null;
    final Object? inner =
        data['data'] ?? data['pinTuanCampaign'] ?? data['result'];
    return inner is Map<String, dynamic> ? inner : data;
  }

  /// 订单项可能把活动信息包在 `pinTuanCampaign` / `campaign` 下。
  static Map<String, dynamic> _unwrapItem(Map<String, dynamic> item) {
    final Object? inner =
        item['pinTuanCampaign'] ?? item['campaign'] ?? item['pinTuanInfo'];
    return inner is Map<String, dynamic>
        ? <String, dynamic>{...item, ...inner}
        : item;
  }

  static GroupBuyInfo _parseCampaign(Map<String, dynamic> json) {
    final DateTime now = DateTime.now();
    final DateTime effectiveFrom =
        _timeOf(json['effectiveFrom'] ?? json['startTime']) ?? now;
    final DateTime effectiveTo =
        _timeOf(json['effectiveTo'] ?? json['endTime']) ??
        now.add(const Duration(days: 7));

    return GroupBuyInfo(
      id: _intOf(json['id'] ?? json['pinTuanId'] ?? json['campaignId']),
      showTitle: _stringOf(
        json['showTitle'] ?? json['title'] ?? json['showName'],
      ),
      showPoster: json['showPoster']?.toString(),
      venue: _stringOf(json['venue']),
      eventTime: _stringOf(json['eventTime'] ?? json['showTime']),
      lowPrice: _moneyOf(json['lowPrice'] ?? json['price']),
      originalPrice: _moneyOf(json['originalPrice'] ?? json['originPrice']),
      succeedNum: _intOf(json['succeedNum'] ?? json['targetNum']),
      currentMembers: _intOf(
        json['currentMembers'] ??
            json['memberCount'] ??
            (json['members'] is List ? (json['members'] as List).length : 0),
      ),
      effectiveFrom: effectiveFrom,
      effectiveTo: effectiveTo,
      status: _statusOf(json['status'] ?? json['orderStatus']),
      slogan: _stringOf(json['slogan']),
      tag: _stringOf(json['tag'] ?? json['pinTuanTag']),
      members: _membersOf(json['members']),
      stock: _intOf(json['stock']),
    );
  }

  static List<GroupBuyMember> _membersOf(Object? raw) {
    if (raw is! List) return const <GroupBuyMember>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (Map<String, dynamic> json) => GroupBuyMember(
            userId: _intOf(json['userId'] ?? json['id']),
            nickname: _stringOf(json['nickname'] ?? json['name']),
            avatarUrl: json['avatarUrl']?.toString(),
            isLeader: json['isLeader'] == true,
            joinedAt:
                _timeOf(json['joinedAt'] ?? json['createTime']) ??
                DateTime.fromMillisecondsSinceEpoch(0),
          ),
        )
        .toList(growable: false);
  }

  static GroupBuyStatus _statusOf(Object? raw) {
    if (raw is String) {
      switch (raw.toLowerCase()) {
        case 'grouping':
          return GroupBuyStatus.grouping;
        case 'success':
          return GroupBuyStatus.success;
        case 'failed':
          return GroupBuyStatus.failed;
        case 'cancelled':
        case 'canceled':
          return GroupBuyStatus.cancelled;
      }
    }
    return switch (_intOf(raw)) {
      2 => GroupBuyStatus.success,
      3 => GroupBuyStatus.failed,
      4 => GroupBuyStatus.cancelled,
      _ => GroupBuyStatus.grouping,
    };
  }

  static Money _moneyOf(Object? raw) {
    if (raw is num) return Money.fromYuan(raw);
    if (raw is String) return Money.tryParse(raw) ?? Money.zero();
    return Money.zero();
  }

  static DateTime? _timeOf(Object? raw) {
    if (raw is num) return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    return DateTime.tryParse(raw?.toString() ?? '');
  }

  static String _stringOf(Object? raw) => raw?.toString() ?? '';

  static int _intOf(Object? raw) {
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }
}
