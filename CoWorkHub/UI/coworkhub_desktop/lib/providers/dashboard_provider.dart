import 'dart:convert';
import 'package:coworkhub_desktop/models/dashboard_stats.dart';
import 'package:coworkhub_desktop/models/revenue_by_month.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';

class DashboardProvider with ChangeNotifier {
  DashboardStats? _stats;
  List<RevenueByMonth>? _revenueByMonth;
  bool _loading = false;

  DashboardStats? get stats => _stats;
  List<RevenueByMonth>? get revenueByMonth => _revenueByMonth;
  bool get loading => _loading;

  /// Fetch main dashboard stats
  Future<void> fetchStats() async {
    _loading = true;
    notifyListeners();

    try {
      String baseUrl = const String.fromEnvironment(
        "baseUrl",
        defaultValue: "http://localhost:5084/",
      );

      final url = Uri.parse("${baseUrl}Dashboard/stats");

      String username = AuthProvider.username ?? "";
      String password = AuthProvider.password ?? "";
      String basicAuth =
          "Basic ${base64Encode(utf8.encode('$username:$password'))}";

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": basicAuth,
        },
      );

      if (response.statusCode < 300) {
        _stats = DashboardStats.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to load dashboard stats");
      }
    } catch (e) {
      debugPrint("Dashboard fetch error: $e");
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// New method: fetch revenue by month for line chart
  Future<void> fetchRevenueByMonth() async {
    _loading = true;
    notifyListeners();

    try {
      String baseUrl = const String.fromEnvironment(
        "baseUrl",
        defaultValue: "http://localhost:5084/",
      );

      final url = Uri.parse("${baseUrl}Dashboard/revenue-by-month");

      String username = AuthProvider.username ?? "";
      String password = AuthProvider.password ?? "";
      String basicAuth =
          "Basic ${base64Encode(utf8.encode('$username:$password'))}";

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": basicAuth,
        },
      );

      if (response.statusCode < 300) {
        final data = jsonDecode(response.body) as List;
        _revenueByMonth = data.map((e) => RevenueByMonth.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load revenue by month");
      }
    } catch (e) {
      debugPrint("Revenue fetch error: $e");
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
