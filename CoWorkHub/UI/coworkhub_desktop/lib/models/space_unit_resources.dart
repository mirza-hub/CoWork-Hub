import 'package:json_annotation/json_annotation.dart';
import 'resource.dart';

part 'space_unit_resources.g.dart';

@JsonSerializable()
class SpaceUnitResources {
  int spaceResourcesId;
  int spaceUnitId;
  int resourcesId;
  Resource? resources;

  SpaceUnitResources({
    required this.spaceResourcesId,
    required this.spaceUnitId,
    required this.resourcesId,
    required this.resources,
  });

  factory SpaceUnitResources.fromJson(Map<String, dynamic> json) =>
      _$SpaceUnitResourcesFromJson(json);
  Map<String, dynamic> toJson() => _$SpaceUnitResourcesToJson(this);
}
