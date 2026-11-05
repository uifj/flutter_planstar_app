/// 不可变配置对象。
library;

/// 只读配置视图。
///
/// 相对来源的刻意改动：来源的 `AppBuilder` 把异步读塞进**构造函数**
/// （30-12），于是同一个字段出现"先 JSON 值后本地值"两个真相。
/// 这里 [AppConfig] 是纯值对象——构造完就是最终值，不会自己再变。
final class AppConfig {
  /// 用原始键值创建。
  const AppConfig(this.values);

  /// 空配置。
  static const AppConfig empty = AppConfig(<String, Object?>{});

  /// 原始键值。
  final Map<String, Object?> values;

  /// 所有键。
  Iterable<String> get keys => values.keys;

  /// 是否含某键。
  bool has(String key) => values.containsKey(key);

  /// 原始值。
  Object? raw(String key) => values[key];

  /// 取字符串。
  String? getString(String key) {
    final value = values[key];
    return value is String ? value : null;
  }

  /// 取整数（兼容 JSON 里以 double 表示的整数）。
  int? getInt(String key) {
    final value = values[key];
    if (value is int) {
      return value;
    }
    if (value is double && value == value.roundToDouble()) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// 取浮点。
  double? getDouble(String key) {
    final value = values[key];
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// 取布尔。
  bool? getBool(String key) {
    final value = values[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value == 'true' ? true : (value == 'false' ? false : null);
    }
    return null;
  }

  /// 取子配置段。
  AppConfig section(String key) {
    final value = values[key];
    return value is Map<Object?, Object?>
        ? AppConfig(
            value.map(
              (Object? k, Object? v) => MapEntry<String, Object?>('$k', v),
            ),
          )
        : AppConfig.empty;
  }

  @override
  String toString() => 'AppConfig(keys: ${values.keys.toList()})';
}
