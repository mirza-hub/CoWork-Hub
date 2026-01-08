import 'package:json_annotation/json_annotation.dart';

part 'working_space_image.g.dart';

@JsonSerializable()
class WorkingSpaceImage {
  int? imageId;
  int? workingSpacesId;
  String? imagePath;
  bool? isDeleted;

  WorkingSpaceImage({
    this.imageId,
    this.workingSpacesId,
    this.imagePath,
    this.isDeleted,
  });

  factory WorkingSpaceImage.fromJson(Map<String, dynamic> json) =>
      _$WorkingSpaceImageFromJson(json);

  Map<String, dynamic> toJson() => _$WorkingSpaceImageToJson(this);
}
