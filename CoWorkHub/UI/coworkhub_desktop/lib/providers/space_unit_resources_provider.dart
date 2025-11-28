import 'package:coworkhub_desktop/models/space_unit_resources.dart';
import 'base_provider.dart';

class SpaceUnitResourcesProvider extends BaseProvider<SpaceUnitResources> {
  SpaceUnitResourcesProvider() : super("SpaceUnitResources");

  @override
  SpaceUnitResources fromJson(data) {
    return SpaceUnitResources.fromJson(data);
  }
}
