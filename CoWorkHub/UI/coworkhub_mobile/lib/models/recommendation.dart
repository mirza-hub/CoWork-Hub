import 'package:json_annotation/json_annotation.dart';

part 'recommendation.g.dart';

@JsonSerializable()
class Recommendation {
  final int spaceUnitId;
  final double score;
  final String name;
  final double pricePerDay;

  Recommendation({
    required this.spaceUnitId,
    required this.score,
    required this.name,
    required this.pricePerDay,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      spaceUnitId: json['spaceUnitId'],
      score: (json['score'] as num).toDouble(),
      name: json['name'],
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
    );
  }
}
