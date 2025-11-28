// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRole _$UserRoleFromJson(Map<String, dynamic> json) => UserRole(
  userRoleId: (json['userRoleId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  roleId: (json['roleId'] as num).toInt(),
  modifiedAt: json['modifiedAt'] == null
      ? null
      : DateTime.parse(json['modifiedAt'] as String),
  role: Role.fromJson(json['role'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserRoleToJson(UserRole instance) => <String, dynamic>{
  'userRoleId': instance.userRoleId,
  'userId': instance.userId,
  'roleId': instance.roleId,
  'modifiedAt': instance.modifiedAt?.toIso8601String(),
  'role': instance.role,
};
