import 'package:json_annotation/json_annotation.dart';

part 'dashboard_stats.g.dart';

@JsonSerializable()
class DashboardStats {
  final int totalReservations;
  final int activeReservations;
  final int cancelledReservations;
  final int totalUsers;
  final int totalWorkingSpaces;
  final double totalRevenue; // decimal sa backend-a mapiramo u double
  final Map<String, int>? reservationsByCity;
  final Map<String, int>? reservationsByWorkspaceType;

  DashboardStats({
    required this.totalReservations,
    required this.activeReservations,
    required this.cancelledReservations,
    required this.totalUsers,
    required this.totalWorkingSpaces,
    required this.totalRevenue,
    this.reservationsByCity,
    this.reservationsByWorkspaceType,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);
}
