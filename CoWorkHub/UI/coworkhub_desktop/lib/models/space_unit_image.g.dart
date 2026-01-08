// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_unit_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceUnitImage _$SpaceUnitImageFromJson(Map<String, dynamic> json) =>
    SpaceUnitImage(
      imageId: (json['imageId'] as num).toInt(),
      spaceUnitId: (json['spaceUnitId'] as num).toInt(),
      imagePath: json['imagePath'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$SpaceUnitImageToJson(SpaceUnitImage instance) =>
    <String, dynamic>{
      'imageId': instance.imageId,
      'spaceUnitId': instance.spaceUnitId,
      'imagePath': instance.imagePath,
      'isDeleted': instance.isDeleted,
    };
