/// 缓存键构造：**稳定序列化 + 强制 scope**。
library;

import 'dart:convert';

import 'package:dio/dio.dart';

/// 未登录场景可显式使用的 scope。
///
/// 它必须**显式传入**，不存在"没给 scope 就当作匿名"的默认行为——
/// 那正是缓存串号 bug 的成因。
const String anonymousScope = 'anon';

/// 构造缓存键。
///
/// 格式：`scope|METHOD|path|query|body`。
///
/// 两处**必须改**：
/// 1. **`scope` 前置且必填**。键若只有 `method + path + query + body`、
///    不含用户身份，企划星支持换账号登录时会让 A 用户的订单列表
///    被 B 用户命中。[scope] 传 userId（或 `anon`）。
/// 2. **`scope` 为空直接抛**。宁可让调用方在开发期炸掉，也不要在运行期
///    静默写出一个所有用户共享的键。
///
/// 键的稳定性靠序列化保证：[query] 与 [body] 走 [_stableEncode] 递归稳定序列化，
/// 嵌套 Map 按键排序、List 保序，解决"同 path 不同 body 撞同一个 key"。
///
/// `⚠` 不做哈希：明文键便于在 L2 里直接排查。若担心键过长或含敏感字段，
/// 由上层在传入 [body] 前自行脱敏。
String buildCacheKey({
  required String scope,
  required String method,
  required String path,
  Map<String, Object?>? query,
  Object? body,
}) {
  final trimmedScope = scope.trim();
  if (trimmedScope.isEmpty) {
    throw ArgumentError.value(
      scope,
      'scope',
      '缓存键必须带用户 scope，否则会串号（30-07）。未登录请显式传 anonymousScope',
    );
  }
  return <String>[
    trimmedScope,
    method.toUpperCase(),
    path,
    _stableEncode(query),
    _stableEncode(body),
  ].join('|');
}

/// 递归稳定序列化：同一份逻辑数据永远得到同一个字符串。
String _stableEncode(Object? value) {
  if (value == null) {
    return 'null';
  }
  if (value is String) {
    return _quote(value);
  }
  if (value is num || value is bool) {
    return '$value';
  }
  if (value is FormData) {
    return _encodeFormData(value);
  }
  if (value is Map<Object?, Object?>) {
    // 按键排序是"稳定"的核心：Map 的迭代顺序取决于插入顺序，
    // 而同一个请求的参数插入顺序可能因调用点不同而不同。
    final keys = value.keys.map((Object? k) => '$k').toList()..sort();
    final buffer = StringBuffer('{');
    for (var i = 0; i < keys.length; i++) {
      if (i > 0) {
        buffer.write(',');
      }
      final rawKey = value.keys.firstWhere((Object? k) => '$k' == keys[i]);
      buffer
        ..write(_quote(keys[i]))
        ..write(':')
        ..write(_stableEncode(value[rawKey]));
    }
    buffer.write('}');
    return buffer.toString();
  }
  if (value is Iterable<Object?>) {
    // List 保序：参数顺序不同的两个列表在 HTTP 语义上通常也不同。
    return '[${value.map(_stableEncode).join(',')}]';
  }
  return _quote(value.toString());
}

/// `FormData` 取字段与文件名：文件内容不参与键（太大且无意义）。
String _encodeFormData(FormData form) {
  final fields = <String, String>{
    for (final field in form.fields) field.key: field.value,
  };
  final files = form.files.map((MapEntry<String, MultipartFile> f) => f.value.filename ?? '').toList()
    ..sort();
  return 'form{${_stableEncode(fields)},files${_stableEncode(files)}}';
}

/// 给字符串加引号并转义，避免分隔符（`,` `:` `|`）造成的歧义碰撞。
String _quote(String raw) => '"${raw.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';

/// 把对象编码成 JSON 文本，供 [HttpCacheEntry] 持久化使用。
String encodeJsonBody(Object? data) => jsonEncode(data);
