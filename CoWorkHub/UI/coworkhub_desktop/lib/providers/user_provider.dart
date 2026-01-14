import 'dart:convert';
import 'package:coworkhub_desktop/models/user.dart';
import 'package:http/http.dart' as http;
import 'base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<User> login(String username, String password) async {
    var url =
        "${BaseProvider.baseUrl}User/login?username=$username&password=$password";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    if (username.isEmpty || password.isEmpty) {
      throw Exception("Molimo unesite korisničko ime i lozinku.");
    }

    var response = await http.post(uri, headers: headers);

    if (response.body.isEmpty) {
      throw Exception("Pogrešno korisničko ime ili lozinka.");
    }

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška prilikom login-a.");
    }
  }

  Future<User> updateForAdmin(int id, Map<String, dynamic> request) async {
    var url = "${BaseProvider.baseUrl}User/$id/update_for_admin";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = jsonEncode(request);

    var response = await http.put(uri, headers: headers, body: body);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška prilikom ažuriranja korisnika.");
    }
  }
}
