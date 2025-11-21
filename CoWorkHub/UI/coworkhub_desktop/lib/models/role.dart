import 'package:json_annotation/json_annotation.dart';

part 'role.g.dart';

@JsonSerializable()
class Role {
  int rolesId;
  String roleName;
  String? description;
  bool? isDeleted;

  Role({
    required this.rolesId,
    required this.roleName,
    this.description,
    this.isDeleted = false,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
