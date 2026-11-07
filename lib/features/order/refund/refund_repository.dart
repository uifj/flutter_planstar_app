import 'package:core/domain.dart';
import 'package:core/network.dart';
import 'package:core/result.dart';

import '../../../app/network/api_paths.dart';
import 'refund_state.dart';

/// 服务端退款单（契约 8.12）。
final class RefundOrder {
  const RefundOrder({
    required this.refundNo,
    required this.orderId,
    required this.refundableAmount,
    required this.status,
    required this.expectedArrivalDays,
  });

  factory RefundOrder.fromJson(Map<String, dynamic> json) {
    return RefundOrder(
      refundNo: '${json['refundNo'] ?? json['refund_no'] ?? ''}',
      orderId: '${json['orderId'] ?? json['order_id'] ?? ''}',
      refundableAmount: Money.fromMinorUnits(
        _asInt(json['refundableAmount'] ?? json['refundable_amount']) ?? 0,
      ),
      status: '${json['status'] ?? ''}',
      expectedArrivalDays:
          _asInt(json['expectedArrivalDays'] ?? json['expected_arrival_days']) ??
          0,
    );
  }

  final String refundNo;
  final String orderId;
  final Money refundableAmount;
  final String status;
  final int expectedArrivalDays;
}

/// 订单详情里可能下发的退款规则（契约当前未定义，缺失时为 null）。
final class RefundRuleInfo {
  const RefundRuleInfo({
    this.orderId,
    this.refundableAmount,
    this.ruleText,
    this.expectedArrivalDays,
    this.canRefund,
  });

  final String? orderId;
  final Money? refundableAmount;
  final String? ruleText;
  final int? expectedArrivalDays;
  final bool? canRefund;
}

/// 退款端口。
abstract interface class RefundRepository {
  /// 读取订单详情里的退款规则字段；字段缺失时对应值为 null。
  Future<Result<RefundRuleInfo>> loadRule(String orderNumber);

  /// 提交退款申请（服务端按 orderId 幂等）。
  Future<Result<RefundOrder>> submit({
    required String orderId,
    required RefundReason reason,
    String? reasonText,
  });

  /// 查询已提交的退款单。
  Future<Result<RefundOrder>> fetchRefund(String orderId);
}

/// 真实退款仓储：`GET/POST /v1/order/{id}/refund` + 订单详情规则字段。
final class RemoteRefundRepository implements RefundRepository {
  const RemoteRefundRepository({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<Result<RefundRuleInfo>> loadRule(String orderNumber) {
    return _client.get<RefundRuleInfo>(
      ApiPaths.orderDetail,
      queryParameters: <String, dynamic>{'orderNumber': orderNumber},
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) {
        final Map<String, dynamic> json = _asMap(data);
        return RefundRuleInfo(
          orderId: _asString(json['orderId'] ?? json['order_id']),
          refundableAmount: _asMoney(
            json['refundableAmount'] ?? json['refundable_amount'],
          ),
          ruleText: _asString(json['refundRule'] ?? json['refund_rule']),
          expectedArrivalDays: _asInt(
            json['expectedArrivalDays'] ?? json['expected_arrival_days'],
          ),
          canRefund: _asBool(json['canRefund'] ?? json['can_refund']),
        );
      },
    );
  }

  @override
  Future<Result<RefundOrder>> submit({
    required String orderId,
    required RefundReason reason,
    String? reasonText,
  }) {
    return _client.post<RefundOrder>(
      ApiPaths.orderRefund(orderId),
      data: <String, dynamic>{
        'reasonCode': reason.name,
        if (reasonText != null && reasonText.trim().isNotEmpty)
          'reasonText': reasonText.trim(),
      },
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => RefundOrder.fromJson(_asMap(data)),
    );
  }

  @override
  Future<Result<RefundOrder>> fetchRefund(String orderId) {
    return _client.get<RefundOrder>(
      ApiPaths.orderRefund(orderId),
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => RefundOrder.fromJson(_asMap(data)),
    );
  }

}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map<Object?, Object?>) {
    return value.map(
      (Object? key, Object? value) => MapEntry<String, dynamic>('$key', value),
    );
  }
  return const <String, dynamic>{};
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _asString(Object? value) {
  if (value == null) return null;
  final String text = value.toString();
  return text.isEmpty ? null : text;
}

bool? _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == 'true' || value == '1';
  return null;
}

Money? _asMoney(Object? value) {
  final int? cents = _asInt(value);
  if (cents == null) return null;
  return Money.fromMinorUnits(cents);
}
