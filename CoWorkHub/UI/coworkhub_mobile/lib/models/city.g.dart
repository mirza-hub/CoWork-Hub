// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

City _$CityFromJson(Map<String, dynamic> json) => City(
  cityId: (json['cityId'] as num).toInt(),
  cityName: json['cityName'] as String,
  postalCode: json['postalCode'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
  'cityId': instance.cityId,
  'cityName': instance.cityName,
  'postalCode': instance.postalCode,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
