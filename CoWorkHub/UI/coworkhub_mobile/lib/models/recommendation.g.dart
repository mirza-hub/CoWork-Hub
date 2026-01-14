// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    Recommendation(
      spaceUnitId: (json['spaceUnitId'] as num).toInt(),
      score: (json['score'] as num).toDouble(),
      name: json['name'] as String,
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
    );

Map<String, dynamic> _$RecommendationToJson(Recommendation instance) =>
    <String, dynamic>{
      'spaceUnitId': instance.spaceUnitId,
      'score': instance.score,
      'name': instance.name,
      'pricePerDay': instance.pricePerDay,
    };
