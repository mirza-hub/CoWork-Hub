import 'dart:async';

import 'package:coworkhub_desktop/models/city.dart';
import 'package:coworkhub_desktop/providers/city_provider.dart';
import 'package:coworkhub_desktop/screens/city_form_screen.dart';
import 'package:coworkhub_desktop/screens/settings_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';

class CityScreen extends StatefulWidget {
  final void Function(Widget) onChangeScreen;

  const CityScreen({super.key, required this.onChangeScreen});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  final CityProvider _cityProvider = CityProvider();
  final TextEditingController _searchController = TextEditingController();

  List<City> cities = [];
  bool isLoading = true;

  final Map<int, String> _sortMap = {
    0: "CityId",
    1: "CityName",
    2: "PostalCode",
  };

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
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    setState(() => isLoading = true);

    final Map<String, dynamic> filter = {
      "IsCountryIncluded": true,
      "IsDeleted": false,
    };
    if (_searchController.text.isNotEmpty) {
      filter["CityNameGTE"] = _searchController.text;
    }

    try {
      final result = await _cityProvider.get(
        filter: filter,
        page: page,
        pageSize: pageSize,
        orderBy: sortColumn,
        sortDirection: sortDirection,
      );

      setState(() {
        cities = result.resultList;
        totalPages = result.totalPages ?? 1;
      });
    } catch (e) {
      debugPrint("Greška pri učitavanju gradova: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      page = 1;
      _fetchCities();
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
    _fetchCities();
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
          /// ---------- HEADER (strelica + naslov) ----------
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
                  "Gradovi",
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
                width: 360, // ⬅️ povećana širina searcha
                height: 40,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: "Pretraži gradove...",
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
                    CityFormScreen(
                      city: null,
                      onChangeScreen: widget.onChangeScreen,
                    ),
                  );
                },

                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  "Dodaj grad",
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
                : cities.isEmpty
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
                            sortColumnIndex: sortColumn == "cityId"
                                ? 0
                                : sortColumn == "cityName"
                                ? 1
                                : sortColumn == "postalCode"
                                ? 2
                                : null,
                            sortAscending: sortDirection == "asc",
                            columns: [
                              DataColumn(
                                label: const Text("ID"),
                                numeric: true,
                                onSort: (index, _) => _onSort(index),
                              ),
                              DataColumn(
                                label: const Text("Naziv"),
                                onSort: (index, _) => _onSort(index),
                              ),
                              DataColumn(
                                label: const Text("Poštanski broj"),
                                onSort: (index, _) => _onSort(index),
                              ),
                              const DataColumn(label: Text("Država")),
                              const DataColumn(label: Text("Akcije")),
                            ],
                            rows: cities.map((city) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(city.cityId.toString())),
                                  DataCell(Text(city.cityName)),
                                  DataCell(Text(city.postalCode)),
                                  DataCell(Text(city.country.countryName)),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.info_outline),
                                          onPressed: () {
                                            widget.onChangeScreen(
                                              CityFormScreen(
                                                city: city,
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
                                                content: const Text(
                                                  "Da li želite obrisati ovaj grad?",
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
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text("Ne"),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmed == true) {
                                              try {
                                                await _cityProvider.delete(
                                                  city.cityId,
                                                );
                                                _fetchCities();
                                                showTopFlushBar(
                                                  context: context,
                                                  message:
                                                      "Grad uspješno obrisan",
                                                  backgroundColor: Colors.green,
                                                );
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
                      _fetchCities();
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
                            _fetchCities();
                          }
                        : null,
                  ),
                  Text("$page / $totalPages"),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: page < totalPages
                        ? () {
                            setState(() => page++);
                            _fetchCities();
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
