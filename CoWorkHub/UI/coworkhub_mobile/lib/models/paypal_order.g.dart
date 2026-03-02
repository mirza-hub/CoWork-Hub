// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paypal_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaypalOrder _$PaypalOrderFromJson(Map<String, dynamic> json) => PaypalOrder(
  id: json['id'] as String,
  status: json['status'] as String,
  links: (json['links'] as List<dynamic>)
      .map((e) => PaypalLink.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaypalOrderToJson(PaypalOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'links': instance.links,
    };

PaypalLink _$PaypalLinkFromJson(Map<String, dynamic> json) =>
    PaypalLink(rel: json['rel'] as String, href: json['href'] as String);

Map<String, dynamic> _$PaypalLinkToJson(PaypalLink instance) =>
    <String, dynamic>{'rel': instance.rel, 'href': instance.href};
