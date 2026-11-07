// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planstar_catalog_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RankingEntry _$RankingEntryFromJson(Map<String, dynamic> json) =>
    _RankingEntry(
      rank: (_readRank(json, 'rank') as num).toInt(),
      metricValue: (_readMetricValue(json, 'metricValue') as num).toInt(),
      show: ShowSummary.fromJson(
        _readProject(json, 'show') as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$RankingEntryToJson(_RankingEntry instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'metricValue': instance.metricValue,
      'show': instance.show,
    };

_BannerDto _$BannerDtoFromJson(Map<String, dynamic> json) => _BannerDto(
  id: _toStringOrEmpty(json['id']),
  title: _toStringOrEmpty(json['title']),
  image: _toStringOrEmpty(json['image']),
  url: _toStringOrNull(json['url']),
  showId: _toStringOrNull(json['showId']),
);

Map<String, dynamic> _$BannerDtoToJson(_BannerDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image': instance.image,
      'url': instance.url,
      'showId': instance.showId,
    };
