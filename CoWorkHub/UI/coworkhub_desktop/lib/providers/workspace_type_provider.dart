import 'package:coworkhub_desktop/models/workspace_type.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_provider.dart';

class WorkspaceTypeProvider extends BaseProvider<WorkspaceType> {
  WorkspaceTypeProvider() : super("WorkspaceType");

  @override
  WorkspaceType fromJson(data) {
    return WorkspaceType.fromJson(data);
  }

  Future<WorkspaceType> restore(int id) async {
    var url = "${BaseProvider.baseUrl}WorkspaceType/$id/restore";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška prilikom vraćanja tipa prostora.");
    }
  }
}
