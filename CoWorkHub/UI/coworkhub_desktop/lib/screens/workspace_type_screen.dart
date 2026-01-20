import 'dart:async';

import 'package:coworkhub_desktop/models/workspace_type.dart';
import 'package:coworkhub_desktop/providers/workspace_type_provider.dart';
import 'package:coworkhub_desktop/screens/settings_screen.dart';
import 'package:coworkhub_desktop/screens/workspace_type_form_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';

class WorkspaceTypeScreen extends StatefulWidget {
  final void Function(Widget) onChangeScreen;

  const WorkspaceTypeScreen({super.key, required this.onChangeScreen});

  @override
  State<WorkspaceTypeScreen> createState() => _WorkspaceTypeScreenState();
}

class _WorkspaceTypeScreenState extends State<WorkspaceTypeScreen> {
  final WorkspaceTypeProvider _provider = WorkspaceTypeProvider();
  final TextEditingController _searchController = TextEditingController();

  static const double actionColumnWidth = 120;

  List<WorkspaceType> types = [];
  bool isLoading = true;

  final Map<int, String> _sortMap = {0: "WorkspaceTypeId", 1: "TypeName"};

  Timer? _debounce;

  int page = 1;
  int pageSize = 5;
  int totalPages = 1;

  String? sortColumn = "WorkspaceTypeId";
  String? sortDirection = "asc";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _fetchTypes();
  }

  Future<void> _fetchTypes() async {
    setState(() => isLoading = true);

    final Map<String, dynamic> filter = {"IsDeleted": false};
    if (_searchController.text.isNotEmpty) {
      filter["TypeNameGTE"] = _searchController.text;
    }

    try {
      final result = await _provider.get(
        filter: filter,
        page: page,
        pageSize: pageSize,
        orderBy: sortColumn,
        sortDirection: sortDirection,
      );

      setState(() {
        types = result.resultList;
        totalPages = result.totalPages ?? 1;
      });
    } catch (e) {
      debugPrint("Greška pri učitavanju tipova prostora: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      page = 1;
      _fetchTypes();
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
    _fetchTypes();
  }

  Widget _sortableHeader(String title, String columnKey) {
    Widget icon;
    if (sortColumn != columnKey) {
      icon = const Icon(Icons.unfold_more, size: 18, color: Colors.grey);
    } else {
      icon = Icon(
        sortDirection == "asc" ? Icons.arrow_upward : Icons.arrow_downward,
        size: 16,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(title), const SizedBox(width: 6), icon],
    );
  }

  DataColumn _centeredColumn(Widget label, {void Function(int, bool)? onSort}) {
    return DataColumn(
      label: SizedBox(width: 160, child: Center(child: label)),
      onSort: onSort,
    );
  }

  DataCell _centeredCell(String text) {
    return DataCell(
      SizedBox(
        width: 160,
        child: Center(
          child: Text(text, textAlign: TextAlign.center, softWrap: true),
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
        children: [
          // HEADER
          Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 28,
                  onPressed: () {
                    widget.onChangeScreen(
                      SettingsScreen(onChangeScreen: widget.onChangeScreen),
                    );
                  },
                ),
              ),
              const Center(
                child: Text(
                  "Tipovi prostora",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // SEARCH + ADD
          Row(
            children: [
              SizedBox(
                width: 360,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: "Pretraži tipove prostora...",
                    prefixIcon: Icon(Icons.search),
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  widget.onChangeScreen(
                    WorkspaceTypeFormScreen(
                      workspaceType: null,
                      onChangeScreen: widget.onChangeScreen,
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Dodaj tip prostora",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tabela
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : types.isEmpty
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
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: constraints.maxWidth,
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
                                _sortableHeader("ID", "WorkspaceTypeId"),
                                onSort: (i, _) => _onSort(i),
                              ),
                              _centeredColumn(
                                _sortableHeader("Naziv", "TypeName"),
                                onSort: (i, _) => _onSort(i),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: actionColumnWidth,
                                  child: const Center(child: Text("Akcije")),
                                ),
                              ),
                            ],
                            rows: types.map((t) {
                              return DataRow(
                                cells: [
                                  _centeredCell(t.workspaceTypeId.toString()),
                                  _centeredCell(t.typeName),
                                  DataCell(
                                    SizedBox(
                                      width: actionColumnWidth,
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.info_outline,
                                              ),
                                              onPressed: () {
                                                widget.onChangeScreen(
                                                  WorkspaceTypeFormScreen(
                                                    workspaceType: t,
                                                    onChangeScreen:
                                                        widget.onChangeScreen,
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () async {
                                                final confirmed = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text(
                                                      "Potvrda brisanja",
                                                    ),
                                                    content: Text(
                                                      "Da li želite obrisati tip prostora?",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.blue,
                                                            ),
                                                        child: const Text(
                                                          "Da",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text("Ne"),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirmed == true) {
                                                  try {
                                                    await _provider.delete(
                                                      t.workspaceTypeId,
                                                    );
                                                    _fetchTypes();
                                                    showTopFlushBar(
                                                      context: context,
                                                      message:
                                                          "Tip prostora je obrisan",
                                                      backgroundColor:
                                                          Colors.green,
                                                    );
                                                  } catch (e) {
                                                    showTopFlushBar(
                                                      context: context,
                                                      message:
                                                          "Greška pri brisanju: $e",
                                                      backgroundColor:
                                                          Colors.red,
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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

          // Footer
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("Prikaži:"),
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
                      _fetchTypes();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: page > 1
                        ? () {
                            setState(() => page--);
                            _fetchTypes();
                          }
                        : null,
                  ),
                  Text("$page / $totalPages"),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: page < totalPages
                        ? () {
                            setState(() => page++);
                            _fetchTypes();
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
