/// JSON 形状校验的小工具。
///
/// 企划星的响应是"裸模型"，`dart:convert` 解出来是 `Map<String, dynamic>`，
/// 但 `strict-casts` 下不能直接当 `Map<String, Object?>` 用。这里做一次
/// **显式**转换：不是对象就抛 [FormatException]，由 `ApiClient` 收敛成
/// `PARSE_ERROR` 失败——而不是静默得到一个空对象。
library;

/// 把任意 JSON 对象转成 `Map<String, Object?>`。
///
/// [what] 只用于报错信息（`'登录响应'`）。
Map<String, Object?> asStringKeyedMap(Object? data, {required String what}) {
  if (data is! Map<Object?, Object?>) {
    throw FormatException('$what不是 JSON 对象：$data');
  }
  final result = <String, Object?>{};
  data.forEach((Object? key, Object? value) {
    result['$key'] = value;
  });
  return result;
}
