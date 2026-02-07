import 'dart:async';

import 'package:coworkhub_desktop/models/payment_method.dart';
import 'package:coworkhub_desktop/providers/payment_method_provider.dart';
import 'package:coworkhub_desktop/screens/payment_method_form_screen.dart';
import 'package:coworkhub_desktop/screens/settings_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatefulWidget {
  final void Function(Widget) onChangeScreen;

  const PaymentMethodScreen({super.key, required this.onChangeScreen});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final PaymentMethodProvider _provider = PaymentMethodProvider();
  final TextEditingController _searchController = TextEditingController();

  static const double actionColumnWidth = 120;

  List<PaymentMethod> items = [];
  bool isLoading = true;
  bool? filterIsDeleted = false;

  final Map<int, String> _sortMap = {
    0: "PaymentMethodId",
    1: "PaymentMethodName",
  };

  Timer? _debounce;

  int page = 1;
  int pageSize = 5;
  int totalPages = 1;
  int totalCount = 0;

  String? sortColumn;
  String? sortDirection;

  @override
  void initState() {
    super.initState();

    sortColumn = "PaymentMethodId";
    sortDirection = "asc";

    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() => isLoading = true);

    final Map<String, dynamic> filter = {};
    if (_searchController.text.isNotEmpty) {
      filter["PaymentMethodNameGTE"] = _searchController.text;
    }
    if (filterIsDeleted != null) {
      filter["IsDeleted"] = filterIsDeleted;
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
        items = result.resultList;
        totalPages = result.totalPages ?? 1;
        totalCount = result.count ?? 0;
      });
    } catch (e) {
      debugPrint("Greška pri učitavanju metoda plaćanja: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      page = 1;
      _fetchItems();
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
    _fetchItems();
  }

  Widget _sortableHeader(String title, String columnKey) {
    Widget icon;

    if (sortColumn != columnKey) {
      icon = const Icon(Icons.unfold_more, size: 18, color: Colors.grey);
    } else {
      icon = Icon(
        sortDirection == "asc" ? Icons.arrow_downward : Icons.arrow_upward,
        size: 16,
        color: Colors.black,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(title), const SizedBox(width: 6), icon],
    );
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (_) {
        bool? tempDeleted = filterIsDeleted ?? false;

        return StatefulBuilder(
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
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Obrisane"),
                    DropdownButton<bool?>(
                      isExpanded: true,
                      value: tempDeleted,
                      items: const [
                        DropdownMenuItem(value: null, child: Text("Sve")),
                        DropdownMenuItem(
                          value: false,
                          child: Text("Neobrisane"),
                        ),
                        DropdownMenuItem(value: true, child: Text("Obrisane")),
                      ],
                      onChanged: (val) {
                        setDialogState(() => tempDeleted = val);
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
                          setState(() {
                            filterIsDeleted = tempDeleted;
                            page = 1;
                          });
                          Navigator.pop(context);
                          _fetchItems();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Primijeni",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            filterIsDeleted = false;
                            page = 1;
                          });
                          Navigator.pop(context);
                          _fetchItems();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Resetiraj",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  DataCell _centeredCell(String text, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(child: Text(text, textAlign: TextAlign.center)),
      ),
    );
  }

  DataCell _alignedCell(
    String text,
    double width, {
    Alignment alignment = Alignment.centerLeft,
    TextAlign textAlign = TextAlign.left,
  }) {
    return DataCell(
      SizedBox(
        width: width,
        child: Align(
          alignment: alignment,
          child: Text(text, textAlign: textAlign),
        ),
      ),
    );
  }

  DataColumn _centeredColumn(
    Widget label, {
    bool numeric = false,
    void Function(int, bool)? onSort,
  }) {
    return DataColumn(
      label: SizedBox(width: 120, child: Center(child: label)),
      numeric: numeric,
      onSort: onSort,
    );
  }

  DataColumn _alignedColumn(
    Widget label, {
    double width = 120,
    Alignment alignment = Alignment.centerLeft,
    void Function(int, bool)? onSort,
  }) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Align(alignment: alignment, child: label),
      ),
      onSort: onSort,
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
                  "Metode plaćanja",
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
                    labelText: "Pretraži metode plaćanja...",
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
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  widget.onChangeScreen(
                    PaymentMethodFormScreen(
                      paymentMethod: null,
                      onChangeScreen: widget.onChangeScreen,
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Dodaj metodu plaćanja",
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
          // TABELA
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
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
                                _sortableHeader("ID", "PaymentMethodId"),
                                onSort: (i, _) => _onSort(i),
                              ),
                              _centeredColumn(
                                _sortableHeader("Naziv", "PaymentMethodName"),
                                onSort: (i, _) => _onSort(i),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: actionColumnWidth,
                                  child: const Center(child: Text("Akcije")),
                                ),
                              ),
                            ],
                            rows: items.map((item) {
                              return DataRow(
                                cells: [
                                  _centeredCell(
                                    item.paymentMethodId.toString(),
                                    120,
                                  ),
                                  _centeredCell(item.paymentMethodName, 120),
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
                                                  PaymentMethodFormScreen(
                                                    paymentMethod: item,
                                                    onChangeScreen:
                                                        widget.onChangeScreen,
                                                  ),
                                                );
                                              },
                                            ),
                                            if (!item.isDeleted)
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
                                                      content: const Text(
                                                        "Da li želite obrisati ovu metodu plaćanja?",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(true),
                                                          style:
                                                              ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.blue,
                                                              ),
                                                          child: const Text(
                                                            "Da",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(false),
                                                          child: const Text(
                                                            "Ne",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirmed == true) {
                                                    try {
                                                      await _provider.delete(
                                                        item.paymentMethodId,
                                                      );
                                                      _fetchItems();
                                                      showTopFlushBar(
                                                        context: context,
                                                        message:
                                                            "Metoda plaćanja uspješno obrisana",
                                                        backgroundColor:
                                                            Colors.green,
                                                      );
                                                    } catch (e) {
                                                      showTopFlushBar(
                                                        context: context,
                                                        message:
                                                            "Brisanje nije uspjelo",
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
          // FOOTER
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
                      _fetchItems();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    totalCount == 0
                        ? "0 od 0"
                        : "${((page - 1) * pageSize) + 1}–${((page - 1) * pageSize) + items.length} od $totalCount",
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: page > 1
                        ? () {
                            page--;
                            _fetchItems();
                          }
                        : null,
                  ),
                  Text("$page / $totalPages"),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: page < totalPages
                        ? () {
                            page++;
                            _fetchItems();
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
