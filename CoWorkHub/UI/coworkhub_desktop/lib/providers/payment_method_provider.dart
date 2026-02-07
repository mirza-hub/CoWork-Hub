import 'dart:convert';

import 'package:coworkhub_desktop/models/payment_method.dart';
import 'package:coworkhub_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class PaymentMethodProvider extends BaseProvider<PaymentMethod> {
  PaymentMethodProvider() : super("PaymentMethod");

  @override
  PaymentMethod fromJson(data) {
    return PaymentMethod.fromJson(data);
  }

  Future<PaymentMethod> restore(int id) async {
    var url = "${BaseProvider.baseUrl}PaymentMethod/$id/restore";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška prilikom vraćanja metode plaćanja.");
    }
  }
}
