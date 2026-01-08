import 'dart:async';

import 'package:coworkhub_desktop/models/city.dart';
import 'package:coworkhub_desktop/providers/city_provider.dart';
import 'package:coworkhub_desktop/screens/user_details_screen.dart';
import 'package:flutter/material.dart';
import '../models/user.dart'; // ovo je tvoj User model
import '../providers/user_provider.dart';

class UsersScreen extends StatefulWidget {
  final void Function(Widget) onChangeScreen;

  const UsersScreen({super.key, required this.onChangeScreen});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emailSearchController = TextEditingController();
  final UserProvider _userProvider = UserProvider();
  final CityProvider cityProvider = CityProvider();

  List<User> users = [];
  List<City> cities = [];
  bool isLoading = true;
  Timer? _debounce;
  String? selectedCityId;
  String selectedActive = "true";
  String selectedDeleted = "false";
  String? sortColumn;
  bool sortAscending = true;
  String? sortDirection;
  int page = 1;
  int pageSize = 10;
  int totalPages = 1;

  List<DropdownMenuItem<String>> activeOptions = const [
    DropdownMenuItem(value: "All", child: Text("Svi")),
    DropdownMenuItem(value: "true", child: Text("Aktivni")),
    DropdownMenuItem(value: "false", child: Text("Neaktivni")),
  ];

  List<DropdownMenuItem<String>> deletedOptions = const [
    DropdownMenuItem(value: "All", child: Text("Svi")),
    DropdownMenuItem(value: "true", child: Text("Obrisani")),
    DropdownMenuItem(value: "false", child: Text("Neobrisani")),
  ];

