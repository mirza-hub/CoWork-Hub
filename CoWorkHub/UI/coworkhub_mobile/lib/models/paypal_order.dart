import 'package:json_annotation/json_annotation.dart';

part 'paypal_order.g.dart';

@JsonSerializable()
class PaypalOrder {
  final String id;
  final String status;
  final List<PaypalLink> links;

  PaypalOrder({required this.id, required this.status, required this.links});

  String? get approvalUrl {
    try {
      return links.firstWhere((link) => link.rel == "approve").href;
    } catch (e) {
      return null;
    }
  }

  factory PaypalOrder.fromJson(Map<String, dynamic> json) =>
      _$PaypalOrderFromJson(json);

  Map<String, dynamic> toJson() => _$PaypalOrderToJson(this);
}

@JsonSerializable()
class PaypalLink {
  final String rel;
  final String href;

  PaypalLink({required this.rel, required this.href});

  factory PaypalLink.fromJson(Map<String, dynamic> json) =>
      _$PaypalLinkFromJson(json);

  Map<String, dynamic> toJson() => _$PaypalLinkToJson(this);
}
