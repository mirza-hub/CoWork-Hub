import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'space_unit.dart';

part 'reservation.g.dart';

@JsonSerializable()
class Reservation {
  int reservationId;
  int spaceUnitId;
  int usersId;
  DateTime startDate;
  DateTime endDate;
  int peopleCount;
  double totalPrice;
  String stateMachine;
  bool isDeleted;
  User? users;
  SpaceUnit? spaceUnit;
  DateTime? createdAt;

  Reservation({
    required this.reservationId,
    required this.spaceUnitId,
    required this.usersId,
    required this.startDate,
    required this.endDate,
    this.peopleCount = 1,
    required this.totalPrice,
    required this.stateMachine,
    this.isDeleted = false,
    this.users,
    this.spaceUnit,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
  Map<String, dynamic> toJson() => _$ReservationToJson(this);
}
