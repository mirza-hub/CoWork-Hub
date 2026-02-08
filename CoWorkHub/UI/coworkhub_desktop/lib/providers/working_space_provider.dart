import 'dart:convert';

import 'package:coworkhub_desktop/models/paged_result.dart';
import 'package:coworkhub_desktop/models/working_space.dart';
import 'package:coworkhub_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class WorkingSpaceProvider extends BaseProvider<WorkingSpace> {
  WorkingSpaceProvider() : super("WorkingSpace");

  @override
  WorkingSpace fromJson(data) {
    return WorkingSpace.fromJson(data);
  }

  Future<PagedResult<WorkingSpace>> getFiltered({
    String? nameFts,
    String? addressFts,
    int? cityId,
    bool? isDeleted,
    int page = 1,
    int pageSize = 10,
    String? orderBy,
    String? sortDirection,
  }) async {
    final filter = {
      if (nameFts != null && nameFts.isNotEmpty) 'nameFts': nameFts,
      if (addressFts != null && addressFts.isNotEmpty) 'addressFts': addressFts,
      if (cityId != null) 'cityId': cityId,
      if (isDeleted != null) 'isDeleted': isDeleted,
      'page': page,
      'pageSize': pageSize,
      if (orderBy != null) 'orderBy': orderBy,
      if (sortDirection != null) 'sortDirection': sortDirection,
    };

    final result = await get(filter: filter);
    return result;
  }

  Future<WorkingSpace> restore(int id) async {
    var url = "${BaseProvider.baseUrl}WorkingSpace/$id/restore";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška prilikom vraćanja radnog prostora.");
    }
  }
}