  List<DropdownMenuItem<String>> cityOptions = [
    DropdownMenuItem(value: null, child: Text("Svi")),
    DropdownMenuItem(value: "1", child: Text("Sarajevo")),
    DropdownMenuItem(value: "2", child: Text("Mostar")),
    DropdownMenuItem(value: "3", child: Text("Tuzla")),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _emailSearchController.addListener(() {
      _onSearchChanged(_emailSearchController.text);
    });
    _fetchUsers();
    loadCities();
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    final Map<String, dynamic> flt = {};

    if (_searchController.text.isNotEmpty) {
      flt["fts"] = _searchController.text;
    }

    if (_emailSearchController.text.isNotEmpty) {
      flt["email"] = _emailSearchController.text;
    }

    if (selectedActive != "All") {
      flt["isActive"] = selectedActive == "true";
    }

    if (selectedDeleted != "All") {
      flt["isDeleted"] = selectedDeleted == "true";
    }

    if (selectedCityId != null) {
      flt["cityId"] = selectedCityId;
    }

    flt["IsUserRolesIncluded"] = true;

    try {
      final result = await _userProvider.get(
        filter: flt,
        page: page,
        pageSize: pageSize,
        orderBy: sortColumn,
        sortDirection: sortDirection,
        // fromJsonT: (json) => User.fromJson(json as Map<String, dynamic>),
      );
      setState(() {
        users = result.resultList;
        totalPages = result.totalPages ?? 1;
      });
    } catch (e) {
      debugPrint("Greška: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadCities() async {
    try {
      final result = await cityProvider.get(
        filter: {'RetrieveAll': true},
        // fromJsonT: (json) => City.fromJson(json as Map<String, dynamic>),
      );

      cityOptions = [
        const DropdownMenuItem(value: null, child: Text("Svi")),
        ...result.resultList.map(
          (city) => DropdownMenuItem(
            value: city.cityId.toString(),
            child: Text(city.cityName),
          ),
        ),
      ];

      cities = result.resultList;
      setState(() {});
    } catch (e) {
      debugPrint("Greška pri učitavanju gradova: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      page = 1;
      _fetchUsers();
    });
  }

  void _onSort(String column) {
    if (sortColumn == column) {
      sortDirection = sortDirection == "asc" ? "desc" : "asc";
    } else {
      sortColumn = column;
      sortDirection = "asc";
    }
    _fetchUsers();
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (_) {
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
            width: 500,
            child: GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 3,
              ),
              children: [
                // City
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Grad"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCityId,
                      items: cityOptions,
                      onChanged: (val) {
                        setState(() => selectedCityId = val);
                      },
                    ),
                  ],
                ),

                // Active
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Aktivnost"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedActive,
                      items: activeOptions,
                      onChanged: (val) {
                        setState(() => selectedActive = val!);
                      },
                    ),
                  ],
                ),

                // Deleted
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Obrisani"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedDeleted,
                      items: deletedOptions,
                      onChanged: (val) {
                        setState(() => selectedDeleted = val!);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _fetchUsers();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                "Potvrdi",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                // RESET FILTER
                setState(() {
                  selectedCityId = null;
                  selectedActive = "true";
                  selectedDeleted = "false";
                });
                Navigator.pop(context);
                _fetchUsers();
              },
              child: const Text("Resetiraj"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH + FILTER
          Row(
            children: [
              SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Pretraži...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: _emailSearchController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.search),
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

          // ------------------- TABELA -------------------
          // ------------------- TABELA -------------------
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
                ? const Center(
                    child: Text(
                      "Nema podataka za prikazivanje",
                      style: TextStyle(fontSize: 16),
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
                            headingRowColor:
                                MaterialStateProperty.resolveWith<Color?>((
                                  Set<MaterialState> states,
                                ) {
                                  return const Color.fromARGB(
                                    255,
                                    243,
                                    242,
                                    242,
                                  );
                                }),

                            sortColumnIndex: sortColumn == "UsersId"
                                ? 0
                                : sortColumn == "FirstName"
                                ? 1
                                : sortColumn == "LastName"
                                ? 2
                                : sortColumn == "Email"
                                ? 3
                                : sortColumn == "Username"
                                ? 4
                                : null,
                            sortAscending: sortDirection == "asc",
                            columns: [
                              DataColumn(
                                label: Text("ID"),
                                numeric: true,
                                onSort: (columnIndex, ascending) {
                                  _onSort("UsersId");
                                },
                              ),

                              DataColumn(
                                label: Text("Ime"),
                                onSort: (columnIndex, ascending) =>
                                    _onSort("FirstName"),
                              ),
                              DataColumn(
                                label: Text("Prezime"),
                                onSort: (columnIndex, ascending) =>
                                    _onSort("LastName"),
                              ),
                              DataColumn(
                                label: Text("Email"),
                                onSort: (columnIndex, ascending) =>
                                    _onSort("Email"),
                              ),
                              DataColumn(
                                label: Text("Username"),
                                onSort: (columnIndex, ascending) =>
                                    _onSort("Username"),
                              ),
                              DataColumn(label: Text("Status")),
                              DataColumn(label: Text("Akcije")),
                            ],
                            rows: users
                                .map(
                                  (user) => DataRow(
                                    cells: [
                                      DataCell(Text(user.usersId.toString())),
                                      DataCell(Text(user.firstName)),
                                      DataCell(Text(user.lastName)),
                                      DataCell(Text(user.email)),
                                      DataCell(Text(user.username)),
                                      DataCell(
                                        Text(
                                          user.isActive
                                              ? "Aktivan"
                                              : "Neaktivan",
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.info_outline,
                                              ),
                                              onPressed: () {
                                                widget.onChangeScreen(
                                                  UserDetailsScreen(
                                                    user: user,
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
                                              onPressed: () {},
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
                      );
                    },
                  ),
          ),

          const Divider(
            color: Colors.grey, // ista boja kao header, možeš prilagoditi
            thickness: 1,
            height: 1,
          ),
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
                      _fetchUsers();
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
                            await _fetchUsers();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    "${users.isEmpty ? 0 : page} / ${totalPages == 0 ? 0 : totalPages}",
                  ),
                  IconButton(
                    onPressed: page < totalPages
                        ? () async {
                            setState(() => page++);
                            await _fetchUsers();
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

/// HEADER CELL
class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(this.text, {this.flex = 1, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// BODY CELL
class _TableCell extends StatelessWidget {
  final String text;
  final int flex;

  const _TableCell(this.text, {this.flex = 1, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(text),
      ),
    );
  }
}
