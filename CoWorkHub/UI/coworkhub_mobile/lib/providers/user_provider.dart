import 'dart:convert';
import 'package:coworkhub_mobile/models/password_reset_request.dart';
import 'package:coworkhub_mobile/models/user.dart';
import 'package:coworkhub_mobile/exceptions/user_exception.dart';
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
      throw UserException("Molimo unesite korisničko ime i lozinku.");
    }

    var url =
        "${BaseProvider.baseUrl}User/login?username=$username&password=$password";
    var uri = Uri.parse(url);

    var response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    if (response.body.isEmpty || response.statusCode == 401) {
      throw UserException("Pogrešno korisničko ime ili lozinka.");
    }

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw _handleError(response);
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
      throw UserException("Greška pri slanju zahtjeva: $e");
    }

    if (isValidResponse(response)) {
      try {
        final data = jsonDecode(response.body);
        return PasswordResetRequest.fromJson(data);
      } catch (e) {
        throw UserException("Nevažeći odgovor servera.");
      }
    } else {
      throw _handleError(response);
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
      throw _handleError(response);
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
