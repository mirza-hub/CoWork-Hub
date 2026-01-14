// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  reviewsId: (json['reviewsId'] as num).toInt(),
  reservationId: (json['reservationId'] as num).toInt(),
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  reservation: json['reservation'] == null
      ? null
      : Reservation.fromJson(json['reservation'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'reviewsId': instance.reviewsId,
  'reservationId': instance.reservationId,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'reservation': instance.reservation,
};
