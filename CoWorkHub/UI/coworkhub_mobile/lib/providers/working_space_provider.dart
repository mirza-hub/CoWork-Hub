import 'package:coworkhub_mobile/models/paged_result.dart';
import 'package:coworkhub_mobile/models/working_space.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';

class WorkingSpaceProvider extends BaseProvider<WorkingSpace> {
  WorkingSpaceProvider() : super("WorkingSpace");

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

    final result = await get(
      filter: filter,
      // fromJsonT: (Object? json) {
      //   return WorkingSpace.fromJson(json as Map<String, dynamic>);
      // },
    );
    return result;
  }

  @override
  WorkingSpace fromJson(data) {
    return WorkingSpace.fromJson(data);
  }
}
