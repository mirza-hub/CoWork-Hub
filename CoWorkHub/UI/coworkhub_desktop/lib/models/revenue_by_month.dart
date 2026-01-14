import 'package:json_annotation/json_annotation.dart';
part 'revenue_by_month.g.dart';

@JsonSerializable()
class RevenueByMonth {
  String month;
  double revenue;

  RevenueByMonth({required this.month, required this.revenue});

  factory RevenueByMonth.fromJson(Map<String, dynamic> json) =>
      _$RevenueByMonthFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueByMonthToJson(this);
}
