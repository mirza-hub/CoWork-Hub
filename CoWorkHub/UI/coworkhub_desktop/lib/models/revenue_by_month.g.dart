// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_by_month.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevenueByMonth _$RevenueByMonthFromJson(Map<String, dynamic> json) =>
    RevenueByMonth(
      month: json['month'] as String,
      revenue: (json['revenue'] as num).toDouble(),
    );

Map<String, dynamic> _$RevenueByMonthToJson(RevenueByMonth instance) =>
    <String, dynamic>{'month': instance.month, 'revenue': instance.revenue};
