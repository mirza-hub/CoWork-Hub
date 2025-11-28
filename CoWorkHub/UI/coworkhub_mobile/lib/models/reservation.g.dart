// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reservation _$ReservationFromJson(Map<String, dynamic> json) => Reservation(
  reservationId: (json['reservationId'] as num).toInt(),
  spaceUnitId: (json['spaceUnitId'] as num).toInt(),
  usersId: (json['usersId'] as num).toInt(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  peopleCount: (json['peopleCount'] as num?)?.toInt() ?? 1,
  totalPrice: (json['totalPrice'] as num).toDouble(),
  stateMachine: json['stateMachine'] as String,
  isDeleted: json['isDeleted'] as bool? ?? false,
  users: json['users'] == null
      ? null
      : User.fromJson(json['users'] as Map<String, dynamic>),
  spaceUnit: json['spaceUnit'] == null
      ? null
      : SpaceUnit.fromJson(json['spaceUnit'] as Map<String, dynamic>),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'reservationId': instance.reservationId,
      'spaceUnitId': instance.spaceUnitId,
      'usersId': instance.usersId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'peopleCount': instance.peopleCount,
      'totalPrice': instance.totalPrice,
      'stateMachine': instance.stateMachine,
      'isDeleted': instance.isDeleted,
      'users': instance.users,
      'spaceUnit': instance.spaceUnit,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
