import 'package:json_annotation/json_annotation.dart';
part 'country.g.dart';

@JsonSerializable()
class Country {
  final int countryId;
  final String countryName;

  Country({required this.countryId, required this.countryName});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      countryId: json['countryId'],
      countryName: json['countryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'countryId': countryId, 'countryName': countryName};
  }
}
