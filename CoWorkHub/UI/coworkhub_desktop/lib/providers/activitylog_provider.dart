import 'package:coworkhub_desktop/models/activitylog.dart';
import 'package:coworkhub_desktop/providers/base_provider.dart';

class ActivityLogProvider extends BaseProvider<ActivityLog> {
  ActivityLogProvider() : super("ActivityLog");

  @override
  ActivityLog fromJson(data) {
    return ActivityLog.fromJson(data);
  }
}
