// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
  countryId: (json['countryId'] as num).toInt(),
  countryName: json['countryName'] as String,
  isDeleted: json['isDeleted'] as bool?,
);

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
  'countryId': instance.countryId,
  'countryName': instance.countryName,
  'isDeleted': instance.isDeleted,
};
