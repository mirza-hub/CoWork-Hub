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

    try {
      final result = await _userProvider.get(
        filter: flt,
        page: page,
        pageSize: pageSize,
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
        filter: {'retrieveAll': true},
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
                    const Text("Active status"),
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _fetchUsers();
              },
              child: const Text("Potvrdi"),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
            ],
          ),
          const SizedBox(height: 20),

          // TABELA
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // HEADER
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                    child: Row(
                      children: const [
                        _HeaderCell("ID", flex: 2),
                        _HeaderCell("Ime", flex: 2),
                        _HeaderCell("Prezime", flex: 2),
                        _HeaderCell("Email", flex: 3),
                        _HeaderCell("Username", flex: 2),
                        _HeaderCell("Status", flex: 2),
                        _HeaderCell("Akcije", flex: 2),
                      ],
                    ),
                  ),

                  // BODY
                  isLoading
                      ? const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : users.isEmpty
                      ? const Expanded(
                          child: Center(
                            child: Text("Nema podataka za prikaz."),
                          ),
                        )
                      : Expanded(
                          child: ListView.separated(
                            itemCount: users.length,
                            separatorBuilder: (_, _) =>
                                Divider(color: Colors.grey.shade300, height: 1),
                            itemBuilder: (context, index) {
                              final u = users[index];

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          UserDetailsScreen(user: u),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  height: 50,
                                  child: Row(
                                    children: [
                                      _TableCell(u.usersId.toString(), flex: 2),
                                      _TableCell(u.firstName, flex: 2),
                                      _TableCell(u.lastName, flex: 2),
                                      _TableCell(u.email, flex: 3),
                                      _TableCell(u.username, flex: 2),

                                      // STATUS
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: u.isActive
                                                    ? Colors.green
                                                    : Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              u.isActive
                                                  ? "Aktivni"
                                                  : "Neaktivni",
                                              style: TextStyle(
                                                color: u.isActive
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // AKCIJE
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                widget.onChangeScreen(
                                                  UserDetailsScreen(user: u),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {},
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  // FOOTER (PAGINATION)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(6),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ITEMS PER PAGE
                        Row(
                          children: [
                            const Text("Prikaži:"),
                            const SizedBox(width: 10),
                            DropdownButton<int>(
                              value: pageSize,
                              items: const [
                                DropdownMenuItem(value: 10, child: Text("10")),
                                DropdownMenuItem(value: 20, child: Text("20")),
                                DropdownMenuItem(value: 50, child: Text("50")),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  pageSize = v!;
                                  _fetchUsers();
                                });
                              },
                            ),
                          ],
                        ),

                        // PAGINATION
                        // Pagination
                        Row(
                          children: [
                            TextButton(
                              onPressed: page > 1
                                  ? () async {
                                      setState(() => page--);
                                      await _fetchUsers(); // fetch za prethodnu stranicu
                                    }
                                  : null,
                              child: const Text("Prev"),
                            ),
                            Text(
                              "Stranica $page / $totalPages",
                            ), // prikaži i ukupan broj stranica
                            TextButton(
                              onPressed: page < totalPages
                                  ? () async {
                                      setState(() => page++);
                                      await _fetchUsers(); // fetch za sljedeću stranicu
                                    }
                                  : null,
                              child: const Text("Next"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
