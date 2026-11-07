// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubCategoryTag _$SubCategoryTagFromJson(Map<String, dynamic> json) =>
    _SubCategoryTag(
      id: (_readSubCategoryId(json, 'id') as num).toInt(),
      categoryId: (_readCategoryId(json, 'categoryId') as num).toInt(),
      name: _readName(json, 'name') as String,
    );

Map<String, dynamic> _$SubCategoryTagToJson(_SubCategoryTag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'name': instance.name,
    };

_ShowCategory _$ShowCategoryFromJson(Map<String, dynamic> json) =>
    _ShowCategory(
      id: (_readShowCategoryId(json, 'id') as num).toInt(),
      name: _readShowCategoryName(json, 'name') as String,
      enName: _readShowCategoryEnName(json, 'enName') as String,
      pinyin: _readShowCategoryPinyin(json, 'pinyin') as String,
      subTags: _subTagList(_readSubTags(json, 'subTags')),
      status: (_readShowCategoryStatus(json, 'status') as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$ShowCategoryToJson(_ShowCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'enName': instance.enName,
      'pinyin': instance.pinyin,
      'subTags': instance.subTags,
      'status': instance.status,
    };
