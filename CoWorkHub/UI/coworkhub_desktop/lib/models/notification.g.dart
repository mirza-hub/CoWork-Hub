// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  notificationId: (json['notificationId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  message: json['message'] as String,
  isRead: json['isRead'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
      'userId': instance.userId,
      'message': instance.message,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };
