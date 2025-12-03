import 'package:json_annotation/json_annotation.dart';

part 'city.g.dart';

@JsonSerializable()
class City {
  int cityId;
  String cityName;
  String postalCode;
  double? latitude;
  double? longitude;

  City({
    required this.cityId,
    required this.cityName,
    required this.postalCode,
    this.latitude,
    this.longitude,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
  Map<String, dynamic> toJson() => _$CityToJson(this);
}
