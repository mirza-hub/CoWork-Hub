import 'package:coworkhub_desktop/models/reservation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int reviewsId;
  final int reservationId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  Reservation? reservation;

  Review({
    required this.reviewsId,
    required this.reservationId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.reservation,
  });

  int? get spaceUnitId => reservation?.spaceUnitId;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
