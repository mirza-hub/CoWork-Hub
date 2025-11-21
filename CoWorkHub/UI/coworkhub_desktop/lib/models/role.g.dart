// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
  rolesId: (json['rolesId'] as num).toInt(),
  roleName: json['roleName'] as String,
  description: json['description'] as String?,
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'rolesId': instance.rolesId,
  'roleName': instance.roleName,
  'description': instance.description,
  'isDeleted': instance.isDeleted,
};
