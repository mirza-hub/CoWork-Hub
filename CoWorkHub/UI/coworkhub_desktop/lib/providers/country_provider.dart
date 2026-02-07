import 'dart:convert';

import 'package:coworkhub_desktop/models/country.dart';
import 'package:coworkhub_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class CountryProvider extends BaseProvider<Country> {
  CountryProvider() : super("Country");

  @override
  Country fromJson(data) {
    return Country.fromJson(data);
  }

  Future<Country> restore(int id) async {
    var url = "${BaseProvider.baseUrl}Country/$id/restore";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška prilikom vraćanja države.");
    }
  }
}
