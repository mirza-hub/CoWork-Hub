// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_availability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayAvailability _$DayAvailabilityFromJson(Map<String, dynamic> json) =>
    DayAvailability(
      date: DateTime.parse(json['date'] as String),
      isAvailable: json['isAvailable'] as bool,
      capacity: (json['capacity'] as num).toInt(),
      reserved: (json['reserved'] as num).toInt(),
      free: (json['free'] as num).toInt(),
    );

Map<String, dynamic> _$DayAvailabilityToJson(DayAvailability instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'isAvailable': instance.isAvailable,
      'capacity': instance.capacity,
      'reserved': instance.reserved,
      'free': instance.free,
    };
