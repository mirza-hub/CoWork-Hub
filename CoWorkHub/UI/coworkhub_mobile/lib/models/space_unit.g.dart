// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceUnit _$SpaceUnitFromJson(Map<String, dynamic> json) => SpaceUnit(
  spaceUnitId: (json['spaceUnitId'] as num).toInt(),
  workingSpaceId: (json['workingSpaceId'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  workspaceTypeId: (json['workspaceTypeId'] as num).toInt(),
  capacity: (json['capacity'] as num).toInt(),
  pricePerDay: (json['pricePerDay'] as num).toDouble(),
  stateMachine: json['stateMachine'] as String,
  isDeleted: json['isDeleted'] as bool? ?? false,
  workingSpace: json['workingSpace'] == null
      ? null
      : WorkingSpace.fromJson(json['workingSpace'] as Map<String, dynamic>),
  spaceUnitResources: (json['spaceUnitResources'] as List<dynamic>)
      .map((e) => SpaceUnitResources.fromJson(e as Map<String, dynamic>))
      .toList(),
  workspaceType: json['workspaceType'] == null
      ? null
      : WorkspaceType.fromJson(json['workspaceType'] as Map<String, dynamic>),
  spaceUnitImages: (json['spaceUnitImages'] as List<dynamic>)
      .map((e) => SpaceUnitImage.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SpaceUnitToJson(SpaceUnit instance) => <String, dynamic>{
  'spaceUnitId': instance.spaceUnitId,
  'workingSpaceId': instance.workingSpaceId,
  'name': instance.name,
  'description': instance.description,
  'workspaceTypeId': instance.workspaceTypeId,
  'capacity': instance.capacity,
  'pricePerDay': instance.pricePerDay,
  'stateMachine': instance.stateMachine,
  'isDeleted': instance.isDeleted,
  'workingSpace': instance.workingSpace?.toJson(),
  'spaceUnitResources': instance.spaceUnitResources
      .map((e) => e.toJson())
      .toList(),
  'workspaceType': instance.workspaceType?.toJson(),
  'spaceUnitImages': instance.spaceUnitImages.map((e) => e.toJson()).toList(),
};
