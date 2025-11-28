import 'package:coworkhub_mobile/models/user_role.dart';

class AuthProvider {
  static String? username;
  static String? password;
  static int? userId;
  static String? firstName;
  static String? lastName;
  static String? email;
  static bool? isActive;
  static bool? isDeleted;
  static List<UserRole>? userRoles;
  static bool isSignedIn = false;
}
