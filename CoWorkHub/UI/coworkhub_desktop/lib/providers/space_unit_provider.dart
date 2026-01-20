import 'dart:convert';

import 'package:coworkhub_desktop/models/space_unit.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'base_provider.dart';

class SpaceUnitProvider extends BaseProvider<SpaceUnit> {
  SpaceUnitProvider() : super("SpaceUnit");

  @override
  SpaceUnit fromJson(data) {
    return SpaceUnit.fromJson(data);
  }

  Future<SpaceUnit> activate(int id) async {
    final response = await put(
      Uri.parse("${BaseProvider.baseUrl!}SpaceUnit/$id/activate"),
      headers: createHeaders(),
      body: jsonEncode(id),
    );
    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    }
    throw Exception("Activation failed");
  }

  Future<SpaceUnit> hide(int id) async {
    final response = await put(
      Uri.parse("${BaseProvider.baseUrl!}SpaceUnit/$id/hide"),
      headers: createHeaders(),
      body: jsonEncode(id),
    );
    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    }
    throw Exception("Hiding failed");
  }

  Future<SpaceUnit> edit(int id) async {
    final response = await put(
      Uri.parse("${BaseProvider.baseUrl!}SpaceUnit/$id/edit"),
      headers: createHeaders(),
      body: jsonEncode(id),
    );
    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    }
    throw Exception("Editing failed");
  }

  Future<SpaceUnit> setMaintenance(int id) async {
    final response = await put(
      Uri.parse("${BaseProvider.baseUrl!}SpaceUnit/$id/setMaintenance"),
      headers: createHeaders(),
      body: jsonEncode(id),
    );
    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    }
    throw Exception("Maintenance failed");
  }

  Future<SpaceUnit> restore(int id) async {
    final response = await put(
      Uri.parse("${BaseProvider.baseUrl!}SpaceUnit/$id/restore"),
      headers: createHeaders(),
      body: jsonEncode(id),
    );
    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    }
    throw Exception("Restoring failed");
  }

  Future<List<String>> allowedActions(int id) async {
    final response = await http.get(
      Uri.parse("${BaseProvider.baseUrl!}SpaceUnit/$id/allowedActions"),
      headers: createHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception("Failed to fetch allowed actions");
    }
  }
}
