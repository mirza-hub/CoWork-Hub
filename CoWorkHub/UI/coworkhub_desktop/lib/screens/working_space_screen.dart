import 'dart:async';

import 'package:coworkhub_desktop/models/city.dart';
import 'package:coworkhub_desktop/models/working_space.dart';
import 'package:coworkhub_desktop/providers/city_provider.dart';
import 'package:coworkhub_desktop/providers/working_space_provider.dart';
import 'package:coworkhub_desktop/screens/working_space_details_screen.dart';
import 'package:coworkhub_desktop/screens/working_space_form_screen.dart';
import 'package:flutter/material.dart';

class WorkingSpacesScreen extends StatefulWidget {
  final void Function(Widget) onChangeScreen;

  const WorkingSpacesScreen({super.key, required this.onChangeScreen});

  @override
  State<WorkingSpacesScreen> createState() => _WorkingSpacesScreenState();
}

class _WorkingSpacesScreenState extends State<WorkingSpacesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();

  final WorkingSpaceProvider provider = WorkingSpaceProvider();
  final CityProvider cityProvider = CityProvider();

  List<WorkingSpace> spaces = [];
  List<City> cities = [];
  String searchName = "";
  String searchAddress = "";
  int? filterCityId;
  bool? filterIsDeleted = false;
  bool _isLoadingSpaces = true;

  int page = 1;
  int pageSize = 10;
  int totalPages = 1;
  String? sortColumn;
  String? sortDirection;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _emailAddressController.addListener(() {
      _onSearchChanged(_emailAddressController.text);
    });
    _loadCities();
    _loadSpaces();
  }

  Future<void> _loadCities() async {
    var response = await cityProvider.get();
    cities = response.resultList;
    setState(() {});
  }

  Future<void> _loadSpaces() async {
    setState(() => _isLoadingSpaces = true);

    final result = await provider.getFiltered(
      nameFts: _searchController.text,
      addressFts: _emailAddressController.text,
      cityId: filterCityId,
      isDeleted: filterIsDeleted,
      page: page,
      pageSize: pageSize,
      orderBy: sortColumn,
      sortDirection: sortDirection,
    );
    setState(() {
      spaces = result.resultList;
      totalPages = result.totalPages!;
      _isLoadingSpaces = false;
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      page = 1;
      _loadSpaces();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int? selectedCity = filterCityId;
        bool? selectedDeleted = filterIsDeleted;
        return AlertDialog(
          title: const Text("Filteri"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedCity,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("Svi gradovi"),
                  ),
                  ...cities.map(
                    (c) => DropdownMenuItem(
                      value: c.cityId,
                      child: Text(c.cityName),
                    ),
                  ),
                ],
                onChanged: (v) => selectedCity = v,
                decoration: const InputDecoration(labelText: "Grad"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<bool>(
                value: selectedDeleted,
                items: const [
                  DropdownMenuItem(value: null, child: Text("Svi")),
                  DropdownMenuItem(value: false, child: Text("Neobrisani")),
                  DropdownMenuItem(value: true, child: Text("Obrisani")),
                ],
                onChanged: (v) => selectedDeleted = v,
                decoration: const InputDecoration(labelText: "Obrisan"),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                filterCityId = selectedCity;
                filterIsDeleted = selectedDeleted;
                page = 1;
                _loadSpaces();
                Navigator.pop(context);
              },
              child: const Text("Primijeni"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Otkaži"),
            ),
          ],
        );
      },
    );
  }

  void _onSort(String column) {
    if (sortColumn == column) {
      sortDirection = sortDirection == "asc" ? "desc" : "asc";
    } else {
      sortColumn = column;
      sortDirection = "asc";
    }
    _loadSpaces();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH
          // Padding(
          // padding: const EdgeInsets.all(8.0),
          Row(
            children: [
              SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Naziv",
                    labelStyle: TextStyle(
                      color: Colors.grey, // ← izgleda kao placeholder
                    ),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // Expanded(
              //   child: TextField(
              //     decoration: const InputDecoration(labelText: "Naziv"),
              //     onChanged: (v) => searchName = v,
              //   ),
              // ),
              const SizedBox(width: 12),
              SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: _emailAddressController,
                  decoration: InputDecoration(
                    labelText: "Adresa",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // Expanded(
              //   child: TextField(
              //     decoration: const InputDecoration(labelText: "Adresa"),
              //     onChanged: (v) => searchAddress = v,
              //   ),
              // ),
              const SizedBox(width: 8),
              // ElevatedButton(
              //   onPressed: _openFilterDialog,
              //   child: const Text("Filter"),
              // ),
              ElevatedButton.icon(
                onPressed: _openFilterDialog,
                icon: const Icon(Icons.filter_list),
                label: const Text("Filteri"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
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
                    WorkingSpaceFormScreen(
                      workspace: null,
                      onChangeScreen: widget.onChangeScreen,
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Kreiraj novi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
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

          // DATA TABLE
          Expanded(
            child: _isLoadingSpaces
                ? const Center(child: CircularProgressIndicator())
                : spaces.isEmpty
                ? const Center(
                    child: Text(
                      "Nema podataka za prikazivanje",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        return const Color.fromARGB(255, 243, 242, 242);
                      }),
                      sortColumnIndex: sortColumn == "WorkingSpacesId"
                          ? 0
                          : sortColumn == "Name"
                          ? 1
                          : null,
                      sortAscending: sortDirection == "asc",
                      columns: [
                        DataColumn(
                          label: const Text("ID"),
                          numeric: true,
                          onSort: (columnIndex, ascending) {
                            _onSort("WorkingSpacesId");
                          },
                        ),
                        DataColumn(
                          label: const Text("Naziv"),
                          onSort: (columnIndex, ascending) => _onSort("Name"),
                        ),
                        DataColumn(label: const Text("Adresa")),
                        DataColumn(label: const Text("Opis")),
                        DataColumn(label: const Text("Aktivan")),
                        DataColumn(label: const Text("Akcije")),
                      ],
                      rows: spaces
                          .map(
                            (ws) => DataRow(
                              cells: [
                                DataCell(Text(ws.workingSpacesId.toString())),
                                DataCell(Text(ws.name)),
                                DataCell(Text(ws.address)),
                                DataCell(Text(ws.description)),
                                DataCell(
                                  Text(ws.isDeleted == true ? "Ne" : "Da"),
                                ),

                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          widget.onChangeScreen(
                                            WorkingSpaceDetailsScreen(
                                              space: ws,
                                              onChangeScreen:
                                                  widget.onChangeScreen,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.info_outline),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          bool?
                                          confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                "Potvrda brisanja",
                                              ),
                                              content: const Text(
                                                "Da li želite obrisati ovaj zapis?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text("Da"),
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

                                          if (confirm == true) {
                                            await provider.delete(
                                              ws.workingSpacesId,
                                            );
                                            _loadSpaces();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
          const Divider(
            color: Colors.grey, // ista boja kao header, možeš prilagoditi
            thickness: 1,
            height: 1,
          ),
          // PAGINATION
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
                      _loadSpaces();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: page > 1
                        ? () async {
                            setState(() => page--);
                            await _loadSpaces();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    "${spaces.isEmpty ? 0 : page} / ${totalPages == 0 ? 0 : totalPages}",
                  ),
                  IconButton(
                    onPressed: page < totalPages
                        ? () async {
                            setState(() => page++);
                            await _loadSpaces();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
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
