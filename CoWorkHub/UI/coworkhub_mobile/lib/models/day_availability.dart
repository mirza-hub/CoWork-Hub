import 'package:json_annotation/json_annotation.dart';

part 'day_availability.g.dart';

@JsonSerializable()
class DayAvailability {
  DateTime date;
  bool isAvailable;
  int capacity;
  int reserved;
  int free;

  DayAvailability({
    required this.date,
    required this.isAvailable,
    required this.capacity,
    required this.reserved,
    required this.free,
  });

  factory DayAvailability.fromJson(Map<String, dynamic> json) =>
      _$DayAvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$DayAvailabilityToJson(this);
}
