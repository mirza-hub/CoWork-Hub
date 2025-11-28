import 'package:json_annotation/json_annotation.dart';

part 'resource.g.dart';

@JsonSerializable()
class Resource {
  int resourcesId;
  String resourceName;
  bool? isDeleted;

  Resource({
    required this.resourcesId,
    required this.resourceName,
    this.isDeleted = false,
  });

  factory Resource.fromJson(Map<String, dynamic> json) =>
      _$ResourceFromJson(json);
  Map<String, dynamic> toJson() => _$ResourceToJson(this);
}
