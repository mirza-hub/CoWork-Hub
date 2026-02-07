// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    PaymentMethod(
      paymentMethodId: (json['paymentMethodId'] as num).toInt(),
      paymentMethodName: json['paymentMethodName'] as String,
      isDeleted: json['isDeleted'] as bool,
    );

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'paymentMethodId': instance.paymentMethodId,
      'paymentMethodName': instance.paymentMethodName,
      'isDeleted': instance.isDeleted,
    };
