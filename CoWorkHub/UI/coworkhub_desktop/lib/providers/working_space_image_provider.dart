import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/working_space_image.dart';
import 'base_provider.dart';

class WorkingSpaceImageProvider extends BaseProvider<WorkingSpaceImage> {
  WorkingSpaceImageProvider() : super("WorkingSpaceImage");

  @override
  WorkingSpaceImage fromJson(data) => WorkingSpaceImage.fromJson(data);

  Future<List<WorkingSpaceImage>> uploadBase64Images({
    required int workingSpaceId,
    required List<String> base64Images,
    String? description,
  }) async {
    if (base64Images.isEmpty) {
      throw Exception("Nema slika za upload");
    }

    var url = "${BaseProvider.baseUrl!}WorkingSpaceImage/uploadBase64";

    var body = jsonEncode({
      "workingSpacesId": workingSpaceId,
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
      return data.map((e) => WorkingSpaceImage.fromJson(e)).toList();
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
