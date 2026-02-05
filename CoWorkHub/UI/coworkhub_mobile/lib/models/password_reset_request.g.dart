// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordResetRequest _$PasswordResetRequestFromJson(
  Map<String, dynamic> json,
) => PasswordResetRequest(
  userId: (json['userId'] as num).toInt(),
  code: json['code'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PasswordResetRequestToJson(
  PasswordResetRequest instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'code': instance.code,
  'createdAt': instance.createdAt.toIso8601String(),
};
