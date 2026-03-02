import 'dart:convert';

import 'package:coworkhub_desktop/models/notification.dart';
import 'package:coworkhub_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class NotificationProvider extends BaseProvider<Notification> {
  NotificationProvider() : super("Notification");

  @override
  Notification fromJson(data) {
    return Notification.fromJson(data);
  }

  Future<Notification> markAsRead(int id) async {
    var url = "${BaseProvider.baseUrl}Notification/$id/read";

    var response = await http.put(Uri.parse(url), headers: createHeaders());

    if (isValidResponse(response)) {
      return Notification.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Mark as read failed");
    }
  }

  Future<void> markAllAsRead() async {
    var url = "${BaseProvider.baseUrl}Notification/mark-all-as-read";

    var response = await http.put(Uri.parse(url), headers: createHeaders());

    if (!isValidResponse(response)) {
      throw Exception("Mark all as read failed");
    }
  }
}
