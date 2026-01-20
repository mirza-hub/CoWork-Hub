import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/space_unit_image.dart';
import 'base_provider.dart';

class SpaceUnitImageProvider extends BaseProvider<SpaceUnitImage> {
  SpaceUnitImageProvider() : super("SpaceUnitImage");

  @override
  SpaceUnitImage fromJson(dynamic data) {
    return SpaceUnitImage.fromJson(data);
  }

  Future<List<SpaceUnitImage>> uploadBase64Images({
    required int spaceUnitId,
    required List<String> base64Images,
    String? description,
  }) async {
    if (base64Images.isEmpty) {
      throw Exception("Nema slika za upload");
    }

    var url = "${BaseProvider.baseUrl!}SpaceUnitImage/uploadBase64";

    var body = jsonEncode({
      "spaceUnitId": spaceUnitId,
      "base64Images": base64Images,
      "description": description ?? "",
    });

    var response = await http.post(
      Uri.parse(url),
      headers: createHeaders(),
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      var data = jsonDecode(response.body) as List;
      return data.map((e) => SpaceUnitImage.fromJson(e)).toList();
    } else {
      try {
        var errorData = jsonDecode(response.body);
        if (errorData is Map && errorData["message"] != null) {
          throw Exception(errorData["message"]);
        }
      } catch (_) {}

      throw Exception("Upload failed (${response.statusCode})");
    }
  }
}
