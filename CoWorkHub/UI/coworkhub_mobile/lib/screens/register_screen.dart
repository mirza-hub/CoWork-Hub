import 'dart:convert';

import 'package:coworkhub_mobile/models/city.dart';
import 'package:coworkhub_mobile/providers/city_provider.dart';
import 'package:coworkhub_mobile/providers/user_provider.dart';
import 'package:coworkhub_mobile/screens/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';
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

      if (e is http.Response) {
        try {
          final errorJson = jsonDecode(e.body);
          if (errorJson["errors"] != null &&
              errorJson["errors"]["userError"] != null) {
            message = errorJson["errors"]["userError"][0];
          }
        } catch (_) {}
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
          Navigator.pop(context);
        },
        child: const Text("OK", style: TextStyle(color: Colors.white)),
      ),
      onStatusChanged: (status) {
        if (status == FlushbarStatus.DISMISSED) {
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
    if (value == null || value.trim().isEmpty) {
      return 'Polje je obavezno';
    }

    final v = value.trim();

    if (v.length > 30) {
      return 'Ne smije biti duže od 30 karaktera';
    }

    final regex = RegExp(r'^[a-zA-ZšđčćžŠĐČĆŽ]+([ -][a-zA-ZšđčćžŠĐČĆŽ]+)*$');
    if (!regex.hasMatch(v)) {
      return 'Dozvoljena su samo slova';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email je obavezan';

    if (value.length > 100) return 'Email ne smije biti duži od 100 karaktera';

    final regex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!regex.hasMatch(value)) {
      return 'Neispravan format emaila. Primjer: ime.prezime@gmail.com';
    }

    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Korisničko ime je obavezno';
    }

    final v = value.trim();
    if (v.length < 3) return 'Mora imati najmanje 3 karaktera';
    if (v.length > 15) return 'Ne smije biti duže od 15 karaktera';

    final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!regex.hasMatch(v)) return 'Dozvoljena su samo slova, brojevi, _ i -';

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Broj telefona je obavezan';

    final regex = RegExp(r'^\+?[0-9]{6,15}$');
    if (!regex.hasMatch(value)) return 'Neispravan format telefona';

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Lozinka je obavezna';
    if (value.length < 8) return 'Lozinka mora imati najmanje 8 karaktera';
    if (value.length > 64) return 'Lozinka je preduga';
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
      body: SafeArea(
        // ovo rješava status bar / notch problem
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        const Text(
                          'Registracija',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Ime
                        TextFormField(
                          controller: _firstNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Ime',
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(30),
                          ],
                          validator: _validateName,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Prezime
                        TextFormField(
                          controller: _lastNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Prezime',
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(30),
                          ],
                          validator: _validateName,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(100),
                          ],
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Username
                        TextFormField(
                          controller: _usernameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Korisničko ime',
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                          validator: _validateUsername,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Mobitel
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Telefon',
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                          validator: _validatePhone,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Grad dropdown
                        DropdownButtonFormField<City>(
                          value: _selectedCity,
                          items: _cities
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.cityName),
                                ),
                              )
                              .toList(),
                          onChanged: (c) => setState(() => _selectedCity = c),
                          decoration: const InputDecoration(
                            labelText: 'Grad',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateCity,
                        ),
                        const SizedBox(height: 16),

                        // Šifra
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Lozinka',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(64),
                          ],
                          validator: _validatePassword,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        // Šifra potvrda
                        TextFormField(
                          controller: _passwordConfirmCtrl,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Potvrdi lozinku',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(64),
                          ],
                          validator: _validateConfirm,
                        ),
                        const SizedBox(height: 24),
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
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Registrirajte se',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Dugme za login fiksno pri dnu
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
