import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int paymentId;
  final int reservationId;
  final int paymentMethodId;
  final DateTime paymentDate;
  final double? discount;
  final double totalPaymentAmount;
  final String stateMachine;
  final DateTime createdAt;

  Payment({
    required this.paymentId,
    required this.reservationId,
    required this.paymentMethodId,
    required this.paymentDate,
    this.discount,
    required this.totalPaymentAmount,
    required this.stateMachine,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      reservationId: json['reservationId'],
      paymentMethodId: json['paymentMethodId'],
      paymentDate: DateTime.parse(json['paymentDate']),
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
      totalPaymentAmount: (json['totalPaymentAmount'] as num).toDouble(),
      stateMachine: json['stateMachine'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'reservationId': reservationId,
      'paymentMethodId': paymentMethodId,
      'paymentDate': paymentDate.toIso8601String(),
      'discount': discount,
      'totalPaymentAmount': totalPaymentAmount,
      'stateMachine': stateMachine,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
