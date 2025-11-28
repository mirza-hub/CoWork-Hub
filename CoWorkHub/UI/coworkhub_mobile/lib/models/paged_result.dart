import 'package:json_annotation/json_annotation.dart';

part 'paged_result.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PagedResult<T> {
  List<T> resultList;
  int? count;
  int? page;
  int? pageSize;
  int? totalPages;
  bool? hasPreviousPage;
  bool? hasNextPage;

  PagedResult({
    required this.resultList,
    this.count,
    this.page,
    this.pageSize,
    this.totalPages,
    this.hasPreviousPage,
    this.hasNextPage,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PagedResultFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PagedResultToJson(this, toJsonT);
}
