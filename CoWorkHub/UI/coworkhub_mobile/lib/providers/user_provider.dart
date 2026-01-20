import 'dart:convert';
import 'package:coworkhub_mobile/models/user.dart';
import 'package:http/http.dart' as http;
import 'base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<User> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw Exception("Molimo unesite korisničko ime i lozinku.");
    }

    var url =
        "${BaseProvider.baseUrl}User/login?username=$username&password=$password";
    var uri = Uri.parse(url);

    var response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    if (response.body.isEmpty || response.statusCode == 401) {
      throw Exception("Pogrešno korisničko ime ili lozinka.");
    }

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška prilikom login-a.");
    }
  }
}
