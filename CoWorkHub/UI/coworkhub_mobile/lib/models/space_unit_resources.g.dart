// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_unit_resources.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceUnitResources _$SpaceUnitResourcesFromJson(Map<String, dynamic> json) =>
    SpaceUnitResources(
      spaceResourcesId: (json['spaceResourcesId'] as num).toInt(),
      spaceUnitId: (json['spaceUnitId'] as num).toInt(),
      resourcesId: (json['resourcesId'] as num).toInt(),
      resources: Resource.fromJson(json['resources'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SpaceUnitResourcesToJson(SpaceUnitResources instance) =>
    <String, dynamic>{
      'spaceResourcesId': instance.spaceResourcesId,
      'spaceUnitId': instance.spaceUnitId,
      'resourcesId': instance.resourcesId,
      'resources': instance.resources,
    };
