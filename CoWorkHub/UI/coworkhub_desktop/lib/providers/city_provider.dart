import 'package:coworkhub_desktop/models/city.dart';
import 'package:coworkhub_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(data) {
    return City.fromJson(data);
  }

  Future<City> restore(int id) async {
    var url = "${BaseProvider.baseUrl}City/$id/restore";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška prilikom vraćanja grada.");
    }
  }
}
