import 'dart:convert';

import 'package:coworkhub_mobile/models/city.dart';
import 'package:coworkhub_mobile/providers/city_provider.dart';
import 'package:coworkhub_mobile/providers/user_provider.dart';
import 'package:coworkhub_mobile/screens/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  List<City> _cities = [];
  City? _selectedCity;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    var provider = CityProvider();
    var filter = {"RetrieveAll": "true"};
    final result = await provider.get(filter: filter);
    setState(() {
      _cities = result.resultList;
    });
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final payload = {
      "firstName": _firstNameCtrl.text.trim(),
      "lastName": _lastNameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "username": _usernameCtrl.text.trim(),
      "phoneNumber": _phoneCtrl.text.trim(),
      "password": _passwordCtrl.text,
      "passwordConfirm": _passwordConfirmCtrl.text,
      "cityId": _selectedCity?.cityId ?? 0,
    };

    var provider = UserProvider();

    try {
      await provider.insert(payload);
      _showSuccess();
    } catch (e) {
      String message = "Greška prilikom registracije.";

      // provjeri je li e http.Response
      if (e is http.Response) {
        try {
          final errorJson = jsonDecode(e.body);
          if (errorJson["errors"] != null &&
              errorJson["errors"]["userError"] != null) {
            message =
                errorJson["errors"]["userError"][0]; // ovdje je tvoja poruka
          }
        } catch (_) {
          // ako JSON ne radi, ostavi default poruku
        }
      }

      Flushbar(
        message: message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSuccess() {
    Flushbar(
      title: "Uspješno!",
      message: "Registracija je uspješno završena.",
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      mainButton: TextButton(
        onPressed: () {
          Navigator.pop(context); // zatvori Flushbar
        },
        child: const Text("OK", style: TextStyle(color: Colors.white)),
      ),
      // Dodaj ovo
      onStatusChanged: (status) {
        if (status == FlushbarStatus.DISMISSED) {
          // očisti formu kada Flushbar nestane
          _formKey.currentState?.reset();
          setState(() {
            _selectedCity = null;
          });
          _firstNameCtrl.clear();
          _lastNameCtrl.clear();
          _emailCtrl.clear();
          _usernameCtrl.clear();
          _phoneCtrl.clear();
          _passwordCtrl.clear();
          _passwordConfirmCtrl.clear();
        }
      },
    ).show(context);
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Polje je obavezno';
    final regex = RegExp(r'^[a-zA-ZšđčćžŠĐČĆŽ\s-]+$');
    if (!regex.hasMatch(value)) {
      return 'Ne smije sadržavati brojeve ili specijalne znakove';
    }
    if (value.length > 10) {
      return 'Ne smije biti duže od 10 karaktera';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email je obavezan';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Neispravan format emaila';
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Korisničko ime je obavezno';
    if (value.length < 3) {
      return 'Korisničko ime mora imati najmanje 3 karaktera';
    }
    if (value.length > 10) {
      return 'Korisničko ime ne smije biti duže od 10 karaktera';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Broj telefona je obavezan';
    final regex = RegExp(r'^\+?[0-9]{6,15}$');
    if (!regex.hasMatch(value)) return 'Neispravan format telefona';
    if (value.length > 10) {
      return 'Broj telefona ne smije biti duže od 10 karaktera';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Lozinka je obavezna';
    if (value.length < 4) return 'Lozinka mora imati najmanje 6 karaktera';
    if (value.length > 10) return 'Lozinka ne smije imati više od 10 karaktera';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Potvrda lozinke je obavezna';
    if (value != _passwordCtrl.text) return 'Lozinke se ne poklapaju';
    return null;
  }

  String? _validateCity(City? value) {
    if (value == null) return 'Morate odabrati grad';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Registracija',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // First Name
                TextFormField(
                  controller: _firstNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ime',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: _lastNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Prezime',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Username
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Korisničko ime',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateUsername,
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validatePhone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // City dropdown
                DropdownButtonFormField<City>(
                  initialValue: _selectedCity,
                  items: _cities
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c, child: Text(c.cityName)),
                      )
                      .toList(),
                  onChanged: (c) {
                    setState(() {
                      _selectedCity = c;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Grad',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _validateCity(v),
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Lozinka',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),

                // Password confirm
                TextFormField(
                  controller: _passwordConfirmCtrl,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Potvrdi lozinku',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: _validateConfirm,
                ),
                const SizedBox(height: 24),

                // Register button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Registrirajte se',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Link nazad na login
                RichText(
                  text: TextSpan(
                    text: 'Već imate račun? ',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'Prijavite se',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // navigacija na RegisterScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
