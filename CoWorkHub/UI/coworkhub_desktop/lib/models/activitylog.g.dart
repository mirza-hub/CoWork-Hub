// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activitylog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityLog _$ActivityLogFromJson(Map<String, dynamic> json) => ActivityLog(
  activityLogId: (json['activityLogId'] as num).toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  action: json['action'] as String,
  entity: json['entity'] as String,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ActivityLogToJson(ActivityLog instance) =>
    <String, dynamic>{
      'activityLogId': instance.activityLogId,
      'userId': instance.userId,
      'action': instance.action,
      'entity': instance.entity,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'user': instance.user,
    };
