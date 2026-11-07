import 'package:core/domain.dart';
import 'package:core/network.dart';
import 'package:core/result.dart';

import '../../../app/network/api_paths.dart';

/// 支付单状态（契约：pending / success / failed / expired）。
enum PaymentStatus {
  pending,
  success,
  failed,
  expired;

  static PaymentStatus fromWire(String? raw) => switch (raw) {
    'success' => PaymentStatus.success,
    'failed' => PaymentStatus.failed,
    'expired' => PaymentStatus.expired,
    _ => PaymentStatus.pending,
  };

  bool get isTerminal => this != PaymentStatus.pending;
}

/// 服务端支付单（契约 8.12）。
final class PaymentOrder {
  const PaymentOrder({
    required this.payNo,
    required this.orderNumber,
    required this.amount,
    required this.channel,
    required this.status,
    required this.payParams,
    required this.expireAt,
    required this.paidAt,
    required this.thirdTradeNo,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      payNo: '${json['payNo'] ?? json['pay_no'] ?? ''}',
      orderNumber: '${json['orderNumber'] ?? json['order_number'] ?? ''}',
      amount: Money.fromMinorUnits(_asInt(json['amount']) ?? 0),
      channel: '${json['channel'] ?? json['payChannel'] ?? ''}',
      status: PaymentStatus.fromWire(
        json['status']?.toString(),
      ),
      payParams: _asMap(json['payParams'] ?? json['pay_params']),
      expireAt: _asTime(json['expireAt'] ?? json['expire_at']),
      paidAt: _asTime(json['paidAt'] ?? json['paid_at']),
      thirdTradeNo:
          '${json['thirdTradeNo'] ?? json['third_trade_no'] ?? ''}',
    );
  }

  final String payNo;
  final String orderNumber;
  final Money amount;
  final String channel;
  final PaymentStatus status;
  final Map<String, dynamic> payParams;
  final DateTime? expireAt;
  final DateTime? paidAt;
  final String thirdTradeNo;

  bool get isSuccess => status == PaymentStatus.success;
}

/// 支付接口客户端：创建支付单 + 查询支付状态。
final class PlanstarPayApi {
  const PlanstarPayApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  Future<Result<PaymentOrder>> createPayment({
    required String orderNumber,
    required String channel,
  }) {
    return _client.post<PaymentOrder>(
      ApiPaths.unifiedPay,
      data: <String, dynamic>{
        'orderNumber': orderNumber,
        'channel': channel,
      },
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => _parsePayment(data),
    );
  }

  Future<Result<PaymentOrder>> fetchPaymentDetail({
    String? payNo,
    String? orderNumber,
  }) {
    return _client.get<PaymentOrder>(
      ApiPaths.unifiedPayDetail,
      queryParameters: <String, dynamic>{
        if (payNo != null && payNo.isNotEmpty) 'payNo': payNo,
        if (orderNumber != null && orderNumber.isNotEmpty)
          'orderNumber': orderNumber,
      },
      envelope: const PassthroughEnvelope(),
      parser: (Object? data) => _parsePayment(data),
    );
  }

  static PaymentOrder _parsePayment(Object? data) {
    final Map<String, dynamic> json = _asMap(data);
    return PaymentOrder.fromJson(json);
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map<Object?, Object?>) {
    return value.map(
      (Object? key, Object? item) => MapEntry<String, dynamic>('$key', item),
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

DateTime? _asTime(Object? value) {
  final int? millis = _asInt(value);
  if (millis == null || millis <= 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(millis);
}
