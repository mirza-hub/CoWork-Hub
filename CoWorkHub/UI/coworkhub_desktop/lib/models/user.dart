import 'package:json_annotation/json_annotation.dart';
import 'user_role.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  int usersId;
  String firstName;
  String lastName;
  String email;
  String username;
  String phoneNumber;
  String? profileImageUrl;
  int cityId;
  bool isActive;
  bool? isDeleted;
  DateTime createdAt;
  List<UserRole> userRoles;

  User({
    required this.usersId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.cityId,
    required this.isActive,
    this.isDeleted = false,
    required this.createdAt,
    required this.userRoles,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
