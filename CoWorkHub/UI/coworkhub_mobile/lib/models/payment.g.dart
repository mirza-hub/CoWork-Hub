// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  paymentId: (json['paymentId'] as num).toInt(),
  reservationId: (json['reservationId'] as num).toInt(),
  paymentMethodId: (json['paymentMethodId'] as num).toInt(),
  paymentDate: DateTime.parse(json['paymentDate'] as String),
  discount: (json['discount'] as num?)?.toDouble(),
  totalPaymentAmount: (json['totalPaymentAmount'] as num).toDouble(),
  stateMachine: json['stateMachine'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'paymentId': instance.paymentId,
  'reservationId': instance.reservationId,
  'paymentMethodId': instance.paymentMethodId,
  'paymentDate': instance.paymentDate.toIso8601String(),
  'discount': instance.discount,
  'totalPaymentAmount': instance.totalPaymentAmount,
  'stateMachine': instance.stateMachine,
  'createdAt': instance.createdAt.toIso8601String(),
};
