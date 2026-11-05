/// 一条缓存记录。
library;

import 'dart:convert';

/// 缓存条目：**存原始 JSON 文本**，不存已解析的对象。
///
/// 为什么存文本而不是 `Map`：已解析对象在回放时可能被调用方原地修改，
/// 造成"第二次命中时数据已经变了"的隐蔽 bug。存文本、每次回放重新解析，
/// 语义上等价于"又发了一次请求"。
final class HttpCacheEntry {
  /// 创建条目。
  HttpCacheEntry({
    required this.body,
    required this.statusCode,
    required this.headers,
    required this.storedAt,
    required this.ttl,
  });

  /// 响应体（JSON 文本）。
  final String body;

  /// HTTP 状态码。
  final int statusCode;

  /// 响应头（只保留单值形式，够缓存回放用）。
  final Map<String, String> headers;

  /// 写入时间。
  final DateTime storedAt;

  /// 有效期。
  final Duration ttl;

  Object? _decoded;
  bool _decodedOnce = false;

  /// 过期时刻。
  DateTime get expiresAt => storedAt.add(ttl);

  /// 在 [now] 时刻是否已过期。
  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  /// 解析后的响应体。解析失败时原样返回文本（非 JSON 接口）。
  ///
  /// 结果会缓存，多次调用只解析一次。
  Object? get decodedBody {
    if (!_decodedOnce) {
      try {
        _decoded = jsonDecode(body);
      } on FormatException {
        _decoded = body;
      }
      _decodedOnce = true;
    }
    return _decoded;
  }

  /// 序列化为可持久化的 JSON。
  Map<String, Object?> toJson() => <String, Object?>{
        'body': body,
        'statusCode': statusCode,
        'headers': headers,
        'storedAt': storedAt.toUtc().toIso8601String(),
        'ttlMicros': ttl.inMicroseconds,
      };

  /// 从持久化 JSON 还原。字段缺失/类型不符时**抛 [FormatException]**，
  /// 由存储层捕获后当作"缓存损坏 = 未命中"，不要静默造一个空条目。
  factory HttpCacheEntry.fromJson(Map<String, Object?> json) {
    final body = json['body'];
    final statusCode = json['statusCode'];
    final storedAt = json['storedAt'];
    final ttlMicros = json['ttlMicros'];
    if (body is! String ||
        statusCode is! int ||
        storedAt is! String ||
        ttlMicros is! int) {
      throw const FormatException('缓存条目字段缺失或类型不符');
    }
    final parsedAt = DateTime.tryParse(storedAt);
    if (parsedAt == null) {
      throw FormatException('缓存条目 storedAt 非法：$storedAt');
    }
    final rawHeaders = json['headers'];
    final headers = <String, String>{};
    if (rawHeaders is Map<Object?, Object?>) {
      rawHeaders.forEach((Object? k, Object? v) {
        if (k != null && v != null) {
          headers['$k'] = '$v';
        }
      });
    }
    return HttpCacheEntry(
      body: body,
      statusCode: statusCode,
      headers: headers,
      storedAt: parsedAt,
      ttl: Duration(microseconds: ttlMicros),
    );
  }

  @override
  String toString() =>
      'HttpCacheEntry(status: $statusCode, ttl: $ttl, storedAt: $storedAt, '
      'bodyLength: ${body.length})';
}
