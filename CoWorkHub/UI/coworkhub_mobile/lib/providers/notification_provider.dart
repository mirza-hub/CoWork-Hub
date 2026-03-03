import 'dart:convert';

import 'package:coworkhub_mobile/models/notification.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';
import 'package:coworkhub_mobile/exceptions/user_exception.dart';
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
      throw _handleError(response);
    }
  }

  Future<void> markAllAsRead() async {
    var url = "${BaseProvider.baseUrl}Notification/mark-all-as-read";

    var response = await http.put(Uri.parse(url), headers: createHeaders());

    if (!isValidResponse(response)) {
      throw _handleError(response);
    }
  }

  UserException _handleError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data['errors'] != null && data['errors'] is Map) {
        final errorsMap = data['errors'] as Map<String, dynamic>;

        if (errorsMap.isNotEmpty) {
          final firstKey = errorsMap.keys.first;
          final errorValue = errorsMap[firstKey];

          if (errorValue is List && errorValue.isNotEmpty) {
            return UserException(
              errorValue.first.toString(),
              statusCode: response.statusCode,
            );
          }
        }
      }

      if (data['message'] != null) {
        return UserException(
          data['message'].toString(),
          statusCode: response.statusCode,
        );
      }

      return UserException(
        "Greška sa servera (${response.statusCode})",
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is UserException) rethrow;
      return UserException(
        "Greška sa servera (${response.statusCode})",
        statusCode: response.statusCode,
      );
    }
  }
}
