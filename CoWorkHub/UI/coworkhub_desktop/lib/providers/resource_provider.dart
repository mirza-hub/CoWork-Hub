import 'package:coworkhub_desktop/models/resource.dart';

import 'base_provider.dart';

class ResourceProvider extends BaseProvider<Resource> {
  ResourceProvider() : super("Resource");

  @override
  Resource fromJson(data) {
    return Resource.fromJson(data);
  }
}
