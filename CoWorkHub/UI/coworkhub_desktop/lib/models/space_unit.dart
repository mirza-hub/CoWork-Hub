import 'package:json_annotation/json_annotation.dart';
import 'workspace_type.dart';
import 'space_unit_resources.dart';
import 'working_space.dart';

part 'space_unit.g.dart';

@JsonSerializable()
class SpaceUnit {
  int spaceUnitId;
  int workingSpaceId;
  String name;
  String description;
  int workspaceTypeId;
  int capacity;
  double pricePerDay;
  String stateMachine;
  bool isDeleted;
  WorkingSpace? workingSpace;
  List<SpaceUnitResources> spaceUnitResources;
  WorkspaceType? workspaceType;

  SpaceUnit({
    required this.spaceUnitId,
    required this.workingSpaceId,
    required this.name,
    required this.description,
    required this.workspaceTypeId,
    required this.capacity,
    required this.pricePerDay,
    required this.stateMachine,
    this.isDeleted = false,
    this.workingSpace,
    required this.spaceUnitResources,
    this.workspaceType,
  });

  factory SpaceUnit.fromJson(Map<String, dynamic> json) =>
      _$SpaceUnitFromJson(json);
  Map<String, dynamic> toJson() => _$SpaceUnitToJson(this);
}
