// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) =>
    _LoginResponseDto(
      needCaptcha: json['needCaptcha'] == null
          ? false
          : _asBool(json['needCaptcha']),
      newUser: json['newUser'] == null ? false : _asBool(json['newUser']),
      user: _authUserOrNull(json['user']),
    );

Map<String, dynamic> _$LoginResponseDtoToJson(_LoginResponseDto instance) =>
    <String, dynamic>{
      'needCaptcha': instance.needCaptcha,
      'newUser': instance.newUser,
      'user': instance.user,
    };
