import 'package:json_annotation/json_annotation.dart';

part 'password_reset_request.g.dart';

@JsonSerializable()
class PasswordResetRequest {
  int userId;
  String code;
  DateTime createdAt;

  PasswordResetRequest({
    required this.userId,
    required this.code,
    required this.createdAt,
  });

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordResetRequestToJson(this);
}
