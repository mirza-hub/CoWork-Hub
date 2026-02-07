import 'package:json_annotation/json_annotation.dart';
part 'country.g.dart';

@JsonSerializable()
class Country {
  final int countryId;
  final String countryName;
  final bool? isDeleted;

  Country({required this.countryId, required this.countryName, this.isDeleted});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      countryId: json['countryId'],
      countryName: json['countryName'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryId': countryId,
      'countryName': countryName,
      'isDeleted': isDeleted,
    };
  }
}
