// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  usersId: (json['usersId'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  phoneNumber: json['phoneNumber'] as String,
  profileImageUrl: json['profileImageUrl'] as String?,
  cityId: (json['cityId'] as num).toInt(),
  isActive: json['isActive'] as bool,
  isDeleted: json['isDeleted'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  userRoles: (json['userRoles'] as List<dynamic>)
      .map((e) => UserRole.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'usersId': instance.usersId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'username': instance.username,
  'phoneNumber': instance.phoneNumber,
  'profileImageUrl': instance.profileImageUrl,
  'cityId': instance.cityId,
  'isActive': instance.isActive,
  'isDeleted': instance.isDeleted,
  'createdAt': instance.createdAt.toIso8601String(),
  'userRoles': instance.userRoles.map((e) => e.toJson()).toList(),
};
