import 'dart:convert';

import 'package:coworkhub_desktop/models/role.dart';
import 'package:coworkhub_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RoleProvider extends BaseProvider<Role> {
  RoleProvider() : super("Role");

  @override
  Role fromJson(data) {
    return Role.fromJson(data);
  }

  Future<Role> restore(int id) async {
    var url = "${BaseProvider.baseUrl}Role/$id/restore";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška prilikom vraćanja uloge.");
    }
  }
}
