import 'package:coworkhub_mobile/models/city.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(data) {
    return City.fromJson(data);
  }
}
