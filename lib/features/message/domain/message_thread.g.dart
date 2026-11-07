// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageThread _$MessageThreadFromJson(Map<String, dynamic> json) =>
    _MessageThread(
      id: _readId(json, 'id') as String,
      title: _readTitle(json, 'title') as String,
      preview: _readPreview(json, 'preview') as String,
      updatedAt: _dateTimeOrNow(_readUpdatedAt(json, 'updatedAt')),
      unreadCount:
          (_readUnreadCount(json, 'unreadCount') as num?)?.toInt() ?? 0,
      avatarFallbackUrl: _readAvatar(json, 'avatarFallbackUrl') as String?,
      isOfficial: _readIsOfficial(json, 'isOfficial') as bool? ?? false,
    );

Map<String, dynamic> _$MessageThreadToJson(_MessageThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'preview': instance.preview,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'avatarFallbackUrl': instance.avatarFallbackUrl,
      'isOfficial': instance.isOfficial,
    };
