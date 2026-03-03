import 'dart:convert';
import 'package:coworkhub_mobile/models/recommendation.dart';
import 'package:coworkhub_mobile/exceptions/user_exception.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';
import 'base_provider.dart';

class RecommenderProvider {
  String get _baseUrl => "${BaseProvider.baseUrl}api/Recommender";

  Future<List<Recommendation>> getRecommendations() async {
    final bool isLoggedIn = AuthProvider.isSignedIn;

    final String url = isLoggedIn
        ? "$_baseUrl/recommended-for-user"
        : "$_baseUrl/recommended-for-guest";

    final response = await http.get(
      Uri.parse(url),
      headers: _createHeaders(isLoggedIn),
    );

    if (response.statusCode >= 300) {
      throw _handleError(response);
    }

    final data = jsonDecode(response.body);
    final List list = data['recommendations'];

    return list.map((e) => Recommendation.fromJson(e)).toList();
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

  Map<String, String> _createHeaders(bool isLoggedIn) {
    if (!isLoggedIn) {
      return {"Content-Type": "application/json"};
    }

    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    return {"Content-Type": "application/json", "Authorization": basicAuth};
  }
}
