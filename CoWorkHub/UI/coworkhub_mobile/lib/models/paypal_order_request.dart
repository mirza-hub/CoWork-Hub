import 'package:json_annotation/json_annotation.dart';

part 'paypal_order_request.g.dart';

@JsonSerializable()
class PaypalOrderRequest {
  final double amount;

  PaypalOrderRequest({required this.amount});

  factory PaypalOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$PaypalOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaypalOrderRequestToJson(this);
}
