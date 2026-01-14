import 'dart:convert';
import 'package:coworkhub_mobile/models/recommendation.dart';
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
      throw Exception("Failed to load recommendations");
    }

    final data = jsonDecode(response.body);
    final List list = data['recommendations'];

    return list.map((e) => Recommendation.fromJson(e)).toList();
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
