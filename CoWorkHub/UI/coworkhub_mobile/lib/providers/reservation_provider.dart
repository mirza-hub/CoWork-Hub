import 'dart:convert';

import 'package:coworkhub_mobile/models/reservation.dart';
import 'package:http/http.dart' as http;
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
      throw Exception('Greška prilikom kreiranja rezervacije');
    }
  }

  Future<Reservation> cancel(int id) async {
    final url = "${BaseProvider.baseUrl}Reservation/$id/cancel";
    final response = await http.put(Uri.parse(url), headers: createHeaders());

    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    }

    final body = jsonDecode(response.body);

    if (body is Map && body['errors'] != null) {
      final errors = body['errors'] as Map<String, dynamic>;
      if (errors['userError'] != null && errors['userError'] is List) {
        throw (errors['userError'][0]);
      }
    }

    throw Exception("Greška sa servera (${response.statusCode})");
  }

  Future<Reservation> complete(int id) async {
    final response = await http.put(
      Uri.parse('${BaseProvider.baseUrl}/$id/complete'),
      headers: createHeaders(),
    );

    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          if (errors['userError'] != null && errors['userError'] is List) {
            throw errors['userError'][0].toString();
          }
        }
      } catch (_) {
        throw "Kompletiranje nije moguće";
      }

      throw "Greška sa servera: ${response.statusCode}";
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
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          if (errors['userError'] != null && errors['userError'] is List) {
            throw errors['userError'][0].toString();
          }
        }
      } catch (_) {
        throw "Potvrda nije moguća";
      }

      throw "Greška sa servera: ${response.statusCode}";
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
      throw Exception('Greška prilikom dohvaćanja dozvoljenih akcija');
    }
  }

  Future<bool> hasReviewed(int reservationId) async {
    final url =
        "${BaseProvider.baseUrl}Reservation/$reservationId/has-reviewed";

    final response = await http.get(Uri.parse(url), headers: createHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    }

    throw Exception('Ne mogu provjeriti recenziju');
  }
}
