/// 分类目录的领域模型。
///
/// ## 数据来源
///
/// 演示数据已转成 `demo_categories.dart` 的编译期常量（本地 assets 已移除）。
/// 分类**不含图标**——表现层按 `categoryId` 映射 Lucide 图标，这里只做
/// "分类是什么"。
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'show_category.freezed.dart';
part 'show_category.g.dart';

/// 二级分类标签（`subCategoryTags[]`）。
@freezed
abstract class SubCategoryTag with _$SubCategoryTag {
  const factory SubCategoryTag({
    @JsonKey(readValue: _readSubCategoryId) required int id,
    @JsonKey(readValue: _readCategoryId) required int categoryId,
    @JsonKey(readValue: _readName) required String name,
  }) = _SubCategoryTag;

  factory SubCategoryTag.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryTagFromJson(json);
}

/// 一级分类。
@freezed
abstract class ShowCategory with _$ShowCategory {
  const ShowCategory._();

  const factory ShowCategory({
    @JsonKey(readValue: _readShowCategoryId) required int id,
    @JsonKey(readValue: _readShowCategoryName) required String name,
    @JsonKey(readValue: _readShowCategoryEnName) required String enName,
    @JsonKey(readValue: _readShowCategoryPinyin) required String pinyin,
    @JsonKey(readValue: _readSubTags, fromJson: _subTagList)
    required List<SubCategoryTag> subTags,
    @JsonKey(readValue: _readShowCategoryStatus) @Default(1) int status,
  }) = _ShowCategory;

  factory ShowCategory.fromJson(Map<String, dynamic> json) =>
      _$ShowCategoryFromJson(json);

  bool get isActive => status == 1;
}

/// 热门场馆（首页「热门场馆」楼层）。
///
/// 企划星这个楼层展示的是"场馆 + 该场馆近期 2 场演出"的复合卡片
/// （`item_home_venues.xml`：268×312，头部 72dp，下面两个 115dp 的小卡）。
final class VenueSummary {
  const VenueSummary({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.showCount,
    required this.showIds,
  });

  final String id;
  final String name;
  final String city;
  final String address;

  /// 近期场次数。
  final int showCount;

  /// 该场馆近期演出 id（最多取 2 个用于卡片）。
  final List<String> showIds;
}

// ── JSON 兼容读取 ───────────────────────────────────────────────────────

Object? _readSubCategoryId(Map<dynamic, dynamic> json, String key) =>
    (json['subCategoryId'] as num).toInt();

Object? _readCategoryId(Map<dynamic, dynamic> json, String key) =>
    (json['categoryId'] as num?)?.toInt() ?? 0;

Object? _readName(Map<dynamic, dynamic> json, String key) =>
    json['name'] as String? ?? '';

Object? _readShowCategoryId(Map<dynamic, dynamic> json, String key) =>
    (json['id'] as num).toInt();

Object? _readShowCategoryName(Map<dynamic, dynamic> json, String key) =>
    json['name'] as String? ?? '';

Object? _readShowCategoryEnName(Map<dynamic, dynamic> json, String key) =>
    json['enName'] as String? ?? '';

Object? _readShowCategoryPinyin(Map<dynamic, dynamic> json, String key) =>
    json['pinyin'] as String? ?? '';

Object? _readShowCategoryStatus(Map<dynamic, dynamic> json, String key) =>
    (json['status'] as num?)?.toInt() ?? 1;

Object? _readSubTags(Map<dynamic, dynamic> json, String key) =>
    json['subCategoryTags'];

List<SubCategoryTag> _subTagList(Object? raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(SubCategoryTag.fromJson)
        .toList(growable: false);
  }
  return const <SubCategoryTag>[];
}
