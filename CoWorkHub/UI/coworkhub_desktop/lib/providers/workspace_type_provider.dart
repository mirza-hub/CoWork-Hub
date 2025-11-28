import 'package:coworkhub_desktop/models/workspace_type.dart';
import 'base_provider.dart';

class WorkspaceTypeProvider extends BaseProvider<WorkspaceType> {
  WorkspaceTypeProvider() : super("WorkspaceType");

  @override
  WorkspaceType fromJson(data) {
    return WorkspaceType.fromJson(data);
  }
}
