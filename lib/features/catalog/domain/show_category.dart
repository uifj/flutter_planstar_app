/// 分类目录的领域模型。
///
/// ## 数据来源
///
/// 演示数据已转成 `demo_categories.dart` 的编译期常量（本地 assets 已移除）。
/// 分类**不含图标**——表现层按 `categoryId` 映射 Lucide 图标，这里只做
/// "分类是什么"。
library;

/// 二级分类标签（`subCategoryTags[]`）。
final class SubCategoryTag {
  const SubCategoryTag({
    required this.id,
    required this.categoryId,
    required this.name,
  });

  final int id;
  final int categoryId;
  final String name;

  factory SubCategoryTag.fromJson(Map<String, dynamic> json) {
    return SubCategoryTag(
      id: (json['subCategoryId'] as num).toInt(),
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}

/// 一级分类。
final class ShowCategory {
  const ShowCategory({
    required this.id,
    required this.name,
    required this.enName,
    required this.pinyin,
    required this.subTags,
    this.status = 1,
  });

  final int id;
  final String name;
  final String enName;
  final String pinyin;
  final List<SubCategoryTag> subTags;

  /// `1` = 上架。企划星用它做软下架，客户端只渲染 `status == 1` 的分类。
  final int status;

  bool get isActive => status == 1;

  factory ShowCategory.fromJson(Map<String, dynamic> json) {
    final tags = (json['subCategoryTags'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(SubCategoryTag.fromJson)
        .toList(growable: false);
    return ShowCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      enName: json['enName'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 1,
      subTags: tags,
    );
  }
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

  /// 副标题：`浦东新区 · 12 场演出`。
  String get subtitle => '$address · $showCount 场演出';
}
