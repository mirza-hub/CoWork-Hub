import 'package:coworkhub_desktop/models/user.dart';
import 'package:json_annotation/json_annotation.dart';
part 'activitylog.g.dart';

@JsonSerializable()
class ActivityLog {
  final int activityLogId;
  final int? userId;
  final String action;
  final String entity;
  final String? description;
  final DateTime createdAt;
  final User? user;

  ActivityLog({
    required this.activityLogId,
    this.userId,
    required this.action,
    required this.entity,
    this.description,
    required this.createdAt,
    this.user,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityLogToJson(this);
}
