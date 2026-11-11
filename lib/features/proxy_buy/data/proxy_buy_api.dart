import 'package:core/domain.dart';
import 'package:core/network.dart';
import 'package:core/result.dart';

import '../../../app/network/api_paths.dart';
import '../domain/proxy_buy.dart';
import '../domain/services/proxy_buy_pricing.dart';

/// 代抢 API 适配。
///
/// | 用途 | 方法 | 路径 |
/// |---|---|---|
/// | 我的代抢订单 | GET | `v1/proxyBuyOrder/myOrders` |
///
/// 代抢规则没有独立端点（内嵌在企划详情里），提交接口后端未提供，
/// 由仓储层决定降级行为，不在这里造打不通的路径。
final class ProxyBuyApi {
  ProxyBuyApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  /// 我的代抢订单。
  Future<Result<List<ProxyBuyOrder>>> fetchOrders() {
    return _client.get<List<ProxyBuyOrder>>(
      ApiPaths.proxyBuyOrders,
      queryParameters: <String, dynamic>{'pageIndex': 1, 'pageSize': 50},
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final List<dynamic> raw = _unwrapList(data);
        return raw
            .whereType<Map<String, dynamic>>()
            .map(_parseOrder)
            .toList(growable: false);
      },
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

  static ProxyBuyOrder _parseOrder(Map<String, dynamic> json) {
    final Money ticketPrice = _moneyOf(
      json['ticketPrice'] ?? json['price'] ?? json['unitPrice'],
    );
    final Money fee = _moneyOf(json['proxyBuyFee'] ?? json['serviceFee']);
    final int quantity = _intOf(json['quantity'] ?? json['count'] ?? 1);
    final Money total = json['totalAmount'] != null
        ? _moneyOf(json['totalAmount'])
        : ProxyBuyPricing.flat(fee).total(
            ticketPrice: ticketPrice,
            quantity: quantity > 0 ? quantity : 1,
          );

    return ProxyBuyOrder(
      id: _intOf(json['id'] ?? json['orderId']),
      showTitle: _stringOf(
        json['showTitle'] ?? json['title'] ?? json['showName'],
      ),
      showPoster: json['showPoster']?.toString(),
      venue: _stringOf(json['venue']),
      eventTime: _stringOf(json['eventTime'] ?? json['showTime']),
      turn: _turnOf(json['turn'] ?? json['proxyBuyTurnInfo']),
      deadline: _deadlineOf(json['deadline'] ?? json['proxyBuyTimeInfo']),
      ticketPrice: ticketPrice,
      quantity: quantity > 0 ? quantity : 1,
      proxyBuyFee: fee,
      totalAmount: total,
      status: _statusOf(json['status'] ?? json['orderStatus']),
      createdAt:
          _timeOf(json['createdAt'] ?? json['createTime']) ?? DateTime.now(),
      compensationEnabled: json['compensationEnabled'] == true,
    );
  }

  static ProxyBuyTurn _turnOf(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return ProxyBuyTurn(
        title: _stringOf(raw['title']),
        timeStr: _stringOf(raw['timeStr'] ?? raw['time']),
      );
    }
    return const ProxyBuyTurn(title: '第一场', timeStr: '');
  }

  static ProxyBuyDeadline _deadlineOf(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return ProxyBuyDeadline(
        endValue: _intOf(raw['endValue']),
        desc: _stringOf(raw['endValueDesc'] ?? raw['desc']),
      );
    }
    return const ProxyBuyDeadline(endValue: 1, desc: '开抢即抢');
  }

  static ProxyBuyStatus _statusOf(Object? raw) {
    if (raw is String) {
      switch (raw.toLowerCase()) {
        case 'pending':
          return ProxyBuyStatus.pending;
        case 'inprogress':
        case 'in_progress':
          return ProxyBuyStatus.inProgress;
        case 'success':
          return ProxyBuyStatus.success;
        case 'failed':
          return ProxyBuyStatus.failed;
        case 'cancelled':
        case 'canceled':
          return ProxyBuyStatus.cancelled;
      }
    }
    return switch (_intOf(raw)) {
      2 => ProxyBuyStatus.inProgress,
      3 => ProxyBuyStatus.success,
      4 => ProxyBuyStatus.failed,
      5 => ProxyBuyStatus.cancelled,
      _ => ProxyBuyStatus.pending,
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
