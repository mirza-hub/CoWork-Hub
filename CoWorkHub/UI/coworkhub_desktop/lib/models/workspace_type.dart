import 'package:json_annotation/json_annotation.dart';

part 'workspace_type.g.dart';

@JsonSerializable()
class WorkspaceType {
  int workspaceTypeId;
  String typeName;
  bool isDeleted;

  WorkspaceType({
    required this.workspaceTypeId,
    required this.typeName,
    this.isDeleted = false,
  });

  factory WorkspaceType.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceTypeFromJson(json);
  Map<String, dynamic> toJson() => _$WorkspaceTypeToJson(this);
}
