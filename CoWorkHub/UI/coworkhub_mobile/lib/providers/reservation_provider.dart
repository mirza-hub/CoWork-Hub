import 'dart:convert';

import 'package:coworkhub_mobile/models/reservation.dart';
import 'package:http/http.dart' as http;
import '../exceptions/user_exception.dart';
import 'base_provider.dart';

class ReservationProvider extends BaseProvider<Reservation> {
  ReservationProvider() : super("Reservation");

  @override
  Reservation fromJson(data) {
    return Reservation.fromJson(data);
  }

  Future<int> insert2(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$BaseProvider.baseUrl/reservations'),
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['reservationId'];
    } else {
      throw _handleError(response);
    }
  }

  Future<Reservation> cancel(int id) async {
    final url = "${BaseProvider.baseUrl}Reservation/$id/cancel";
    final response = await http.put(Uri.parse(url), headers: createHeaders());

    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    }

    throw _handleError(response);
  }

  Future<Reservation> complete(int id) async {
    final response = await http.put(
      Uri.parse('${BaseProvider.baseUrl}/$id/complete'),
      headers: createHeaders(),
    );

    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw _handleError(response);
    }
  }

  Future<Reservation> confirm(int id) async {
    final response = await http.put(
      Uri.parse('${BaseProvider.baseUrl}/$id/confirm'),
      headers: createHeaders(),
    );

    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw _handleError(response);
    }
  }

  Future<List<String>> allowedActions(int id) async {
    final response = await http.put(
      Uri.parse('${BaseProvider.baseUrl}/$id/allowedActions'),
      headers: createHeaders(),
    );

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => e.toString()).toList();
    } else {
      throw _handleError(response);
    }
  }

  Future<bool> hasReviewed(int reservationId) async {
    final url =
        "${BaseProvider.baseUrl}Reservation/$reservationId/has-reviewed";

    final response = await http.get(Uri.parse(url), headers: createHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    }

    throw _handleError(response);
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
