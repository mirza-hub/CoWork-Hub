import 'package:json_annotation/json_annotation.dart';
import 'workspace_type.dart';
import 'space_unit_resources.dart';
import 'working_space.dart';
import 'space_unit_image.dart';

part 'space_unit.g.dart';

@JsonSerializable(explicitToJson: true)
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
  List<SpaceUnitImage> spaceUnitImages;

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
    required this.spaceUnitImages,
  });

  factory SpaceUnit.fromJson(Map<String, dynamic> json) =>
      _$SpaceUnitFromJson(json);

  Map<String, dynamic> toJson() => _$SpaceUnitToJson(this);
}
