import 'dart:convert';
import 'package:coworkhub_mobile/models/password_reset_request.dart';
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

  // Slanje koda za šifre
  Future<PasswordResetRequest> sendPasswordResetCode(String email) async {
    var url = Uri.parse("${BaseProvider.baseUrl}User/password-reset/send-code");
    http.Response response;
    try {
      response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Email": email}),
      );
    } catch (e) {
      throw Exception("Greška pri slanju zahtjeva: $e");
    }

    if (isValidResponse(response)) {
      try {
        final data = jsonDecode(response.body);
        return PasswordResetRequest.fromJson(data);
      } catch (e) {
        throw Exception("Nevažeći odgovor servera.");
      }
    } else {
      // try to extract error message from response body
      String message = "Greška pri slanju koda za reset lozinke.";
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson is Map) {
          if (errorJson["message"] != null) {
            message = errorJson["message"];
          } else if (errorJson["errors"] != null) {
            final errors = errorJson["errors"];
            if (errors is Map) {
              // Prefer explicit userError key when present
              if (errors["userError"] is List &&
                  errors["userError"].isNotEmpty) {
                message = errors["userError"][0];
              } else {
                final first = errors.values.first;
                if (first is List && first.isNotEmpty) message = first[0];
              }
            }
          }
        }
      } catch (_) {}

      throw Exception(message);
    }
  }

  // Verifikacija koda
  Future<bool> verifyResetCode(String email, String code) async {
    var url = Uri.parse(
      "${BaseProvider.baseUrl}User/password-reset/verify-code",
    );
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"Email": email, "Code": code}),
    );

    if (!isValidResponse(response)) {
      throw Exception("Greška pri provjeri koda.");
    }

    var data = jsonDecode(response.body);
    return data == true;
  }

  // Reset nove lozinke
  Future<void> resetPassword(
    String email,
    String newPassword,
    String newPasswordConfirm,
  ) async {
    var url = Uri.parse(
      "${BaseProvider.baseUrl}User/password-reset/new-password",
    );
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Email": email,
        "NewPassword": newPassword,
        "NewPasswordConfirm": newPasswordConfirm,
      }),
    );

    if (!isValidResponse(response)) {
      throw Exception("Greška pri resetovanju lozinke.");
    }
  }
}
