import 'dart:convert';
import 'dart:io';

import 'package:coworkhub_mobile/models/extensions/user_image_extension.dart';
import 'package:coworkhub_mobile/providers/auth_provider.dart';
import 'package:coworkhub_mobile/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User?> _futureUser;
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String? _imageBase64;

  @override
  void initState() {
    super.initState();
    _futureUser = _fetchUser();
  }

  Future<User?> _fetchUser() async {
    final provider = context.read<UserProvider>();
    final filter = {
      "UsersId": AuthProvider.userId,
      "IsUserRolesIncluded": true,
    };

    final result = await provider.get(filter: filter);

    if (result.resultList.isNotEmpty) {
      final user = result.resultList.first;

      final bytes = user.getImageBytes();
      if (bytes != null && bytes.isNotEmpty) {
        _imageBase64 = base64Encode(bytes);
      }

      return user;
    }

    return null;
  }

  Future<void> _updateUser(User user) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<UserProvider>();
    try {
      final updatedUser = await provider.update(user.usersId, {
        "firstName": _controllers['firstName']!.text,
        "lastName": _controllers['lastName']!.text,
        "phoneNumber": _controllers['phoneNumber']!.text,
        "username": _controllers['username']!.text,
        "profileImageBase64": _imageBase64,
        // if (_imageBase64 != null) "profileImageBase64": _imageBase64,
        if (_passwordController.text.isNotEmpty)
          "password": _passwordController.text,
        if (_confirmPasswordController.text.isNotEmpty)
          "passwordConfirm": _confirmPasswordController.text,
      });

      setState(() {
        _futureUser = Future.value(updatedUser);

        _controllers['firstName']!.text = updatedUser.firstName;
        _controllers['lastName']!.text = updatedUser.lastName;
        _controllers['phoneNumber']!.text = updatedUser.phoneNumber;
        _controllers['username']!.text = updatedUser.username;
        _passwordController.clear();
        _confirmPasswordController.clear();
      });

      showTopFlushBar(
        context: context,
        message: 'Uspešno ste ažurirali profil',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      String message = "Greška prilikom registracije.";

      if (e is http.Response) {
        try {
          final errorJson = jsonDecode(e.body);
          if (errorJson["errors"] != null &&
              errorJson["errors"]["userError"] != null) {
            message = errorJson["errors"]["userError"][0];
          }
        } catch (_) {}
      }

      // Flushbar(
      //   message: message,
      //   backgroundColor: Colors.red,
      //   duration: const Duration(seconds: 3),
      //   margin: const EdgeInsets.all(10),
      //   borderRadius: BorderRadius.circular(8),
      //   flushbarPosition: FlushbarPosition.TOP,
      // ).show(context);

      showTopFlushBar(
        context: context,
        message: message,
        backgroundColor: Colors.red,
      );
    }
  }

  final ImagePicker _picker = ImagePicker();

  // Future<void> _pickImage(ImageSource source) async {
  //   try {
  //     final XFile? pickedFile = await _picker.pickImage(
  //       source: source,
  //       maxWidth: 800,
  //       maxHeight: 800,
  //       imageQuality: 80,
  //     );

  //     if (pickedFile != null) {
  //       File imageFile = File(pickedFile.path);
  //       final bytes = await imageFile.readAsBytes();
  //       setState(() {
  //         _selectedImage = imageFile;
  //         _imageBase64 = base64Encode(bytes);
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Greška pri odabiru slike: $e');
  //   }
  // }

  // void _showImagePickerDialog() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (_) => SafeArea(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.photo_camera),
  //             title: const Text('Kamera'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _pickImage(ImageSource.camera);
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.photo_library),
  //             title: const Text('Galerija'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _pickImage(ImageSource.gallery);
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.delete),
  //             title: const Text('Obriši sliku'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               setState(() {
  //                 _selectedImage = null;
  //                 _imageBase64 = null; // ili "" ako želiš
  //               });
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerija'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null ||
                (_imageBase64 != null && _imageBase64!.isNotEmpty))
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Obriši sliku'),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();

      setState(() {
        _selectedImage = file;
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 43, 16, 5),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 1.5),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Moj profil',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: FutureBuilder<User?>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'Korisnik nije pronađen',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final user = snapshot.data!;
          // inicijaliziraj kontrolere
          _controllers['firstName'] ??= TextEditingController(
            text: user.firstName,
          );
          _controllers['lastName'] ??= TextEditingController(
            text: user.lastName,
          );
          _controllers['email'] ??= TextEditingController(text: user.email);
          _controllers['phoneNumber'] ??= TextEditingController(
            text: user.phoneNumber,
          );
          _controllers['username'] ??= TextEditingController(
            text: user.username,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade200,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (_imageBase64 != null && _imageBase64!.isNotEmpty)
                      ? MemoryImage(base64Decode(_imageBase64!))
                      : (user.getImageBytes() != null &&
                            user.getImageBytes()!.isNotEmpty)
                      ? MemoryImage(user.getImageBytes()!)
                      : null,
                  child:
                      (_selectedImage == null &&
                          (_imageBase64 == null || _imageBase64!.isEmpty) &&
                          (user.getImageBytes() == null ||
                              user.getImageBytes()!.isEmpty))
                      ? Text(
                          user.firstName[0] + user.lastName[0],
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showImagePickerDialog,
                  child: const Text(
                    'Odaberite drugu sliku',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _editableFormField(
                        label: 'Ime',
                        controller: _controllers['firstName']!,
                      ),
                      _editableFormField(
                        label: 'Prezime',
                        controller: _controllers['lastName']!,
                      ),
                      _editableFormField(
                        label: 'Broj telefona',
                        controller: _controllers['phoneNumber']!,
                        keyboardType: TextInputType.phone,
                      ),
                      _editableFormField(
                        label: 'Korisničko ime',
                        controller: _controllers['username']!,
                      ),

                      // Polje za lozinku
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 6) {
                            return "Lozinka mora imati najmanje 6 karaktera";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Lozinka',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Polje za potvrdu lozinke
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (_passwordController.text.isNotEmpty &&
                              value != _passwordController.text) {
                            return "Lozinke se ne podudaraju";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Potvrda lozinke',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _readOnlyField('Email', user.email),
                _readOnlyField(
                  'Uloga',
                  user.userRoles.map((role) => role.role.roleName).join(', '),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _updateUser(user),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sačuvaj',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _readOnlyField(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        enabled: false,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _editableFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    List<TextInputFormatter> inputFormatters = [];
    String? Function(String?)? validator;

    if (label == 'Ime' || label == 'Prezime') {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZčćđšžČĆĐŠŽ]')),
        LengthLimitingTextInputFormatter(10),
      ];
      validator = (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label je obavezno polje';
        }
        if (!RegExp(r'^[a-zA-ZčćđšžČĆĐŠŽ]+$').hasMatch(value)) {
          return '$label može sadržavati samo slova';
        }
        return null;
      };
    } else if (label == 'Broj telefona') {
      inputFormatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];
      validator = (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Broj telefona je obavezan';
        }
        final regex = RegExp(r'^\+?[0-9]{6,15}$');
        if (!regex.hasMatch(value)) return 'Neispravan format telefona';
        if (value.length > 10) {
          return 'Broj telefona ne smije biti duže od 10 karaktera';
        }
        return null;
      };
    } else if (label == 'Korisničko ime') {
      inputFormatters = [LengthLimitingTextInputFormatter(10)];
      validator = (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Korisničko ime je obavezno';
        }
        if (value.length > 10) {
          return 'Korisničko ime ne smije biti duže od 10 karaktera';
        }
        if (value.length < 3) {
          return 'Korisničko ime mora imati najmanje 3 karaktera';
        }
        return null;
      };
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
