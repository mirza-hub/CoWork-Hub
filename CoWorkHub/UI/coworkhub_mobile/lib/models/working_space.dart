import 'package:json_annotation/json_annotation.dart';
import 'package:coworkhub_mobile/models/city.dart';

part 'working_space.g.dart';

@JsonSerializable()
class WorkingSpace {
  int workingSpacesId;
  String name;
  int cityId;
  String description;
  String address;
  double latitude;
  double longitude;
  bool? isDeleted;
  City? city;

  WorkingSpace({
    required this.workingSpacesId,
    required this.name,
    required this.cityId,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isDeleted,
    this.city,
  });

  factory WorkingSpace.fromJson(Map<String, dynamic> json) =>
      _$WorkingSpaceFromJson(json);

  Map<String, dynamic> toJson() => _$WorkingSpaceToJson(this);
}
