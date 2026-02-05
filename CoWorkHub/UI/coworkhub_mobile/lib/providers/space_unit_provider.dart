import 'dart:convert';

import 'package:coworkhub_mobile/models/day_availability.dart';
import 'package:coworkhub_mobile/models/space_unit.dart';
import 'package:http/http.dart' as http;
import 'base_provider.dart';

class SpaceUnitProvider extends BaseProvider<SpaceUnit> {
  SpaceUnitProvider() : super("SpaceUnit");

  @override
  SpaceUnit fromJson(data) {
    return SpaceUnit.fromJson(data);
  }

  Future<List<DayAvailability>> getAvailability({
    required int spaceUnitId,
    required DateTime from,
    required DateTime to,
    required int peopleCount,
  }) async {
    var url = "${BaseProvider.baseUrl!}SpaceUnit/$spaceUnitId/availability";

    var body = jsonEncode({
      "from": from.toIso8601String(),
      "to": to.toIso8601String(),
      "peopleCount": peopleCount,
    });

    var response = await http.post(
      Uri.parse(url),
      headers: createHeaders(),
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      var data = jsonDecode(response.body) as List;
      return data.map((e) => DayAvailability.fromJson(e)).toList();
    } else {
      try {
        var errorData = jsonDecode(response.body);
        if (errorData is Map && errorData["message"] != null) {
          throw Exception(errorData["message"]);
        }
      } catch (_) {}

      throw Exception("Fetch availability failed (${response.statusCode})");
    }
  }
}
