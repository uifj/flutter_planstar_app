// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShippingAddress _$ShippingAddressFromJson(Map<String, dynamic> json) =>
    _ShippingAddress(
      id: _readId(json, 'id') as String,
      name: _readName(json, 'name') as String,
      mobile: _readMobile(json, 'mobile') as String,
      region: _readRegion(json, 'region') as String,
      detail: _readDetail(json, 'detail') as String,
      isDefault: _readIsDefault(json, 'isDefault') as bool? ?? false,
    );

Map<String, dynamic> _$ShippingAddressToJson(_ShippingAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mobile': instance.mobile,
      'region': instance.region,
      'detail': instance.detail,
      'isDefault': instance.isDefault,
    };
