// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Resource _$ResourceFromJson(Map<String, dynamic> json) => Resource(
  resourcesId: (json['resourcesId'] as num).toInt(),
  resourceName: json['resourceName'] as String,
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$ResourceToJson(Resource instance) => <String, dynamic>{
  'resourcesId': instance.resourcesId,
  'resourceName': instance.resourceName,
  'isDeleted': instance.isDeleted,
};
