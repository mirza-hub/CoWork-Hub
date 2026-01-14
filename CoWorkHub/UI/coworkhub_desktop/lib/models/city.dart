import 'package:coworkhub_desktop/models/country.dart';
import 'package:json_annotation/json_annotation.dart';
part 'city.g.dart';

@JsonSerializable()
class City {
  final int cityId;
  final String cityName;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final int countryId;
  final Country country;

  City({
    required this.cityId,
    required this.cityName,
    required this.postalCode,
    this.latitude,
    this.longitude,
    required this.countryId,
    required this.country,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      cityId: json['cityId'],
      cityName: json['cityName'],
      postalCode: json['postalCode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      countryId: json['countryId'],
      country: json['country'] != null
          ? Country.fromJson(json['country'])
          : Country(countryId: json['countryId'] ?? 0, countryName: ""),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityId': cityId,
      'cityName': cityName,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'countryId': countryId,
      'country': country.toJson(),
    };
  }
}
