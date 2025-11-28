import 'package:json_annotation/json_annotation.dart';
part 'city.g.dart';

@JsonSerializable()
class City {
  int cityId;
  String cityName;
  String postalCode;

  City({
    required this.cityId,
    required this.cityName,
    required this.postalCode,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
  Map<String, dynamic> toJson() => _$CityToJson(this);
}
