import 'dart:async';

import 'package:coworkhub_desktop/models/activitylog.dart';
import 'package:coworkhub_desktop/providers/activitylog_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityLogScreen extends StatefulWidget {
  final void Function(Widget) onChangeScreen;

  const ActivityLogScreen({super.key, required this.onChangeScreen});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final ActivityLogProvider _activityLogProvider = ActivityLogProvider();
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final DateFormat _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

  static const double idColumnWidth = 90;
  static const double userColumnWidth = 200;
  static const double descriptionColumnWidth = 320;
  static const double createdAtColumnWidth = 170;

  List<ActivityLog> logs = [];
  bool isLoading = true;

  DateTime? filterDateFrom;
  DateTime? filterDateTo;

  Timer? _debounce;

  int page = 1;
  int pageSize = 5;
  int totalPages = 1;
  int totalCount = 0;

  final Map<int, String> _sortMap = {0: "ActivityLogId", 3: "CreatedAt"};

  String? sortColumn = "CreatedAt";
  String? sortDirection = "desc";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => isLoading = true);

    final Map<String, dynamic> filter = {};
    if (_searchController.text.isNotEmpty) {
      filter["Action"] = _searchController.text;
    }
    if (filterDateFrom != null) {
      filter["From"] = filterDateFrom!.toIso8601String();
    }
    if (filterDateTo != null) {
      filter["To"] = filterDateTo!.toIso8601String();
    }

    try {
      final result = await _activityLogProvider.get(
        filter: filter,
        page: page,
        pageSize: pageSize,
        orderBy: sortColumn,
        sortDirection: sortDirection,
      );

      setState(() {
        logs = result.resultList;
        totalPages = result.totalPages ?? 1;
        totalCount = result.count ?? 0;
      });
    } catch (e) {
      debugPrint("Greska pri ucitavanju aktivnosti: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      page = 1;
      _fetchLogs();
    });
  }

  void _onSort(int columnIndex) {
    final backendColumn = _sortMap[columnIndex];
    if (backendColumn == null) return;

    if (sortColumn == backendColumn) {
      sortDirection = sortDirection == "asc" ? "desc" : "asc";
    } else {
      sortColumn = backendColumn;
      sortDirection = "asc";
    }

    page = 1;
    _fetchLogs();
  }

  Widget _sortableHeader(String title, String columnKey) {
    Widget icon;

    if (sortColumn != columnKey) {
      icon = const Icon(Icons.unfold_more, size: 18, color: Colors.grey);
    } else {
      icon = Icon(
        sortDirection == "asc" ? Icons.arrow_downward : Icons.arrow_upward,
        size: 16,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(title), const SizedBox(width: 6), icon],
    );
  }

  void _openFilterDialog() {
    DateTime? tempDateFrom = filterDateFrom;
    DateTime? tempDateTo = filterDateTo;

    final fromController = TextEditingController(
      text: tempDateFrom != null ? _dateFormat.format(tempDateFrom) : "",
    );
    final toController = TextEditingController(
      text: tempDateTo != null ? _dateFormat.format(tempDateTo) : "",
    );

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filteri",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  child: const Icon(Icons.close, size: 22),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: fromController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Datum od",
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: tempDateFrom ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setDialogState(() {
                          tempDateFrom = date;
                          fromController.text = _dateFormat.format(date);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: toController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Datum do",
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: tempDateTo ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setDialogState(() {
                          tempDateTo = date;
                          toController.text = _dateFormat.format(date);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        filterDateFrom = tempDateFrom;
                        filterDateTo = tempDateTo;
                        page = 1;
                        _fetchLogs();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Primijeni",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        filterDateFrom = null;
                        filterDateTo = null;
                        page = 1;
                        _fetchLogs();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Resetiraj",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _userFullName(ActivityLog log) {
    final firstName = log.user?.firstName?.trim();
    final lastName = log.user?.lastName?.trim();
    final parts = [
      if (firstName != null && firstName.isNotEmpty) firstName,
      if (lastName != null && lastName.isNotEmpty) lastName,
    ];

    if (parts.isEmpty) {
      return "-";
    }

    return parts.join(" ");
  }

  DataColumn _centeredColumn(
    Widget label, {
    double width = 150,
    bool numeric = false,
    void Function(int, bool)? onSort,
  }) {
    return DataColumn(
      numeric: numeric,
      onSort: onSort,
      label: SizedBox(
        width: width,
        child: Center(child: label),
      ),
    );
  }

  DataCell _centeredCell(String text, {double width = 150}) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Stack(
            children: [
              const Center(
                child: Text(
                  "Aktivnosti",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // SEARCH + FILTER
          Row(
            children: [
              SizedBox(
                width: 360,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: "Pretrazi korisnike...",
                    prefixIcon: Icon(Icons.search),
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _openFilterDialog,
                icon: const Icon(Icons.filter_list),
                label: const Text("Filteri"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // TABELA
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : logs.isEmpty
                ? const Center(
                    child: Text(
                      "Nema podataka za prikazivanje",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            headingRowHeight: 50,
                            dataRowHeight: 48,
                            columnSpacing: 0,
                            horizontalMargin: 0,
                            headingRowColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 243, 242, 242),
                            ),
                            columns: [
                              _centeredColumn(
                                _sortableHeader("ID", "ActivityLogId"),
                                width: idColumnWidth,
                                onSort: (i, __) => _onSort(i),
                              ),
                              _centeredColumn(
                                const Text("Korisnik"),
                                width: userColumnWidth,
                              ),
                              _centeredColumn(
                                const Text("Opis"),
                                width: descriptionColumnWidth,
                              ),
                              _centeredColumn(
                                _sortableHeader("Kreirano", "CreatedAt"),
                                width: createdAtColumnWidth,
                                onSort: (i, __) => _onSort(i),
                              ),
                            ],
                            rows: logs.map((log) {
                              final description = log.description?.trim();
                              return DataRow(
                                cells: [
                                  _centeredCell(
                                    log.activityLogId.toString(),
                                    width: idColumnWidth,
                                  ),
                                  _centeredCell(
                                    _userFullName(log),
                                    width: userColumnWidth,
                                  ),
                                  _centeredCell(
                                    (description == null || description.isEmpty)
                                        ? "-"
                                        : description,
                                    width: descriptionColumnWidth,
                                  ),
                                  _centeredCell(
                                    _dateTimeFormat.format(log.createdAt),
                                    width: createdAtColumnWidth,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // FOOTER
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("Prikazi:"),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: pageSize,
                    items: const [
                      DropdownMenuItem(value: 5, child: Text("5")),
                      DropdownMenuItem(value: 10, child: Text("10")),
                      DropdownMenuItem(value: 20, child: Text("20")),
                      DropdownMenuItem(value: 50, child: Text("50")),
                    ],
                    onChanged: (v) {
                      pageSize = v!;
                      page = 1;
                      _fetchLogs();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    totalCount == 0
                        ? "0 od 0"
                        : "${((page - 1) * pageSize) + 1}-${((page - 1) * pageSize) + logs.length} od $totalCount",
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: page > 1
                        ? () {
                            setState(() => page--);
                            _fetchLogs();
                          }
                        : null,
                  ),
                  Text(
                    "${logs.isEmpty ? 0 : page} / ${totalPages == 0 ? 0 : totalPages}",
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: page < totalPages
                        ? () {
                            setState(() => page++);
                            _fetchLogs();
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
