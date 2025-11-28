import 'package:json_annotation/json_annotation.dart';
import 'role.dart';

part 'user_role.g.dart';

@JsonSerializable()
class UserRole {
  int userRoleId;
  int userId;
  int roleId;
  DateTime? modifiedAt;
  Role role;

  UserRole({
    required this.userRoleId,
    required this.userId,
    required this.roleId,
    this.modifiedAt,
    required this.role,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) =>
      _$UserRoleFromJson(json);
  Map<String, dynamic> toJson() => _$UserRoleToJson(this);
}
