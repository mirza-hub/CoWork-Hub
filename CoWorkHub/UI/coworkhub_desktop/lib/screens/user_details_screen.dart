import 'dart:convert';
import 'package:coworkhub_desktop/models/role.dart';
import 'package:coworkhub_desktop/models/user.dart';
import 'package:coworkhub_desktop/models/city.dart';
import 'package:coworkhub_desktop/providers/city_provider.dart';
import 'package:coworkhub_desktop/providers/role_provider.dart';
import 'package:coworkhub_desktop/providers/user_provider.dart';
import 'package:coworkhub_desktop/screens/users_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:coworkhub_desktop/utils/format_date.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

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
  final UserProvider _userProvider = UserProvider();

  City? city;
  List<Role> selectedRoles = [];
  String? profileImageBase64;
  bool loading = true;
  bool? activeValue;
  bool isLoadingCity = true;
  bool? _initialActiveValue;
  String? _initialProfileImageBase64;
  Set<int> _initialRolesId = {};

  List<Role> roles = [];

  @override
  void initState() {
    super.initState();
    _loadCity();
    activeValue = widget.user.isActive;
    _loadRoles();
    profileImageBase64 = widget.user.profileImageBase64;
    _initialActiveValue = widget.user.isActive;
    _initialProfileImageBase64 = widget.user.profileImageBase64;
    _initialRolesId = widget.user.userRoles.map((ur) => ur.roleId).toSet();
  }

  Future<void> _loadCity() async {
    if (widget.user.cityId != null) {
      try {
        final result = await cityProvider.getById(widget.user.cityId);
        setState(() {
          city = result;
          isLoadingCity = false;
        });
      } catch (e) {
        print("Greška pri dohvaćanju grada: $e");
        setState(() => isLoadingCity = false);
      }
    }
  }

  Future<void> _loadRoles() async {
    try {
      final response = await roleProvider.get();
      final fetchedRoles = response.resultList;

      setState(() {
        roles = fetchedRoles;

        selectedRoles = [];

        if (widget.user.userRoles != null) {
          for (var ur in widget.user.userRoles!) {
            final match = fetchedRoles
                .where((r) => r.rolesId == ur.roleId)
                .toList();

            if (match.isNotEmpty) {
              selectedRoles.add(match.first);
            } else if (ur.role != null) {
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

  Future<void> _saveUser() async {
    try {
      List<int> rolesId = selectedRoles.map((r) => r.rolesId).toList();
      final bool isActiveCurrent = activeValue ?? widget.user.isActive;
      final String? imageCurrent = profileImageBase64;
      final Set<int> rolesCurrent = rolesId.toSet();

      final bool hasChanges =
          isActiveCurrent != (_initialActiveValue ?? widget.user.isActive) ||
          imageCurrent != _initialProfileImageBase64 ||
          rolesCurrent.length != _initialRolesId.length ||
          !rolesCurrent.containsAll(_initialRolesId);

      if (!hasChanges) {
        showTopFlushBar(
          context: context,
          message: "Niste ništa promijenili",
          backgroundColor: Colors.orange,
        );
        return;
      }

      final request = {
        "ProfileImageBase64": profileImageBase64,
        "IsActive": isActiveCurrent,
        "RolesId": rolesId,
      };

      await _userProvider.updateForAdmin(widget.user.usersId, request);
      setState(() {
        _initialActiveValue = isActiveCurrent;
        _initialProfileImageBase64 = imageCurrent;
        _initialRolesId = rolesCurrent;
      });

      showTopFlushBar(
        context: context,
        message: "Korisnik je uspješno ažuriran",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      showTopFlushBar(
        context: context,
        message: e.toString(),
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _restoreUser() async {
    try {
      await _userProvider.restore(widget.user.usersId);

      showTopFlushBar(
        context: context,
        message: "Korisnik je uspješno vraćen",
        backgroundColor: Colors.green,
      );

      widget.onChangeScreen(UsersScreen(onChangeScreen: widget.onChangeScreen));
    } catch (e) {
      showTopFlushBar(
        context: context,
        message: e.toString(),
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final bool isDeleted = widget.user.isDeleted == true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Strelica nazad + ime korisnika
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

            // Glavni izgled (2 kolone)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lijeva strana
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
                      _buildField("Kreiran profil", formatDate(user.createdAt)),
                    ],
                  ),
                ),

                // Desna strana
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Slika profila + dugme za promjenu
                      Column(
                        children: [
                          IgnorePointer(
                            ignoring: isDeleted,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Opacity(
                                opacity: isDeleted ? 0.5 : 1,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
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
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: isDeleted ? null : _pickImage,
                            child: const Text(
                              "Odaberite drugu sliku",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      // Dropdown za aktivan/neaktivan
                      _buildActiveDropdown(),
                      // Dropdown za obrisan/neobrisan
                      _buildField(
                        "Obrisan/Neobrisan",
                        user.isDeleted == true ? "Obrisan" : "Neobrisan",
                      ),
                      // Role toggles
                      _buildRoleToggles(),
                      const SizedBox(height: 25),
                      // Dugme sačuvaj
                      Center(
                        child: SizedBox(
                          width: 180,
                          height: 40,
                          child: widget.user.isDeleted == true
                              ? ElevatedButton(
                                  onPressed: _restoreUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    "Vrati korisnika",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _saveUser,
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

  // Text polje za prikaz podataka
  Widget _buildField(String label, String value, {bool enabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: 450,
        child: isLoadingCity
            ? const CircularProgressIndicator()
            : TextFormField(
                initialValue: value ?? "Nije odabrano",
                enabled: enabled,
                decoration: const InputDecoration(
                  labelText: " ",
                  border: OutlineInputBorder(),
                ).copyWith(labelText: label),
              ),
      ),
    );
  }

  // Role toggles (barem jedna rola mora biti izabrana ili obe)
  Widget _buildRoleToggles() {
    final bool isDeleted = widget.user.isDeleted == true;

    bool isAdminSelected = selectedRoles.any(
      (role) => role.roleName.toLowerCase() == "admin",
    );
    bool isUserSelected = selectedRoles.any(
      (role) => role.roleName.toLowerCase() == "user",
    );

    void toggleRole(String roleName) {
      if (isDeleted) return;

      setState(() {
        final roleNameLower = roleName.toLowerCase();
        final isSelected = selectedRoles.any(
          (r) => r.roleName.toLowerCase() == roleNameLower,
        );

        if (isSelected) {
          if (selectedRoles.length > 1) {
            selectedRoles.removeWhere(
              (r) => r.roleName.toLowerCase() == roleNameLower,
            );
          }
        } else {
          // dodaj rolu
          selectedRoles.add(
            roles.firstWhere(
              (r) => r.roleName.toLowerCase() == roleNameLower,
              orElse: () => Role(
                rolesId: 0,
                roleName: roleName,
                description: "",
                isDeleted: false,
              ),
            ),
          );
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Uloge",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                // Admin toggle
                GestureDetector(
                  onTap: () => toggleRole("Admin"),
                  child: Opacity(
                    opacity: isDeleted ? 0.5 : 1,
                    child: Container(
                      width: 80,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isAdminSelected
                            ? Colors.lightBlue[300]
                            : Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Admin",
                        style: TextStyle(
                          color: isAdminSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // User toggle
                GestureDetector(
                  onTap: () => toggleRole("User"),
                  child: Opacity(
                    opacity: isDeleted ? 0.5 : 1,
                    child: Container(
                      width: 80,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isUserSelected
                            ? Colors.lightBlue[300]
                            : Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "User",
                        style: TextStyle(
                          color: isUserSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dropdown za aktivan/neaktivan
  Widget _buildActiveDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: 450,
        child: DropdownButtonFormField<bool>(
          isExpanded: true,
          value: activeValue,
          items: const [
            DropdownMenuItem(value: true, child: Text("Aktivan")),
            DropdownMenuItem(value: false, child: Text("Neaktivan")),
          ],
          onChanged: widget.user.isDeleted!
              ? null
              : (value) {
                  setState(() {
                    activeValue = value;
                  });
                },
          decoration: const InputDecoration(
            labelText: "Aktivan",
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
