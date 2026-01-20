// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_space.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkingSpace _$WorkingSpaceFromJson(Map<String, dynamic> json) => WorkingSpace(
  workingSpacesId: (json['workingSpacesId'] as num).toInt(),
  name: json['name'] as String,
  cityId: (json['cityId'] as num).toInt(),
  description: json['description'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  isDeleted: json['isDeleted'] as bool?,
  city: json['city'] == null
      ? null
      : City.fromJson(json['city'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WorkingSpaceToJson(WorkingSpace instance) =>
    <String, dynamic>{
      'workingSpacesId': instance.workingSpacesId,
      'name': instance.name,
      'cityId': instance.cityId,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isDeleted': instance.isDeleted,
      'city': instance.city,
    };
