import 'package:coworkhub_mobile/models/role.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';

class RoleProvider extends BaseProvider<Role> {
  RoleProvider() : super("Role");

  @override
  Role fromJson(data) {
    return Role.fromJson(data);
  }
}
