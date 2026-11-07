// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_code_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SendCodeResponseDto _$SendCodeResponseDtoFromJson(Map<String, dynamic> json) =>
    _SendCodeResponseDto(
      success: _asBool(json['success']),
      needCaptcha: json['needCaptcha'] == null
          ? false
          : _asBool(json['needCaptcha']),
      errorMsg: _nonEmptyStringOrNull(json['errorMsg']),
    );

Map<String, dynamic> _$SendCodeResponseDtoToJson(
  _SendCodeResponseDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'needCaptcha': instance.needCaptcha,
  'errorMsg': instance.errorMsg,
};
