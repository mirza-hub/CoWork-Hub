import 'package:coworkhub_mobile/models/space_unit.dart';
import 'base_provider.dart';

class SpaceUnitProvider extends BaseProvider<SpaceUnit> {
  SpaceUnitProvider() : super("SpaceUnit");

  @override
  SpaceUnit fromJson(data) {
    return SpaceUnit.fromJson(data);
  }
}
