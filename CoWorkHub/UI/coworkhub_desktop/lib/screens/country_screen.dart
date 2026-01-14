import 'dart:async';
import 'package:coworkhub_desktop/models/country.dart';
import 'package:coworkhub_desktop/providers/country_provider.dart';
import 'package:coworkhub_desktop/screens/country_form_screen.dart';
import 'package:coworkhub_desktop/screens/settings_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';

class CountryScreen extends StatefulWidget {
  final void Function(Widget) onChangeScreen;

  const CountryScreen({super.key, required this.onChangeScreen});

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  final CountryProvider _countryProvider = CountryProvider();
  final TextEditingController _searchController = TextEditingController();

  List<Country> countries = [];
  bool isLoading = true;

  Timer? _debounce;
  int page = 1;
  int pageSize = 5;
  int totalPages = 1;

  String? sortColumn;
  String? sortDirection;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    setState(() => isLoading = true);

    final Map<String, dynamic> filter = {'IsDeleted': false};
    if (_searchController.text.isNotEmpty) {
      filter["CountryNameGTE"] = _searchController.text;
    }

    try {
      final result = await _countryProvider.get(
        filter: filter,
        page: page,
        pageSize: pageSize,
        orderBy: sortColumn,
        sortDirection: sortDirection,
      );

      setState(() {
        countries = result.resultList;
        totalPages = result.totalPages ?? 1;
      });
    } catch (e) {
      debugPrint("Greška pri učitavanju država: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      page = 1;
      _fetchCountries();
    });
  }

  void _onSort(String column) {
    String backendColumn;
    switch (column) {
      case "ID":
        backendColumn = "countryId";
        break;
      case "Naziv":
        backendColumn = "countryName";
        break;
      default:
        backendColumn = column;
    }

    if (sortColumn == backendColumn) {
      sortDirection = sortDirection == "asc" ? "desc" : "asc";
    } else {
      sortColumn = backendColumn;
      sortDirection = "asc";
    }
    _fetchCountries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // void _openForm({Country? country}) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => CountryFormScreen(
  //         country: country,
  //         onSave: () {
  //           _fetchCountries();
  //         },
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- HEADER ----------
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
                  "Države",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          /// ---------- SEARCH + ADD ----------
          Row(
            children: [
              SizedBox(
                width: 300,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: "Pretraži države...",
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
                    CountryFormScreen(
                      country: null,
                      onChangeScreen: widget.onChangeScreen,
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  "Dodaj državu",
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

          /// ---------- TABLE ----------
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : countries.isEmpty
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
                            headingRowColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 243, 242, 242),
                            ),
                            sortColumnIndex: sortColumn == "countryId" ? 0 : 1,
                            sortAscending: sortDirection == "asc",
                            columns: [
                              DataColumn(
                                label: const Text("ID"),
                                numeric: true,
                                onSort: (_, __) => _onSort("ID"),
                              ),
                              DataColumn(
                                label: const Text("Naziv"),
                                onSort: (_, __) => _onSort("Naziv"),
                              ),
                              const DataColumn(label: Text("Akcije")),
                            ],
                            rows: countries.map((country) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(country.countryId.toString())),
                                  DataCell(Text(country.countryName)),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.info_outline),
                                          onPressed: () {
                                            widget.onChangeScreen(
                                              CountryFormScreen(
                                                country: country,
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
                                                  "Da li ste sigurni da želite obrisati ${country.countryName}?",
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
                                                await _countryProvider.delete(
                                                  country.countryId,
                                                );
                                                showTopFlushBar(
                                                  context: context,
                                                  message:
                                                      "Država uspješno obrisana",
                                                  backgroundColor: Colors.green,
                                                );
                                                _fetchCountries();
                                              } catch (e) {
                                                showTopFlushBar(
                                                  context: context,
                                                  message:
                                                      "Brisanje nije uspjelo",
                                                  backgroundColor: Colors.red,
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
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

          /// ---------- FOOTER ----------
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
                      _fetchCountries();
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
                            _fetchCountries();
                          }
                        : null,
                  ),
                  Text("$page / $totalPages"),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: page < totalPages
                        ? () {
                            setState(() => page++);
                            _fetchCountries();
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
