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
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function(User)? onUserUpdated;

  const ProfileScreen({super.key, this.onUserUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User?> _futureUser;
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  bool _obscureOldPassword = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String? _imageBase64;
  bool _imageDeleted = false;
  String? _originalFirstName;
  String? _originalLastName;
  String? _originalPhoneNumber;
  String? _originalUsername;
  String? _originalImageBase64;
  bool _isUpdating = false;

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
        _originalImageBase64 = _imageBase64;
      }

      _originalFirstName = user.firstName;
      _originalLastName = user.lastName;
      _originalPhoneNumber = user.phoneNumber;
      _originalUsername = user.username;

      return user;
    }

    return null;
  }

  bool _hasChanges() {
    if (_controllers['firstName']?.text != _originalFirstName) return true;
    if (_controllers['lastName']?.text != _originalLastName) return true;
    if (_controllers['phoneNumber']?.text != _originalPhoneNumber) return true;
    if (_controllers['username']?.text != _originalUsername) return true;

    if (_passwordController.text.isNotEmpty) return true;

    if (_imageDeleted) return true;
    if (_selectedImage != null) return true;
    if (_imageBase64 != _originalImageBase64) return true;

    return false;
  }

  Future<void> _updateUser(User user) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasChanges()) {
      showTopFlushBar(
        context: context,
        message: 'Niste ništa promijenili',
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() => _isUpdating = true);

    final provider = context.read<UserProvider>();
    try {
      final Map<String, dynamic> updateData = {
        "firstName": _controllers['firstName']!.text,
        "lastName": _controllers['lastName']!.text,
        "phoneNumber": _controllers['phoneNumber']!.text,
        "username": _controllers['username']!.text,
      };

      if (_imageDeleted) {
        updateData["profileImageBase64"] = null;
      } else if (_imageBase64 != null) {
        updateData["profileImageBase64"] = _imageBase64;
      }

      if (_passwordController.text.isNotEmpty) {
        updateData["oldPassword"] = _oldPasswordController.text;
        updateData["password"] = _passwordController.text;
        updateData["passwordConfirm"] = _confirmPasswordController.text;
      }

      final updatedUser = await provider.update(user.usersId, updateData);

      final passwordChanged = _passwordController.text.isNotEmpty;

      setState(() {
        setState(() {
          _selectedImage = null;
          _imageDeleted = false;
          _imageBase64 = null;
          _futureUser = _fetchUser();
        });

        _controllers['firstName']!.text = updatedUser.firstName;
        _controllers['lastName']!.text = updatedUser.lastName;
        _controllers['phoneNumber']!.text = updatedUser.phoneNumber;
        _controllers['username']!.text = updatedUser.username;
        _passwordController.clear();
        _confirmPasswordController.clear();
        _oldPasswordController.clear();

        _selectedImage = null;
        _imageDeleted = false;
        final bytes = updatedUser.getImageBytes();
        if (bytes != null && bytes.isNotEmpty) {
          _imageBase64 = base64Encode(bytes);
        } else {
          _imageBase64 = null;
        }
      });

      showTopFlushBar(
        context: context,
        message: 'Uspešno ste ažurirali profil',
        backgroundColor: Colors.green,
      );

      if (passwordChanged && mounted) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          AuthProvider.isSignedIn = false;
          AuthProvider.userId = null;
          AuthProvider.userRoles = [];
          AuthProvider.username = null;
          AuthProvider.password = null;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isUpdating = false);
          if (widget.onUserUpdated != null) {
            widget.onUserUpdated!(updatedUser);
          }
        }
      }
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
      showTopFlushBar(
        context: context,
        message: message,
        backgroundColor: Colors.red,
      );
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

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
            if (!_imageDeleted &&
                (_selectedImage != null ||
                    (_imageBase64 != null && _imageBase64!.isNotEmpty)))
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
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
        _imageDeleted = false;
      });
    }
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 8) return 'Lozinka mora imati najmanje 8 karaktera';
    if (value.length > 64) return 'Lozinka je preduga';
    return null;
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageBase64 = null;
      _imageDeleted = true;
    });
  }

  ImageProvider? _getImageProvider(User user) {
    if (_imageDeleted) {
      return null;
    }

    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
      return MemoryImage(base64Decode(_imageBase64!));
    }

    if (!_imageDeleted) {
      final bytes = user.getImageBytes();
      if (bytes != null && bytes.isNotEmpty) {
        return MemoryImage(bytes);
      }
    }

    return null;
  }

  bool _shouldShowInitials(User user) {
    return _imageDeleted ||
        (_selectedImage == null &&
            (_imageBase64 == null || _imageBase64!.isEmpty) &&
            (user.getImageBytes() == null || user.getImageBytes()!.isEmpty));
  }

  String? oldPasswordValidator(String? value) {
    if (_passwordController.text.isEmpty) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'Morate unijeti staru lozinku';
    }

    return null;
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
                  backgroundImage: _getImageProvider(user),
                  child: _shouldShowInitials(user)
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
                  child: Text(
                    _imageDeleted
                        ? 'Slika će biti obrisana pri spremanju'
                        : 'Odaberite drugu sliku',
                    style: TextStyle(
                      color: _imageDeleted ? Colors.red : Colors.blue,
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

                      // Lozinka
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: passwordValidator,
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

                      // Potvrda lozinke
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (_passwordController.text.isEmpty) {
                            return null;
                          }
                          if (value != _passwordController.text) {
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
                      const SizedBox(height: 12),
                      // Stara lozinka
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: _obscureOldPassword,
                        validator: oldPasswordValidator,
                        decoration: InputDecoration(
                          labelText: 'Stara lozinka',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureOldPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscureOldPassword = !_obscureOldPassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _readOnlyField('Email', user.email),
                _readOnlyField(
                  'Uloga',
                  user.userRoles.map((role) => role.role.roleName).join(', '),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : () => _updateUser(user),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Sačuvaj',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
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
        style: const TextStyle(color: Colors.grey),
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
