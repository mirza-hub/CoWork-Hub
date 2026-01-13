// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_space_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkingSpaceImage _$WorkingSpaceImageFromJson(Map<String, dynamic> json) =>
    WorkingSpaceImage(
      imageId: (json['imageId'] as num?)?.toInt(),
      workingSpacesId: (json['workingSpacesId'] as num?)?.toInt(),
      imagePath: json['imagePath'] as String?,
      isDeleted: json['isDeleted'] as bool?,
    );

Map<String, dynamic> _$WorkingSpaceImageToJson(WorkingSpaceImage instance) =>
    <String, dynamic>{
      'imageId': instance.imageId,
      'workingSpacesId': instance.workingSpacesId,
      'imagePath': instance.imagePath,
      'isDeleted': instance.isDeleted,
    };
