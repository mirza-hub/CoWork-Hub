import 'dart:async';

import 'package:coworkhub_desktop/models/city.dart';
import 'package:coworkhub_desktop/providers/auth_provider.dart';
import 'package:coworkhub_desktop/providers/city_provider.dart';
import 'package:coworkhub_desktop/screens/user_details_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user.dart';
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
  String? sortColumn = "UsersId";
  bool sortAscending = true;

  void _forceLogout() {
    AuthProvider.username = null;
    AuthProvider.password = null;
    AuthProvider.userId = null;
    AuthProvider.firstName = null;
    AuthProvider.lastName = null;
    AuthProvider.email = null;
    AuthProvider.isActive = null;
    AuthProvider.isDeleted = null;
    AuthProvider.userRoles = null;
    AuthProvider.isSignedIn = false;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  String? sortDirection = "asc";
  static const double columnWidth = 140;
  static const double actionColumnWidth = 120;
  int page = 1;
  int pageSize = 10;
  int totalPages = 1;
  int totalCount = 0;

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
      );
      setState(() {
        users = result.resultList;
        totalPages = result.totalPages ?? 1;
        totalCount = result.count ?? 0;
      });
    } catch (e) {
      debugPrint("Greška: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadCities() async {
    try {
      final result = await cityProvider.get(filter: {'RetrieveAll': true});

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
    showDialog(
      context: context,
      builder: (_) {
        String? tempCity = selectedCityId;
        String tempActive = selectedActive;
        String tempDeleted = selectedDeleted;

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
                    const Text("Grad"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: tempCity,
                      items: cityOptions,
                      onChanged: (val) {
                        setDialogState(() => tempCity = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    const Text("Aktivnost"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: tempActive,
                      items: activeOptions,
                      onChanged: (val) {
                        setDialogState(() => tempActive = val!);
                      },
                    ),
                    const SizedBox(height: 12),

                    const Text("Obrisani"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: tempDeleted,
                      items: deletedOptions,
                      onChanged: (val) {
                        setDialogState(() {
                          tempDeleted = val!;
                          if (tempDeleted == "true") {
                            tempActive = "false";
                          }
                        });
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
                            selectedCityId = tempCity;
                            selectedActive = tempActive;
                            selectedDeleted = tempDeleted;
                            page = 1;
                          });
                          Navigator.pop(context);
                          _fetchUsers();
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
                          setState(() {
                            selectedCityId = null;
                            selectedActive = "true";
                            selectedDeleted = "false";
                            page = 1;
                          });
                          Navigator.pop(context);
                          _fetchUsers();
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
        );
      },
    );
  }

  DataColumn _centeredColumn(
    Widget label, {
    double width = columnWidth,
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

  DataCell _centeredCell(String text, {double width = columnWidth}) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(text, textAlign: TextAlign.center, softWrap: true),
        ),
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    final text = isActive ? "AKTIVAN" : "NEAKTIVAN";
    final color = isActive ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
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
                    labelStyle: TextStyle(color: Colors.grey),
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

          // Tabela
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
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
                                _sortableHeader("ID", "UsersId"),
                                numeric: true,
                                onSort: (i, __) => _onSort("UsersId"),
                              ),
                              _centeredColumn(
                                _sortableHeader("Ime", "FirstName"),
                                onSort: (i, __) => _onSort("FirstName"),
                              ),
                              _centeredColumn(
                                _sortableHeader("Prezime", "LastName"),
                                onSort: (i, __) => _onSort("LastName"),
                              ),
                              _centeredColumn(
                                _sortableHeader("Email", "Email"),
                                onSort: (i, __) => _onSort("Email"),
                              ),
                              _centeredColumn(
                                _sortableHeader("Username", "Username"),
                                onSort: (i, __) => _onSort("Username"),
                              ),
                              _centeredColumn(const Text("Status")),
                              _centeredColumn(
                                const Text("Akcije"),
                                width: actionColumnWidth,
                              ),
                            ],
                            rows: users
                                .map(
                                  (user) => DataRow(
                                    cells: [
                                      _centeredCell(user.usersId.toString()),
                                      _centeredCell(user.firstName),
                                      _centeredCell(user.lastName),
                                      _centeredCell(user.email),
                                      _centeredCell(user.username),
                                      DataCell(
                                        SizedBox(
                                          width: columnWidth,
                                          child: Center(
                                            child: _statusBadge(user.isActive),
                                          ),
                                        ),
                                      ),
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
                                                      UserDetailsScreen(
                                                        user: user,
                                                        onChangeScreen: widget
                                                            .onChangeScreen,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                if (!user.isDeleted!)
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
                                                            "Da li ste sigurni da želite obrisati korisnika?",
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(true),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.blue,
                                                              ),
                                                              child: const Text(
                                                                "Da",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
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
                                                          await _userProvider
                                                              .delete(
                                                                user.usersId,
                                                              );
                                                          showTopFlushBar(
                                                            context: context,
                                                            message:
                                                                "Korisnik uspješno obrisan",
                                                            backgroundColor:
                                                                Colors.green,
                                                          );
                                                          if (user.usersId ==
                                                              AuthProvider
                                                                  .userId) {
                                                            _forceLogout();
                                                            return;
                                                          }
                                                          await _fetchUsers();
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
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const Divider(color: Colors.grey, thickness: 1, height: 1),
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
                  Text(
                    totalCount == 0
                        ? "0 od 0"
                        : "${((page - 1) * pageSize) + 1}–${((page - 1) * pageSize) + users.length} od $totalCount",
                  ),
                  const SizedBox(width: 16),
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
