// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkspaceType _$WorkspaceTypeFromJson(Map<String, dynamic> json) =>
    WorkspaceType(
      workspaceTypeId: (json['workspaceTypeId'] as num).toInt(),
      typeName: json['typeName'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkspaceTypeToJson(WorkspaceType instance) =>
    <String, dynamic>{
      'workspaceTypeId': instance.workspaceTypeId,
      'typeName': instance.typeName,
      'isDeleted': instance.isDeleted,
    };
