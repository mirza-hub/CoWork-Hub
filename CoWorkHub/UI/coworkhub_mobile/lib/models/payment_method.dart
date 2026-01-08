import 'package:json_annotation/json_annotation.dart';

part 'payment_method.g.dart';

@JsonSerializable()
class PaymentMethod {
  final int paymentMethodId;
  final String paymentMethodName;
  final bool isDeleted;

  PaymentMethod({
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.isDeleted,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      paymentMethodId: json['paymentMethodId'],
      paymentMethodName: json['paymentMethodName'],
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
