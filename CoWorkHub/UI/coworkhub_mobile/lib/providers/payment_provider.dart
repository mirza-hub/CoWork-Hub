import 'dart:convert';

import 'package:coworkhub_mobile/models/payment.dart';
import 'package:coworkhub_mobile/models/paypal_order.dart';
import 'package:coworkhub_mobile/models/paypal_order_request.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class PaymentProvider extends BaseProvider<Payment> {
  PaymentProvider() : super("Payment");

  @override
  Payment fromJson(data) {
    return Payment.fromJson(data);
  }

  Future<PaypalOrder> createPaypalOrder(double amount) async {
    var url = "${BaseProvider.baseUrl}Payment/create-paypal-order";
    var request = PaypalOrderRequest(amount: amount);
    var body = jsonEncode(request.toJson());

    final response = await http.post(
      Uri.parse(url),
      headers: createHeaders(),
      body: body,
    );

    if (response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return PaypalOrder.fromJson(json);
    } else {
      throw Exception("Error: ${response.statusCode} - ${response.body}");
    }
  }

  Future<void> capturePaypalOrder(String orderId) async {
    var url = "${BaseProvider.baseUrl}Payment/capture-paypal-order";

    final response = await http.post(
      Uri.parse(url),
      headers: createHeaders(),
      body: jsonEncode(orderId),
    );

    if (response.statusCode >= 300) {
      throw Exception("Neuspjesna potvrda PayPal ordera");
    }
  }
}
