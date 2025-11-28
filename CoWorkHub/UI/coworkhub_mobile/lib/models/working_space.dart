import 'package:json_annotation/json_annotation.dart';

part 'working_space.g.dart';

@JsonSerializable()
class WorkingSpace {
  int workingSpacesId;
  String name;
  int cityId;
  String description;
  String address;
  bool? isDeleted;

  WorkingSpace({
    required this.workingSpacesId,
    required this.name,
    required this.cityId,
    required this.description,
    required this.address,
    this.isDeleted,
  });

  factory WorkingSpace.fromJson(Map<String, dynamic> json) =>
      _$WorkingSpaceFromJson(json);

  Map<String, dynamic> toJson() => _$WorkingSpaceToJson(this);
}
