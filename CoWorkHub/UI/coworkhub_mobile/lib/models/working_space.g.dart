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
  isDeleted: json['isDeleted'] as bool?,
);

Map<String, dynamic> _$WorkingSpaceToJson(WorkingSpace instance) =>
    <String, dynamic>{
      'workingSpacesId': instance.workingSpacesId,
      'name': instance.name,
      'cityId': instance.cityId,
      'description': instance.description,
      'address': instance.address,
      'isDeleted': instance.isDeleted,
    };
