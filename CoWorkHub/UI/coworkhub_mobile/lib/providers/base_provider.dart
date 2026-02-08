import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/paged_result.dart';
import 'auth_provider.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? baseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    baseUrl = dotenv.env['baseUrl'] ?? "http://10.0.2.2:5084/";
  }

  T fromJson(dynamic data) {
    throw UnimplementedError();
  }

  Future<PagedResult<T>> get({
    dynamic filter,
    int? page,
    int? pageSize,
    String? orderBy,
    String? sortDirection,
    // required T Function(Object? json) fromJsonT,
  }) async {
    var url = "$baseUrl$_endpoint";
    Map<String, dynamic> queryParams = {};
    if (filter != null) queryParams.addAll(filter);
    if (page != null) queryParams['page'] = page;
    if (pageSize != null) queryParams['pageSize'] = pageSize;
    if (orderBy != null) queryParams['orderBy'] = orderBy;
    if (sortDirection != null) queryParams['sortDirection'] = sortDirection;

    if (queryParams.isNotEmpty) url = "$url?${_getQueryString(queryParams)}";

    var response = await http.get(Uri.parse(url), headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var resultList = (data['resultList'] as List)
          .map((e) => fromJson(e))
          .toList();
      return PagedResult<T>(
        resultList: resultList,
        count: data['count'],
        page: data['page'],
        pageSize: data['pageSize'],
        totalPages: data['totalPages'],
        hasPreviousPage: data['hasPreviousPage'],
        hasNextPage: data['hasNextPage'],
      );
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T?> getById(int id) async {
    var url = "$baseUrl$_endpoint/$id";

    var response = await http.get(Uri.parse(url), headers: createHeaders());

    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    }

    return null;
  }

  Future<T> insert(dynamic request) async {
    var response = await http.post(
      Uri.parse("$baseUrl$_endpoint"),
      headers: createHeaders(),
      body: jsonEncode(request),
    );

    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw response;
    }
  }

  Future<T> update(int id, dynamic request) async {
    var response = await http.put(
      Uri.parse("$baseUrl$_endpoint/$id"),
      headers: createHeaders(),
      body: jsonEncode(request),
    );

    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw response;
    }
  }

  Future<void> delete(int id) async {
    var response = await http.delete(
      Uri.parse("$baseUrl$_endpoint/$id"),
      headers: createHeaders(),
    );
    if (!isValidResponse(response)) throw Exception("Delete failed");
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";
    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";
    return {"Content-Type": "application/json", "Authorization": basicAuth};
  }

  bool isValidResponse(http.Response response) => response.statusCode < 300;

  String _getQueryString(Map params) {
    return params.entries
        .map(
          (e) =>
              "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent('${e.value}')}",
        )
        .join("&");
  }
}
