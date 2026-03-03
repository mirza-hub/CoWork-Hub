import 'dart:convert';

import 'package:coworkhub_mobile/models/payment.dart';
import 'package:coworkhub_mobile/models/paypal_order.dart';
import 'package:coworkhub_mobile/models/paypal_order_request.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';
import 'package:coworkhub_mobile/exceptions/user_exception.dart';
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
      throw _handleError(response);
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
      throw _handleError(response);
    }
  }

  UserException _handleError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data['errors'] != null && data['errors'] is Map) {
        final errorsMap = data['errors'] as Map<String, dynamic>;

        if (errorsMap.isNotEmpty) {
          final firstKey = errorsMap.keys.first;
          final errorValue = errorsMap[firstKey];

          if (errorValue is List && errorValue.isNotEmpty) {
            return UserException(
              errorValue.first.toString(),
              statusCode: response.statusCode,
            );
          }
        }
      }

      if (data['message'] != null) {
        return UserException(
          data['message'].toString(),
          statusCode: response.statusCode,
        );
      }

      return UserException(
        "Greška sa servera (${response.statusCode})",
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is UserException) rethrow;
      return UserException(
        "Greška sa servera (${response.statusCode})",
        statusCode: response.statusCode,
      );
    }
  }
}
