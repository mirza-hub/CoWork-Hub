import 'dart:convert';
import 'package:coworkhub_desktop/models/role.dart';
import 'package:coworkhub_desktop/models/user.dart';
import 'package:coworkhub_desktop/models/city.dart';
import 'package:coworkhub_desktop/providers/city_provider.dart';
import 'package:coworkhub_desktop/providers/role_provider.dart';
import 'package:coworkhub_desktop/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class UserDetailsScreen extends StatefulWidget {
  final void Function(Widget) onChangeScreen;
  final User user;

  const UserDetailsScreen({
    super.key,
    required this.user,
    required this.onChangeScreen,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final CityProvider cityProvider = CityProvider();
  final RoleProvider roleProvider = RoleProvider();

  City? city;
  List<Role> selectedRoles = [];
  String? profileImageBase64;
  bool loading = true;
  bool? activeValue;
  bool isLoadingCity = true;

  List<Role> roles = [];

  // ACTIVE DROPDOWN VALUE

  @override
  void initState() {
    super.initState();
    _loadCity();
    activeValue = widget.user.isActive; // default active state
    _loadRoles();
    profileImageBase64 = widget.user.profileImageBase64;
    if (widget.user.userRoles != null) {
      selectedRoles = widget.user.userRoles!
          .map((ur) => roles.firstWhere((r) => r.rolesId == ur.roleId))
          .toList();
    }
  }

  // ---------------------------------------------
  // LOAD CITY
  // ---------------------------------------------
  Future<void> _loadCity() async {
    if (widget.user.cityId != null) {
      try {
        final result = await cityProvider.getById(widget.user.cityId);
        setState(() {
          city = result;
          isLoadingCity = false; // Grad je učitan
        });
      } catch (e) {
        print("Greška pri dohvaćanju grada: $e");
        setState(
          () => isLoadingCity = false,
        ); // čak i ako je greška, prestani loader
      }
    } else {
      setState(() => isLoadingCity = false); // nema grada
    }
  }

  // ---------------------------------------------
  // LOAD ROLES
  // ---------------------------------------------
  Future<void> _loadRoles() async {
    try {
      final response = await roleProvider.get();
      final fetchedRoles = response.resultList;

      setState(() {
        roles = fetchedRoles;

        selectedRoles = [];

        if (widget.user.userRoles != null) {
          for (var ur in widget.user.userRoles!) {
            // pokušaj pronaći među dostupnim rolama
            final match = fetchedRoles
                .where((r) => r.rolesId == ur.roleId)
                .toList();

            if (match.isNotEmpty) {
              selectedRoles.add(match.first);
            } else if (ur.role != null) {
              // fallback: koristi rolu iz userRole
              selectedRoles.add(
                Role(
                  rolesId: ur.roleId,
                  roleName: ur.role!.roleName,
                  description: ur.role!.description,
                  isDeleted: ur.role!.isDeleted,
                ),
              );
            }
          }
        }
      });
    } catch (e) {
      debugPrint("Greška pri učitavanju rola: $e");
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      setState(() {
        profileImageBase64 = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------------------------
            // BACK BUTTON
            // ---------------------------------------------
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed: () {
                    widget.onChangeScreen(
                      UsersScreen(onChangeScreen: widget.onChangeScreen),
                    );
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  "${user.firstName} ${user.lastName}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ---------------------------------------------
            // MAIN LAYOUT (2 COLUMNS)
            // ---------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT SIDE
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildField("Korisnik ID", user.usersId.toString()),
                      _buildField("Ime", user.firstName),
                      _buildField("Prezime", user.lastName),
                      _buildField("Email", user.email),
                      _buildField("Username", user.username),
                      _buildField("Broj mobitela", user.phoneNumber ?? ""),
                      _buildField("Grad", city?.cityName ?? "Učitavanje..."),
                    ],
                  ),
                ),

                // RIGHT SIDE
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // -----------------------------------------
                      // PROFILE IMAGE
                      // -----------------------------------------
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey.shade200,
                            image:
                                (profileImageBase64 != null &&
                                    profileImageBase64!.isNotEmpty)
                                ? DecorationImage(
                                    image: MemoryImage(
                                      base64Decode(profileImageBase64!),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              (profileImageBase64 == null ||
                                  profileImageBase64!.isEmpty)
                              ? const Icon(
                                  Icons.person,
                                  size: 100,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // -------------------------------------------------
                      // ACTIVE DROPDOWN
                      // -------------------------------------------------
                      _buildActiveDropdown(),

                      _buildField(
                        "Deleted",
                        user.isDeleted == true ? "Obrisan" : "Neobrisan",
                      ),
                      _buildField("Kreiran profil", user.createdAt.toString()),

                      _buildRolesMultiSelect(),

                      const SizedBox(height: 25),

                      // -------------------------------------------------
                      // SAVE BUTTON (CENTERED)
                      // -------------------------------------------------
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: backend update
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              "Sačuvaj",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // Reusable text field
  // --------------------------------------------------------
  Widget _buildField(String label, String value, {bool enabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: 450,
        height: 75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            isLoadingCity
                ? const CircularProgressIndicator()
                : TextFormField(
                    initialValue: value ?? "Nije odabrano",
                    enabled: enabled,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: enabled ? Colors.white : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // ROLE DROPDOWN
  // --------------------------------------------------------
  Widget _buildRolesMultiSelect() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Role",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),

            MultiSelectDialogField<Role>(
              items: roles
                  .map((role) => MultiSelectItem<Role>(role, role.roleName))
                  .toList(),
              initialValue: selectedRoles,
              searchable: true,
              title: const Text("Odaberi role"),
              buttonText: const Text("Odaberi role"),
              selectedColor: Colors.blue,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade400),
              ),

              onConfirm: (values) {
                setState(() {
                  selectedRoles = List<Role>.from(values);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // ACTIVE DROPDOWN
  // --------------------------------------------------------
  Widget _buildActiveDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Aktivan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<bool>(
              isExpanded: true,
              value: activeValue,
              items: const [
                DropdownMenuItem(value: true, child: Text("Aktivan")),
                DropdownMenuItem(value: false, child: Text("Neaktivan")),
              ],
              onChanged: (value) {
                setState(() {
                  activeValue = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
