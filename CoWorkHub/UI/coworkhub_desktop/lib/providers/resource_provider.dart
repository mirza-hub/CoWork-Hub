import 'package:coworkhub_desktop/models/resource.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'base_provider.dart';

class ResourceProvider extends BaseProvider<Resource> {
  ResourceProvider() : super("Resources");

  @override
  Resource fromJson(data) {
    return Resource.fromJson(data);
  }

  Future<Resource> restore(int id) async {
    var url = "${BaseProvider.baseUrl}Resources/$id/restore";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška prilikom vraćanja resursa.");
    }
  }
}
