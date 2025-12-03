import 'package:json_annotation/json_annotation.dart';

part 'space_unit_image.g.dart';

@JsonSerializable()
class SpaceUnitImage {
  int imageId;
  int spaceUnitId;
  String imagePath;
  bool isDeleted;

  SpaceUnitImage({
    required this.imageId,
    required this.spaceUnitId,
    required this.imagePath,
    this.isDeleted = false,
  });

  factory SpaceUnitImage.fromJson(Map<String, dynamic> json) =>
      _$SpaceUnitImageFromJson(json);

  Map<String, dynamic> toJson() => _$SpaceUnitImageToJson(this);
}
