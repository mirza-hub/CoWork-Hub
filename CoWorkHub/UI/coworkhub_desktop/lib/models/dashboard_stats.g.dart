// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    DashboardStats(
      totalReservations: (json['totalReservations'] as num).toInt(),
      activeReservations: (json['activeReservations'] as num).toInt(),
      cancelledReservations: (json['cancelledReservations'] as num).toInt(),
      totalUsers: (json['totalUsers'] as num).toInt(),
      totalWorkingSpaces: (json['totalWorkingSpaces'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      reservationsByCity: (json['reservationsByCity'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toInt())),
      reservationsByWorkspaceType:
          (json['reservationsByWorkspaceType'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ),
    );

Map<String, dynamic> _$DashboardStatsToJson(DashboardStats instance) =>
    <String, dynamic>{
      'totalReservations': instance.totalReservations,
      'activeReservations': instance.activeReservations,
      'cancelledReservations': instance.cancelledReservations,
      'totalUsers': instance.totalUsers,
      'totalWorkingSpaces': instance.totalWorkingSpaces,
      'totalRevenue': instance.totalRevenue,
      'reservationsByCity': instance.reservationsByCity,
      'reservationsByWorkspaceType': instance.reservationsByWorkspaceType,
    };
